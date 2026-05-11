# POS Inventory Management System

A hybrid offline-first POS (Point of Sale) and Inventory Management System built using Flutter, SQLite, and Firebase.
The system is designed for fast and reliable retail billing operations with automatic cloud backup and recovery support.

## 🚀 Project Goal

This project aims to build a lightweight and scalable POS system for local retail shops with features like:

* ⚡ Fast offline billing
* 📦 Inventory management
* 🔍 Barcode-based product billing
* ☁️ Cloud backup and sync
* 🔐 User authentication
* 🔄 Automatic data recovery

Initially designed for a local saree shop, the system is planned to scale into a multi-shop retail management product.

---

# 🧠 System Architecture

```text id="g1x7pr"
Flutter Desktop App
        ↓
SQLite (Primary Local Database)
        ↓
Background Sync Engine
        ↓
Firebase (Cloud Backup + Authentication)
```

---

# 🛠️ Tech Stack

| Component      | Technology         |
| -------------- | ------------------ |
| Frontend/UI    | Flutter            |
| Language       | Dart               |
| Local Database | SQLite             |
| Cloud Database | Firebase Firestore |
| Authentication | Firebase Auth      |
| IDE            | Android Studio     |

---

# 🎯 Core Features

* Product management
* Barcode-based billing
* Cart system
* Payment handling
* Automatic stock updates
* Offline-first transaction system
* Background cloud synchronization
* Auto restore after login
* Duplicate transaction prevention

---

# ⚙️ System Flow

## 🛒 Billing Flow

```text id="sxtj3i"
Scan Barcode
    ↓
Fetch Product from SQLite
    ↓
Add to Cart
    ↓
Calculate Total
    ↓
Confirm Payment
    ↓
Save Sale Locally
    ↓
Mark as Unsynced
```

---

## 🔄 Sync Flow

```text id="2x2v8u"
Unsynced Local Data
        ↓
Background Sync Engine
        ↓
Push to Firebase
        ↓
Mark as Synced
```

---

## 🔁 Restore Flow

```text id="jz0v1m"
User Login
    ↓
Check Local Database
    ↓
If Empty → Fetch Firebase Data
    ↓
Rebuild SQLite Database
```

---

# 🗄️ Database Design

## Products Table

```sql
CREATE TABLE products (
    barcode TEXT PRIMARY KEY,
    name TEXT,
    price INTEGER,
    stock INTEGER,
    is_synced INTEGER
);
```

---

## Sales Table

```sql
CREATE TABLE sales (
    sale_id TEXT PRIMARY KEY,
    total INTEGER,
    payment_method TEXT,
    amount_received INTEGER,
    date TEXT,
    is_synced INTEGER
);
```

---

## Sales_Items Table

```sql
CREATE TABLE sales_items (
    id INTEGER,
    sale_id TEXT,
    barcode TEXT,
    quantity INTEGER
);
```

---

# ☁️ Firebase Structure

```text id="f1w5rd"
users/
  user_id/
    products/
    sales/
```

The same structure is maintained locally and on cloud for simplified synchronization.

---

# 🔥 Offline-First Sync System

The system prioritizes local SQLite operations for maximum billing speed.

### Sync Model

```text id="h0n5yb"
is_synced = 0 → Pending
is_synced = 1 → Completed
```

### Sync Logic

```sql
SELECT * FROM table WHERE is_synced = 0;
```

Unsynced records are automatically pushed to Firebase in the background.

### Retry Mechanism

The system retries synchronization when:

* App reopens
* Internet reconnects
* Background sync triggers

---

# ⚠️ Edge Case Handling

## ❌ Internet Failure

* Billing continues using SQLite
* Data remains safe locally
* Sync resumes automatically later

## ❌ Duplicate Transactions

* UUID-based unique sale IDs prevent duplicates

## ❌ App Crash / System Failure

* Firebase backup enables automatic recovery

---

# 🔐 Security

* Firebase Authentication
* User-specific isolated data
* Secure login system
* No public database access

---

# 🖥️ Application Screens

* Login Screen
* Billing Screen
* Payment Screen
* Add Product Screen
* Inventory Screen

---

# 🧱 Project Structure

```text id="x4c0eg"
lib/
├── core/
├── screens/
├── widgets/
├── models/
├── controllers/
├── services/
├── database/
├── repositories/
├── firebase/
├── sync/
└── utils/
```

The project follows a modular and scalable architecture using:

* Controllers
* Repositories
* Services
* DAO layers
* Sync management modules

---

# 🚀 Development Roadmap

## Phase 1

* SQLite setup
* Product management
* Billing system

## Phase 2

* Payment workflows
* Stock update automation

## Phase 3

* Firebase authentication
* Background synchronization

## Phase 4

* Auto restore system
* UI optimization
* Performance improvements

---

# 💡 Future Improvements

* Multi-shop support
* Analytics dashboard
* GST invoice generation
* Thermal printer integration
* Sales reporting
* Role-based access control
* Product search optimization

---

# 📌 Current Status

🚧 Currently under active development.

The UI architecture and system design are completed, and backend/database integration is in progress.

---

# 👨‍💻 Author

Developed by Saqib Khan and Anshuman Vaidya
