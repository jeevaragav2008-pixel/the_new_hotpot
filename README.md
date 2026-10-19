# 🍽️ THE NEW HOTPOT

### Good Food. Seamless Ordering. Better Experiences. 🔥

**THE NEW HOTPOT** is a modern restaurant ordering application built using **Flutter, FastAPI, Python, and SQLite**. It brings together a customer-friendly food ordering interface and backend restaurant management functionality in one project.

From browsing dishes and managing cart quantities to placing orders and managing menu items, THE NEW HOTPOT aims to make restaurant operations simpler and the customer experience smoother.

<p align="center">
  <strong>🍛 Explore Food • 🛒 Place Orders • ⚙️ Manage Your Menu</strong>
</p>

<p align="center">
  <a href="https://github.com/jeevaragav2008-pixel/the_new_hotpot">
    <img src="https://img.shields.io/badge/Project-THE%20NEW%20HOTPOT-red?style=for-the-badge" alt="THE NEW HOTPOT"/>
  </a>
  <img src="https://img.shields.io/badge/Frontend-Flutter-blue?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi" alt="FastAPI"/>
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?style=for-the-badge&logo=sqlite" alt="SQLite"/>
</p>

---

## 📌 Table of Contents

- [✨ Features](#-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [🏗️ System Architecture](#️-system-architecture)
- [📂 Project Structure](#-project-structure)
- [🚀 Getting Started](#-getting-started)
- [🔌 Backend API](#-backend-api)
- [🧪 Testing](#-testing)
- [🔒 Security](#-security)
- [✅ Development Status](#-development-status)
- [🔮 Future Enhancements](#-future-enhancements)
- [👨‍💻 Developer](#-developer)

---

## ✨ Features

### 📱 1. Customer Application

A clean, modern interface designed to make browsing and ordering food convenient.

- 🎨 **Attractive UI:** Modern red-themed application interface.
- 👋 **Welcome Greeting:** A friendly welcome for customers.
- 🔍 **Food Search:** Search for dishes by name.
- 🗂️ **Food Categories:** Browse categories such as Biryani, Fried Rice, Starters, Desserts, and Soup.
- 🍛 **Food Menu:** Includes sample dishes such as Chicken Biryani, Mutton Biryani, Chicken Fried Rice, Chicken 65, and Gulab Jamun.
- 🛒 **Cart Management:** Add dishes and update item quantities.
- 💰 **Dynamic Order Total:** Calculate the order total from selected items and quantities.
- 📝 **Customer Details:** Collect customer name, phone number, and delivery address.
- ✅ **Order Submission:** Submit customer orders to the FastAPI backend.
- ⭐ **Feedback Interface:** A dedicated page with a feedback submission interface.

### ⚙️ 2. Restaurant Menu Management

**Implemented and tested!** Menu management allows the restaurant to maintain its food offerings.

- ➕ **Add Foods:** Add new dishes to the menu.
- ✏️ **Edit Foods:** Update existing food details.
- 💵 **Update Prices:** Change food prices as needed.
- 🗑️ **Remove Foods:** Delete dishes that are no longer offered.
- 🔄 **Menu Maintenance:** Keep the restaurant menu up to date.

The add, edit, remove, and price-update operations have been tested.

### 🚀 3. Backend & Order Management

Powered by FastAPI and SQLAlchemy, the backend handles application requests and order storage.

- ⚡ **REST API:** Connect the Flutter application to the backend.
- 🗄️ **SQLite Database:** Store order records locally.
- 🧩 **SQLAlchemy ORM:** Interact with the database through Python models.
- 📦 **Order Storage:** Save customer details, order totals, order status, and associated items.
- 🔗 **Order Items:** Store food names and quantities linked to their respective orders.
- 📚 **Swagger UI:** Explore and test implemented API endpoints interactively.

### 🎯 4. User Experience

- Simple navigation between application screens.
- Searchable food menu.
- Category-based browsing.
- Convenient cart quantity management.
- Dedicated customer details and feedback screens.
- Integration between the Flutter frontend and Python backend.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Frontend programming language |
| Python | Backend programming language |
| FastAPI | REST API development |
| SQLite | Local database |
| SQLAlchemy | Database ORM |
| Uvicorn | ASGI application server |
| Git | Version control |
| GitHub | Source code hosting |

---

## 🏗️ System Architecture

THE NEW HOTPOT follows a frontend–backend–database architecture.

```text
              ┌───────────────────────────┐
              │   Flutter Customer App    │
              │                           │
              │  Food Menu & Search       │
              │  Categories & Cart        │
              │  Customer Details         │
              │  Feedback Interface       │
              └─────────────┬─────────────┘
                            │
                       HTTP / JSON
                            │
                            ▼
              ┌───────────────────────────┐
              │      FastAPI Backend      │
              │                           │
              │  API Endpoints            │
              │  Menu Management          │
              │  Order Processing         │
              └─────────────┬─────────────┘
                            │
                      SQLAlchemy ORM
                            │
                            ▼
              ┌───────────────────────────┐
              │      SQLite Database      │
              │                           │
              │  Orders                   │
              │  Order Items              │
              │  Other configured data    │
              └───────────────────────────┘
```

*The diagram illustrates the application's logical architecture. The exact persistence and API behavior depend on the implemented routes and database models.*

---

## 📂 Project Structure

The following is a representative structure based on the files used during development. Adjust it if your repository uses different locations.

```text
the_new_hotpot/
│
├── backend/
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── requirements.txt
│   └── hotpot.db
│
├── lib/
│   ├── main.dart
│   └── ... Flutter application source
│
├── assets/
│   └── ... Images and other assets
│
├── test/
│   └── ... Flutter tests
│
├── .gitignore
├── pubspec.yaml
└── README.md
```

**Note:** The database filename and Flutter subfolders may differ in your actual repository. The `hotpot.db` file is shown as a local development example, not a file that should necessarily be committed.

---

## 🚀 Getting Started

Follow these instructions to run the application in your local development environment.

### 📋 Prerequisites

Install the following tools:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python](https://www.python.org/downloads/)
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/)
- An Android emulator, supported mobile device, or other configured Flutter target

Verify the installations:

```bash
flutter doctor
python --version
git --version
```

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/jeevaragav2008-pixel/the_new_hotpot.git
cd the_new_hotpot
```

### 2️⃣ Set Up the Backend

Open a terminal in VS Code.

```cmd
cd backend
python -m venv venv
venv\Scripts\activate
```

Install dependencies using the project's dependency file:

```cmd
pip install -r requirements.txt
```

If the repository does not yet contain `requirements.txt`, install the core dependencies:

```cmd
pip install fastapi uvicorn sqlalchemy
```

Start the backend server:

```cmd
uvicorn main:app --reload
```

If your entry point is `backend/main.py` and you start the command from the `backend` directory, this command should work, provided the application initializes its database correctly.

### 3️⃣ Access the Backend

Once the server starts, open:

| Resource | URL |
|---|---|
| API base URL | `http://127.0.0.1:8000` |
| Swagger UI | `http://127.0.0.1:8000/docs` |
| ReDoc | `http://127.0.0.1:8000/redoc` |

The available routes and operations are defined by your backend implementation.

### 4️⃣ Set Up the Flutter App

Open a second terminal at the project root:

```cmd
flutter pub get
```

Check that the API base URL configured in the Flutter code matches your running backend.

**Android emulator:** To access a backend running on your development computer, the typical Android emulator host address is:

```text
http://10.0.2.2:8000
```

**Physical Android device:** Use your computer's reachable local network IP address, configure the server to accept connections on the appropriate interface, and ensure both devices can communicate over the network.

### 5️⃣ Run the Application

From the Flutter project root:

```cmd
flutter run
```

Choose your target device when prompted.

---

## 🔌 Backend API

The backend uses FastAPI to expose HTTP endpoints for application operations.

### Interactive API Documentation

Visit:

**[Open THE NEW HOTPOT API Docs](http://127.0.0.1:8000/docs)**

This address works when the backend is running locally.

Swagger UI lets you inspect available endpoints, view request and response schemas, and manually test supported operations.

### Order Data

The order model developed for this project includes fields for:

- Order ID
- Customer name
- Phone number
- Delivery address
- Total amount
- Order status
- Ordered food items
- Quantity of each item

### Menu Data

Menu management supports the tested operations:

- Creating food items
- Editing food details
- Updating prices
- Removing food items

Refer to the actual Swagger documentation for the precise route paths, HTTP methods, request formats, and responses. This README intentionally does not invent endpoint names.

---

## 🧪 Testing

### Menu Management

The following operations have been manually tested during development:

- [x] Add a food item.
- [x] Edit an existing food item.
- [x] Update food prices.
- [x] Remove a food item.

### Order Workflow

The backend order functionality has been developed to store customer information and order items.

For an end-to-end verification, test the following workflow:

1. Start the FastAPI backend.
2. Launch the Flutter application.
3. Browse the menu and add food items to the cart.
4. Check quantities and the calculated total.
5. Enter the customer details.
6. Submit an order.
7. Inspect the stored order using the implemented API routes.

The complete workflow should be re-tested whenever menu pricing, cart logic, or order processing changes.

### Flutter Diagnostics

```cmd
flutter analyze
```

If automated tests are configured:

```cmd
flutter test
```

### Backend Diagnostics

If the project has a configured test suite, run it from the backend directory using its documented test command.

---

## 🔒 Security & Data Protection

Security is important when handling customer information and restaurant orders.

- 🔑 Keep credentials and secret keys out of source control.
- 🚫 Never commit private customer data or sensitive production database files.
- 🛡️ Validate incoming requests on the backend.
- 🌐 Configure CORS appropriately for the intended frontend.
- 🔐 Use HTTPS for production API communication.
- 👥 Add authentication and authorization before exposing privileged restaurant management operations publicly.
- 💾 Maintain appropriate database backups and access controls.
- ⚠️ Do not expose the development server directly to the public internet.

SQLite is suitable for local development. Before production use, evaluate database concurrency, deployment, access controls, monitoring, and backup requirements.

---

## ✅ Development Status

| Feature | Status |
|---|---|
| Flutter customer UI | Implemented |
| Food search and categories | Implemented |
| Cart and quantity management | Implemented |
| Customer details screen | Implemented |
| FastAPI backend | Implemented |
| SQLite order storage | Implemented |
| Restaurant menu management | Implemented and tested |
| Add, edit, and remove foods | Implemented and tested |
| Food price updates | Implemented and tested |
| Feedback interface | Implemented |
| Persistent feedback storage | Future enhancement |
| Production deployment | Future enhancement |

---

## 🔮 Future Enhancements

Potential improvements for upcoming versions include:

- [ ] Persistent customer feedback storage.
- [ ] Advanced order status tracking.
- [ ] Order history interface.
- [ ] Restaurant sales and analytics dashboard.
- [ ] Food images and detailed menu descriptions.
- [ ] Automated backend and Flutter tests.
- [ ] Improved error handling and loading states.
- [ ] Authentication and role-based permissions.
- [ ] Production deployment with secure configuration.
- [ ] Database backups and monitoring.

These are potential future improvements and are not represented as completed features.

---

## 🎓 Learning Outcomes

This project provides hands-on experience with:

- Cross-platform application development using Flutter.
- Dart programming and UI design.
- Building REST APIs with FastAPI.
- Integrating a frontend with a Python backend.
- Database operations using SQLite and SQLAlchemy.
- Implementing CRUD operations for restaurant menu management.
- Managing customer orders and associated order items.
- Using Git and GitHub for source control and collaboration.

---

## 👨‍💻 Developer

**THE NEW HOTPOT**

Repository: [jeevaragav2008-pixel/the_new_hotpot](https://github.com/jeevaragav2008-pixel/the_new_hotpot)

Built with ❤️ using Flutter, FastAPI, Python, and SQLite.

---

## 📄 License

No specific open-source license is claimed here. Add a license file if you intend to grant others permission to use, modify, or distribute this project.

---

<p align="center">
  <strong>🍽️ THE NEW HOTPOT</strong><br/>
  Good Food. Seamless Ordering. Better Experiences.
</p>

<p align="center">
  ⭐ If you find this project interesting, consider starring the repository!
</p>
