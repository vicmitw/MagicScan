# 🧙‍♂️ MagicScan – MTG Card Scanner & Collection Tracker

MagicScan is a modern mobile app built with Flutter that revolutionizes MTG card collection management through **unlimited free scanning** and powerful local-first architecture. Unlike competitors with scan limits, MagicScan offers infinite scanning for free, with premium features for advanced analytics and deck building.

## 🎯 **Competitive Advantage**

### 🆓 **Unlimited Free Scanning (Our Secret Weapon)**
- **Zero scan limits** – Scan your entire collection without restrictions
- **100% local storage** – No server costs = no need to limit users
- **Instant offline access** – Works without internet after initial setup
- **Complete privacy** – Your data never leaves your device

### 🔥 **Vs. Competition:**
```
❌ Delver Lens: $4/month subscription
❌ Lion's Eye: Premium scanner behind paywall  
❌ TCGScan: $4.99/week or $49.99/year
✅ MagicScan: Unlimited scanning FREE forever
```

---

## ✨ **Core Features**

### 🆓 **Free Tier (The Hook)**
- **Unlimited Card Scanning**
  - Advanced overlay-guided scanning system
  - Instant card identification with 95%+ accuracy
  - Real-time price display via Scryfall API
  - Local database storage (unlimited)
  - Export to CSV/JSON

### 💎 **Premium Features (€4 One-time Purchase)**
- **Pack ROI Analytics**
  - Track booster pack profitability
  - Historical pack performance analysis
  - Set profitability comparisons
  - Streamer-friendly live stats overlay

- **Physical Deck Builder**
  - Build decks using real physical cards
  - Continuous scanning mode for deck creation
  - Advanced deck statistics (mana curve, type distribution)
  - Physical card-based deck management

- **Advanced Analytics**
  - Collection value tracking over time
  - Best/worst pack analysis
  - Investment ROI calculations
  - Format legality checking

- **Data Portability**
  - Cloud backup (iCloud/Google Drive)
  - Advanced CSV import/export
  - Cross-device synchronization
  - Desktop companion app integration

---

## 🧠 **Advanced Local-First Scanning Engine**

### 🎯 **Atomic Scanning Motor (Core Architecture)**

Our proprietary scanning engine follows **Single Responsibility Principle** with modular, reusable components:

```
📷 Image Capture → 🖼️ Processing → 📝 OCR → 🔍 Matching → ✅ Result
```

#### **Phase 1: Guided Image Capture**
- **Smart overlay system** similar to document scanners
- **Card proportion guides** (63mm x 88mm ratio)
- **Auto-crop to overlay boundaries** for consistent results
- **Real-time quality feedback** (lighting, focus, alignment)

#### **Phase 2: Local Processing Pipeline**
- **Contrast enhancement** for better OCR accuracy
- **Multi-region text extraction** (name, set symbol, collector number)
- **Confidence scoring** for each extracted element
- **Fallback OCR** with multiple engines if needed

#### **Phase 3: Smart Card Matching**
1. **Extract card name** via Google ML Kit OCR
2. **Query local Scryfall database** for all variants of that name
3. **Reduce search space** from 70k+ cards to ~30 variants
4. **Image comparison** using perceptual hashing algorithms
5. **80%+ similarity** = auto-match, otherwise manual selection

#### **Phase 4: Intelligent Fallback**
- **Low confidence** triggers visual confirmation screen
- **Grid of candidate cards** with images for user selection
- **Fuzzy name matching** for OCR errors ("Lighting Bolt" → "Lightning Bolt")
- **Set symbol recognition** for additional accuracy

---

## 📦 **Enhanced Local Database Structure**

### **Core Tables:**
#### `scryfall_cards` (Local Mirror)
| Field | Type | Description |
|-------|------|-------------|
| id | TEXT | Scryfall UUID |
| name | TEXT | Card name |
| set_code | TEXT | Set abbreviation |
| collector_number | TEXT | Collector number |
| rarity | TEXT | Card rarity |
| type_line | TEXT | Type information |
| mana_cost | TEXT | Mana cost |
| cmc | INTEGER | Converted mana cost |
| image_uri | TEXT | Local/remote image path |
| price_usd | REAL | Latest USD price |
| price_updated | TEXT | Price last updated |

#### `user_cards` (Scanned Collection)
| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER | Primary key |
| scryfall_id | TEXT | Reference to scryfall_cards |
| condition | TEXT | Card condition |
| foil | BOOLEAN | Foil status |
| date_scanned | TEXT | When card was added |
| scan_session_id | TEXT | Batch scanning session |
| notes | TEXT | User notes |

#### `pack_sessions` (Premium Analytics)
| Field | Type | Description |
|-------|------|-------------|
| id | TEXT | Session UUID |
| pack_price | REAL | Cost per pack |
| expected_cards | INTEGER | Cards per pack (15/20/custom) |
| date_opened | TEXT | Opening date |
| total_value | REAL | Total card value |
| roi_percentage | REAL | Calculated ROI |
| set_code | TEXT | Dominant set |

#### `pack_cards` (Pack Contents)
| Field | Type | Description |
|-------|------|-------------|
| pack_session_id | TEXT | Foreign key |
| scryfall_id | TEXT | Card reference |
| card_value | REAL | Value at time of scan |
| rarity | TEXT | Card rarity |
| scan_order | INTEGER | Order scanned in pack |

#### `decks` (Premium Deck Builder)
| Field | Type | Description |
|-------|------|-------------|
| id | TEXT | Deck UUID |
| name | TEXT | Deck name |
| format | TEXT | Magic format |
| date_created | TEXT | Creation date |
| total_value | REAL | Current deck value |
| commander_id | TEXT | Commander card (EDH) |

---

## 💰 **Pack ROI Analytics (Premium Feature)**

### 🎰 **Pack Opening Experience**
```
1. Set pack price (€4.00)
2. Choose pack type (Standard 15 / Jumbo 20 / Custom)
3. Continuous scanning with live counters
4. Real-time value tracking
5. Beautiful results summary with profit/loss
6. Historical comparison and trends
```

### 📊 **Advanced Analytics Dashboard**
- **ROI trends over time** with interactive charts
- **Set performance comparison** (which sets are profitable?)
- **Best/worst pack tracking** with detailed breakdowns
- **Streamer mode** with OBS-compatible overlays
- **Profitability predictions** based on historical data

### 🎥 **Content Creator Features**
- **Live streaming overlay** showing current pack value
- **Real-time ROI calculations** for audience engagement
- **Session statistics** for multi-pack openings
- **Export highlights** (best pulls, worst packs)

---

## 🃏 **Physical Deck Builder (Premium Feature)**

### 🏗️ **Revolutionary Approach**
Instead of dragging digital cards, build decks with **real physical cards**:

1. **Place phone on scanning platform**
2. **Pass physical cards** one by one under camera
3. **Automatic recognition** and deck building
4. **Real-time statistics** as you build
5. **Physical card ownership validation**

### 📈 **Deck Analytics**
- **Mana curve visualization** with interactive charts
- **Type distribution** (creatures, spells, lands)
- **Color distribution** and fixing analysis
- **Average CMC calculation**
- **Format legality checking**
- **Total deck value** tracking
- **Missing cards suggestions** for optimization

---

## 🔌 **APIs & Data Sources**

### **Scryfall Integration**
- **Bulk data download** for offline operation
- **Daily price updates** when online
- **Complete card database** with images
- **Format legality data**
- **Ruling and errata information**

### **Future Integrations (Roadmap)**
- **TCGPlayer API** for market price comparison
- **Cardmarket API** for European pricing
- **EDHREC API** for deck recommendations
- **MTGGoldfish API** for meta analysis

---

## 📤 **Advanced Export & Backup System**

### **Export Formats**
- **CSV** with customizable fields
- **JSON** for developer integration
- **Moxfield** deck import format
- **MTGA/MTGO** deck lists
- **Plain text** for sharing

### **Cloud Backup (Premium)**
- **Automatic iCloud/Google Drive** backup
- **Cross-device synchronization**
- **Backup encryption** for security
- **Restore from backup** with version control
- **Export scheduling** (weekly/monthly backups)

---

## 🏗️ **Technical Architecture**

### **Local-First Design**
- **Zero server dependency** for core functionality
- **Offline-first approach** with online enhancements
- **Local image processing** for privacy and speed
- **Cached price data** for offline price display

### **Modular Engine Design**
```dart
// Core interfaces following SOLID principles
abstract class CardScanEngine {
  Future<ScanResult> scanCard(File image);
}

abstract class CardDatabase {
  Future<List<Card>> searchByName(String name);
}

abstract class PriceProvider {
  Future<double> getPrice(String cardId);
}
```

### **Performance Optimizations**
- **Progressive loading** of card database
- **Image caching** for frequently scanned cards
- **Background processing** for non-critical operations
- **Memory management** for large collections

---

## 📱 **Built With (Updated Stack)**

- **Flutter 3.x** (Cross-platform framework)
- **Google ML Kit** (On-device OCR)
- **SQLite (sqflite)** (Local database)
- **Riverpod** (State management)
- **Image** (Image processing)
- **fl_chart** (Analytics visualization)
- **share_plus** (Export functionality)
- **path_provider** (File system access)
- **in_app_purchase** (Premium features)

---

## 🎯 **Monetization Strategy**

### **Freemium Model (Local-First Advantage)**
```
🆓 FREE FOREVER:
✅ Unlimited card scanning
✅ Local storage
✅ Basic price display
✅ CSV export
✅ Collection management

💎 PREMIUM (€4 one-time):
✅ Pack ROI analytics
✅ Physical deck builder
✅ Advanced statistics
✅ Cloud backup
✅ Import/export advanced
✅ Streaming overlays
```

### **Why This Model Works**
- **No ongoing costs** due to local-first architecture
- **Competitive advantage** vs subscription models
- **High conversion potential** due to valuable premium features
- **Sustainable business** with 98%+ profit margins

---

## 🚀 **Development Roadmap**

### **Phase 1: Core Engine (Weeks 1-3)**
- [x] Project setup and architecture
- [ ] Camera integration with overlay system
- [ ] OCR implementation (Google ML Kit)
- [ ] Local Scryfall database setup
- [ ] Basic card matching algorithm
- [ ] Local storage implementation

### **Phase 2: Premium Features (Weeks 4-6)**
- [ ] Pack scanning analytics
- [ ] Physical deck builder
- [ ] Advanced statistics dashboard
- [ ] Export/import system
- [ ] In-app purchase integration

### **Phase 3: Polish & Launch (Weeks 7-8)**
- [ ] Performance optimization
- [ ] Beta testing with MTG community
- [ ] App Store submission
- [ ] Marketing materials creation

### **Phase 4: Post-Launch (Months 2-6)**
- [ ] Cloud backup implementation
- [ ] Desktop companion app
- [ ] Additional price sources
- [ ] Community feedback implementation

---

## 🎮 **Target Market Analysis**

### **Primary Users**
- **Active MTG collectors** with large collections (1000+ cards)
- **Content creators** (streamers, YouTubers) opening packs
- **Store owners** tracking inventory and profitability
- **Competitive players** building and testing decks

### **User Personas**
1. **The Collector** - Wants to catalog entire collection efficiently
2. **The Content Creator** - Needs pack opening analytics for content
3. **The Deck Builder** - Builds decks with physical cards owned
4. **The Investor** - Tracks card values and ROI over time

---

## 📄 **License**

This app is proprietary software. All card data provided by [Scryfall](https://scryfall.com), used under their permissive API license. MTG card names, types, and artwork are property of Wizards of the Coast.
