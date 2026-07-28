// alertEngine.js - Alert processing engine for Crypto-hub

function getCurrencySymbol(vs) {
    if (!vs) return "$";
    var cur = vs.toLowerCase();
    if (cur === "usd" || cur === "cad" || cur === "aud") return "$";
    if (cur === "eur") return "€";
    if (cur === "uah") return "₴";
    if (cur === "gbp") return "£";
    if (cur === "jpy" || cur === "cny") return "¥";
    if (cur === "pln") return "zł";
    if (cur === "try") return "₺";
    if (cur === "czk") return "Kč";
    if (cur === "dkk" || cur === "sek" || cur === "nok") return "kr";
    if (cur === "huf") return "Ft";
    if (cur === "ils") return "₪";
    if (cur === "inr") return "₹";
    return vs.toUpperCase() + " ";
}

function getAlertCountForCoin(alertsJson, coinId) {
    if (!alertsJson || !coinId) return 0;
    try {
        var data = JSON.parse(alertsJson);
        var alerts = data.alerts || [];
        var count = 0;
        var cleanId = coinId.trim().toLowerCase();
        for (var i = 0; i < alerts.length; i++) {
            var a = alerts[i];
            if (a.targetType === "coin" && a.targetId.toLowerCase() === cleanId) {
                if (a.frequency === "once" && a.lastTriggered > 0) {
                    continue;
                }
                count++;
            }
        }
        return count;
    } catch(e) {
        return 0;
    }
}

function cleanupOrphanedAlerts(alertsJson, isDesktop, desktopCardType, favoriteCoins) {
    if (!alertsJson) return "{\"alerts\":[]}";
    try {
        var data = JSON.parse(alertsJson);
        var alerts = data.alerts || [];
        var favList = (favoriteCoins || "").split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
        var filtered = [];
        var modified = false;

        for (var i = 0; i < alerts.length; i++) {
            var a = alerts[i];
            var valid = true;

            if (a.frequency === "once" && a.lastTriggered > 0) {
                valid = false;
            } else if (a.targetType === "coin") {
                if (favList.indexOf(a.targetId.toLowerCase()) === -1) {
                    valid = false;
                }
            } else if (isDesktop) {
                if (desktopCardType === 1 && a.targetId !== "fng") valid = false;
                else if (desktopCardType === 2 && a.targetId !== "market_cap") valid = false;
                else if (desktopCardType === 3 && (a.targetId !== "btc_dom" && a.targetId !== "eth_dom")) valid = false;
                else if (desktopCardType === 4 && a.targetId !== "active_coins") valid = false;
                else if (desktopCardType === 9 && a.targetId !== "global_volume") valid = false;
                else if (desktopCardType === 10 && a.targetId !== "eth_btc_ratio") valid = false;
                else if (desktopCardType === 11 && a.targetId !== "halving") valid = false;
                else if (desktopCardType === 12 && a.targetId !== "btc_rainbow") valid = false;
                else if (desktopCardType === 13 && a.targetId !== "stable_dom") valid = false;
                else if (desktopCardType === 0 || desktopCardType === 5 || desktopCardType === 6 || desktopCardType === 7 || desktopCardType === 8 || desktopCardType === 14) {
                    if (a.targetType === "macro") valid = false;
                }
            }

            if (valid) {
                filtered.push(a);
            } else {
                modified = true;
            }
        }

        return modified ? JSON.stringify({ "alerts": filtered }) : alertsJson;
    } catch(e) {
        return alertsJson;
    }
}

function evaluateAlerts(alertsJson, coinsData, globalData, fngData, vsCurrency, previousPrices, lastAlertState) {
    if (!alertsJson) return null;

    var data;
    try {
        data = JSON.parse(alertsJson);
    } catch(e) {
        return null;
    }

    var alerts = data.alerts || [];
    if (alerts.length === 0) return null;

    var now = Date.now();
    var cur = (vsCurrency || "usd").toLowerCase();
    var currSym = getCurrencySymbol(cur);
    var triggeredList = [];
    var modified = false;
    var state = lastAlertState || {};

    var halvingTargetDate = new Date("2028-04-17T00:00:00Z");
    var daysToHalving = Math.max(0, Math.ceil((halvingTargetDate - new Date()) / (1000 * 60 * 60 * 24)));

    for (var i = 0; i < alerts.length; i++) {
        var alert = alerts[i];

        var lastT = alert.lastTriggered || 0;
        if (alert.frequency === "once" && lastT > 0) {
            continue;
        }
        if (alert.frequency === "daily" && (now - lastT < 86400000)) {
            continue;
        }
        if (alert.frequency === "always" && (now - lastT < 60000)) {
            continue;
        }

        var isTriggered = false;
        var msgTitle = "Crypto-hub";
        var msgText = "";

        if (alert.targetType === "coin") {
            var cId = alert.targetId.toLowerCase();
            if (!coinsData || !coinsData[cId]) continue;

            var coinInfo = coinsData[cId];
            var price = coinInfo[cur] || 0;

            if (price <= 0) continue;

            var change24h = coinInfo[cur + "_24h_change"] || 0;
            var prevPrice = (previousPrices && previousPrices[cId]) ? previousPrices[cId] : price;
            var sym = (coinInfo.symbol || alert.symbol || cId).toUpperCase();

            if (alert.type === "price_reaches") {
                if ((prevPrice < alert.targetValue && price >= alert.targetValue) ||
                    (prevPrice > alert.targetValue && price <= alert.targetValue) ||
                    (prevPrice === price && Math.abs(price - alert.targetValue) / alert.targetValue < 0.001)) {
                    isTriggered = true;
                msgTitle = sym + " • " + i18n("Price Reached Target");
                msgText = i18n("%1 reached target price: %2").arg(sym).arg(currSym + price.toLocaleString());
                    }
            } else if (alert.type === "price_above") {
                if (price > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("Price Above Target");
                    msgText = i18n("%1 is above %2 (current: %3)").arg(sym).arg(currSym + alert.targetValue).arg(currSym + price.toLocaleString());
                }
            } else if (alert.type === "price_below") {
                if (price < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("Price Below Target");
                    msgText = i18n("%1 is below %2 (current: %3)").arg(sym).arg(currSym + alert.targetValue).arg(currSym + price.toLocaleString());
                }
            } else if (alert.type === "change_24h_above") {
                if (change24h > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("24h Surge");
                    msgText = i18n("%1 24h change is +%2% (> %3%)").arg(sym).arg(change24h.toFixed(2)).arg(alert.targetValue);
                }
            } else if (alert.type === "change_24h_below") {
                if (change24h < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("24h Drop");
                    msgText = i18n("%1 24h change is %2% (< %3%)").arg(sym).arg(change24h.toFixed(2)).arg(alert.targetValue);
                }
            } else if (alert.type === "ath_reached") {
                if (coinInfo.ath && price >= coinInfo.ath) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("New ATH! 🚀");
                    msgText = i18n("%1 reached a new All-Time High of %2").arg(sym).arg(currSym + price.toLocaleString());
                }
            } else if (alert.type === "atl_reached") {
                if (coinInfo.atl && price <= coinInfo.atl) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("New ATL 🚨");
                    msgText = i18n("%1 dropped to a new All-Time Low of %2").arg(sym).arg(currSym + price.toLocaleString());
                }
            } else if (alert.type === "high_24h_breakout") {
                if (coinInfo.high_24h && price >= coinInfo.high_24h) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("24h High Breakout");
                    msgText = i18n("%1 broke 24h high of %2").arg(sym).arg(currSym + coinInfo.high_24h.toLocaleString());
                }
            } else if (alert.type === "low_24h_breakout") {
                if (coinInfo.low_24h && price <= coinInfo.low_24h) {
                    isTriggered = true;
                    msgTitle = sym + " • " + i18n("24h Low Breakout");
                    msgText = i18n("%1 broke 24h low of %2").arg(sym).arg(currSym + coinInfo.low_24h.toLocaleString());
                }
            } else if (alert.type === "ath_drop") {
                if (coinInfo.ath && coinInfo.ath > 0) {
                    var dropPct = ((coinInfo.ath - price) / coinInfo.ath) * 100;
                    if (dropPct > alert.targetValue) {
                        isTriggered = true;
                        msgTitle = sym + " • " + i18n("Drop from ATH");
                        msgText = i18n("%1 is down %2% from ATH (> %3%)").arg(sym).arg(dropPct.toFixed(1)).arg(alert.targetValue);
                    }
                }
            } else if (alert.type === "atl_rise") {
                if (coinInfo.atl && coinInfo.atl > 0) {
                    var risePct = ((price - coinInfo.atl) / coinInfo.atl) * 100;
                    if (risePct > alert.targetValue) {
                        isTriggered = true;
                        msgTitle = sym + " • " + i18n("Rise from ATL");
                        msgText = i18n("%1 is up %2% from ATL (> %3%)").arg(sym).arg(risePct.toFixed(1)).arg(alert.targetValue);
                    }
                }
            }

        } else if (alert.targetType === "macro") {
            var tId = alert.targetId;

            if (tId === "fng" && fngData) {
                var fVal = parseInt(fngData.value || 0);
                var fClass = fngData.value_classification || "";

                if (alert.type === "fng_above" && fVal > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("Fear & Greed Index");
                    msgText = i18n("Fear & Greed Index is %1 (> %2)").arg(fVal).arg(alert.targetValue);
                } else if (alert.type === "fng_below" && fVal < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("Fear & Greed Index");
                    msgText = i18n("Fear & Greed Index is %1 (< %2)").arg(fVal).arg(alert.targetValue);
                } else if (alert.type === "fng_status_change") {
                    if (state.fearGreedClass && state.fearGreedClass !== fClass) {
                        isTriggered = true;
                        msgTitle = i18n("Fear & Greed Shift");
                        msgText = i18n("Market sentiment changed to %1 (%2)").arg(fClass).arg(fVal);
                    }
                    state.fearGreedClass = fClass;
                }

            } else if (tId === "market_cap" && globalData && globalData.total_market_cap) {
                var mcVal = globalData.total_market_cap[cur] || 0;
                if (alert.type === "value_above" && mcVal > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("Global Market Cap");
                    msgText = i18n("Global Market Cap is above target value");
                } else if (alert.type === "value_below" && mcVal < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("Global Market Cap");
                    msgText = i18n("Global Market Cap is below target value");
                }

            } else if (tId === "global_volume" && globalData && globalData.total_volume) {
                var volVal = globalData.total_volume[cur] || 0;
                if (alert.type === "value_above" && volVal > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("24h Total Volume");
                    msgText = i18n("24h Total Volume is above target value");
                } else if (alert.type === "value_below" && volVal < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("24h Total Volume");
                    msgText = i18n("24h Total Volume is below target value");
                }

            } else if ((tId === "btc_dom" || tId === "eth_dom" || tId === "stable_dom") && globalData && globalData.market_cap_percentage) {
                var domPct = 0;
                var domName = i18n("Dominance");
                if (tId === "btc_dom") {
                    domPct = globalData.market_cap_percentage["btc"] || 0;
                    domName = "BTC Dominance";
                } else if (tId === "eth_dom") {
                    domPct = globalData.market_cap_percentage["eth"] || 0;
                    domName = "ETH Dominance";
                } else if (tId === "stable_dom") {
                    domPct = (globalData.market_cap_percentage["usdt"] || 0) + (globalData.market_cap_percentage["usdc"] || 0);
                    domName = "Stablecoin Dominance";
                }

                if (alert.type === "dom_above" && domPct > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = domName;
                    msgText = i18n("%1 is %2% (> %3%)").arg(domName).arg(domPct.toFixed(1)).arg(alert.targetValue);
                } else if (alert.type === "dom_below" && domPct < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = domName;
                    msgText = i18n("%1 is %2% (< %3%)").arg(domName).arg(domPct.toFixed(1)).arg(alert.targetValue);
                }

            } else if (tId === "active_coins" && globalData && globalData.active_cryptocurrencies) {
                var actCount = globalData.active_cryptocurrencies;
                if (alert.type === "coins_above" && actCount > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("Active Cryptocurrencies");
                    msgText = i18n("Active Cryptocurrencies count is %1 (> %2)").arg(actCount).arg(alert.targetValue);
                } else if (alert.type === "coins_below" && actCount < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("Active Cryptocurrencies");
                    msgText = i18n("Active Cryptocurrencies count is %1 (< %2)").arg(actCount).arg(alert.targetValue);
                }

            } else if (tId === "eth_btc_ratio" && coinsData && coinsData["bitcoin"] && coinsData["ethereum"]) {
                var bPrice = coinsData["bitcoin"][cur] || 0;
                var ePrice = coinsData["ethereum"][cur] || 0;
                var ratio = bPrice > 0 ? (ePrice / bPrice) : 0;

                if (alert.type === "ratio_above" && ratio > alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("ETH/BTC Ratio");
                    msgText = i18n("ETH/BTC Ratio is %1 (> %2)").arg(ratio.toFixed(4)).arg(alert.targetValue);
                } else if (alert.type === "ratio_below" && ratio < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("ETH/BTC Ratio");
                    msgText = i18n("ETH/BTC Ratio is %1 (< %2)").arg(ratio.toFixed(4)).arg(alert.targetValue);
                }

            } else if (tId === "halving") {
                if (alert.type === "days_left_below" && daysToHalving < alert.targetValue) {
                    isTriggered = true;
                    msgTitle = i18n("BTC Halving");
                    msgText = i18n("Days remaining to BTC Halving: %1 (< %2 days)").arg(daysToHalving).arg(alert.targetValue);
                }
            }
        }

        if (isTriggered) {
            if (alert.note && alert.note.trim() !== "") {
                msgText += " • " + alert.note.trim();
            }

            triggeredList.push({
                "id": alert.id,
                "title": msgTitle,
                "text": msgText
            });

            if (alert.frequency === "once") {
                alerts.splice(i, 1);
                i--;
            } else {
                alert.lastTriggered = now;
            }
            modified = true;
        }
    }

    return {
        "triggered": triggeredList,
        "alerts": alerts,
        "modified": modified,
        "lastAlertState": state
    };
}
