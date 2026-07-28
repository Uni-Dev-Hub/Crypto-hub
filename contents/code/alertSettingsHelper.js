function isAlertValidForCurrentMode(alert, isDesktop, desktopType, favs) {
    if (!alert) return false;
    if (!isDesktop) return true;

    if (alert.targetType === "coin") {
        if (desktopType !== 0) return false;
        var cleanFavs = (favs || "").split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
        if (cleanFavs.length === 0) return false;
        return alert.targetId.toLowerCase() === cleanFavs[0];
    }

    if (alert.targetType === "macro") {
        if (desktopType === 1) return alert.targetId === "fng";
        if (desktopType === 2) return alert.targetId === "market_cap";
        if (desktopType === 3) return alert.targetId === "btc_dom" || alert.targetId === "eth_dom";
        if (desktopType === 4) return alert.targetId === "active_coins";
        if (desktopType === 9) return alert.targetId === "global_volume";
        if (desktopType === 10) return alert.targetId === "eth_btc_ratio";
        if (desktopType === 11) return alert.targetId === "halving";
        if (desktopType === 12) return alert.targetId === "btc_rainbow";
        if (desktopType === 13) return alert.targetId === "stable_dom";
        return false;
    }
    return false;
}

function safeTr(str) {
    if (typeof i18n === "function") {
        return i18n(str);
    }
    return str;
}

function buildTargetComboModel(isDesktop, desktopType, showMini, showAnalysis, showHalving) {
    var list = [];
    if (isDesktop) {
        if (desktopType === 0) list.push({ value: "coin", text: safeTr(i18n("Selected Coin")) });
        else if (desktopType === 1) list.push({ value: "fng", text: safeTr(i18n("Fear & Greed Index")) });
        else if (desktopType === 2) list.push({ value: "market_cap", text: safeTr(i18n("Global Market Cap")) });
        else if (desktopType === 3) list.push({ value: "dominance", text: safeTr(i18n("Dominance (BTC / ETH)")) });
        else if (desktopType === 4) list.push({ value: "active_coins", text: safeTr(i18n("Active Cryptocurrencies")) });
        else if (desktopType === 9) list.push({ value: "global_volume", text: safeTr(i18n("24h Total Volume")) });
        else if (desktopType === 10) list.push({ value: "eth_btc_ratio", text: safeTr(i18n("ETH/BTC Ratio")) });
        else if (desktopType === 11) list.push({ value: "halving", text: safeTr(i18n("BTC Halving Countdown")) });
        else if (desktopType === 12) list.push({ value: "btc_rainbow", text: safeTr(i18n("BTC Rainbow Zone")) });
        else if (desktopType === 13) list.push({ value: "stable_dom", text: safeTr(i18n("Stablecoin Dominance")) });
    } else {
        list.push({ value: "coin", text: safeTr(i18n("Selected Coin")) });
        if (showMini) {
            list.push({ value: "fng", text: safeTr(i18n("Fear & Greed Index")) });
            list.push({ value: "market_cap", text: safeTr(i18n("Global Market Cap")) });
            list.push({ value: "global_volume", text: safeTr(i18n("24h Total Volume")) });
            list.push({ value: "dominance", text: safeTr(i18n("Dominance (BTC / ETH)")) });
            list.push({ value: "stable_dom", text: safeTr(i18n("Stablecoin Dominance")) });
            list.push({ value: "active_coins", text: safeTr(i18n("Active Cryptocurrencies")) });
        }
        if (showAnalysis) {
            list.push({ value: "eth_btc_ratio", text: safeTr(i18n("ETH/BTC Ratio")) });
            list.push({ value: "btc_rainbow", text: safeTr(i18n("BTC Rainbow Zone")) });
        }
        if (showHalving) {
            list.push({ value: "halving", text: safeTr(i18n("BTC Halving Countdown")) });
        }
    }
    return list;
}

function getTriggerModelForId(targetId) {
    if (targetId === "coin") {
        return [
            { value: "price_reaches", text: safeTr(i18n("Price reaches")) },
            { value: "price_above", text: safeTr(i18n("Price above")) },
            { value: "price_below", text: safeTr(i18n("Price below")) },
            { value: "change_24h_above", text: safeTr(i18n("24h Change above (%)")) },
            { value: "change_24h_below", text: safeTr(i18n("24h Change below (%)")) },
            { value: "ath_reached", text: safeTr(i18n("ATH Reached")) },
            { value: "atl_reached", text: safeTr(i18n("ATL Reached")) },
            { value: "high_24h_breakout", text: safeTr(i18n("24h High Breakout")) },
            { value: "low_24h_breakout", text: safeTr(i18n("24h Low Breakout")) },
            { value: "ath_drop", text: safeTr(i18n("Drop from ATH (%) >")) },
            { value: "atl_rise", text: safeTr(i18n("Rise from ATL (%) >")) }
        ];
    } else if (targetId === "fng") {
        return [
            { value: "fng_above", text: safeTr(i18n("Index above")) },
            { value: "fng_below", text: safeTr(i18n("Index below")) },
            { value: "fng_status_change", text: safeTr(i18n("Zone status changes")) }
        ];
    } else if (targetId === "market_cap" || targetId === "global_volume") {
        return [
            { value: "value_above", text: safeTr(i18n("Value above")) },
            { value: "value_below", text: safeTr(i18n("Value below")) }
        ];
    } else if (targetId === "dominance" || targetId === "btc_dom" || targetId === "eth_dom" || targetId === "stable_dom") {
        return [
            { value: "dom_above", text: safeTr(i18n("Dominance above (%)")) },
            { value: "dom_below", text: safeTr(i18n("Dominance below (%)")) }
        ];
    } else if (targetId === "active_coins") {
        return [
            { value: "coins_above", text: safeTr(i18n("Count above")) },
            { value: "coins_below", text: safeTr(i18n("Count below")) }
        ];
    } else if (targetId === "eth_btc_ratio") {
        return [
            { value: "ratio_above", text: safeTr(i18n("Ratio above")) },
            { value: "ratio_below", text: safeTr(i18n("Ratio below")) }
        ];
    } else if (targetId === "btc_rainbow") {
        return [
            { value: "zone_change", text: safeTr(i18n("Valuation Zone changes")) }
        ];
    } else if (targetId === "halving") {
        return [
            { value: "days_left_below", text: safeTr(i18n("Days remaining less than")) }
        ];
    }
    return [];
}

function getFormattedFavorites(favString, Database) {
    if (!favString || favString.trim() === "") return [];
    var list = favString.split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
    var res = [];
    for (var i = 0; i < list.length; i++) {
        var id = list[i];
        var sym = Database ? Database.getSymbolForCoin(id) : id.toUpperCase();
        res.push({ "id": id, "symbol": sym ? sym.toUpperCase() : id.toUpperCase() });
    }
    return res;
}

function findItemIndexInModel(model, propName, val) {
    if (!model) return -1;
    for (var i = 0; i < model.count; i++) {
        if (model.get(i)[propName] === val) return i;
    }
    return -1;
}

function formatTriggerDescription(type, targetType, targetValue) {
    if (type === "price_reaches") return safeTr(i18n("Price reaches"));
    if (type === "price_above") return safeTr(i18n("Price >"));
    if (type === "price_below") return safeTr(i18n("Price <"));
    if (type === "change_24h_above") return safeTr(i18n("24h Change >"));
    if (type === "change_24h_below") return safeTr(i18n("24h Change <"));
    if (type === "ath_reached") return safeTr(i18n("Reached ATH"));
    if (type === "atl_reached") return safeTr(i18n("Reached ATL"));
    if (type === "high_24h_breakout") return safeTr(i18n("24h High Breakout"));
    if (type === "low_24h_breakout") return safeTr(i18n("24h Low Breakout"));
    if (type === "ath_drop") return safeTr(i18n("Drop from ATH >"));
    if (type === "atl_rise") return safeTr(i18n("Rise from ATL >"));
    if (type === "fng_above") return safeTr(i18n("Index >"));
    if (type === "fng_below") return safeTr(i18n("Index <"));
    if (type === "fng_status_change") return safeTr(i18n("Zone shift"));
    if (type === "value_above") return safeTr(i18n("Value >"));
    if (type === "value_below") return safeTr(i18n("Value <"));
    if (type === "dom_above") return safeTr(i18n("Dominance >"));
    if (type === "dom_below") return safeTr(i18n("Dominance <"));
    if (type === "coins_above") return safeTr(i18n("Count >"));
    if (type === "coins_below") return safeTr(i18n("Count <"));
    if (type === "ratio_above") return safeTr(i18n("Ratio >"));
    if (type === "ratio_below") return safeTr(i18n("Ratio <"));
    if (type === "zone_change") return safeTr(i18n("Zone shift"));
    if (type === "days_left_below") return safeTr(i18n("Days left <"));
    return type;
}

function formatTargetValue(alertItem) {
    if (!alertItem) return "";
    var t = alertItem.type;
    if (t === "ath_reached" || t === "atl_reached" || t === "high_24h_breakout" || t === "low_24h_breakout" || t === "fng_status_change" || t === "zone_change") {
        return "";
    }
    var val = alertItem.targetValue;
    if (t === "change_24h_above" || t === "change_24h_below" || t === "ath_drop" || t === "atl_rise" || t === "dom_above" || t === "dom_below") {
        return val + "%";
    }
    if (t === "days_left_below") {
        return val + " d.";
    }
    return val.toString();
}

function formatLiveValueText(targetVal, isSelectedCoin, coinIdx, favList, marketsData, globalData, fngData, domSelectedVal, vsCurrency) {
    if (targetVal === "none") return "";
    if (isSelectedCoin) {
        if (coinIdx >= 0 && coinIdx < favList.length) {
            var cObj = favList[coinIdx];
            if (marketsData && marketsData[cObj.id] && marketsData[cObj.id][vsCurrency]) {
                return vsCurrency.toUpperCase() + " " + marketsData[cObj.id][vsCurrency].toLocaleString(Qt.locale(), "f", 2);
            }
        }
        return "...";
    }

    if (targetVal === "fng") {
        return fngData ? fngData.value.toString() : "...";
    } else if (targetVal === "market_cap") {
        if (globalData && globalData.total_market_cap && globalData.total_market_cap[vsCurrency]) {
            return vsCurrency.toUpperCase() + " " + Math.round(globalData.total_market_cap[vsCurrency]).toLocaleString(Qt.locale(), "f", 0);
        }
        return "...";
    } else if (targetVal === "global_volume") {
        if (globalData && globalData.total_volume && globalData.total_volume[vsCurrency]) {
            return vsCurrency.toUpperCase() + " " + Math.round(globalData.total_volume[vsCurrency]).toLocaleString(Qt.locale(), "f", 0);
        }
        return "...";
    } else if (targetVal === "dominance") {
        if (globalData && globalData.market_cap_percentage) {
            var key = (domSelectedVal === "btc_dom") ? "btc" : "eth";
            var pct = globalData.market_cap_percentage[key] || 0.0;
            return pct.toFixed(1) + "%";
        }
        return "...";
    } else if (targetVal === "stable_dom") {
        if (globalData && globalData.market_cap_percentage) {
            var usdt = globalData.market_cap_percentage["usdt"] || 0.0;
            var usdc = globalData.market_cap_percentage["usdc"] || 0.0;
            return (usdt + usdc).toFixed(1) + "%";
        }
        return "...";
    } else if (targetVal === "active_coins") {
        return (globalData && globalData.active_cryptocurrencies !== undefined) ? globalData.active_cryptocurrencies.toString() : "...";
    } else if (targetVal === "eth_btc_ratio") {
        if (marketsData && marketsData["bitcoin"] && marketsData["ethereum"]) {
            var bp = marketsData["bitcoin"][vsCurrency] || 0;
            var ep = marketsData["ethereum"][vsCurrency] || 0;
            if (bp > 0) return (ep / bp).toFixed(4);
        }
        return "...";
    } else if (targetVal === "btc_rainbow") {
        if (marketsData && marketsData["bitcoin"] && marketsData["bitcoin"][vsCurrency]) {
            var p = marketsData["bitcoin"][vsCurrency];
            var genesis = new Date("2009-01-03T00:00:00Z");
            var days = Math.max(1, (new Date() - genesis) / (1000 * 60 * 60 * 24));
            var offset = (Math.log(p) / Math.LN10) - (5.84 * (Math.log(days) / Math.LN10) - 17.015);
            if (offset < -0.3) return safeTr(i18n("Fire Sale 📉"));
            if (offset < -0.1) return safeTr(i18n("Buy! 🟢"));
            if (offset < 0.1) return safeTr(i18n("Accumulate 🟡"));
            if (offset < 0.3) return safeTr(i18n("Is this FOMO? 🟠"));
            return safeTr(i18n("Maximum Bubble! 🚨"));
        }
        return "...";
    } else if (targetVal === "halving") {
        var halvingDate = new Date("2028-04-17T00:00:00Z");
        var diffMs = halvingDate - new Date();
        var dLeft = Math.max(0, Math.ceil(diffMs / (1000 * 60 * 60 * 24)));
        return dLeft + " d.";
    }
    return "";
}
