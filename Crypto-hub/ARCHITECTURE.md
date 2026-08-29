# Architecture of Crypto-hub (v1.1.0 for KDE Plasma 6)

## 1. Philosophy and Architectural Principles
The project is built on the principles of **Separation of Concerns (SoC)** and **Layered Architecture**.
The core rule of the project: *"Logic to logic, interface to interface"*.

### Three Main System Layers:
1. **Business Logic & Math Layer (`contents/code/`):**
   - Pure JavaScript modules (`.js`).
   - Completely decoupled from the Qt Quick / QML graphical environment.
   - Responsible for computations, local SQLite database management, alert trigger evaluations, market analysis algorithms, and portfolio math.
2. **Service Layer / State Managers (`contents/services/`):**
   - Non-visual QML components (`.qml`).
   - Encapsulates network operations (`XMLHttpRequest`), cascade timers, caching, API 429 Too Many Requests rate-limit mitigation, and system notifications (`KNotification`).
3. **Presentation / UI Layer (`contents/ui/`):**
   - Pure visual UI (`.qml`).
   - Responsible for responsive layouts, animations, theming, scaling factors (`scaleFactor`), and user interactions.

---

## 2. Project Directory Tree

Crypto-hub/
├── metadata.json # KDE Plasma 6 applet metadata manifest (v1.1.0)
├── ARCHITECTURE.md # Architectural roadmap and technical specifications
├── README.md # Project overview, features, and documentation
└── contents/
├── config/
│ ├── main.xml # KConfigXT configuration schema (12 settings keys)
│ └── config.qml # Settings window categories declaration
│
├── code/ # [1. PURE LOGIC LAYER (Pure JS)]
│ ├── database.js # SQLite engine (coin cache, instant offline search)
│ ├── coingecko.js # Low-level CoinGecko API HTTP client
│ ├── fng.js # Low-level Alternative.me F&G API HTTP client
│ ├── alertEngine.js # Alert trigger evaluation engine
│ ├── portfolioEngine.js # Portfolio calculation and valuation engine
│ ├── marketSummary.js # Market condition evaluation algorithm
│ ├── constants.js # Global constants and macro helpers (BTC Halving)
│ ├── coinSettingsHelper.js # Helper for coin search, batch add, and sorting
│ └── alertSettingsHelper.js # Helper for alert values formatting and validation
│
├── services/ # [2. SERVICE LAYER (QML Managers)]
│ ├── NetworkManager.qml # Network scheduler, cascade timers, and cache manager
│ └── NotificationManager.qml # KNotification wrapper for desktop notifications
│
└── ui/ # [3. PRESENTATION LAYER (QML UI)]
├── main.qml # Root applet coordinator
├── CompactRepresentation.qml # Panel compact representation (indicator status icon)
├── DesktopFullRepresentation.qml # Desktop widget mode (1 of 16 modular cards)
├── PanelFullRepresentation.qml # Pop-up panel mode (3-tab full sliding interface)
│
├── components/ # UI Components
│ ├── FeedTab.qml # Market Feed tab (macro metrics & leaderboards)
│ ├── FavoritesTab.qml # Watchlist tab (custom favorites coin grid)
│ ├── PortfolioTab.qml # Portfolio tab (balance, 24h PnL, ROI, allocation)
│ ├── CoinTile.qml # Watchlist coin tile (alerts and portfolio badges)
│ └── cards/ # 16 Modular Desktop Widget Cards
│ ├── CoinCard.qml # Selected Coin card (alerts and portfolio badges)
│ ├── PortfolioCard.qml # Crypto Portfolio card
│ ├── FearGreedCard.qml # Fear & Greed Index card
│ ├── MarketCapCard.qml # Global Market Cap card
│ ├── DominanceCard.qml # BTC/ETH/USDT Dominance Distribution card
│ ├── ActiveCoinsCard.qml # Active Cryptocurrencies card
│ ├── TickerCard.qml # Marquee Price Ticker card
│ ├── TopGainersCard.qml # Top 5 Gainers card
│ ├── TopLosersCard.qml # Top 5 Losers card
│ ├── TrendingCard.qml # Trending Coins card
│ ├── Volume24hCard.qml # 24h Trading Volume card
│ ├── EthBtcRatioCard.qml # ETH/BTC Ratio card
│ ├── HalvingCountdownCard.qml # BTC Halving Countdown card
│ ├── RainbowChartCard.qml # BTC Price Valuation (Rainbow Zone) card
│ ├── StablecoinDominanceCard.qml # Stablecoin Dominance card
│ └── MarketSummaryCard.qml # Market Analytics Summary card
│
└── settings/ # Configuration Pages
├── GeneralSettings.qml # General settings (target currency, interval, card type)
├── CoinsSettings.qml # Watchlist manager (search, batch add, reorder)
├── PortfolioSettings.qml # Portfolio asset manager, buy prices, privacy toggle
├── AlertsSettings.qml # Alert builder for coins, macro indicators, and portfolio
├── BackupSettings.qml # JSON backup export/import via native FileDialog & reset
└── SupportSettings.qml # Release notes, development team info, FAQ

---

## 3. Detailed Description of Core Modules

### Crypto Portfolio Module (`portfolioEngine.js` & `PortfolioTab.qml`)
- **100% Local & Private:** Holdings, quantities, and average buy prices are stored strictly on the local device in `portfolioJson`. No balances or transaction records are ever sent to remote servers or third parties.
- **Real-Time Analytics:** Calculates total portfolio valuation, 24h profit/loss (in fiat and percentage), all-time return on investment (All-Time ROI), and asset allocation distribution with minimum bar width guarantees.
- **Instant Privacy Mode:** Quick balance masking toggle (`••••••`) across both desktop cards and the pop-up panel.

### Backup & Restore Module (`BackupSettings.qml`)
- **Native FileDialog Export:** Exports a complete snapshot of all 12 configuration keys, watchlist, alert rules, and portfolio assets into a standardized `.json` file with default navigation to the Downloads folder.
- **Secure Sandbox Reading:** Uses `Plasma5Support.DataSource` with Base64 stream decoding to reliably read local backup files within the Qt 6 / KDE Plasma environment.
- **Validation & Factory Reset:** Verifies JSON structure integrity, displays asset and alert previews before restoration, and provides a safe factory reset mechanism with confirmation dialogs.

### Alerts & Notifications Module (`alertEngine.js` & `NotificationManager.qml`)
- Supports threshold monitoring for specific coins (target price, 24h High/Low breakout, ATH/ATL reach), macro market sentiment (Fear & Greed index shifts, Dominance %, BTC Halving countdown), and portfolio triggers (total balance targets, 24h gain/loss %, ROI milestones).
- Dispatches desktop notifications via the native `KNotification` workspace interface.

---
*Document updated for Crypto-hub v1.1.0 (KDE Plasma 6).*
