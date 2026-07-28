// Модуль безпечної взаємодії з CoinGecko API
function fetchCoinData(coins, vsCurrency, callback) {
    if (!coins || coins.trim() === "") {
        callback({});
        return;
    }
    var xhr = new XMLHttpRequest();
    var cleanCoins = encodeURIComponent(coins.replace(/\s+/g, ""));
    var currency = encodeURIComponent(vsCurrency);
    var url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=" + currency + "&ids=" + cleanCoins;

    xhr.open("GET", url, true);
    xhr.timeout = 10000;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var json = JSON.parse(xhr.responseText);
                    var result = {};
                    for (var i = 0; i < json.length; i++) {
                        var coin = json[i];
                        var id = coin.id;
                        result[id] = {
                            "image": coin.image || ""
                        };
                        result[id][vsCurrency] = coin.current_price;
                        result[id][vsCurrency + "_24h_change"] = coin.price_change_percentage_24h || 0.0;
                    }
                    callback(result);
                    return;
                } catch (e) {
                    console.warn("Coin data parsing error:", e);
                }
            }
            callback(null);
        }
    };
    xhr.ontimeout = function() {
        callback(null);
    };
    xhr.send();
}

function fetchGlobalData(callback) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://api.coingecko.com/api/v3/global", true);
    xhr.timeout = 10000;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var json = JSON.parse(xhr.responseText);
                    if (json && json.data) {
                        callback(json.data);
                        return;
                    }
                } catch (e) {
                    console.warn("Global data parsing error:", e);
                }
            }
            callback(null);
        }
    };
    xhr.ontimeout = function() {
        callback(null);
    };
    xhr.send();
}

function fetchTrending(callback) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://api.coingecko.com/api/v3/search/trending", true);
    xhr.timeout = 10000;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var json = JSON.parse(xhr.responseText);
                    var coins = [];
                    if (json && json.coins) {
                        for (var i = 0; i < json.coins.length; i++) {
                            var item = json.coins[i].item;
                            coins.push({
                                "symbol": item.symbol || "",
                                "name": item.name || "",
                                "image": item.small || ""
                            });
                        }
                    }
                    callback(coins);
                    return;
                } catch (e) {
                    console.warn("Trending parsing error:", e);
                }
            }
            callback(null);
        }
    };
    xhr.ontimeout = function() {
        callback(null);
    };
    xhr.send();
}

function fetchGainersLosers(vsCurrency, callback) {
    var xhr = new XMLHttpRequest();
    var currency = encodeURIComponent(vsCurrency);
    // Отримуємо топ-100 для безпечного формування лідерів росту та падіння в один запит
    var url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=" + currency + "&order=market_cap_desc&per_page=100&page=1&price_change_percentage=24h";

    xhr.open("GET", url, true);
    xhr.timeout = 10000;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var json = JSON.parse(xhr.responseText);
                    var markets = [];
                    var validCoins = [];

                    for (var i = 0; i < json.length; i++) {
                        var coin = json[i];
                        markets.push({
                            "symbol": coin.symbol || "",
                            "image": coin.image || "",
                            "price": coin.current_price || 0.0,
                            "change": coin.price_change_percentage_24h || 0.0
                        });
                        if (coin.price_change_percentage_24h !== null && coin.price_change_percentage_24h !== undefined) {
                            validCoins.push(coin);
                        }
                    }

                    // Сортування для виявлення лідерів зростання
                    var sortedGainers = validCoins.slice().sort(function(a, b) {
                        return b.price_change_percentage_24h - a.price_change_percentage_24h;
                    });

                    // Сортування для виявлення лідерів падіння
                    var sortedLosers = validCoins.slice().sort(function(a, b) {
                        return a.price_change_percentage_24h - b.price_change_percentage_24h;
                    });

                    var gainers = [];
                    for (var g = 0; g < Math.min(5, sortedGainers.length); g++) {
                        gainers.push({
                            "symbol": sortedGainers[g].symbol || "",
                            "image": sortedGainers[g].image || "",
                            "change": sortedGainers[g].price_change_percentage_24h
                        });
                    }

                    var losers = [];
                    for (var l = 0; l < Math.min(5, sortedLosers.length); l++) {
                        losers.push({
                            "symbol": sortedLosers[l].symbol || "",
                            "image": sortedLosers[l].image || "",
                            "change": sortedLosers[l].price_change_percentage_24h
                        });
                    }

                    callback({
                        "gainers": gainers,
                        "losers": losers,
                        "markets": markets
                    });
                    return;
                } catch (e) {
                    console.warn("Gainers/Losers parsing error:", e);
                }
            }
            callback(null);
        }
    };
    xhr.ontimeout = function() {
        callback(null);
    };
    xhr.send();
}
