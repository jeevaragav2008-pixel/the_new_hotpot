from datetime import datetime
from typing import List
from pydantic import BaseModel

class OrderItemCreate(BaseModel):
    food_name:str
    quantity:int

class OrderCreate(BaseModel):
    name:str
    phone:str
    address:str
    total:int
    items:List[OrderItemCreate]
class FeedbackCreate(BaseModel):
    customer_name: str | None = None
    message: str


class AdminLogin(BaseModel):
    username: str
    password: str
class OrderTrackRequest(BaseModel):
    order_id: str
    phone: str


class FoodCreate(BaseModel):
    name: str
    category: str
    price: float
    image_url: str = ""
    description: str = ""
    available: bool = True


class FoodUpdate(BaseModel):
    name: str | None = None
    category: str | None = None
    price: float | None = None
    image_url: str | None = None
    description: str | None = None
    available: bool | None = None


class FoodOut(BaseModel):
    id: int
    name: str
    category: str
    price: float
    image_url: str
    description: str
    available: bool
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
