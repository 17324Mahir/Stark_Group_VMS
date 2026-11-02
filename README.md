# Stark Group Vehicle Management System (VMS)

An enterprise-grade, desktop-first admin portal frontend for managing vehicle fleet operations, tracking asset readiness, and scheduling vehicle maintenance.

---

## 🚀 Overview

The **Stark Group Vehicle Management System (VMS)** frontend is built with **Flutter Web** utilizing **Material 3**. It provides a clean, responsive administrative interface tailored for fleet operators and administrators.

> **Architecture Note:**  
> This repository contains exclusively the **Frontend** client application. It is decoupled from the backend and is designed to communicate with a dedicated **Java Spring Boot** REST backend service. Currently, all operations utilize a reactive in-memory mock repository (`VehicleRepository`), making it fully interactive without requiring active backend services during initial UI development.

---

## ✨ Features & Planned Screens

### 1. 🔐 Admin Authentication (`/login`)
- Desktop-first split-screen branding panel with feature highlights.
- Administrative login form with real-time field validation.
- Password visibility toggle & "Remember Workstation" toggle.
- **"Fill Demo Info"** button for instantaneous testing and evaluation.

### 2. 🗂️ Application Shell (`AppShell`)
- **Desktop / Tablet**: Persistent sidebar navigation (`NavigationRail`) with brand header, navigation destinations, and user profile card.
- **Mobile**: Responsive adaptive `Drawer` for smaller screens.
- **Top Header Bar**: Quick stats indicators, dynamic **Light / Dark theme toggle**, and logout control.

### 3. 🚙 Fleet Vehicles Directory (`/vehicles`)
- **Summary KPI Cards**: Live metrics for Total Fleet, Active Assets, In-Maintenance Units, and Average Fleet Odometer reading.
- **Advanced Filtering**: Live search by license plate, make, model, VIN, or assigned driver.
- **Filter Controls**: Multi-attribute dropdowns for Operational Status and Vehicle Body Type with a quick "Reset Filters" action.
- **Interactive Data Table**: Detailed fleet registry displaying vehicle specs, license plates, status badges, mileage, assigned drivers, and inline actions (Edit & Delete).
- **Destructive Action Guards**: Modal confirmation dialog before removing any vehicle from the fleet.

### 4. 📝 Register & Edit Vehicle (`/vehicles/new` & `/vehicles/edit`)
- Dual-mode form handling new registrations or updating existing fleet assets.
- Logically partitioned into 3 clean Material 3 cards:
  1. **Vehicle Identification**: License plate, VIN, make, model, and manufacturing year.
  2. **Specifications & Classification**: Vehicle body type, fuel/powertrain type, and odometer reading.
  3. **Fleet Operations & Assignment**: Operational status, assigned driver, and last service date picker.
- Client-side validation ensuring data integrity before saving.

### 5. 📊 Fleet Operational Dashboard (Overview)
- Operational readiness percentage score.
- Priority maintenance queue surfacing flagged vehicles requiring workshop attention.

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                                  # Application entry point & theme state listener
├── core/
│   ├── theme/
│   │   └── app_theme.dart                     # Material 3 light & dark theme definitions
│   └── utils/
│       └── responsive.dart                    # Breakpoint utilities (Desktop, Tablet, Mobile)
├── models/
│   └── vehicle.dart                          # Vehicle entity model and domain enums
├── data/
│   ├── mock_data.dart                        # Seed fleet dataset
│   └── vehicle_repository.dart               # In-memory reactive state manager (Repository pattern)
├── router/
│   └── app_router.dart                       # Centralized route definitions and page builders
├── widgets/
│   ├── app_shell.dart                        # Responsive navigation shell & theme toggle
│   ├── stat_card.dart                        # Reusable dashboard metric card
│   ├── status_badge.dart                     # Color-coded operational status chips
│   └── confirmation_dialog.dart              # Modal confirmation dialog
└── screens/
    ├── auth/
    │   └── login_screen.dart                 # Administrative login view
    ├── vehicles/
    │   ├── vehicle_list_screen.dart          # Primary fleet table and search view
    │   └── vehicle_form_screen.dart          # Vehicle registration and edit view
    └── dashboard/
        └── dashboard_overview_screen.dart    # Operational overview and maintenance queue
```

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22.0 or higher recommended)
- Google Chrome (or any modern Chromium/Web browser)

### Local Development
To launch the application locally in Google Chrome:

```bash
# Fetch package dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

### Static Analysis & Verification
Run static analysis and automated widget tests:

```bash
# Verify code quality and lints
flutter analyze

# Execute test suite
flutter test
```

### Production Web Build
To compile the standalone production bundle for deployment:

```bash
flutter build web --release
```
The optimized web distribution will be generated in `build/web/`.

---

## 🔒 Security Guidelines

- **No Sensitive Information**: Never commit environment files (`.env`), API keys, credentials, local path configurations (`local.properties`), keystores, or private certificates to this repository.
- **Clean Configuration**: All sensitive local files are strictly ignored via `.gitignore`.
