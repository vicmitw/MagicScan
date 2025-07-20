# 📁 Estructura del Proyecto MagicScan

> **Organización Atómica:** Cada directorio y archivo tiene una responsabilidad específica y bien definida.

## 🏗️ **Estructura General del Monorepo**

```
magicscan/
├── 📱 mobile/                 # Flutter App
├── 🌐 web/                   # Next.js Web App  
├── ⚡ backend/               # FastAPI Backend
├── 🗄️ database/             # Scripts DB y migraciones
├── 🐳 docker/               # Containers para desarrollo
├── 📚 docs/                 # Documentación técnica
├── 🧪 testing/              # Tests e2e y integración
└── 🛠️ tools/               # Scripts de desarrollo
```

## 📱 **Mobile App (Flutter)**

```
mobile/
├── lib/
│   ├── 🎯 main.dart                 # Entry point atómico
│   ├── 🏗️ core/                    # Fundaciones de la app
│   │   ├── constants/              # Constantes globales
│   │   ├── errors/                 # Manejo de errores
│   │   ├── network/                # Cliente HTTP base
│   │   └── utils/                  # Utilidades comunes
│   ├── 📊 data/                    # Capa de datos (Repository Pattern)
│   │   ├── datasources/            # Fuentes de datos
│   │   │   ├── local/              # SQLite, Hive, SharedPrefs
│   │   │   └── remote/             # API calls
│   │   ├── models/                 # Modelos de datos
│   │   └── repositories/           # Implementación de repositorios
│   ├── 🎮 domain/                  # Lógica de negocio pura
│   │   ├── entities/               # Entidades del dominio
│   │   ├── repositories/           # Interfaces de repositorios
│   │   └── usecases/              # Casos de uso específicos
│   ├── 🎨 presentation/            # UI y Estado
│   │   ├── providers/              # Riverpod providers
│   │   ├── screens/                # Pantallas principales
│   │   ├── widgets/                # Widgets reutilizables
│   │   └── theme/                  # Theming y estilos
│   └── 📷 features/               # Características específicas
│       ├── scanner/                # Escáner de cartas
│       ├── collection/             # Gestión de colección
│       ├── decks/                  # Constructor de mazos
│       └── sync/                   # Sincronización
├── test/                          # Tests unitarios
├── integration_test/              # Tests de integración
└── pubspec.yaml                   # Dependencias Flutter
```

### **🔍 Detalles de Características (Features)**

#### **📷 Scanner Feature**
```
features/scanner/
├── data/
│   ├── models/
│   │   ├── card_recognition_model.dart    # Modelo de reconocimiento
│   │   └── scan_result_model.dart         # Resultado del escaneo
│   ├── datasources/
│   │   ├── camera_datasource.dart         # Acceso a cámara
│   │   ├── ml_datasource.dart             # CoreML/MLKit
│   │   └── api_datasource.dart            # Verificación servidor
│   └── repositories/
│       └── scanner_repository_impl.dart   # Implementación
├── domain/
│   ├── entities/
│   │   ├── card.dart                      # Entidad carta
│   │   └── scan_session.dart              # Sesión de escaneo
│   ├── repositories/
│   │   └── scanner_repository.dart        # Interface
│   └── usecases/
│       ├── scan_card_usecase.dart         # Escanear una carta
│       ├── batch_scan_usecase.dart        # Escaneo múltiple
│       └── verify_card_usecase.dart       # Verificar resultado
└── presentation/
    ├── providers/
    │   ├── scanner_provider.dart          # Estado del escáner
    │   └── scan_session_provider.dart     # Estado de sesión
    ├── screens/
    │   ├── scanner_screen.dart            # Pantalla principal
    │   └── scan_results_screen.dart       # Resultados
    └── widgets/
        ├── camera_widget.dart             # Widget de cámara
        ├── scan_overlay_widget.dart       # Overlay de escaneo
        └── result_card_widget.dart        # Card de resultado
```

## 🌐 **Web App (Next.js)**

```
web/
├── 📄 pages/                      # Rutas de Next.js
│   ├── api/                      # API routes (proxy)
│   ├── index.tsx                 # Página principal
│   ├── collection/               # Gestión de colección
│   ├── decks/                    # Constructor de mazos
│   └── analytics/                # Análisis y estadísticas
├── 🎨 components/                # Componentes React
│   ├── ui/                       # Componentes base
│   ├── layout/                   # Layout components
│   ├── features/                 # Componentes por feature
│   └── animations/               # Animaciones 2D
├── 🎣 hooks/                     # Custom React hooks
├── 🏪 store/                     # Zustand stores
├── 🛠️ utils/                     # Utilidades
├── 🎨 styles/                    # Estilos Tailwind
├── 📡 lib/                       # Configuraciones
│   ├── api.ts                    # Cliente API
│   ├── socket.ts                 # WebSocket client
│   └── auth.ts                   # Autenticación
└── 📦 public/                    # Assets estáticos
```

### **🎨 Componentes por Feature**

#### **🃏 Deck Builder Feature**
```
components/features/deck-builder/
├── DeckCanvas.tsx                # Canvas principal drag&drop
├── CardLibrary.tsx               # Biblioteca de cartas
├── DeckAnalyzer.tsx              # Análisis de mazo
├── ManaChart.tsx                 # Gráfico de curva de mana
├── CardSearch.tsx                # Búsqueda de cartas
└── animations/
    ├── CardFlip.tsx              # Animación flip carta
    ├── DragEffect.tsx            # Efectos de arrastre
    └── SpellEffect.tsx           # Efectos mágicos
```

## ⚡ **Backend API (FastAPI)**

```
backend/
├── 🎯 main.py                    # Entry point FastAPI
├── 🏗️ core/                     # Configuración central
│   ├── config.py                # Settings y configuración
│   ├── database.py              # Conexión DB
│   ├── security.py              # JWT y autenticación
│   └── exceptions.py            # Excepciones personalizadas
├── 📊 models/                   # Modelos SQLAlchemy
│   ├── user.py                  # Usuario
│   ├── card.py                  # Carta MTG
│   ├── collection.py            # Colección
│   └── deck.py                  # Mazo
├── 📋 schemas/                  # Pydantic schemas
│   ├── user_schemas.py          # Schemas de usuario
│   ├── card_schemas.py          # Schemas de carta
│   └── deck_schemas.py          # Schemas de mazo
├── 🛣️ routers/                  # Endpoints API
│   ├── auth.py                  # Autenticación
│   ├── cards.py                 # Gestión de cartas
│   ├── collection.py            # Colección
│   ├── decks.py                 # Mazos
│   └── scanner.py               # Escáner de cartas
├── 🧠 services/                 # Lógica de negocio
│   ├── auth_service.py          # Servicio autenticación
│   ├── card_service.py          # Servicio cartas
│   ├── scanner_service.py       # Servicio escáner
│   └── ai_service.py            # Servicio IA
├── 🗄️ repositories/             # Acceso a datos
│   ├── base_repository.py       # Repository base
│   ├── user_repository.py       # Repositorio usuarios
│   └── card_repository.py       # Repositorio cartas
├── 🤖 ml/                       # Machine Learning
│   ├── card_recognition/        # Reconocimiento de cartas
│   │   ├── models/              # Modelos entrenados
│   │   ├── preprocessing.py     # Preprocesamiento
│   │   └── inference.py         # Inferencia
│   └── deck_analysis/           # Análisis de mazos
│       ├── meta_analyzer.py     # Análisis de meta
│       └── synergy_detector.py  # Detector sinergias
├── 🛠️ utils/                    # Utilidades
│   ├── image_processing.py      # Procesamiento imágenes
│   ├── cache.py                 # Utilidades cache
│   └── validators.py            # Validadores
└── 🧪 tests/                    # Tests backend
    ├── unit/                    # Tests unitarios
    ├── integration/             # Tests integración
    └── fixtures/                # Fixtures de testing
```

### **🔍 Detalles del Sistema de Reconocimiento**

#### **🤖 ML Pipeline**
```
ml/card_recognition/
├── models/
│   ├── yolo_card_detector.onnx  # Detector de cartas YOLO
│   ├── feature_extractor.pt     # Extractor características
│   └── card_classifier.pkl     # Clasificador final
├── pipeline/
│   ├── detector.py              # Detección de cartas en imagen
│   ├── extractor.py             # Extracción características
│   ├── matcher.py               # Matching con base datos
│   └── confidence.py            # Cálculo de confianza
└── training/                    # Scripts entrenamiento
    ├── data_preparation.py      # Preparación dataset
    ├── train_detector.py        # Entrenamiento detector
    └── train_classifier.py      # Entrenamiento clasificador
```

## 🗄️ **Base de Datos**

```
database/
├── 📊 schema/                   # Esquemas SQL
│   ├── 001_initial.sql          # Migración inicial
│   ├── 002_cards_table.sql      # Tabla cartas
│   └── 003_collections.sql      # Colecciones
├── 📦 seeds/                    # Datos iniciales
│   ├── mtg_cards.sql            # Base datos MTG completa
│   └── test_data.sql            # Datos de prueba
├── 🔄 migrations/               # Migraciones Alembic
└── 🛠️ scripts/                 # Scripts mantenimiento
    ├── backup.py                # Script backup
    ├── import_cards.py          # Importar cartas MTG
    └── cleanup.py               # Limpieza datos
```

### **📊 Diseño de Base de Datos**

#### **Tablas Principales**
```sql
-- Usuarios
users (id, username, email, created_at, settings)

-- Cartas MTG (base de datos completa)
mtg_cards (id, name, set_code, collector_number, image_url, price)

-- Colecciones de usuarios
user_collections (id, user_id, card_id, quantity, condition, foil)

-- Mazos
decks (id, user_id, name, format, description, created_at)
deck_cards (deck_id, card_id, quantity, sideboard)

-- Sesiones de escaneo
scan_sessions (id, user_id, created_at, total_cards, status)
scan_results (id, session_id, card_id, confidence, verified)
```

## 🐳 **Docker & DevOps**

```
docker/
├── 🐳 docker-compose.yml       # Orquestación servicios
├── 📦 backend/
│   ├── Dockerfile              # Container backend
│   └── requirements.txt        # Dependencias Python
├── 🗄️ database/
│   ├── Dockerfile              # Container PostgreSQL
│   └── init.sql                # Inicialización DB
├── 🔴 redis/
│   └── redis.conf              # Configuración Redis
└── 🔍 monitoring/
    ├── prometheus.yml          # Configuración Prometheus
    └── grafana/                # Dashboards Grafana
```

## 📚 **Documentación Técnica**

```
docs/
├── 🏗️ architecture/            # Documentación arquitectura
│   ├── system-design.md        # Diseño del sistema
│   ├── database-design.md      # Diseño base datos
│   └── api-design.md           # Diseño API
├── 🧠 learning/                # Guías de aprendizaje
│   ├── backend-fundamentals.md # Fundamentos backend
│   ├── flutter-patterns.md     # Patrones Flutter
│   └── ml-pipeline.md          # Pipeline ML
├── 🚀 deployment/              # Guías deployment
│   ├── local-setup.md          # Setup local
│   ├── mini-pc-setup.md        # Setup mini PC
│   └── troubleshooting.md      # Solución problemas
└── 📖 api/                     # Documentación API
    └── openapi.json            # Spec OpenAPI auto-generada
```

---

> **Cada directorio incluye su propio README.md explicando su propósito específico y cómo contribuye al sistema general.** 