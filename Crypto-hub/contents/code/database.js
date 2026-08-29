// SQLite Local Database Engine for Crypto-hub
.import QtQuick.LocalStorage 2.0 as Sql

var DB_NAME = "CryptohubDB";
var DB_VERSION = "1.0";
var DB_DESC = "Crypto-hub offline coins database";
var DB_SIZE = 10000000;

var primaryTickers = {
    "btc": "bitcoin",
    "bitcoin": "bitcoin",
    "eth": "ethereum",
    "ethereum": "ethereum",
    "doge": "dogecoin",
    "dogecoin": "dogecoin",
    "sol": "solana",
    "solana": "solana",
    "bnb": "binancecoin",
    "binancecoin": "binancecoin",
    "xrp": "ripple",
    "ripple": "ripple",
    "ada": "cardano",
    "cardano": "cardano",
    "vet": "vechain",
    "vechain": "vechain",
    "xlm": "stellar",
    "stellar": "stellar",
    "btt": "bittorrent",
    "bittorrent": "bittorrent",
    "trx": "tron",
    "tron": "tron",
    "dot": "polkadot",
    "polkadot": "polkadot",
    "avax": "avalanche-2",
    "link": "chainlink",
    "matic": "matic-network",
    "pol": "matic-network",
    "near": "near",
    "ton": "the-open-network",
    "shib": "shiba-inu",
    "ltc": "litecoin",
    "bch": "bitcoin-cash",
    "atom": "cosmos",
    "uni": "uniswap",
    "xmr": "monero",
    "etc": "ethereum-classic",
    "apt": "aptos",
    "sui": "sui",
    "pepe": "pepe",
    "kas": "kaspa",
    "icp": "internet-computer"
};

function getDatabase() {
    try {
        var db = Sql.LocalStorage.openDatabaseSync(DB_NAME, DB_VERSION, DB_DESC, DB_SIZE);
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS coins (id TEXT PRIMARY KEY, symbol TEXT, name TEXT, thumb TEXT)");
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_symbol ON coins(symbol)");
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_name ON coins(name)");
        });
        return db;
    } catch(e) {
        return null;
    }
}

function getCoinsCount() {
    var db = getDatabase();
    if (!db) return 0;
    var count = 0;
    try {
        db.readTransaction(function(tx) {
            var rs = tx.executeSql("SELECT count(*) as c FROM coins");
            if (rs.rows.length > 0) {
                count = rs.rows.item(0).c;
            }
        });
    } catch(e) {}
    return count;
}

function updateCoinsDatabase(coinsArray, callback) {
    var db = getDatabase();
    if (!db || !Array.isArray(coinsArray) || coinsArray.length === 0) {
        if (callback) callback(false);
        return;
    }

    try {
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM coins");
            for (var i = 0; i < coinsArray.length; i++) {
                var c = coinsArray[i];
                if (c && c.id && c.symbol) {
                    tx.executeSql("INSERT OR REPLACE INTO coins VALUES (?, ?, ?, ?)", [
                        c.id.toLowerCase().trim(),
                        c.symbol.toLowerCase().trim(),
                        c.name || c.symbol.toUpperCase(),
                        c.image || c.thumb || ""
                    ]);
                }
            }
        });
        if (callback) callback(true);
    } catch(e) {
        if (callback) callback(false);
    }
}

function searchCoins(query, limit) {
    if (!query || query.trim() === "") return [];
    var clean = query.trim().toLowerCase();
    var maxResults = limit || 6;
    var results = [];

    // Перевірка пріоритетної таблиці
    if (primaryTickers[clean]) {
        var pId = primaryTickers[clean];
        var info = getCoinInfo(pId);
        if (info) {
            results.push(info);
        } else {
            results.push({
                coinId: pId,
                symbol: clean.toUpperCase(),
                name: pId.charAt(0).toUpperCase() + pId.slice(1),
                thumb: ""
            });
        }
    }

    var db = getDatabase();
    if (!db) return results;

    try {
        db.readTransaction(function(tx) {
            var rs = tx.executeSql(
                "SELECT id, symbol, name, thumb FROM coins WHERE symbol = ? OR id = ? OR symbol LIKE ? OR name LIKE ? " +
                "ORDER BY " +
                "CASE WHEN LOWER(symbol) = ? THEN 1 WHEN LOWER(id) = ? THEN 2 WHEN LOWER(symbol) LIKE ? THEN 3 ELSE 4 END, " +
                "length(id) ASC LIMIT ?",
                [clean, clean, clean + "%", "%" + clean + "%", clean, clean, clean + "%", maxResults * 2]
            );

            for (var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i);
                var isDup = false;
                for (var j = 0; j < results.length; j++) {
                    if (results[j].coinId === item.id) {
                        isDup = true;
                        break;
                    }
                }
                if (!isDup) {
                    results.push({
                        coinId: item.id,
                        symbol: item.symbol.toUpperCase(),
                        name: item.name,
                        thumb: item.thumb || ""
                    });
                }
                if (results.length >= maxResults) break;
            }
        });
    } catch(e) {}

    return results;
}

function resolveTicker(ticker) {
    if (!ticker) return "";
    var clean = ticker.toLowerCase().trim();

    if (primaryTickers[clean]) {
        return primaryTickers[clean];
    }

    var db = getDatabase();
    if (!db) return clean;

    var resolved = clean;
    try {
        db.readTransaction(function(tx) {
            var rs = tx.executeSql(
                "SELECT id FROM coins WHERE symbol = ? ORDER BY length(id) ASC LIMIT 1",
                [clean]
            );
            if (rs.rows.length > 0) {
                resolved = rs.rows.item(0).id;
            }
        });
    } catch(e) {}

    return resolved;
}

function getCoinInfo(coinId) {
    if (!coinId) return null;
    var clean = coinId.toLowerCase().trim();

    var db = getDatabase();
    if (!db) return null;

    var info = null;
    try {
        db.readTransaction(function(tx) {
            var rs = tx.executeSql("SELECT id, symbol, name, thumb FROM coins WHERE id = ? LIMIT 1", [clean]);
            if (rs.rows.length > 0) {
                var item = rs.rows.item(0);
                info = {
                    coinId: item.id,
                    symbol: item.symbol.toUpperCase(),
                    name: item.name,
                    thumb: item.thumb || ""
                };
            }
        });
    } catch(e) {}

    return info;
}

function getSymbolForCoin(coinId) {
    var info = getCoinInfo(coinId);
    if (info && info.symbol) return info.symbol;
    if (primaryTickers[coinId.toLowerCase()]) return coinId.toUpperCase();
    return coinId.toUpperCase();
}

function updateCoinImage(coinId, imageUrl) {
    if (!coinId || !imageUrl) return;
    var db = getDatabase();
    if (!db) return;
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE coins SET thumb = ? WHERE id = ?", [imageUrl, coinId.toLowerCase().trim()]);
        });
    } catch(e) {}
}
