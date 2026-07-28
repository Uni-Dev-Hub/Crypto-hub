.import QtQuick.LocalStorage 2.0 as Sql
.import "constants.js" as Constants

var dbInstance = null;

function safeTr(s) {
    if (typeof i18n === "function") return i18n(s);
    return s;
}

function getDatabase() {
    if (dbInstance) return dbInstance;
    try {
        dbInstance = Sql.LocalStorage.openDatabaseSync("CryptoHubCoinsDB_v5", "1.0", "CoinGecko Coins & Currencies Offline DB", 10000000);
        dbInstance.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS coins (id TEXT PRIMARY KEY, symbol TEXT, name TEXT, image TEXT)");
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_symbol ON coins(symbol)");
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_name ON coins(name)");

            tx.executeSql("CREATE TABLE IF NOT EXISTS currencies (code TEXT PRIMARY KEY, name TEXT)");

            tx.executeSql("DELETE FROM currencies");
            var defaultCurrencies = [
                { code: "usd", name: safeTr(i18n("USD ($) — US Dollar")) },
                               { code: "eur", name: safeTr(i18n("EUR (€) — Euro")) },
                               { code: "uah", name: safeTr(i18n("UAH (₴) — Ukrainian Hryvnia")) },
                               { code: "gbp", name: safeTr(i18n("GBP (£) — British Pound")) },
                               { code: "jpy", name: safeTr(i18n("JPY (¥) — Japanese Yen")) },
                               { code: "cad", name: safeTr(i18n("CAD ($) — Canadian Dollar")) },
                               { code: "aud", name: safeTr(i18n("AUD ($) — Australian Dollar")) },
                               { code: "chf", name: safeTr(i18n("CHF — Swiss Franc")) },
                               { code: "pln", name: safeTr(i18n("PLN (zł) — Polish Zloty")) },
                               { code: "try", name: safeTr(i18n("TRY (₺) — Turkish Lira")) },
                               { code: "cny", name: safeTr(i18n("CNY (¥) — Chinese Yuan")) },
                               { code: "czk", name: safeTr(i18n("CZK (Kč) — Czech Koruna")) },
                               { code: "dkk", name: safeTr(i18n("DKK (kr) — Danish Krone")) },
                               { code: "sek", name: safeTr(i18n("SEK (kr) — Swedish Krona")) },
                               { code: "nok", name: safeTr(i18n("NOK (kr) — Norwegian Krone")) },
                               { code: "huf", name: safeTr(i18n("HUF (Ft) — Hungarian Forint")) },
                               { code: "ils", name: safeTr(i18n("ILS (₪) — Israeli Shekel")) },
                               { code: "inr", name: safeTr(i18n("INR (₹) — Indian Rupee")) }
            ];
            for (var i = 0; i < defaultCurrencies.length; i++) {
                tx.executeSql("INSERT INTO currencies (code, name) VALUES (?, ?)", [defaultCurrencies[i].code, defaultCurrencies[i].name]);
            }
        });
    } catch (e) {
        console.warn("CRYPTO-HUB DB Error:", e);
    }
    return dbInstance;
}

function getCurrencies() {
    var list = [];
    var db = getDatabase();
    if (!db) return list;
    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT code, name FROM currencies");
        for (var i = 0; i < rs.rows.length; i++) {
            var rawName = rs.rows.item(i).name;
            list.push({
                "value": rs.rows.item(i).code,
                      "text": safeTr(i18n(rawName))
            });
        }
    });
    return list;
}

function getCoinById(id) {
    var db = getDatabase();
    if (!db || !id) return null;
    var result = null;
    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT id, symbol, name, image FROM coins WHERE id = ? OR symbol = ? LIMIT 1", [id.toLowerCase(), id.toLowerCase()]);
        if (rs.rows.length > 0) {
            result = {
                "id": rs.rows.item(0).id,
                       "symbol": rs.rows.item(0).symbol,
                       "name": rs.rows.item(0).name,
                       "image": rs.rows.item(0).image || ""
            };
        }
    });
    return result;
}

function searchCoins(query, limit) {
    var results = [];
    var db = getDatabase();
    if (!db) return results;

    var qLower = query.toLowerCase();

    db.readTransaction(function(tx) {
        var qPref = qLower + "%";
        var rs = tx.executeSql("SELECT id, symbol, name, image FROM coins WHERE symbol = ? OR symbol LIKE ? OR id LIKE ? OR name LIKE ? LIMIT 50", [qLower, qPref, qPref, qPref]);

        var candidates = [];
        var topTierCoins = Constants.TOP_TIER_COINS;
        var penalties = Constants.SEARCH_PENALTY_KEYWORDS;

        for (var i = 0; i < rs.rows.length; i++) {
            var id = rs.rows.item(i).id;
            var symbol = rs.rows.item(i).symbol.toLowerCase();
            var name = rs.rows.item(i).name.toLowerCase();

            var score = 99;

            if (symbol === qLower) {
                score = 1;
            } else if (id === qLower) {
                score = 2;
            } else if (symbol.indexOf(qLower) === 0) {
                score = 3;
            } else if (id.indexOf(qLower) === 0) {
                score = 4;
            } else if (name.indexOf(qLower) === 0) {
                score = 5;
            } else if (symbol.indexOf(qLower) !== -1) {
                score = 6;
            } else if (id.indexOf(qLower) !== -1) {
                score = 7;
            } else {
                score = 8;
            }

            if (topTierCoins && topTierCoins[id]) {
                score -= 5.0;
            }

            var hyphenCount = id.split("-").length - 1;
            score += hyphenCount * 5.0;
            score += id.length * 0.5;

            if (penalties) {
                for (var k = 0; k < penalties.length; k++) {
                    if (id.indexOf(penalties[k]) !== -1 || name.indexOf(penalties[k]) !== -1) {
                        score += 100.0;
                        break;
                    }
                }
            }

            var words = id.split("-");
            for (var w = 0; w < words.length; w++) {
                words[w] = words[w].charAt(0).toUpperCase() + words[w].slice(1);
            }
            var displayName = words.join(" ");

            candidates.push({
                "coinId": id,
                "symbol": rs.rows.item(i).symbol,
                            "name": displayName,
                            "image": rs.rows.item(i).image || "",
                            "score": score
            });
        }

        candidates.sort(function(a, b) {
            return a.score - b.score;
        });

        results = candidates.slice(0, limit);
    });

    return results;
}

function updateCoinImage(id, imageUrl) {
    var db = getDatabase();
    if (!db) return;
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE coins SET image = ? WHERE id = ?", [imageUrl, id]);
        });
    } catch (e) {
        console.warn("DB update image error:", e);
    }
}

function resolveTicker(ticker) {
    var db = getDatabase();
    if (!db) return ticker;
    var resolved = ticker;
    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT id FROM coins WHERE symbol = ? OR id = ? LIMIT 1", [ticker.toLowerCase(), ticker.toLowerCase()]);
        if (rs.rows.length > 0) {
            resolved = rs.rows.item(0).id;
        }
    });
    return resolved;
}

function getCoinsCount() {
    var count = 0;
    var db = getDatabase();
    if (!db) return 0;
    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT COUNT(*) as c FROM coins");
        count = rs.rows.item(0).c;
    });
    return count;
}

function updateCoinsDatabase(coinsArray, callback) {
    var db = getDatabase();
    if (!db) {
        if (callback) callback(false);
        return;
    }

    try {
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM coins");
            for (var i = 0; i < coinsArray.length; i++) {
                var c = coinsArray[i];
                if (c && c.id && c.symbol && c.name) {
                    tx.executeSql("INSERT OR REPLACE INTO coins (id, symbol, name, image) VALUES (?, ?, ?, ?)", [c.id, c.symbol.toLowerCase(), c.name, c.image || ""]);
                }
            }
        });
        if (callback) callback(true);
    } catch (e) {
        console.warn("Error inserting coins to SQLite:", e);
        if (callback) callback(false);
    }
}
