from fastapi import FastAPI
from database import Base,engine
import models 
from routes import router
from fastapi.middleware.cors import CORSMiddleware
from auth import create_initial_admin
from database import SessionLocal
from models import Food

def seed_initial_menu():
    db = SessionLocal()
    try:
        if db.query(Food).first() is not None:
            return

        initial_dishes = [
            {
                "name": "Chicken Biryani",
                "category": "Biryani",
                "price": 160.0,
                "image_url": "https://www.ruchiskitchen.com/wp-content/uploads/2020/09/Chicken-Biryani-Recipe-01-1.jpg",
                "description": "Fragrant aged basmati, slow-cooked marinated chicken & secret whole spices.",
                "available": True,
            },
            {
                "name": "Mutton Biryani",
                "category": "Biryani",
                "price": 190.0,
                "image_url": "https://png.pngtree.com/thumb_back/fh260/background/20240328/pngtree-mutton-biryani-meal-in-a-plate-on-table-image_15645442.jpg",
                "description": "Tender dum-cooked mutton simmered in deeply caramelized onions and saffron.",
                "available": True,
            },
            {
                "name": "Chicken Fried rice",
                "category": "Fried rice",
                "price": 140.0,
                "image_url": "https://thumbs.dreamstime.com/b/delicious-spicy-chicken-fried-rice-homemade-cast-iron-wok-94297571.jpg",
                "description": "High-heat wok-tossed grains with tender chicken morsels and charred scallions.",
                "available": True,
            },
            {
                "name": "Chicken 65",
                "category": "Starters",
                "price": 130.0,
                "image_url": "https://thumbs.dreamstime.com/b/chicken-chinese-cuisine-s-deep-fried-course-crazy-saltiness-crunchiness-to-punchy-flavours-curry-leaves-ginger-195902298.jpg",
                "description": "Crisp fried boneless chicken tossed with fiery bird’s eye chili & curry leaves.",
                "available": True,
            },
            {
                "name": "Gulab Jamun",
                "category": "Desserts",
                "price": 40.0,
                "image_url": "https://thumbs.dreamstime.com/b/indian-sweets-gulab-jamun-125773271.jpg",
                "description": "Soft khoya dumplings steeped in warm green cardamom and rosewater syrup.",
                "available": True,
            },
        ]
        for dish in initial_dishes:
            db.add(Food(**dish))
        db.commit()
    finally:
        db.close()

Base.metadata.create_all(bind=engine)
create_initial_admin()
seed_initial_menu()
app=FastAPI(title="The Hotpot API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(router)
@app.get("/")
def root():
    return{
       "message": "The backend is running!"
    }
