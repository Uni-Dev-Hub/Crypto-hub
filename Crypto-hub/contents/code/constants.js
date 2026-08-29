.pragma library

// Дати календарних подій Bitcoin
var BTC_GENESIS_DATE = "2009-01-03T00:00:00Z";
var BTC_HALVING_START_DATE = "2024-04-19T00:00:00Z";
var BTC_HALVING_END_DATE = "2028-04-17T00:00:00Z";

// Словник ТОП-монет для пріоритетизації в пошуку
var TOP_TIER_COINS = {
    "bitcoin": true, "ethereum": true, "binancecoin": true, "solana": true,
    "ripple": true, "cardano": true, "dogecoin": true, "shiba-inu": true,
    "avalanche-2": true, "tron": true, "polkadot": true, "chainlink": true,
    "matic-network": true, "the-open-network": true, "near": true,
    "uniswap": true, "litecoin": true, "stellar": true, "vechain": true,
    "bittorrent": true, "filecoin": true, "ethereum-classic": true,
    "cosmos": true, "sui": true, "aptos": true, "pepe": true,
    "hedera-hashgraph": true, "monero": true, "kaspa": true, "optimism": true,
    "arbitrum": true, "render-token": true, "fantom": true, "algorand": true
};

// Ключові слова для зниження рейтингу мемкоїнів/врапнутих токенів при пошуку
var SEARCH_PENALTY_KEYWORDS = [
    "inu", "meme", "obama", "harrypotter", "pacman", "dumbledore", "yugioh", "69",
"elon", "moon", "safe", "baby", "trump", "harris", "pump", "shib", "classic",
"wormhole", "peg", "wrapped", "bridge", "synthetic", "diamond", "gold", "silver",
"pegged", "bep2", "erc20", "gravity-bridge", "portal", "any-", "all-", "shiba",
"cat", "dog"
];

// Дефолтний список валют для ініціалізації SQLite бази
var DEFAULT_CURRENCIES = [
    { "code": "usd", "name": "USD ($) — Долар США" },
    { "code": "eur", "name": "EUR (€) — Євро" },
    { "code": "uah", "name": "UAH (₴) — Українська гривня" },
    { "code": "gbp", "name": "GBP (£) — Британський фунт" },
    { "code": "jpy", "name": "JPY (¥) — Японська єна" },
    { "code": "cad", "name": "CAD ($) — Канадський долар" },
    { "code": "aud", "name": "AUD ($) — Австралійський долар" },
    { "code": "chf", "name": "CHF — Швейцарський франк" },
{ "code": "pln", "name": "PLN (zł) — Польський злотий" },
{ "code": "try", "name": "TRY (₺) — Турецька ліра" },
{ "code": "cny", "name": "CNY (¥) — Китайський юань" },
{ "code": "czk", "name": "CZK (Kč) — Чеська крона" },
{ "code": "dkk", "name": "DKK (kr) — Данська крона" },
{ "code": "sek", "name": "SEK (kr) — Шведська крона" },
{ "code": "nok", "name": "NOK (kr) — Норвезька крона" },
{ "code": "huf", "name": "HUF (Ft) — Угорський форинт" },
{ "code": "ils", "name": "ILS (₪) — Новий ізраїльський шекель" },
{ "code": "inr", "name": "INR (₹) — Индійська рупія" },
{ "code": "krw", "name": "KRW (₩) — Південнокорейська вона" },
{ "code": "mxn", "name": "MXN ($) — Мексиканське песо" },
{ "code": "nzd", "name": "NZD ($) — Новозеландський долар" },
{ "code": "sgd", "name": "SGD ($) — Сінгапурський долар" },
{ "code": "thb", "name": "THB (฿) — Таїландський бат" },
{ "code": "zar", "name": "ZAR (R) — Південноафриканський ранд" },
{ "code": "brl", "name": "BRL (R$) — Бразильський реал" },
{ "code": "hkd", "name": "HKD ($) — Гонконгський долар" },
{ "code": "idr", "name": "IDR (Rp) — Індонезійська рупія" },
{ "code": "myr", "name": "MYR (RM) — Малайзійський ринггіт" },
{ "code": "php", "name": "PHP (₱) — Філіппінське песо" },
{ "code": "pkr", "name": "PKR (₨) — Пакистанська рупія" },
{ "code": "sar", "name": "SAR (SR) — Саудівський ріал" },
{ "code": "twd", "name": "TWD (NT$) — Новий тайванський долар" },
{ "code": "vnd", "name": "VND (₫) — В'єтнамський донг" },
{ "code": "aed", "name": "AED (dh) — Дирхам ОАЕ" },
{ "code": "ars", "name": "ARS ($) — Аргентинське песо" },
{ "code": "bdt", "name": "BDT (৳) — Бангладеська така" },
{ "code": "bhd", "name": "BHD (BD) — Бахрейнський динар" },
{ "code": "bmd", "name": "BMD ($) — Бермудський долар" },
{ "code": "clp", "name": "CLP ($) — Чилійське песо" },
{ "code": "gel", "name": "GEL (₾) — Грузинський ларі" },
{ "code": "kwd", "name": "KWD (KD) — Кувейтський динар" },
{ "code": "lkr", "name": "LKR (Rs) — Шрі-Ланкійська рупія" },
{ "code": "mmk", "name": "MMK (K) — М'янманський к'ят" },
{ "code": "ngn", "name": "NGN (₦) — Нігерійська найра" },
{ "code": "vef", "name": "VEF (Bs.F) — Венесуельський болівар" },
{ "code": "btc", "name": "BTC — Біткоїн (Bitcoin)" },
{ "code": "eth", "name": "ETH — Ефіріум (Ethereum)" },
{ "code": "ltc", "name": "LTC — LiteCoin" },
{ "code": "bch", "name": "BCH — Bitcoin Cash" },
{ "code": "bnb", "name": "BNB — Binance Coin" },
{ "code": "eos", "name": "EOS — EOS" },
{ "code": "xrp", "name": "XRP — Ripple" },
{ "code": "xlm", "name": "XLM — Stellar" },
{ "code": "link", "name": "LINK — Chainlink" },
{ "code": "dot", "name": "DOT — Polkadot" },
{ "code": "yfi", "name": "YFI — Yearn.Finance" },
{ "code": "xag", "name": "XAG — Срібло (унція)" },
{ "code": "xau", "name": "XAU — Золото (унція)" },
{ "code": "bits", "name": "BITS — Біти (Bits)" },
{ "code": "sats", "name": "SATS — Сатоші (Sats)" }
];

/**
 * Отримання символу значка валюти
 */
function getCurrencySymbol(vs) {
    if (!vs) return "$";
    var cur = vs.toLowerCase();
    if (cur === "usd") return "$";
    if (cur === "eur") return "€";
    if (cur === "uah") return "₴";
    if (cur === "rub") return "₽";
    if (cur === "gbp") return "£";
    return vs.toUpperCase();
}

/**
 * Розрахунок залишку днів до Халвінгу BTC
 */
function getDaysToHalving() {
    var end = new Date(BTC_HALVING_END_DATE);
    var now = new Date();
    var diff = end - now;
    return Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
}

/**
 * Розрахунок відсотка прогресу епохи Халвінгу
 */
function getHalvingProgress() {
    var start = new Date(BTC_HALVING_START_DATE);
    var end = new Date(BTC_HALVING_END_DATE);
    var now = new Date();
    var total = end - start;
    var elapsed = now - start;
    return Math.min(100, Math.max(0, (elapsed / total) * 100));
}
