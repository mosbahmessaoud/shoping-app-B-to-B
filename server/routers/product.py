from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from models import get_db
from models.product import Product
from models.category import Category
from models.stock_alert import StockAlert
from schemas.product import ProductCreate, ProductUpdate, ProductResponse, ProductWithCategory, ProductStockStatus
from utils.auth import get_current_admin
from utils.stock_manager import check_and_create_stock_alert

router = APIRouter(prefix="/product", tags=["Product"])

@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    product_data: ProductCreate,
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Créer un nouveau produit (admin seulement)"""
    
    # Vérifier si la catégorie existe
    category = db.query(Category).filter(Category.id == product_data.category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Catégorie non trouvée"
        )
    
    new_product = Product(
        **product_data.dict(exclude={'category_id'}),
        category_id=product_data.category_id,
        admin_id=current_admin.id
    )
    
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    
    # Vérifier le stock et créer une alerte si nécessaire
    check_and_create_stock_alert(db, new_product)
    
    return new_product

@router.get("/", response_model=List[ProductWithCategory])
def get_all_products(
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[int] = None,
    is_active: Optional[bool] = None,
    db: Session = Depends(get_db)
):
    """Obtenir tous les produits"""
    
    query = db.query(Product).join(Category)
    
    if category_id:
        query = query.filter(Product.category_id == category_id)
    
    if is_active is not None:
        query = query.filter(Product.is_active == is_active)
    
    products = query.offset(skip).limit(limit).all()
    
    result = []
    for product in products:
        result.append(ProductWithCategory(
            id=product.id,
            name=product.name,
            description=product.description,
            price=product.price,
            quantity_in_stock=product.quantity_in_stock,
            minimum_stock_level=product.minimum_stock_level,
            image_url=product.image_url,
            category_id=product.category_id,
            admin_id=product.admin_id,
            is_active=product.is_active,
            created_at=product.created_at,
            updated_at=product.updated_at,
            category_name=product.category.name
        ))
    
    return result

@router.get("/low-stock", response_model=List[ProductStockStatus])
def get_low_stock_products(
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Obtenir les produits avec un stock faible (admin seulement)"""
    
    products = db.query(Product).filter(
        Product.quantity_in_stock <= Product.minimum_stock_level
    ).all()
    
    result = []
    for product in products:
        percentage = (product.quantity_in_stock / product.minimum_stock_level * 100) if product.minimum_stock_level > 0 else 0
        result.append(ProductStockStatus(
            id=product.id,
            name=product.name,
            quantity_in_stock=product.quantity_in_stock,
            minimum_stock_level=product.minimum_stock_level,
            is_low_stock=True,
            stock_percentage=round(percentage, 2)
        ))
    
    return result

@router.get("/{product_id}", response_model=ProductWithCategory)
def get_product_by_id(
    product_id: int,
    db: Session = Depends(get_db)
):
    """Obtenir un produit par son ID"""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Produit non trouvé"
        )
    
    return ProductWithCategory(
        id=product.id,
        name=product.name,
        description=product.description,
        price=product.price,
        quantity_in_stock=product.quantity_in_stock,
        minimum_stock_level=product.minimum_stock_level,
        image_url=product.image_url,
        category_id=product.category_id,
        admin_id=product.admin_id,
        is_active=product.is_active,
        created_at=product.created_at,
        updated_at=product.updated_at,
        category_name=product.category.name
    )

@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_data: ProductUpdate,
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Mettre à jour un produit (admin seulement)"""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Produit non trouvé"
        )
    
    # Vérifier si la nouvelle catégorie existe
    if product_data.category_id and product_data.category_id != product.category_id:
        category = db.query(Category).filter(Category.id == product_data.category_id).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Catégorie non trouvée"
            )
        product.category_id = product_data.category_id
    
    # Mettre à jour les champs
    update_data = product_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(product, field, value)
    
    db.commit()
    db.refresh(product)
    
    # Vérifier le stock après la mise à jour
    check_and_create_stock_alert(db, product)
    
    return product

@router.patch("/{product_id}/stock", response_model=ProductResponse)
def update_product_stock(
    product_id: int,
    quantity: int,
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Mettre à jour le stock d'un produit (admin seulement)"""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Produit non trouvé"
        )
    
    if quantity < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La quantité ne peut pas être négative"
        )
    
    product.quantity_in_stock = quantity
    db.commit()
    db.refresh(product)
    
    # Vérifier le stock après la mise à jour
    check_and_create_stock_alert(db, product)
    
    return product

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    current_admin = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Supprimer un produit (admin seulement)"""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Produit non trouvé"
        )
    
    db.delete(product)
    db.commit()
    
    return None