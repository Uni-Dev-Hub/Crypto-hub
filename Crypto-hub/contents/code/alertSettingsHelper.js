// Alert Settings Helper functions for Crypto-hub
.pragma library

function formatTriggerDescription(type, targetType) {
    if (targetType === "portfolio") {
        if (type === "portfolio_val_above") return i18n("Total Value >");
        if (type === "portfolio_val_below") return i18n("Total Value <");
        if (type === "portfolio_change_above") return i18n("24h Change >");
        if (type === "portfolio_change_below") return i18n("24h Change <");
        if (type === "portfolio_pnl_above") return i18n("All-Time ROI >");
        if (type === "portfolio_pnl_below") return i18n("All-Time ROI <");
    }

    if (type === "price_reaches") return i18n("Price reaches");
    if (type === "price_above") return i18n("Price >");
    if (type === "price_below") return i18n("Price <");
    if (type === "change_24h_above") return i18n("24h Change >");
    if (type === "change_24h_below") return i18n("24h Change <");
    if (type === "ath_reached") return i18n("Reached ATH");
    if (type === "atl_reached") return i18n("Reached ATL");
    if (type === "high_24h_breakout") return i18n("24h High Breakout");
    if (type === "low_24h_breakout") return i18n("24h Low Breakout");
    if (type === "ath_drop") return i18n("Drop from ATH >");
    if (type === "atl_rise") return i18n("Rise from ATL >");
    if (type === "fng_above") return i18n("Index >");
    if (type === "fng_below") return i18n("Index <");
    if (type === "fng_status_change") return i18n("Zone shift");
    if (type === "value_above") return i18n("Value >");
    if (type === "value_below") return i18n("Value <");
    if (type === "dom_above") return i18n("Dominance >");
    if (type === "dom_below") return i18n("Dominance <");
    if (type === "coins_above") return i18n("Count >");
    if (type === "coins_below") return i18n("Count <");
    if (type === "ratio_above") return i18n("Ratio >");
    if (type === "ratio_below") return i18n("Ratio <");
    if (type === "zone_change") return i18n("Zone shift");
    if (type === "days_left_below") return i18n("Days left <");
    return type;
}

function formatTargetValue(alertItem) {
    if (!alertItem) return "";
    var t = alertItem.type;
    var v = alertItem.targetValue;
    if (t === "ath_reached" || t === "atl_reached" || t === "high_24h_breakout" || t === "low_24h_breakout" || t === "fng_status_change" || t === "zone_change") {
        return "";
    }
    if (t === "change_24h_above" || t === "change_24h_below" || t === "ath_drop" || t === "atl_rise" || t === "dom_above" || t === "dom_below" || t === "portfolio_change_above" || t === "portfolio_change_below" || t === "portfolio_pnl_above" || t === "portfolio_pnl_below") {
        return v + "%";
    }
    if (t === "days_left_below") {
        return v + " " + i18n("days");
    }
    return v.toString();
}

function findItemIndexInModel(model, propertyName, value) {
    if (!model) return -1;
    for (var i = 0; i < model.count; i++) {
        if (model.get(i)[propertyName] === value) return i;
    }
    return -1;
}

function isAlertValidForCurrentMode(alert, isDesktop, desktopType, favoriteCoins) {
    if (!alert) return false;
    var favList = favoriteCoins ? favoriteCoins.split(",").map(function(s){return s.trim().toLowerCase();}).filter(function(s){return s!=="";}) : [];

    if (alert.targetType === "coin") {
        return favList.indexOf(alert.targetId.toLowerCase()) !== -1;
    }
    return true;
}

function formatLiveValueText(targetValue, isCoin, isPortfolio, coinIdx, favList, marketsData, globalData, fngData, domTarget, vsCur, portStats) {
    if (isPortfolio) {
        if (portStats && portStats.totalCurrentValue !== undefined) {
            return (portStats.totalCurrentValue).toLocaleString(Qt.locale(), "f", 2);
        }
        return "...";
    }

    if (isCoin) {
        if (coinIdx >= 0 && favList && coinIdx < favList.length) {
            var cId = favList[coinIdx].id;
            if (marketsData && marketsData[cId] && marketsData[cId][vsCur]) {
                return (marketsData[cId][vsCur]).toLocaleString(Qt.locale(), "f", 2);
            }
        }
        return "...";
    }

    if (targetValue === "fng") {
        return fngData ? fngData.value.toString() : "...";
    }
    if (targetValue === "market_cap") {
        if (globalData && globalData.total_market_cap && globalData.total_market_cap[vsCur]) {
            return Math.round(globalData.total_market_cap[vsCur]).toLocaleString(Qt.locale(), "f", 0);
        }
        return "...";
    }
    if (targetValue === "global_volume") {
        if (globalData && globalData.total_volume && globalData.total_volume[vsCur]) {
            return Math.round(globalData.total_volume[vsCur]).toLocaleString(Qt.locale(), "f", 0);
        }
        return "...";
    }
    if (targetValue === "dominance") {
        if (globalData && globalData.market_cap_percentage) {
            var key = (domTarget === "btc_dom") ? "btc" : "eth";
            var val = globalData.market_cap_percentage[key];
            return val ? val.toFixed(1) + "%" : "...";
        }
        return "...";
    }
    if (targetValue === "active_coins") {
        return (globalData && globalData.active_cryptocurrencies) ? globalData.active_cryptocurrencies.toString() : "...";
    }
    if (targetValue === "eth_btc_ratio") {
        if (marketsData && marketsData["bitcoin"] && marketsData["ethereum"] && marketsData["bitcoin"][vsCur] > 0) {
            var ratio = marketsData["ethereum"][vsCur] / marketsData["bitcoin"][vsCur];
            return ratio.toFixed(4);
        }
        return "...";
    }
    if (targetValue === "btc_rainbow") {
        return i18n("Zone Status");
    }
    if (targetValue === "halving") {
        return i18n("Days remaining");
    }

    return "...";
}
