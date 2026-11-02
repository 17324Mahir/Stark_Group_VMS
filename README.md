# Stark Group Vehicle Management System (VMS)

An enterprise-grade, desktop-first admin portal frontend for managing fleet operations across Stark Group subsidiaries.

---

## 🚀 Overview

The **Stark Group Vehicle Management System (VMS)** frontend is built with **Flutter Web** utilizing **Material 3**. It provides a clean, restrained, accessible business administration interface designed for daily fleet-management work.

> **Architecture & Demonstration Note:**  
> This project contains exclusively the **Frontend** client application. It is decoupled from backend systems and will interface with a separate **Java Spring Boot** REST backend in a subsequent phase. All vehicle records operate on a single shared in-memory mock repository (`VehicleRepository`). Changes are interactive and reset upon browser refresh.

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

## 🔒 Security Guidelines

- **Zero Sensitive Data**: No real credentials, API secrets, private keys, or keystores are stored in this repository.
- **Protected Environment**: All machine configurations and build outputs are strictly excluded via `.gitignore`.
