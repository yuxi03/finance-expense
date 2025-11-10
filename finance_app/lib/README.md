# Finance App - Project Structure

## 📁 Folder Organization

This project follows a **feature-first architecture** with clear separation of concerns.

```
lib/
├── main.dart                              # App entry point
├── core/                                  # Core utilities & shared functionality
│   ├── constants/                         # App-wide constants
│   ├── theme/                             # Theme configuration
│   └── utils/                             # Utility functions
│       └── format.dart                    # Date & currency formatting
│
├── features/                              # Feature modules
│   └── transactions/                      # Transaction feature
│       ├── data/                          # Data layer
│       │   ├── models/                    # Data models
│       │   │   ├── transaction.dart       # Transaction model
│       │   │   └── category.dart          # Category model & constants
│       │   ├── repositories/              # Data repositories
│       │   │   └── transaction_repository.dart
│       │   └── services/                  # External services
│       │       └── database_service.dart  # SQLite database service
│       │
│       └── presentation/                  # Presentation layer (UI)
│           ├── pages/                     # Full page screens
│           │   └── home_page.dart         # Main home page
│           ├── widgets/                   # Feature-specific widgets
│           │   ├── add_transaction_sheet.dart
│           │   ├── edit_transaction_sheet.dart
│           │   └── transaction_list.dart
│           └── providers/                 # State management
│               └── transaction_providers.dart  # Riverpod providers
│
└── shared/                                # Shared across features
    └── widgets/                           # Reusable widgets
        └── empty_state.dart               # Empty state widget
```

## 🏗️ Architecture Layers

### **1. Data Layer** (`features/*/data/`)
- **Models**: Plain Dart classes representing data structures
- **Repositories**: Abstract data sources, handle CRUD operations
- **Services**: External dependencies (database, API, etc.)

### **2. Presentation Layer** (`features/*/presentation/`)
- **Pages**: Full-screen UI components
- **Widgets**: Reusable UI components specific to the feature
- **Providers**: State management (Riverpod)

### **3. Core** (`core/`)
- Shared utilities used across the entire app
- Theme configuration
- Constants and configurations

### **4. Shared** (`shared/`)
- Widgets and utilities that can be used by multiple features
- Generic, reusable components

## 🎯 Benefits of This Structure

1. **Scalability**: Easy to add new features without affecting existing code
2. **Maintainability**: Clear separation makes code easier to understand and maintain
3. **Testability**: Each layer can be tested independently
4. **Team Collaboration**: Multiple developers can work on different features simultaneously
5. **Reusability**: Shared components are clearly identified
6. **Clean Architecture**: Follows industry best practices

## 📝 Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `camelCase` with `const`
- **Folders**: `lowercase` (no spaces or special characters)

## 🔄 Import Guidelines

Always use **absolute imports** from the package root:

```dart
// ✅ Good
import 'package:finance_app/features/transactions/data/models/transaction.dart';
import 'package:finance_app/core/utils/format.dart';

// ❌ Bad
import '../models/transaction.dart';
import '../../utils/format.dart';
```

## 🚀 Adding New Features

To add a new feature (e.g., "budgets"):

1. Create feature folder: `lib/features/budgets/`
2. Add data layer: `data/models/`, `data/repositories/`, `data/services/`
3. Add presentation layer: `presentation/pages/`, `presentation/widgets/`, `presentation/providers/`
4. Update imports to use the new paths
5. Register providers in main.dart if needed

## 📦 Current Features

- **Transactions**: Full transaction management (add, edit, delete, view)
  - SQLite local storage
  - Date-based filtering
  - Category system
  - Income/Expense tracking
  - Swipe gestures for edit/delete

## 🛠️ Tech Stack

- **Framework**: Flutter 3.35.7
- **State Management**: Riverpod 2.6.1
- **Local Database**: sqflite 2.4.1
- **Path Management**: path_provider 2.1.5
- **UUID Generation**: uuid 4.5.1
- **Internationalization**: intl 0.19.0
