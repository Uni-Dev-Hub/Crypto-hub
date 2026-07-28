Ось готовий, 100% чистий текст файлу `README.md`. 

Виділіть і скопіюйте вміст із блоку нижче:

```markdown
# 🪙 Crypto-hub for KDE Plasma 6

**Crypto-hub** is a modern, feature-rich cryptocurrency monitoring widget designed specifically for **KDE Plasma 6** and built according to Material You design guidelines.

![KDE Plasma 6](https://img.shields.io/badge/KDE-Plasma_6-blue.svg)
![Qt Version](https://img.shields.io/badge/Qt-6.0%2B-green.svg)
![License](https://img.shields.io/badge/License-GPL_v3-blue.svg)

---

## ✨ Key Features

- **15 Modular Desktop Cards**: Choose individual cards (Coin Price, Market Cap, Fear & Greed Index, BTC Halving, ETH/BTC Parity, BTC Rainbow Zone, etc.) or full feed view.
- **Full Feed & Favorites View**: Seamless sliding panel with market summaries, top gainers/losers, trending coins, and customizable list monitoring.
- **Smart System Notifications**: Flexible triggers for price breakouts, ATH/ATL reach, 24h highs/lows, Fear & Greed shifts, and macro indicator alerts.
- **Rate-Limit Safe**: Built-in cascade request scheduling to prevent API blockages.
- **Offline Coins Cache**: Fast search and ticker resolution powered by a local SQLite database and fallback CDN sync.

---

## 🛠️ Installation

### Option 1: Automatic via Installation Script

1. Clone this repository:
   ```bash
   git clone https://github.com/Uni-Dev-Hub/Crypto-hub.git
   cd Crypto-hub
   ```

2. Make script executable and run:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

### Option 2: Manual via kpackagetool6

To install:
```bash
kpackagetool6 -t Plasma/Applet -i .
```

To update an existing installation:
```bash
kpackagetool6 -t Plasma/Applet -u .
```

---

## ⚙️ Configuration

- **Target Currency**: Choose your preferred display currency (USD, EUR, UAH, GBP, PLN, JPY, etc.).
- **Update Interval**: From 1 minute to 1 hour.
- **Widget Mode**: Set unique desktop widget view or standard panel pop-up.
- **Feed Customization**: Toggle individual sections on/off in the pop-up view.

---

## 📐 Architecture & Technology Stack

Built using a strict Layered Architecture (Separation of Concerns):
- **Pure JS Logic** (`contents/code/`): Clean JS modules for calculations, alerts evaluation, and SQLite handling.
- **QML Services** (`contents/services/`): Non-visual state managers handling network traffic and native system notifications (`KNotification`).
- **QML Visual UI** (`contents/ui/`): 100% pure Kirigami UI with zero network or business logic pollution.

---

## 📄 License

Distributed under the GNU General Public License v3.0 or later. See `LICENSE.md` for more details.
```
