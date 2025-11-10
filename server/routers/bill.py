from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from datetime import datetime
from decimal import Decimal
from models import get_db
from models.bill import Bill
from models.bill_item import BillItem
from models.product import Product
from models.client import Client
from schemas.bill import BillCreate, BillResponse, BillWithItems, BillWithClient, BillSummary
from utils.auth import get_current_client, get_current_admin
from utils.stock_manager import check_and_create_stock_alert
from utils.notification_manager import create_bill_notification

router = APIRouter(prefix="/bill", tags=["Bill"])

@router.post("/", response_model=BillWithItems, status_code=status.HTTP_201_CREATED)
def create_bill(
    bill_data: BillCreate,
    current_client = Depends(get_current_client),
    db: Session = Depends(get_db)
):
    """Créer une nouvelle facture (client seulement)"""
    
    # Générer un numéro de facture unique
    bill_count = db.query(Bill).count()
    bill_number = f"BILL-{datetime.now().strftime('%Y%m%d')}-{bill_count + 1:04d}"
    
    # Créer la facture
    new_bill = Bill(
        client_id=current_client.id,
        bill_number=bill_number,
        total_amount=Decimal('0.00'),
        total_paid=Decimal('0.00'),
        total_remaining=Decimal('0.00'),
        status="not paid"
    )
    
    db.add(new_bill)
    db.flush()
    
    # Ajouter les articles de la facture
    total_amount = Decimal('0.00')
    bill_items = []
    
    for item in bill_data.items:
        # Vérifier si le produit existe
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if not product:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Produit avec ID {item.product_id} non trouvé"
            )
        
        # Vérifier si le produit est actif
        if not product.is_active:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Le produit '{product.name}' n'est pas disponible"
            )
        
        # Vérifier le stock
        if product.quantity_in_stock < item.quantity:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Stock insuffisant pour le produit '{product.name}'. Stock disponible: {product.quantity_in_stock}"
            )
        
        # Calculer le sous-total
        subtotal = product.price * item.quantity
        total_amount += subtotal
        
        # Créer l'article de facture
        bill_item = BillItem(
            bill_id=new_bill.id,
            product_id=product.id,
            product_name=product.name,
            unit_price=product.price,
            quantity=item.quantity,
            subtotal=subtotal
        )
        db.add(bill_item)
        bill_items.append(bill_item)
        
        # Décrémenter le stock
        product.quantity_in_stock -= item.quantity
        
        # Vérifier et créer une alerte de stock si nécessaire
        check_and_create_stock_alert(db, product)
    
    # Mettre à jour les totaux de la facture
    new_bill.total_amount = total_amount
    new_bill.total_remaining = total_amount
    
    db.commit()
    db.refresh(new_bill)
    
    # Créer une notification pour l'admin
    create_bill_notification(db, new_bill, current_client)
    
    return BillWithItems(
        id=new_bill.id,
        bill_number=new_bill.bill_number,
        client_id=new_bill.client_id,
        total_amount=new_bill.total_amount,
        total_paid=new_bill.total_paid,
        total_remaining=new_bill.total_remaining,
        status=new_bill.status,
        created_at=new_bill.created_at,
        updated_at=new_bill.updated_at,
        notification_sent=new_bill.notification_sent,
        items=[{
            "id": item.id,
            "product_id": item.product_id,
            "product_name": item.product_name,
            "unit_price": item.unit_price,
            "quantity": item.quantity,
            "subtotal": item.subtotal,
            "created_at": item.created_at
        } for item in bill_items]
    )

@router.get("/my-bills", response_model=List[BillWithItems])
def get_my_bills(
    skip: int = 0,
    limit: int = 100,
    current_client = Depends(get_current_client),
    db: Session = Depends(get_db)
):
    """Obtenir toutes les factures du client connecté"""
    
    bills = db.query(Bill).filter(Bill.client_id == current_client.id).offset(skip).limit(limit).all()
    
    result = []
    for bill in bills:
        result.append(BillWithItems(
            id=bill.id,
            bill_number=bill.bill_number,
            client_id=bill.client_id,
            total_amount=bill.total_amount,
            total_paid=bill.total_paid,
            total_remaining=bill.total_remaining,
            status=bill.status,
            created_at=bill.created_at,
            updated_at=bill.updated_at,
            notification_sent=bill.notification_sent,
            items=[{
                "id": item.id,
                "product_id": item.product_id,
                "product_name": item.product_name,
                "unit_price": item.unit_price,
                "quantity": item.quantity,
                "subtotal": item.subtotal,
                "created_at": item.created_at
            } for item in bill.bill_items]
        ))
    
    return result

@router.get("/all", response_model=List[BillWithClient])
def get_all_bills(
    skip: int = 0,
    limit: int = 100,
    status_filter: str = None,
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Obtenir toutes les factures (admin seulement)"""
    
    query = db.query(Bill)
    
    if status_filter:
        query = query.filter(Bill.status == status_filter)
    
    bills = query.offset(skip).limit(limit).all()
    
    result = []
    for bill in bills:
        result.append(BillWithClient(
            id=bill.id,
            bill_number=bill.bill_number,
            client_id=bill.client_id,
            total_amount=bill.total_amount,
            total_paid=bill.total_paid,
            total_remaining=bill.total_remaining,
            status=bill.status,
            created_at=bill.created_at,
            updated_at=bill.updated_at,
            notification_sent=bill.notification_sent,
            client_name=bill.client.username,
            client_email=bill.client.email,
            client_phone=bill.client.phone_number,
            items=[{
                "id": item.id,
                "product_id": item.product_id,
                "product_name": item.product_name,
                "unit_price": item.unit_price,
                "quantity": item.quantity,
                "subtotal": item.subtotal,
                "created_at": item.created_at
            } for item in bill.bill_items]
        ))
    
    return result

@router.get("/summary", response_model=BillSummary)
def get_bill_summary(
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Obtenir le résumé des factures (admin seulement)"""
    
    total_bills = db.query(Bill).count()
    total_revenue = db.query(func.sum(Bill.total_amount)).scalar() or Decimal('0.00')
    total_paid = db.query(func.sum(Bill.total_paid)).scalar() or Decimal('0.00')
    total_pending = db.query(func.sum(Bill.total_remaining)).scalar() or Decimal('0.00')
    paid_bills = db.query(Bill).filter(Bill.status == "paid").count()
    unpaid_bills = db.query(Bill).filter(Bill.status == "not paid").count()
    
    return BillSummary(
        total_bills=total_bills,
        total_revenue=total_revenue,
        total_paid=total_paid,
        total_pending=total_pending,
        paid_bills=paid_bills,
        unpaid_bills=unpaid_bills
    )

@router.get("/{bill_id}", response_model=BillWithItems)
def get_bill_by_id(
    bill_id: int,
    current_client = Depends(get_current_client),
    db: Session = Depends(get_db)
):
    """Obtenir une facture par son ID"""
    
    bill = db.query(Bill).filter(Bill.id == bill_id).first()
    if not bill:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Facture non trouvée"
        )
    
    # Vérifier que le client accède à sa propre facture
    if bill.client_id != current_client.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Vous n'avez pas accès à cette facture"
        )
    
    return BillWithItems(
        id=bill.id,
        bill_number=bill.bill_number,
        client_id=bill.client_id,
        total_amount=bill.total_amount,
        total_paid=bill.total_paid,
        total_remaining=bill.total_remaining,
        status=bill.status,
        created_at=bill.created_at,
        updated_at=bill.updated_at,
        notification_sent=bill.notification_sent,
        items=[{
            "id": item.id,
            "product_id": item.product_id,
            "product_name": item.product_name,
            "unit_price": item.unit_price,
            "quantity": item.quantity,
            "subtotal": item.subtotal,
            "created_at": item.created_at
        } for item in bill.bill_items]
    )