📌 1. Філософія та архітектурні принципи
Проєкт побудовано за принципом Розділення Відповідальностей (Separation of Concerns - SoC) та Багатошарової Архітектури (Layered Architecture).
Головне правило проєкту: «Логіка до логіки, інтерфейс до інтерфейсу».
Основні три шари системи:
Шар Бізнес-Логіки та Математики (contents/code/):
Чисті JavaScript-модулі (.js).
Не залежать від графічного середовища Qt Quick / QML.
Відповідають за обчислення, роботу з базой даних SQLite, математику сповіщень та парсингу API.
Сервісний Шар / Менеджери Стану (contents/services/):
Невізуальні QML-компоненти (.qml).
Інкапсулюють керування мережевими запитами (XMLHttpRequest), таймерами, кешуванням, обробкою помилок 429 Too Many Requests та системними сповіщеннями (KNotification).
Не містять жодних елементів верстки (кнопок, плашок, контурів).
Шар Відображення / Інтерфейс (contents/ui/):
100% чистий візуальний UI (.qml).
Відповідає виключно за верстку, анімації, стилі, адаптивність під розміри та події кліків користувача.
Не робить прямих HTTP-запитів і не містить складних циклів обчислень.
📂 2. Дерево каталогу проєкту
code
Text
Crypto-hub/
├── metadata.json                          # Маніфест плазмоїда KDE Plasma 6
├── ARCHITECTURE.md                        # Цей документ (Архітектурна карта)
└── contents/
    ├── config/
    │   └── config.qml                     # Декларація категорій вікна налаштувань
    │
    ├── code/                              # [1. ШАР ЧИСТОЇ ЛОГІКИ (Pure JS)]
    │   ├── database.js                    # Двигун SQLite (кеш монет, пошук, токени)
    │   ├── coingecko.js                   # Низькорівневий HTTP-клієнт CoinGecko API
    │   ├── fng.js                         # Низькорівневий HTTP-клієнт Alternative.me F&G
    │   ├── alertEngine.js                 # Математичний двигун оцінки умов сповіщень
    │   ├── marketSummary.js              # Аналітичний алгоритм оцінки стану ринку
    │   ├── constants.js                   # Глобальні константи та макро-функції (Халвінг)
    │   ├── coinSettingsHelper.js          # Хелпер для обробки списку монет та пошуку
    │   └── alertSettingsHelper.js         # Хелпер для форматування даних сповіщень
    │
    ├── services/                          # [2. СЕРВІСНИЙ ШАР (QML Managers)]
    │   ├── NetworkManager.qml            # Менеджер мережі, каскадних таймерів та кешу
    │   └── NotificationManager.qml       # Обгортка над KNotification (системні сповіщення)
    │
    └── ui/                                # [3. ШАР ВІЗУАЛЬНОГО ІНТЕРФЕЙСУ (QML UI)]
        ├── main.qml                       # Головний координатор плазмоїда (~120 рядків)
        ├── CompactRepresentation.qml      # Компактний вигляд (іконка на панелі)
        ├── DesktopFullRepresentation.qml   # Десктопний режим (відображення однієї картки)
        ├── PanelFullRepresentation.qml     # Панельний режим (повнорозмірний поп-ап)
        │
        ├── components/                    # Компоненти інтерфейсу
        │   ├── FeedTab.qml                # Вкладка «Стрічка»
        │   ├── FavoritesTab.qml           # Вкладка «Обране»
        │   ├── CoinTile.qml               # Плитка монети у сітці Обраного (із 🔔 N)
        │   └── cards/                     # 15 десктопних віджет-карток
        │       ├── CoinCard.qml           # Картка обраної монети (із 🔔 N)
        │       ├── FearGreedCard.qml      # Індекс страху та жадібності
        │       ├── MarketCapCard.qml      # Глобальна капіталізація
        │       ├── DominanceCard.qml      # Домінація BTC/ETH
        │       ├── ActiveCoinsCard.qml    # Активні криптовалюти
        │       ├── TickerCard.qml         # Бігучий рядок цін
        │       ├── TopGainersCard.qml     # Топ-5 зростання
        │       ├── TopLosersCard.qml      # Топ-5 падіння
        │       ├── TrendingCard.qml       # Зараз шукають (Тренди)
        │       ├── Volume24hCard.qml      # Об'єм торгів за 24г
        │       ├── EthBtcRatioCard.qml    # Паритет ETH/BTC
        │       ├── HalvingCountdownCard.qml # Зворотний відлік до Халвінгу
        │       ├── RainbowChartCard.qml   # Оцінка ціни BTC (Rainbow Zone)
        │       ├── StablecoinDominanceCard.qml # Домінація стейблкоїнів
        │       └── MarketSummaryCard.qml  # Аналітичний ринковий підсумок
        │
        └── settings/                      # Шаблони сторінок налаштувань
            ├── GeneralSettings.qml        # Загальні налаштування (валюта, інтервал, тип віджета)
            ├── CoinsSettings.qml          # Пошук, додавання та сортування монет
            └── AlertsSettings.qml         # Конструктор та менеджер сповіщень
🔄 3. Детальний опис модулів
🧠 Зона 1: Чиста логіка (contents/code/)
database.js: Створює та обслуговує локальну SQLite базу даних для оффлайн-пошуку монет за назвою або тікером.
alertEngine.js: Головний двигун сповіщень:
evaluateAlerts(...) — порівнює поточні ціни, ATH/ATL, хаї/лоу за 24г та макроіндикатори з цільовими значеннями користувача.
cleanupOrphanedAlerts(...) — автоматично очищує сповіщення від старих карток при зміні типу віджета на робочому столі.
getAlertCountForCoin(...) — оптимізований підрахунок активних сповіщень для монети без створення навантаження на Garbage Collector.
marketSummary.js: Генерує текстовку ринкового підсумку на основі сукупності F&G, домінації стейблів, співвідношення ETH/BTC та капіталізації.
coinSettingsHelper.js & alertSettingsHelper.js: Сервісні JS-функції для підготовки даних у вікнах налаштувань без захаращення QML-файлів.
⚙️ Зона 2: Сервіси (contents/services/)
NetworkManager.qml:
Каскадна завантажувальна система: Використовує ланцюжок крокових таймерів (step2Timer...step5Timer з інтервалом 400 мс) між запитами до CoinGecko API. Це повністю захищає від помилки 429 Too Many Requests.
Захист від Race Condition: Перед кожним новим оновленням викликає stopStepTimers(), скасовуючи попередні незавершені каскади.
Дворівневий Fallback бази SQLite: Спочатку намагається оновити список монет з офіційного CoinGecko API, а в разі неуспіху — завантажує актуальний coins.json з GitHub CDN.
Розумний стан завантаження: Розділяє isFetching (фонове оновлення без блокування UI) та isLoading (показ спінера тільки при холодному старті).
NotificationManager.qml:
Інкапсулює робочий компонент KNotification.Notification з урахуванням специфіки KDE Plasma 6 (componentName: "plasma_workspace", eventId: "warning").
Надає публічні методи sendNotification(title, body) та sendTestNotification().
🎨 Зона 3: Візуальний UI (contents/ui/)
ui/main.qml:
Вступає як точковий координатор.
Підключає NetworkManager та NotificationManager.
При отриманні сигналу NetworkManager.dataUpdated передає свіжі дані в AlertEngine, викликає системні сповіщення для спрацьованих тригерів і оновлює конфігурацію.
ui/DesktopFullRepresentation.qml:
Реалізує адаптивний масштабований контейнер (scaleFactor) для відображення однієї з 15 карток на робочому столі.
ui/PanelFullRepresentation.qml:
Двокомпонентний поп-ап з плавним слайдером перемикання між вкладками «Стрічка» та «Обране».
ui/components/cards/CoinCard.qml & CoinTile.qml:
Відображають актуальну ціну, добову зміну, логотип монети та рожево-зелену плашку з кількістю активних сповіщень 🔔 N.
⚡ 4. Потік даних (Data Flow Pipeline)
Ініціалізація:
main.qml ➔ Запускає NetworkManager.qml ➔ NetworkManager перевіряє базу SQLite (при необхідності виконує оффлайн-синхронізацію).
Завантаження ринку (Каскад):
NetworkManager.refreshAllData() ➔
Крок 1: Прямий виклик markets для обраних монет (directFetchCoinData).
Крок 2 (через 400мс): Глобальні дані ринку (fetchGlobalData).
Крок 3 (через 400мс): Індекс страху та жадібності (fetchFearAndGreed).
Крок 4 (через 400мс): Тренди (fetchTrending).
Крок 5 (через 400мс): Лідери зростання/падіння (fetchGainersLosers).
Фінал: Випромінюється сигнал dataUpdated().
Обробка сповіщень:
main.qml отримує dataUpdated() ➔ Викликає AlertEngine.evaluateAlerts(...) ➔ Якщо умова виконана, передає текст у NotificationManager.sendNotification(...) ➔ Система виводить спливаюче сповіщення Linux.
🛠️ 5. Інструкція для розробника (Як розширювати проєкт)
Як додати нову картку на робочий стіл:
Створіть новий QML-файл у contents/ui/components/cards/NewCard.qml.
Додайте назву нової картки у модель cardTypeCombo в GeneralSettings.qml.
Додайте новий case у Loader в DesktopFullRepresentation.qml.
Якщо картка підтримує сповіщення, додайте відповідний тип у AlertEngine.cleanupOrphanedAlerts() та AlertSettingsHelper.isAlertValidForCurrentMode().
Як додати новий тип тригера для сповіщень:
Додайте опис тригера у відповідну модель (coinTriggerModel або macroTriggerModel) в alertSettingsHelper.js.
Додайте блок перевірки математичної умови у функцію evaluateAlerts() всередині alertEngine.js.
Документ створено та актуалізовано для Crypto-hub v1.0.0 (KDE Plasma 6).
