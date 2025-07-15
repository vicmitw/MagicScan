# 🏗️ MagicScan - Estructura de Proyecto

## 📁 **Arquitectura Modular (SOLID Principles)**

### 🎯 **Single Responsibility Principle (SRP)**
Cada archivo y clase tiene **una única responsabilidad** bien definida.

```
lib/
├── 🎨 presentation/          # UI/UX Layer
├── 🧠 domain/               # Business Logic Layer  
├── 📦 data/                 # Data Access Layer
├── 🔧 core/                 # Shared Utilities
└── 📱 main.dart             # App Entry Point
```

---

## 📱 **Presentation Layer (UI/UX)**

```
lib/presentation/
├── 📱 app/
│   ├── magic_scan_app.dart           # Main App Widget
│   └── app_router.dart               # Navigation Configuration
│
├── 🎨 theme/
│   ├── app_theme.dart                # Theme Data
│   ├── app_colors.dart               # Color Palette
│   ├── app_text_styles.dart          # Typography
│   └── app_dimensions.dart           # Spacing & Sizes
│
├── 📄 pages/
│   ├── 🏠 home/
│   │   ├── home_page.dart            # Main Navigation Hub
│   │   └── widgets/
│   │       ├── navigation_bar.dart   # Bottom Navigation
│   │       └── quick_actions.dart    # Quick Access Buttons
│   │
│   ├── 📷 scanner/
│   │   ├── scanner_page.dart         # Camera Scanner Screen
│   │   ├── scan_result_page.dart     # Result Display
│   │   └── widgets/
│   │       ├── camera_overlay.dart   # Scanning Guide
│   │       ├── card_preview.dart     # Scanned Card Display
│   │       ├── confidence_indicator.dart # Match Confidence
│   │       └── manual_selection.dart # Fallback Selection
│   │
│   ├── 📦 collection/
│   │   ├── collection_page.dart      # Collection Overview
│   │   ├── card_details_page.dart    # Individual Card View
│   │   └── widgets/
│   │       ├── collection_grid.dart  # Card Grid Display
│   │       ├── search_bar.dart       # Collection Search
│   │       ├── filter_panel.dart     # Filtering Options
│   │       └── sort_options.dart     # Sorting Controls
│   │
│   ├── 💰 pack_analytics/ (Premium)
│   │   ├── pack_scanner_page.dart    # Pack Opening Interface
│   │   ├── pack_results_page.dart    # Pack Analysis Results
│   │   ├── pack_history_page.dart    # Historical Analytics
│   │   └── widgets/
│   │       ├── pack_progress.dart    # Real-time Progress
│   │       ├── roi_chart.dart        # ROI Visualization
│   │       ├── pack_summary.dart     # Pack Summary Card
│   │       └── streamer_overlay.dart # OBS Integration
│   │
│   ├── 🃏 deck_builder/ (Premium)
│   │   ├── deck_builder_page.dart    # Physical Deck Builder
│   │   ├── deck_stats_page.dart      # Deck Analytics
│   │   ├── deck_list_page.dart       # All Decks Overview
│   │   └── widgets/
│   │       ├── mana_curve_chart.dart # Mana Curve Display
│   │       ├── type_distribution.dart # Card Type Stats
│   │       ├── deck_card_list.dart   # Deck Contents
│   │       └── format_validator.dart # Format Legality
│   │
│   ├── 📊 statistics/ (Premium)
│   │   ├── statistics_page.dart      # Analytics Dashboard
│   │   └── widgets/
│   │       ├── value_timeline.dart   # Collection Value Over Time
│   │       ├── set_performance.dart  # Set ROI Analysis
│   │       ├── rarity_breakdown.dart # Rarity Distribution
│   │       └── investment_summary.dart # Investment Overview
│   │
│   ├── ⚙️ settings/
│   │   ├── settings_page.dart        # App Settings
│   │   ├── premium_page.dart         # Premium Features
│   │   ├── export_page.dart          # Data Export Options
│   │   └── widgets/
│   │       ├── setting_tile.dart     # Individual Setting
│   │       ├── premium_card.dart     # Premium Feature Card
│   │       └── export_options.dart   # Export Format Options
│   │
│   └── 🔐 premium/
│       ├── premium_guard.dart        # Premium Feature Guard
│       ├── purchase_dialog.dart      # In-App Purchase UI
│       └── premium_benefits.dart     # Features Overview
│
├── 🎛️ providers/
│   ├── scanner_provider.dart         # Scanner State Management
│   ├── collection_provider.dart      # Collection State
│   ├── pack_analytics_provider.dart  # Pack Analytics State
│   ├── deck_builder_provider.dart    # Deck Builder State
│   ├── settings_provider.dart        # App Settings State
│   └── premium_provider.dart         # Premium Status State
│
└── 🧩 widgets/
    ├── common/
    │   ├── loading_indicator.dart     # Loading States
    │   ├── error_widget.dart          # Error Display
    │   ├── empty_state.dart           # Empty Collections
    │   ├── premium_badge.dart         # Premium Feature Badge
    │   └── confirmation_dialog.dart   # Confirmation Dialogs
    │
    ├── cards/
    │   ├── card_tile.dart             # Collection Card Tile
    │   ├── card_image.dart            # Card Image Display
    │   ├── price_display.dart         # Price Information
    │   └── rarity_indicator.dart      # Rarity Visual
    │
    └── charts/
        ├── base_chart.dart            # Chart Base Widget
        ├── line_chart.dart            # Line Chart Implementation
        ├── pie_chart.dart             # Pie Chart Implementation
        └── bar_chart.dart             # Bar Chart Implementation
```

---

## 🧠 **Domain Layer (Business Logic)**

```
lib/domain/
├── 📋 entities/
│   ├── card.dart                     # Card Entity
│   ├── pack_session.dart             # Pack Opening Session
│   ├── deck.dart                     # Deck Entity
│   ├── scan_result.dart              # Scan Result Entity
│   ├── collection.dart               # Collection Entity
│   ├── pack_analytics.dart           # Pack Analytics Data
│   └── user_preferences.dart         # User Settings Entity
│
├── 🎯 use_cases/
│   ├── scanning/
│   │   ├── scan_card_use_case.dart           # Single Card Scanning
│   │   ├── process_image_use_case.dart       # Image Processing
│   │   ├── match_card_use_case.dart          # Card Matching Logic
│   │   └── extract_text_use_case.dart        # OCR Text Extraction
│   │
│   ├── collection/
│   │   ├── add_card_use_case.dart            # Add Card to Collection
│   │   ├── remove_card_use_case.dart         # Remove Card
│   │   ├── search_collection_use_case.dart   # Search Cards
│   │   ├── filter_collection_use_case.dart   # Filter Cards
│   │   └── export_collection_use_case.dart   # Export Collection
│   │
│   ├── pack_analytics/
│   │   ├── start_pack_session_use_case.dart  # Start Pack Opening
│   │   ├── add_card_to_pack_use_case.dart    # Add Card to Pack
│   │   ├── finish_pack_session_use_case.dart # Finish Pack
│   │   ├── calculate_roi_use_case.dart       # Calculate Pack ROI
│   │   └── analyze_pack_history_use_case.dart # Historical Analysis
│   │
│   ├── deck_builder/
│   │   ├── create_deck_use_case.dart         # Create New Deck
│   │   ├── add_card_to_deck_use_case.dart    # Add Card to Deck
│   │   ├── calculate_deck_stats_use_case.dart # Deck Statistics
│   │   ├── validate_deck_format_use_case.dart # Format Validation
│   │   └── export_deck_use_case.dart         # Export Deck List
│   │
│   └── premium/
│       ├── purchase_premium_use_case.dart    # Handle Purchase
│       ├── restore_purchase_use_case.dart    # Restore Purchase
│       └── check_premium_status_use_case.dart # Check Status
│
├── 🔌 repositories/
│   ├── card_repository.dart          # Card Data Repository
│   ├── collection_repository.dart    # Collection Repository
│   ├── pack_repository.dart          # Pack Analytics Repository
│   ├── deck_repository.dart          # Deck Repository
│   ├── price_repository.dart         # Price Data Repository
│   ├── settings_repository.dart      # Settings Repository
│   └── premium_repository.dart       # Premium Status Repository
│
├── 🏭 services/
│   ├── scanning/
│   │   ├── card_scan_service.dart    # Core Scanning Service
│   │   ├── image_processor.dart      # Image Processing Service
│   │   ├── text_extractor.dart       # OCR Service
│   │   └── card_matcher.dart         # Card Matching Service
│   │
│   ├── analytics/
│   │   ├── pack_analyzer.dart        # Pack Analytics Service
│   │   ├── collection_analyzer.dart  # Collection Analytics
│   │   ├── deck_analyzer.dart        # Deck Analytics Service
│   │   └── roi_calculator.dart       # ROI Calculation Service
│   │
│   └── export/
│       ├── csv_export_service.dart   # CSV Export Service
│       ├── json_export_service.dart  # JSON Export Service
│       ├── backup_service.dart       # Backup Service
│       └── cloud_sync_service.dart   # Cloud Synchronization
│
└── 📏 value_objects/
    ├── card_id.dart                  # Card Identifier VO
    ├── price.dart                    # Price Value Object
    ├── confidence_score.dart         # Confidence Value Object
    ├── scan_session_id.dart          # Scan Session Identifier
    └── deck_format.dart              # Magic Format VO
```

---

## 📦 **Data Layer (Storage & APIs)**

```
lib/data/
├── 🗄️ datasources/
│   ├── local/
│   │   ├── database/
│   │   │   ├── database_helper.dart        # SQLite Helper
│   │   │   ├── migrations/
│   │   │   │   ├── migration_v1.dart       # Initial Schema
│   │   │   │   ├── migration_v2.dart       # Schema Updates
│   │   │   │   └── migration_manager.dart  # Migration Management
│   │   │   │
│   │   │   └── tables/
│   │   │       ├── scryfall_cards_table.dart # Card Database Table
│   │   │       ├── user_cards_table.dart     # User Collection Table
│   │   │       ├── pack_sessions_table.dart  # Pack Analytics Table
│   │   │       ├── pack_cards_table.dart     # Pack Contents Table
│   │   │       └── decks_table.dart          # Decks Table
│   │   │
│   │   ├── storage/
│   │   │   ├── file_storage.dart           # Local File Storage
│   │   │   ├── image_cache.dart            # Image Caching
│   │   │   ├── preferences_storage.dart    # Shared Preferences
│   │   │   └── backup_storage.dart         # Local Backup Storage
│   │   │
│   │   └── scanning/
│   │       ├── camera_datasource.dart      # Camera Access
│   │       ├── ml_kit_datasource.dart      # Google ML Kit OCR
│   │       └── image_processing_datasource.dart # Image Processing
│   │
│   ├── remote/
│   │   ├── scryfall/
│   │   │   ├── scryfall_api.dart           # Scryfall API Client
│   │   │   ├── scryfall_endpoints.dart     # API Endpoints
│   │   │   ├── scryfall_models.dart        # API Response Models
│   │   │   └── scryfall_bulk_downloader.dart # Bulk Data Download
│   │   │
│   │   ├── price_providers/
│   │   │   ├── tcgplayer_api.dart          # TCGPlayer Integration
│   │   │   ├── cardmarket_api.dart         # Cardmarket Integration
│   │   │   └── price_aggregator.dart       # Price Comparison
│   │   │
│   │   └── cloud/
│   │       ├── icloud_datasource.dart      # iCloud Integration
│   │       ├── google_drive_datasource.dart # Google Drive Integration
│   │       └── backup_uploader.dart        # Cloud Backup
│   │
│   └── premium/
│       ├── app_store_datasource.dart       # iOS In-App Purchase
│       ├── play_store_datasource.dart      # Android In-App Purchase
│       └── purchase_validator.dart         # Purchase Validation
│
├── 📄 models/
│   ├── card_model.dart               # Card Data Model
│   ├── collection_model.dart         # Collection Data Model
│   ├── pack_session_model.dart       # Pack Session Data Model
│   ├── deck_model.dart               # Deck Data Model
│   ├── scan_result_model.dart        # Scan Result Data Model
│   ├── analytics_model.dart          # Analytics Data Model
│   └── user_preferences_model.dart   # User Preferences Model
│
├── 🔄 repositories/
│   ├── card_repository_impl.dart     # Card Repository Implementation
│   ├── collection_repository_impl.dart # Collection Repository Impl
│   ├── pack_repository_impl.dart     # Pack Repository Implementation
│   ├── deck_repository_impl.dart     # Deck Repository Implementation
│   ├── price_repository_impl.dart    # Price Repository Implementation
│   ├── settings_repository_impl.dart # Settings Repository Impl
│   └── premium_repository_impl.dart  # Premium Repository Impl
│
└── 🗂️ mappers/
    ├── card_mapper.dart              # Entity ↔ Model Mapper
    ├── collection_mapper.dart        # Collection Entity Mapper
    ├── pack_mapper.dart              # Pack Session Entity Mapper
    ├── deck_mapper.dart              # Deck Entity Mapper
    └── analytics_mapper.dart         # Analytics Entity Mapper
```

---

## 🔧 **Core Layer (Shared Utilities)**

```
lib/core/
├── 🛠️ utils/
│   ├── constants.dart                # App Constants
│   ├── enums.dart                    # App Enumerations
│   ├── extensions.dart               # Dart Extensions
│   ├── validators.dart               # Input Validators
│   ├── formatters.dart               # Data Formatters
│   ├── logger.dart                   # Logging Utility
│   └── device_info.dart              # Device Information
│
├── ⚠️ errors/
│   ├── failures.dart                 # Failure Base Classes
│   ├── exceptions.dart               # Exception Definitions
│   ├── error_handler.dart            # Global Error Handler
│   └── error_messages.dart           # Error Message Constants
│
├── 🌐 network/
│   ├── api_client.dart               # HTTP Client
│   ├── network_info.dart             # Connectivity Checker
│   ├── request_interceptor.dart      # Request Interceptors
│   └── response_interceptor.dart     # Response Interceptors
│
├── 📂 platform/
│   ├── file_manager.dart             # File Operations
│   ├── camera_manager.dart           # Camera Operations
│   ├── permission_manager.dart       # Permission Handling
│   └── platform_specific.dart       # Platform-Specific Code
│
├── 🔐 security/
│   ├── encryption.dart               # Data Encryption
│   ├── secure_storage.dart           # Secure Key Storage
│   └── biometric_auth.dart           # Biometric Authentication
│
└── 📊 analytics/
    ├── analytics_service.dart        # Analytics Integration
    ├── crash_reporter.dart           # Crash Reporting
    └── performance_monitor.dart      # Performance Monitoring
```

---

## 📱 **Main Entry Point**

```
lib/
├── main.dart                         # App Entry Point
├── main_development.dart             # Development Environment
├── main_staging.dart                 # Staging Environment
└── main_production.dart              # Production Environment
```

---

## ⚙️ **Configuration Files**

```
├── 📋 pubspec.yaml                   # Dependencies & Assets
├── 🔧 analysis_options.yaml          # Linting Rules
├── 🏗️ build.yaml                     # Build Configuration
├── 🔒 android/app/build.gradle       # Android Configuration
├── 📱 ios/Runner.xcodeproj/           # iOS Configuration
├── 🌍 assets/
│   ├── images/                       # App Images
│   ├── icons/                        # App Icons
│   └── fonts/                        # Custom Fonts
│
└── 🧪 test/
    ├── unit/                         # Unit Tests
    ├── integration/                  # Integration Tests
    ├── widget/                       # Widget Tests
    └── mocks/                        # Test Mocks
```

---

## 🎯 **Benefits of This Structure**

### ✅ **Single Responsibility Principle (SRP)**
- Each file has **one clear purpose**
- Easy to locate and modify specific functionality
- **No 400+ line files** - maximum ~150 lines per file

### 🔄 **Open/Closed Principle (OCP)**
- Easy to **extend** without modifying existing code
- New features can be added through new files/classes
- **Plugin-based architecture** for scanning engines

### 🔀 **Dependency Inversion (DIP)**
- **Abstractions** in domain layer
- **Implementations** in data layer
- Easy to **swap implementations** (e.g., different OCR engines)

### 🧪 **Testability**
- **Clear separation** makes unit testing straightforward
- **Mockable interfaces** for all external dependencies
- **Isolated business logic** in use cases

### 📈 **Scalability**
- **Easy to add new features** without affecting existing code
- **Team-friendly** - multiple developers can work on different areas
- **Maintainable** codebase that grows gracefully

### 🔧 **Development Efficiency**
- **Clear file locations** - no guessing where code belongs
- **Consistent patterns** across all features
- **Easy refactoring** when following SOLID principles

---

## 🚀 **Development Workflow**

### 📝 **Adding New Features:**
1. **Domain First**: Define entities and use cases
2. **Data Layer**: Implement repository and datasources
3. **Presentation**: Create UI and state management
4. **Test**: Add unit and widget tests

### 🔍 **File Size Guidelines:**
- **Entity files**: ~50-100 lines
- **Use case files**: ~50-150 lines
- **Widget files**: ~100-200 lines
- **Repository files**: ~100-200 lines
- **Maximum file size**: **250 lines** (hard limit)

### 📦 **Package Organization:**
```dart
// Clear imports organization
import 'package:flutter/material.dart';           // Flutter
import 'package:riverpod/riverpod.dart';          // External packages

import '../../../core/utils/constants.dart';       // Core utilities
import '../../../domain/entities/card.dart';       // Domain layer
import '../../../data/models/card_model.dart';     // Data layer
import '../../widgets/common/loading_indicator.dart'; // Presentation widgets
```

Esta estructura te permitirá desarrollar una app **mantenible, escalable y fácil de entender**, donde cada archivo tiene una responsabilidad clara y específica. 🎯 