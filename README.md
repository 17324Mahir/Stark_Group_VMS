# Stark Group Vehicle Management System (VMS)

An enterprise-grade, desktop-first admin portal frontend for managing fleet operations across Stark Group subsidiaries.

---

## 🚀 Overview

The **Stark Group Vehicle Management System (VMS)** frontend is built with **Flutter Web** utilizing **Material 3**. It provides a clean, restrained, accessible business administration interface designed for daily fleet-management work.

> **Architecture Note:**  
> This monorepo workspace contains:
> 1. **Frontend (`/`)**: A Flutter Web client application using Material 3 with interactive mock fleet state.
> 2. **Backend (`/backend`)**: A Java Spring Boot application providing the database connectivity foundation to PostgreSQL via Spring Data JPA and Spring Boot Actuator. Vehicle schema and CRUD REST APIs will be layered in subsequent phases.

---

## 🔑 Demo Access

- **Demo URL / Local Web Port**: Runs on localhost via Chrome / Web browser.
- **Demo Email**: `demo@starkgroup.test`
- **Demo Password**: `Demo@12345`
- An **"Autofill"** shortcut is available on the Login screen for instant testing.

---

## ✨ Features & Implemented Screens

### 1. 🔐 Login Screen (`/login`)
- Clean text-based **Stark Group** branding with "Vehicle Management System" supporting text.
- Concise welcome heading and VMS purpose explanation.
- Form inputs for Email and Password with visibility toggle and keyboard submission.
- Validation for required fields and email formatting with clear inline alerts for invalid credentials.
- Small demo information panel displaying credentials and a one-click autofill shortcut.

### 2. 🗂️ Application Shell (`AppShell`)
- **Desktop**: Persistent navy sidebar displaying the brand treatment, the active **Vehicles** destination, and user account footer.
- **Tablet & Mobile**: Collapsible navigation drawer preserving quick access to destinations and user profile.
- **Header**: Active page title, subtle "Demo · Mock data" badge, and a functional **Sign out** menu action.
- Free of inactive controls, placeholder destinations, or non-functional buttons.

### 3. 🚙 Vehicles Directory (`/vehicles`)
- **Header**: Total vehicle count indicator and primary "Register vehicle" action.
- **Toolbar**: Case-insensitive search (matching Vehicle Number, Company, Brand, and Model), Company selector, Status filter (Active, Inactive, Maintenance), and a "Clear filters" action.
- **Data Table (Desktop)**: Structured table with bold vehicle numbers, company, vehicle body type, brand, model, accessible status badges, and action buttons with tooltips.
- **Card List (Mobile / Narrow Screens)**: Responsive card layout preventing horizontal overflow while keeping all fields and actions accessible.
- **Sorting**: Toggleable sorting by **Vehicle Number** and **Company** with active direction indicators.
- **Local Pagination**: Default 10 items per page with page controls and result summary (`Showing 1–10 of 18 vehicles`).
- **Empty States**: Dedicated views for empty registry and zero-match search results.

### 4. 📝 Register & Edit Vehicle Forms (`/vehicles/new` & `/vehicles/edit`)
- Reusable form component partitioned into three clear groups:
  1. **Vehicle Identity**: Vehicle Number (required, unique, case-insensitive duplicate check) and Company selector.
  2. **Vehicle Details**: Vehicle Type (Sedan, SUV, Truck, Van, Electric), Brand, and Model.
  3. **Operational State**: Status selector (Active, Inactive, Maintenance).
- Responsive two-column layout on wide screens, single-column on narrow screens.
- Full validation preventing blank or whitespace-only inputs.
- Unsaved changes guard: Dialog prompt to confirm discarding changes before navigating away.
- Useful recovery screen if an invalid or missing record ID is requested.

### 5. 🗑️ Delete Flow
- Modal confirmation dialog identifying the vehicle by its Vehicle Number and Company.
- Distinguishes destructive action with clear explanation and keyboard interaction support.
- Automatically updates pagination, visible records, and totals upon deletion.

---

## 🎨 Visual Direction & Design Tokens

- **Brand Navy**: `#0F172A` (Sidebar & brand accents)
- **Action Blue**: `#2563EB` (Primary buttons & active selected states)
- **Background**: `#F8FAFC` (Light neutral)
- **Surfaces**: `#FFFFFF` (White cards & tables with subtle `#E2E8F0` borders)
- **Status Treatments**:
  - **Active**: Green text `#15803D`, background `#DCFCE7`, border `#86EFAC`
  - **Inactive**: Slate text `#475569`, background `#F1F5F9`, border `#CBD5E1`
  - **Maintenance**: Amber text `#B45309`, background `#FEF3C7`, border `#FCD34D`
- **Spacing Scale**: 4, 8, 12, 16, 20, 24, 32
- **Border Radius**: 4px (small), 6px (medium), 8px (large)

---

## 🏗️ Project Structure

```
lib/
├── main.dart                                  # Application entry point & centralized theme
├── core/
│   ├── theme/
│   │   └── app_theme.dart                     # Color tokens, typography, and Material 3 theme
│   └── utils/
│       └── responsive.dart                    # Responsive breakpoint utilities (Desktop, Tablet, Mobile)
├── models/
│   └── vehicle.dart                          # Domain model & VehicleStatus enum (Active, Inactive, Maintenance)
├── data/
│   ├── mock_data.dart                        # 18 realistic fictional fleet seed records & company lists
│   └── vehicle_repository.dart               # In-memory reactive state manager (Repository pattern)
├── router/
│   └── app_router.dart                       # Centralized named routes & 404 recovery handling
├── widgets/
│   ├── app_shell.dart                        # Responsive navigation shell with user menu
│   ├── status_badge.dart                     # Accessible status indicator chip
│   └── confirmation_dialog.dart              # Modal dialogs for deletion & discard confirmation
└── screens/
    ├── auth/
    │   └── login_screen.dart                 # Administrative demo login view
    └── vehicles/
        ├── vehicle_list_screen.dart          # Fleet directory with search, filter, sort, & pagination
        └── vehicle_form_screen.dart          # Reusable Register & Edit vehicle form
```

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.x / Flutter 3.x)
- Google Chrome or any modern Chromium browser

### Run Locally
```bash
flutter run -d chrome
```

### Static Analysis & Verification
```bash
flutter analyze
flutter test
```

### Build Production Web Bundle
```bash
flutter build web --release
```
Distribution files are generated in `build/web/`.

---

## ☕ Backend Database Connectivity (`backend/`)

The backend service is built with **Spring Boot 3.4.x**, **Spring Data JPA**, and **PostgreSQL JDBC**. It is configured for secure, externalized configuration with no automated DDL execution.

### 1. Prerequisites
- **Java**: JDK 21+ (built with OpenJDK 26 targeting Java 21 bytecode)
- **Database**: PostgreSQL 16+ (tested on PostgreSQL 18.6)
- **Gradle**: Provided via Gradle wrapper (`./gradlew`)

### 2. Database Preparation
Create a dedicated local development database and a non-superuser application role in PostgreSQL:

```sql
-- Connect via psql as administrator:
CREATE DATABASE stark_vms_db;
CREATE USER vms_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE stark_vms_db TO vms_user;

-- Grant schema permissions:
\c stark_vms_db
GRANT ALL ON SCHEMA public TO vms_user;
```

### 3. Environment Variables
The application datasource properties are strictly externalized. Do not hardcode credentials in source files.

| Variable | Description | Example Format |
|---|---|---|
| `DB_URL` | JDBC Connection URL | `jdbc:postgresql://localhost:5432/stark_vms_db` |
| `DB_USERNAME` | PostgreSQL Application Role | `vms_user` |
| `DB_PASSWORD` | Application User Password | `your_secure_password` |

A template is available at [`backend/.env.example`](file:///Users/mahir/Documents/Projects/stark_vms/backend/.env.example). You can export these variables into your shell or configure them in your IDE Run Configuration:

```bash
export DB_URL="jdbc:postgresql://localhost:5432/stark_vms_db"
export DB_USERNAME="vms_user"
export DB_PASSWORD="your_secure_password"
```

> **Fail-Fast Protection:**  
> If any of the required environment variables are absent, the application refuses to start with a configuration failure rather than falling back to an in-memory or default database.

### 4. Schema Safety
To ensure zero unintended modifications to existing production or shared databases:
- `spring.jpa.hibernate.ddl-auto=none`
- `spring.sql.init.mode=never`

No tables, sequences, or test data are generated on application startup.

### 5. Running Integration Tests
Execute the automated database connectivity test to verify credentials, connection validity, product name (`PostgreSQL`), and active user/database queries:

```bash
cd backend
DB_URL="jdbc:postgresql://localhost:5432/stark_vms_db" \
DB_USERNAME="vms_user" \
DB_PASSWORD="your_secure_password" \
./gradlew test
```

### 6. Starting the Backend Server
```bash
cd backend
DB_URL="jdbc:postgresql://localhost:5432/stark_vms_db" \
DB_USERNAME="vms_user" \
DB_PASSWORD="your_secure_password" \
./gradlew bootRun
```
The server starts by default on port `8080`.

### 7. Actuator Health Verification
Confirm the PostgreSQL connection health without leaking sensitive parameters:

```bash
curl -s http://localhost:8080/actuator/health
```

Expected JSON response:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": { "status": "UP" },
    "ping": { "status": "UP" }
  }
}
```

---

## 🔒 Security Guidelines

- **Zero Sensitive Data**: No real credentials, API secrets, private keys, or keystores are stored in this repository.
- **Protected Environment**: All machine configurations and build outputs are strictly excluded via `.gitignore`.
