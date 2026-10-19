from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session
from database import SessionLocal
from models import AdminUser, OrderItem, Order, Feedback, Food
from schemas import (
    AdminLogin,
    OrderCreate,
    FeedbackCreate,
    OrderTrackRequest,
    FoodCreate,
    FoodUpdate,
    FoodOut,
)
from auth import create_access_token, require_admin, verify_password


router=APIRouter()

def get_db():
    db=SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/orders")
def create_order(order_data: OrderCreate, db: Session = Depends(get_db)):
    try:
        order = Order(
            id=str(__import__("time").time_ns()),
            name=order_data.name,
            phone=order_data.phone,
            address=order_data.address,
            total=order_data.total,
            status="pending",
        )
        db.add(order)
        for item in order_data.items:
            order_item = OrderItem(
                order_id=order.id,
                food_name=item.food_name,
                quantity=item.quantity,
            )
            db.add(order_item)
        db.commit()
        db.refresh(order)
        return {
            "message": "Order created successfully",
            "order_id": order.id,
            "order_status": order.status,
        }
    except Exception as e:
        print("Order error", e)
        db.rollback()
        raise
@router.post("/admin/login")
def admin_login(credentials: AdminLogin, db: Session = Depends(get_db)):
    admin = db.query(AdminUser).filter(
        AdminUser.username == credentials.username.strip()
    ).first()
    if admin is None or not verify_password(credentials.password, admin.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password",
        )
    return {"access_token": create_access_token(admin.username), "token_type": "bearer"}


@router.get("/orders")
def get_order(
    db: Session = Depends(get_db),
    _: AdminUser = Depends(require_admin),
):
    orders=db.query(Order).all()
    result=[]
    for order in orders:
        result.append({
            "id":order.id,
            "name":order.name,
            "phone":order.phone,
            "address":order.address,
            "total":order.total,
            "status":order.status,
            "items":[
                {
                    "food_name":item.food_name,
                    "quantity":item.quantity
                }
                for item in order.items
            ]
        })
    return result
@router.patch("/orders/{order_id}/status")
def update_order_status(
    order_id: str,
    status: str,
    db: Session = Depends(get_db),
    _: AdminUser = Depends(require_admin),
):
    order = db.query(Order).filter(
        Order.id == order_id
    ).first()

    if order is None:
        return {"message": "Order not found"}

    allowed_statuses = [
        "pending",
        "preparing",
        "ready",
        "delivered"
    ]

    if status not in allowed_statuses:
        return {
            "message": "Invalid status",
            "allowed_statuses": allowed_statuses
        }

    order.status = status
    db.commit()
    db.refresh(order)

    return {
        "message": "Order status updated successfully",
        "order_id": order.id,
        "status": order.status
    }
@router.post("/feedback")
def create_feedback(
    feedback_data: FeedbackCreate,
    db: Session = Depends(get_db)
):
    feedback = Feedback(
        customer_name=feedback_data.customer_name,
        message=feedback_data.message
    )

    db.add(feedback)
    db.commit()
    db.refresh(feedback)

    return {
        "message": "Feedback submitted successfully",
        "feedback_id": feedback.id
    }


@router.get("/feedback")
def get_feedback(db: Session = Depends(get_db)):
    return db.query(Feedback).all()
@router.post("/orders/track")
def track_order(
    request: OrderTrackRequest,
    db: Session = Depends(get_db)
):
    order = db.query(Order).filter(
        Order.id == request.order_id,
        Order.phone == request.phone
    ).first()

    if order is None:
        raise HTTPException(
            status_code=404,
            detail="Order not found. Check your order ID and phone number."
        )

    return {
        "order_id": order.id,
        "status": order.status,
        "total": order.total,
        "items": [
            {
                "food_name": item.food_name,
                "quantity": item.quantity
            }
            for item in order.items
        ]
    }


# ==========================================
# PUBLIC / CUSTOMER MENU ENDPOINTS
# ==========================================

@router.get("/foods", response_model=List[FoodOut])
def get_foods(
    category: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Fetch all available foods for customers. Normal customers only see available dishes."""
    query = db.query(Food).filter(Food.available == True)
    if isinstance(category, str) and category.strip() and category.strip().lower() != "all":
        query = query.filter(func.lower(Food.category) == category.strip().lower())
    foods = query.order_by(Food.id.asc()).all()
    return foods


# ==========================================
# ADMIN MENU MANAGEMENT ENDPOINTS
# ==========================================

@router.get("/admin/foods", response_model=List[FoodOut])
def admin_get_foods(
    category: Optional[str] = None,
    db: Session = Depends(get_db),
    _: AdminUser = Depends(require_admin),
):
    """Admin endpoint to fetch all dishes (both available and sold out)."""
    query = db.query(Food)
    if isinstance(category, str) and category.strip() and category.strip().lower() != "all":
        query = query.filter(func.lower(Food.category) == category.strip().lower())
    foods = query.order_by(Food.id.asc()).all()
    return foods


@router.post("/admin/foods", response_model=FoodOut, status_code=status.HTTP_201_CREATED)
def admin_create_food(
    food_data: FoodCreate,
    db: Session = Depends(get_db),
    _: AdminUser = Depends(require_admin),
):
    """Admin endpoint to create a new food dish."""
    name = food_data.name.strip() if food_data.name else ""
    if not name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Dish name cannot be empty.",
        )

    category = food_data.category.strip() if food_data.category else ""
    if not category:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Category cannot be empty.",
        )

    if food_data.price <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Price must be greater than zero.",
        )

    existing = db.query(Food).filter(func.lower(Food.name) == name.lower()).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"A dish named '{name}' already exists.",
        )

    food = Food(
        name=name,
        category=category,
        price=float(food_data.price),
        image_url=food_data.image_url.strip() if food_data.image_url else "",
        description=food_data.description.strip() if food_data.description else "",
        available=food_data.available,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    db.add(food)
    db.commit()
    db.refresh(food)
    return food


@router.patch("/admin/foods/{food_id}", response_model=FoodOut)
def admin_update_food(
    food_id: int,
    food_data: FoodUpdate,
    db: Session = Depends(get_db),
    _: AdminUser = Depends(require_admin),
):
    """Admin endpoint to update dish details, price, category, or toggle availability."""
    food = db.query(Food).filter(Food.id == food_id).first()
    if food is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dish not found.",
        )

    if food_data.name is not None:
        new_name = food_data.name.strip()
        if not new_name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Dish name cannot be empty.",
            )
        duplicate = db.query(Food).filter(
            func.lower(Food.name) == new_name.lower(),
            Food.id != food_id,
        ).first()
        if duplicate:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Another dish named '{new_name}' already exists.",
            )
        food.name = new_name

    if food_data.category is not None:
        new_category = food_data.category.strip()
        if not new_category:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Category cannot be empty.",
            )
        food.category = new_category

    if food_data.price is not None:
        if food_data.price <= 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Price must be greater than zero.",
            )
        food.price = float(food_data.price)

    if food_data.image_url is not None:
        food.image_url = food_data.image_url.strip()

    if food_data.description is not None:
        food.description = food_data.description.strip()

    if food_data.available is not None:
        food.available = food_data.available

    food.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(food)
    return food


@router.delete("/admin/foods/{food_id}")
def admin_delete_food(
    food_id: int,
    db: Session = Depends(get_db),
    _: AdminUser = Depends(require_admin),
):
    """Admin endpoint to delete a dish. Historical orders remain intact."""
    food = db.query(Food).filter(Food.id == food_id).first()
    if food is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dish not found.",
        )

    deleted_name = food.name
    db.delete(food)
    db.commit()
    return {
        "message": f"Dish '{deleted_name}' deleted successfully",
        "id": food_id,
    }