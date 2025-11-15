from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
from decimal import Decimal


# Product Base Schema
class ProductBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    price: Decimal = Field(..., gt=0, decimal_places=2)
    quantity_in_stock: int = Field(..., ge=0)
    minimum_stock_level: int = Field(default=10, ge=0)
    image_url: Optional[str] = Field(None, max_length=500)
    category_id: int
    is_active: bool = True

# Product Create Schema


class ProductCreate(ProductBase):
    pass

# Product Update Schema


class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    price: Optional[Decimal] = Field(None, gt=0, decimal_places=2)
    quantity_in_stock: Optional[int] = Field(None, ge=0)
    minimum_stock_level: Optional[int] = Field(None, ge=0)
    image_url: Optional[str] = Field(None, max_length=500)
    category_id: Optional[int] = None
    is_active: Optional[bool] = None

# Product Response Schema


class ProductCount(BaseModel):
    count: int


class ProductResponse(ProductBase):
    id: int
    admin_id: int
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True

# Product with Category Name


class ProductWithCategory(ProductResponse):
    category_name: str

    class Config:
        from_attributes = True

# Product Stock Status


class ProductStockStatus(BaseModel):
    id: int
    name: str
    quantity_in_stock: int
    minimum_stock_level: int
    is_low_stock: bool
    stock_percentage: float

    class Config:
        from_attributes = True

# Stock Update Schema


class StockUpdate(BaseModel):
    quantity: int
