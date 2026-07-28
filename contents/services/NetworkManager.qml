pragma ComponentBehavior: Bound

import QtQuick
import "../code/coingecko.js" as CoinGecko
import "../code/fng.js" as FnG
import "../code/database.js" as Database

Item {
    id: networkManager

    property string favoriteCoins: ""
    property string vsCurrency: "usd"
    property int updateInterval: 5

    property var coinsData: ({})
    property var globalData: null
    property var fngData: null
    property var trendingData: []
    property var gainersData: []
    property var losersData: []
    property var marketCoinsData: []

    property bool isFetching: false
    property bool isSyncingDb: false
    property bool hasError: false
    property bool isRateLimited: false
    property int errorCountdown: 60
    property int consecutive429Count: 0
    property string lastUpdatedTime: ""
    property int coinsDataChangeCounter: 0

    property var previousPrices: ({})
    property double lastFetchCoinsTime: 0
    property double lastFetchGlobalTime: 0
    property double lastFetchFngTime: 0
    property double lastFetchTrendingTime: 0
    property double lastFetchGainersTime: 0

    property string lastFetchedCoinsString: ""
    property string lastFetchedVsCurrency: ""

    property bool isInitializing: true

    signal dataUpdated()
    signal errorOccurred(int countdown)
    signal dbSyncCompleted(bool success)

    onFavoriteCoinsChanged: {
        if (!isInitializing && !isRateLimited) configDebounceTimer.restart();
    }
    onVsCurrencyChanged: {
        if (!isInitializing && !isRateLimited) configDebounceTimer.restart();
    }
    onUpdateIntervalChanged: {
        updateTimer.interval = Math.max(1, updateInterval) * 60000;
        updateTimer.restart();
    }

    Component.onCompleted: {
        networkManager.syncOfflineDatabase();
        initTimer.start();
    }

    // Страхувальний таймер завантаження (10 сек)
    Timer {
        id: safetyTimer
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            if (networkManager.isFetching) {
                networkManager.finishRefresh();
            }
        }
    }

    Timer {
        id: initTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            networkManager.isInitializing = false;
            networkManager.refreshAllData(false);
        }
    }

    Timer {
        id: updateTimer
        interval: Math.max(1, networkManager.updateInterval) * 60000
        running: true
        repeat: true
        triggeredOnStart: false
        onTriggered: networkManager.refreshAllData(false)
    }

    Timer {
        id: configDebounceTimer
        interval: 800
        running: false
        repeat: false
        onTriggered: networkManager.refreshAllData(false)
    }

    Timer {
        id: errorCountdownTimer
        interval: 1000
        running: networkManager.hasError && networkManager.errorCountdown > 0
        repeat: true
        onTriggered: {
            networkManager.errorCountdown--;
            if (networkManager.errorCountdown === 0) {
                networkManager.hasError = false;
                networkManager.isRateLimited = false;
                networkManager.refreshAllData(false);
            }
        }
    }

    Timer {
        id: step2Timer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            if (networkManager.isRateLimited) return;
            var now = Date.now();
            if ((now - networkManager.lastFetchGlobalTime > 900000) || !networkManager.globalData) {
                try {
                    CoinGecko.fetchGlobalData(function(data) {
                        if (data) {
                            networkManager.globalData = data;
                            networkManager.lastFetchGlobalTime = now;
                        }
                        step3Timer.restart();
                    });
                } catch(e) {
                    step3Timer.restart();
                }
            } else {
                step3Timer.restart();
            }
        }
    }

    Timer {
        id: step3Timer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            if (networkManager.isRateLimited) return;
            var now = Date.now();
            if ((now - networkManager.lastFetchFngTime > 14400000) || !networkManager.fngData) {
                try {
                    FnG.fetchFearAndGreed(function(data) {
                        if (data) {
                            networkManager.fngData = data;
                            networkManager.lastFetchFngTime = now;
                        }
                        step4Timer.restart();
                    });
                } catch(e) {
                    step4Timer.restart();
                }
            } else {
                step4Timer.restart();
            }
        }
    }

    Timer {
        id: step4Timer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            if (networkManager.isRateLimited) return;
            var now = Date.now();
            if ((now - networkManager.lastFetchTrendingTime > 1800000) || networkManager.trendingData.length === 0) {
                try {
                    CoinGecko.fetchTrending(function(data) {
                        if (data) {
                            networkManager.trendingData = data;
                            networkManager.lastFetchTrendingTime = now;
                        }
                        step5Timer.restart();
                    });
                } catch(e) {
                    step5Timer.restart();
                }
            } else {
                step5Timer.restart();
            }
        }
    }

    Timer {
        id: step5Timer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            if (networkManager.isRateLimited) return;
            var now = Date.now();
            if ((now - networkManager.lastFetchGainersTime > 900000) || networkManager.gainersData.length === 0) {
                try {
                    CoinGecko.fetchGainersLosers(networkManager.vsCurrency, function(data) {
                        if (data) {
                            networkManager.gainersData = data.gainers || [];
                            networkManager.losersData = data.losers || [];
                            networkManager.marketCoinsData = data.markets || [];
                            networkManager.lastFetchGainersTime = now;
                        }
                        networkManager.finishRefresh();
                    });
                } catch(e) {
                    networkManager.finishRefresh();
                }
            } else {
                networkManager.finishRefresh();
            }
        }
    }

    function stopStepTimers() {
        safetyTimer.stop();
        step2Timer.stop();
        step3Timer.stop();
        step4Timer.stop();
        step5Timer.stop();
    }

    function syncOfflineDatabase() {
        if (Database.getCoinsCount() > 0) {
            return;
        }

        networkManager.isSyncingDb = true;

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.coingecko.com/api/v3/coins/list", true);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.timeout = 8000;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var json = JSON.parse(xhr.responseText);
                        if (Array.isArray(json) && json.length > 0) {
                            Database.updateCoinsDatabase(json, function(success) {
                                networkManager.isSyncingDb = false;
                                networkManager.dbSyncCompleted(success);
                            });
                            return;
                        }
                    } catch (e) {}
                }
                networkManager.fetchFromFallbackCdn();
            }
        };
        xhr.send();
    }

    function fetchFromFallbackCdn() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://cdn.jsdelivr.net/gh/marclopez/coingecko-coins-list@master/coins.json", true);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.timeout = 10000;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var json = JSON.parse(xhr.responseText);
                        if (Array.isArray(json) && json.length > 0) {
                            Database.updateCoinsDatabase(json, function(success) {
                                networkManager.isSyncingDb = false;
                                networkManager.dbSyncCompleted(success);
                            });
                            return;
                        }
                    } catch (e) {}
                }
                networkManager.isSyncingDb = false;
                networkManager.dbSyncCompleted(false);
            }
        };
        xhr.send();
    }

    function triggerRateLimitLockout() {
        safetyTimer.stop();
        networkManager.consecutive429Count++;
        var cooldown = Math.min(300, 60 + (networkManager.consecutive429Count * 15));
        networkManager.hasError = true;
        networkManager.isRateLimited = true;
        networkManager.isFetching = false;
        networkManager.errorCountdown = cooldown;
        networkManager.errorOccurred(cooldown);
    }

    function directFetchCoinData(idsString, targetVsCurrency, callback) {
        if (!idsString || idsString.trim() === "") {
            if (callback) callback(true);
            return;
        }

        var xhr = new XMLHttpRequest();
        var url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=" + targetVsCurrency.toLowerCase() + "&ids=" + encodeURIComponent(idsString);

        xhr.open("GET", url, true);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.timeout = 8000;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        networkManager.consecutive429Count = 0;

                        var json = JSON.parse(xhr.responseText);
                        var map = {};

                        var prevMap = {};
                        var keys = Object.keys(networkManager.coinsData);
                        for (var j = 0; j < keys.length; j++) {
                            var cId = keys[j];
                            var coinObj = networkManager.coinsData[cId];
                            if (coinObj && typeof coinObj === "object") {
                                var curKey = targetVsCurrency.toLowerCase();
                                prevMap[cId] = coinObj[curKey] !== undefined ? coinObj[curKey] : 0;

                                if (coinObj["high_24h"] !== undefined) {
                                    prevMap[cId + "_high_24h"] = coinObj["high_24h"];
                                    prevMap[cId + "_low_24h"] = coinObj["low_24h"];
                                }
                            }
                        }
                        networkManager.previousPrices = prevMap;

                        for (var i = 0; i < json.length; i++) {
                            var coin = json[i];
                            var cur = targetVsCurrency.toLowerCase();

                            var details = {};
                            details[cur] = coin.current_price || 0.0;
                            details[cur + "_24h_change"] = coin.price_change_percentage_24h || 0.0;
                            details["image"] = coin.image || "";
                            details["name"] = coin.name || "";
                            details["symbol"] = coin.symbol || "";

                            details["ath"] = coin.ath || 0.0;
                            details["atl"] = coin.atl || 0.0;
                            details["total_volume"] = coin.total_volume || 0.0;
                            details["high_24h"] = coin.high_24h || 0.0;
                            details["low_24h"] = coin.low_24h || 0.0;
                            details["market_cap_rank"] = coin.market_cap_rank || 0;

                            map[coin.id] = details;

                            Database.updateCoinImage(coin.id, coin.image || "");
                        }

                        networkManager.coinsData = map;
                        networkManager.lastFetchedCoinsString = idsString;
                        networkManager.lastFetchedVsCurrency = targetVsCurrency.toLowerCase();
                        networkManager.coinsDataChangeCounter++;

                        // Миттєво оновлюємо часову позначку
                        var d = new Date();
                        var pad = function(n) { return n < 10 ? "0" + n : n; };
                        networkManager.lastUpdatedTime = pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds());

                        // НЕГАЙНО випромінюємо сигнал для оновлення UI та перевірки сповіщень
                        networkManager.dataUpdated();

                        if (callback) callback(true);
                    } catch (e) {
                        if (callback) callback(false);
                    }
                } else {
                    if (xhr.status === 429) {
                        networkManager.triggerRateLimitLockout();
                    } else {
                        if (callback) callback(false);
                    }
                }
            }
        };

        xhr.ontimeout = function() {
            if (callback) callback(false);
        };

            xhr.onerror = function() {
                if (callback) callback(false);
            };

                xhr.send();
    }

    function refreshAllData(force) {
        if (networkManager.isRateLimited) {
            return;
        }

        networkManager.stopStepTimers();

        var now = Date.now();
        var fetchIds = [];
        if (networkManager.favoriteCoins && networkManager.favoriteCoins.trim() !== "") {
            fetchIds = networkManager.favoriteCoins.split(",").map(function(s) { return s.trim().toLowerCase(); });
        }
        var fetchIdsString = fetchIds.join(",");

        var configChanged = (networkManager.lastFetchedCoinsString !== fetchIdsString) || (networkManager.lastFetchedVsCurrency !== networkManager.vsCurrency.toLowerCase());
        var hasCoins = Object.keys(networkManager.coinsData).length > 0;
        var minIntervalMs = Math.max(50000, (networkManager.updateInterval * 60000) - 10000);

        if (!force && !configChanged && hasCoins && (now - networkManager.lastFetchCoinsTime < minIntervalMs)) {
            return;
        }

        networkManager.isFetching = true;
        safetyTimer.restart();

        if (fetchIdsString !== "") {
            networkManager.directFetchCoinData(fetchIdsString, networkManager.vsCurrency, function(success) {
                if (success) {
                    networkManager.lastFetchCoinsTime = now;
                    step2Timer.restart();
                } else if (!networkManager.isRateLimited) {
                    step2Timer.restart();
                }
            });
        } else {
            step2Timer.restart();
        }
    }

    function finishRefresh() {
        safetyTimer.stop();
        networkManager.isFetching = false;

        var d = new Date();
        var pad = function(n) { return n < 10 ? "0" + n : n; };
        networkManager.lastUpdatedTime = pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds());

        networkManager.dataUpdated();
    }
}
