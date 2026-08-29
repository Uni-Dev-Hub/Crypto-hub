.pragma library

function getAlertCountForCoin(alertsJson, coinId) {
    if (!alertsJson || !coinId) return 0;
    try {
        var data = JSON.parse(alertsJson);
        var list = data.alerts || [];
        var count = 0;
        var clean = coinId.toLowerCase().trim();
        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            if (item.targetType === "coin" && item.targetId && item.targetId.toLowerCase().trim() === clean) {
                count++;
            }
        }
        return count;
    } catch(e) {
        return 0;
    }
}

function cleanupOrphanedAlerts(alertsJson, isDesktop, desktopCardType, favoriteCoinsString) {
    if (!alertsJson) return "{\"alerts\":[]}";
    var data;
    try {
        data = JSON.parse(alertsJson);
    } catch (e) {
        return "{\"alerts\":[]}";
    }

    var list = data.alerts || [];
    var filtered = [];
    var modified = false;

    var favCoins = [];
    if (favoriteCoinsString && favoriteCoinsString.trim() !== "") {
        favCoins = favoriteCoinsString.split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
    }

    for (var i = 0; i < list.length; i++) {
        var alert = list[i];
        var keep = true;

        if (alert.targetType === "coin") {
            var cId = (alert.targetId || "").toLowerCase();
            if (isDesktop && desktopCardType === 0) {
                if (favCoins.length === 0 || favCoins[0] !== cId) keep = false;
            } else if (!isDesktop) {
                if (favCoins.indexOf(cId) === -1) keep = false;
            } else {
                keep = false;
            }
        } else if (alert.targetType === "portfolio") {
            if (isDesktop && desktopCardType !== 15) keep = false;
        } else if (alert.targetType === "macro") {
            if (isDesktop) {
                if (desktopCardType === 1 && alert.targetId !== "fng") keep = false;
                else if (desktopCardType === 2 && alert.targetId !== "market_cap") keep = false;
                else if (desktopCardType === 3 && alert.targetId !== "btc_dom" && alert.targetId !== "eth_dom") keep = false;
                else if (desktopCardType === 4 && alert.targetId !== "active_coins") keep = false;
                else if (desktopCardType === 9 && alert.targetId !== "global_volume") keep = false;
                else if (desktopCardType === 10 && alert.targetId !== "eth_btc_ratio") keep = false;
                else if (desktopCardType === 11 && alert.targetId !== "halving") keep = false;
                else if (desktopCardType === 12 && alert.targetId !== "btc_rainbow") keep = false;
                else if (desktopCardType === 13 && alert.targetId !== "stable_dom") keep = false;
                else if (desktopCardType === 0 || desktopCardType === 5 || desktopCardType === 6 || desktopCardType === 7 || desktopCardType === 8 || desktopCardType === 14) keep = false;
            }
        }

        if (keep) {
            filtered.push(alert);
        } else {
            modified = true;
        }
    }

    if (modified) {
        return JSON.stringify({ "alerts": filtered });
    }
    return alertsJson;
}

function evaluateAlerts(alertsJson, coinsData, globalData, fngData, vsCurrency, previousPrices, lastAlertState, portfolioStats, portfolioData) {
    if (!alertsJson) return null;
    var data;
    try {
        data = JSON.parse(alertsJson);
    } catch(e) {
        return null;
    }

    var list = data.alerts || [];
    if (list.length === 0) return null;

    var triggeredList = [];
    var updatedList = [];
    var modified = false;
    var now = Date.now();
    var cur = (vsCurrency || "usd").toLowerCase();

    var nextAlertState = {
        marketCap: lastAlertState ? lastAlertState.marketCap : 0,
        fearGreedClass: lastAlertState ? lastAlertState.fearGreedClass : "",
        fngValue: lastAlertState ? lastAlertState.fngValue : 50,
        btcRainbowZone: lastAlertState ? lastAlertState.btcRainbowZone : ""
    };

    for (var i = 0; i < list.length; i++) {
        var alert = list[i];
        var isTriggered = false;
        var title = "";
        var text = "";

        var isCooldownOk = true;
        if (alert.frequency === "daily") {
            var ONE_DAY_MS = 24 * 60 * 60 * 1000;
            if (alert.lastTriggered && (now - alert.lastTriggered < ONE_DAY_MS)) {
                isCooldownOk = false;
            }
        }

        if (isCooldownOk) {
            // 1. Сповіщення для монет
            if (alert.targetType === "coin" && coinsData) {
                var cId = alert.targetId.toLowerCase();
                var coin = coinsData[cId];
                if (coin) {
                    var price = coin[cur] || 0.0;
                    var change24h = coin[cur + "_24h_change"] || 0.0;
                    var prevPrice = (previousPrices && previousPrices[cId]) ? previousPrices[cId] : price;
                    var symbol = coin.symbol ? coin.symbol.toUpperCase() : cId.toUpperCase();
                    var ath = coin.ath || 0.0;
                    var atl = coin.atl || 0.0;
                    var high24 = coin.high_24h || 0.0;
                    var low24 = coin.low_24h || 0.0;

                    if (alert.type === "price_reaches") {
                        var minP = Math.min(prevPrice, price);
                        var maxP = Math.max(prevPrice, price);
                        if (alert.targetValue >= minP && alert.targetValue <= maxP) {
                            isTriggered = true;
                            title = i18n("Price Reached Target");
                            text = i18n("%1 reached target price: %2").arg(symbol).arg(price);
                        }
                    } else if (alert.type === "price_above") {
                        if (price > alert.targetValue && prevPrice <= alert.targetValue) {
                            isTriggered = true;
                            title = i18n("Price Above Target");
                            text = i18n("%1 is above %2 (current: %3)").arg(symbol).arg(alert.targetValue).arg(price);
                        }
                    } else if (alert.type === "price_below") {
                        if (price < alert.targetValue && prevPrice >= alert.targetValue) {
                            isTriggered = true;
                            title = i18n("Price Below Target");
                            text = i18n("%1 is below %2 (current: %3)").arg(symbol).arg(alert.targetValue).arg(price);
                        }
                    } else if (alert.type === "change_24h_above") {
                        if (change24h > alert.targetValue) {
                            isTriggered = true;
                            title = i18n("24h Surge");
                            text = i18n("%1 24h change is +%2% (> %3%)").arg(symbol).arg(change24h.toFixed(2)).arg(alert.targetValue);
                        }
                    } else if (alert.type === "change_24h_below") {
                        if (change24h < alert.targetValue) {
                            isTriggered = true;
                            title = i18n("24h Drop");
                            text = i18n("%1 24h change is %2% (< %3%)").arg(symbol).arg(change24h.toFixed(2)).arg(alert.targetValue);
                        }
                    } else if (alert.type === "ath_reached") {
                        if (ath > 0 && price >= ath && prevPrice < ath) {
                            isTriggered = true;
                            title = i18n("New ATH! 🚀");
                            text = i18n("%1 reached a new All-Time High of %2").arg(symbol).arg(price);
                        }
                    } else if (alert.type === "atl_reached") {
                        if (atl > 0 && price <= atl && prevPrice > atl) {
                            isTriggered = true;
                            title = i18n("New ATL 🚨");
                            text = i18n("%1 dropped to a new All-Time Low of %2").arg(symbol).arg(price);
                        }
                    } else if (alert.type === "high_24h_breakout") {
                        var prevHigh = (previousPrices && previousPrices[cId + "_high_24h"]) ? previousPrices[cId + "_high_24h"] : high24;
                        if (prevHigh > 0 && price > prevHigh && prevPrice <= prevHigh) {
                            isTriggered = true;
                            title = i18n("24h High Breakout");
                            text = i18n("%1 broke 24h high of %2").arg(symbol).arg(prevHigh);
                        }
                    } else if (alert.type === "low_24h_breakout") {
                        var prevLow = (previousPrices && previousPrices[cId + "_low_24h"]) ? previousPrices[cId + "_low_24h"] : low24;
                        if (prevLow > 0 && price < prevLow && prevPrice >= prevLow) {
                            isTriggered = true;
                            title = i18n("24h Low Breakout");
                            text = i18n("%1 broke 24h low of %2").arg(symbol).arg(prevLow);
                        }
                    } else if (alert.type === "ath_drop") {
                        if (ath > 0 && price < ath) {
                            var dropPct = ((ath - price) / ath) * 100;
                            if (dropPct > alert.targetValue) {
                                isTriggered = true;
                                title = i18n("Drop from ATH");
                                text = i18n("%1 is down %2% from ATH (> %3%)").arg(symbol).arg(dropPct.toFixed(1)).arg(alert.targetValue);
                            }
                        }
                    } else if (alert.type === "atl_rise") {
                        if (atl > 0 && price > atl) {
                            var risePct = ((price - atl) / atl) * 100;
                            if (risePct > alert.targetValue) {
                                isTriggered = true;
                                title = i18n("Rise from ATL");
                                text = i18n("%1 is up %2% from ATL (> %3%)").arg(symbol).arg(risePct.toFixed(1)).arg(alert.targetValue);
                            }
                        }
                    }
                }
            }

            // 2. Сповіщення для портфелю
            else if (alert.targetType === "portfolio" && portfolioStats && portfolioStats.itemsCount > 0) {
                var totalVal = portfolioStats.totalCurrentValue || 0;
                var change24 = portfolioStats.totalChange24hPct || 0;
                var pnlPct = portfolioStats.totalPnlPct || 0;

                if (alert.type === "portfolio_val_above") {
                    if (totalVal > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Portfolio Target Reached 💼");
                        text = i18n("Total portfolio balance is %1 (> %2)").arg(totalVal.toFixed(2)).arg(alert.targetValue);
                    }
                } else if (alert.type === "portfolio_val_below") {
                    if (totalVal < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Portfolio Value Drop ⚠️");
                        text = i18n("Total portfolio balance dropped below %1 (current: %2)").arg(alert.targetValue).arg(totalVal.toFixed(2));
                    }
                } else if (alert.type === "portfolio_change_above") {
                    if (change24 > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Portfolio 24h Surge 🚀");
                        text = i18n("Portfolio 24h change is +%1% (> %2%)").arg(change24.toFixed(2)).arg(alert.targetValue);
                    }
                } else if (alert.type === "portfolio_change_below") {
                    if (change24 < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Portfolio 24h Drop 🚨");
                        text = i18n("Portfolio 24h change is %1% (< %2%)").arg(change24.toFixed(2)).arg(alert.targetValue);
                    }
                } else if (alert.type === "portfolio_pnl_above" && portfolioStats.hasBuyPrices) {
                    if (pnlPct > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Portfolio ROI Target 🎯");
                        text = i18n("Portfolio ROI reached +%1% (> %2%)").arg(pnlPct.toFixed(1)).arg(alert.targetValue);
                    }
                } else if (alert.type === "portfolio_pnl_below" && portfolioStats.hasBuyPrices) {
                    if (pnlPct < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Portfolio ROI Drop 📉");
                        text = i18n("Portfolio ROI dropped to %1% (< %2%)").arg(pnlPct.toFixed(1)).arg(alert.targetValue);
                    }
                }
            }

            // 3. Сповіщення для макропоказників
            else if (alert.targetType === "macro") {
                if (alert.targetId === "fng" && fngData) {
                    var fngVal = parseInt(fngData.value);
                    var fngClass = fngData.value_classification;
                    if (alert.type === "fng_above" && fngVal > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Fear & Greed Index");
                        text = i18n("Fear & Greed Index is %1 (> %2)").arg(fngVal).arg(alert.targetValue);
                    } else if (alert.type === "fng_below" && fngVal < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Fear & Greed Index");
                        text = i18n("Fear & Greed Index is %1 (< %2)").arg(fngVal).arg(alert.targetValue);
                    } else if (alert.type === "fng_status_change") {
                        if (nextAlertState.fearGreedClass && nextAlertState.fearGreedClass !== "" && nextAlertState.fearGreedClass !== fngClass) {
                            isTriggered = true;
                            title = i18n("Fear & Greed Shift");
                            text = i18n("Market sentiment changed to %1 (%2)").arg(fngClass).arg(fngVal);
                        }
                    }
                    nextAlertState.fearGreedClass = fngClass;
                    nextAlertState.fngValue = fngVal;
                } else if (alert.targetId === "market_cap" && globalData && globalData.total_market_cap) {
                    var mc = globalData.total_market_cap[cur] || 0;
                    if (alert.type === "value_above" && mc > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Global Market Cap");
                        text = i18n("Global Market Cap is above target value");
                    } else if (alert.type === "value_below" && mc < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Global Market Cap");
                        text = i18n("Global Market Cap is below target value");
                    }
                } else if (alert.targetId === "global_volume" && globalData && globalData.total_volume) {
                    var vol = globalData.total_volume[cur] || 0;
                    if (alert.type === "value_above" && vol > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("24h Total Volume");
                        text = i18n("24h Total Volume is above target value");
                    } else if (alert.type === "value_below" && vol < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("24h Total Volume");
                        text = i18n("24h Total Volume is below target value");
                    }
                } else if ((alert.targetId === "btc_dom" || alert.targetId === "eth_dom" || alert.targetId === "stable_dom") && globalData && globalData.market_cap_percentage) {
                    var domVal = 0;
                    var domName = alert.symbol || i18n("Dominance");
                    if (alert.targetId === "btc_dom") domVal = globalData.market_cap_percentage["btc"] || 0;
                    else if (alert.targetId === "eth_dom") domVal = globalData.market_cap_percentage["eth"] || 0;
                    else if (alert.targetId === "stable_dom") {
                        var usdt = globalData.market_cap_percentage["usdt"] || 0;
                        var usdc = globalData.market_cap_percentage["usdc"] || 0;
                        domVal = usdt + usdc;
                    }

                    if (alert.type === "dom_above" && domVal > alert.targetValue) {
                        isTriggered = true;
                        title = domName;
                        text = i18n("%1 is %2% (> %3%)").arg(domName).arg(domVal.toFixed(2)).arg(alert.targetValue);
                    } else if (alert.type === "dom_below" && domVal < alert.targetValue) {
                        isTriggered = true;
                        title = domName;
                        text = i18n("%1 is %2% (< %3%)").arg(domName).arg(domVal.toFixed(2)).arg(alert.targetValue);
                    }
                } else if (alert.targetId === "active_coins" && globalData && globalData.active_cryptocurrencies) {
                    var coinsCount = globalData.active_cryptocurrencies;
                    if (alert.type === "coins_above" && coinsCount > alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Active Cryptocurrencies");
                        text = i18n("Active Cryptocurrencies count is %1 (> %2)").arg(coinsCount).arg(alert.targetValue);
                    } else if (alert.type === "coins_below" && coinsCount < alert.targetValue) {
                        isTriggered = true;
                        title = i18n("Active Cryptocurrencies");
                        text = i18n("Active Cryptocurrencies count is %1 (< %2)").arg(coinsCount).arg(alert.targetValue);
                    }
                } else if (alert.targetId === "eth_btc_ratio" && coinsData) {
                    var btcObj = coinsData["bitcoin"];
                    var ethObj = coinsData["ethereum"];
                    if (btcObj && ethObj && btcObj[cur] > 0 && ethObj[cur] > 0) {
                        var ratio = ethObj[cur] / btcObj[cur];
                        if (alert.type === "ratio_above" && ratio > alert.targetValue) {
                            isTriggered = true;
                            title = i18n("ETH/BTC Ratio");
                            text = i18n("ETH/BTC Ratio is %1 (> %2)").arg(ratio.toFixed(4)).arg(alert.targetValue);
                        } else if (alert.type === "ratio_below" && ratio < alert.targetValue) {
                            isTriggered = true;
                            title = i18n("ETH/BTC Ratio");
                            text = i18n("ETH/BTC Ratio is %1 (< %2)").arg(ratio.toFixed(4)).arg(alert.targetValue);
                        }
                    }
                }
            }
        }

        if (isTriggered) {
            triggeredList.push({ "id": alert.id, "title": title, "text": text });
            if (alert.frequency === "once") {
                modified = true;
            } else {
                alert.lastTriggered = now;
                updatedList.push(alert);
                modified = true;
            }
        } else {
            updatedList.push(alert);
        }
    }

    return {
        "triggered": triggeredList,
        "alerts": updatedList,
        "modified": modified,
        "lastAlertState": nextAlertState
    };
}
