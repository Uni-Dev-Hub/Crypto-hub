.pragma library

function getCurrencySymbol(vs) {
    if (!vs) return "$ ";
    var cur = vs.toLowerCase().trim();
    if (cur === "usd" || cur === "cad" || cur === "aud") return "$ ";
    if (cur === "eur") return "€ ";
    if (cur === "uah") return "₴ ";
    if (cur === "gbp") return "£ ";
    if (cur === "jpy" || cur === "cny") return "¥ ";
    if (cur === "inr") return "₹ ";
    if (cur === "try") return "₺ ";
    if (cur === "pln") return "zł ";
    if (cur === "ils") return "₪ ";
    if (cur === "czk") return "Kč ";
    if (cur === "huf") return "Ft ";
    if (cur === "dkk" || cur === "sek" || cur === "nok") return "kr ";
    if (cur === "chf") return "CHF ";
    return vs.toUpperCase() + " ";
}

function formatCurrency(val, vs, hideBalance) {
    if (hideBalance) return "••••••";
    if (val === undefined || val === null || isNaN(val)) return "...";
    var sym = getCurrencySymbol(vs);
    var num = Number(val);
    if (num === 0) return sym + "0,00";
    var absNum = Math.abs(num);
    var decimals = 2;
    if (absNum >= 1000) decimals = 2;
    else if (absNum >= 1) decimals = 2;
    else if (absNum >= 0.01) decimals = 4;
    else if (absNum >= 0.0001) decimals = 6;
    else decimals = 8;
    return sym + num.toLocaleString(Qt.locale(), "f", decimals);
}

function formatAmount(val) {
    if (val === undefined || val === null || isNaN(val)) return "0";
    var num = Number(val);
    if (num >= 1e9) {
        return (num / 1e9).toLocaleString(Qt.locale(), "f", 2) + "B";
    }
    if (num >= 1e6) {
        return (num / 1e6).toLocaleString(Qt.locale(), "f", 2) + "M";
    }
    if (num >= 1000) {
        return num.toLocaleString(Qt.locale(), "f", 2);
    }
    if (num >= 1) {
        return num.toLocaleString(Qt.locale(), "f", 4).replace(/0+$/, "").replace(/\.$/, "");
    }
    return num.toLocaleString(Qt.locale(), "f", 6).replace(/0+$/, "").replace(/\.$/, "");
}

function formatAllocation(pct) {
    if (pct === undefined || pct === null || isNaN(pct) || pct <= 0) return "0%";
    if (pct >= 99.95 && pct < 100) return "99.9%";
    if (pct === 100) return "100%";
    if (pct < 0.01) return "< 0.01%";
    if (pct < 0.1) return pct.toFixed(2) + "%";
    return pct.toFixed(1) + "%";
}

function getAssetColor(index) {
    var palette = [
        "#f7931a", // BTC Orange
        "#627eea", // ETH Blue
        "#14f195", // SOL Green
        "#e84142", // AVAX Red
        "#00aae4", // XRP Cyan
        "#f3ba2f", // BNB Yellow
        "#9b59b6", // Purple
        "#ff7675", // Coral
        "#00cec9", // Teal
        "#fdcb6e", // Sand
        "#e056fd", // Pink
        "#55efc4"  // Mint
    ];
    return palette[index % palette.length];
}

function parsePortfolio(jsonStr) {
    if (!jsonStr || jsonStr.trim() === "") {
        return { enabled: false, hideBalance: false, items: [] };
    }
    try {
        var obj = JSON.parse(jsonStr);
        return {
            enabled: !!obj.enabled,
            hideBalance: !!obj.hideBalance,
            items: Array.isArray(obj.items) ? obj.items : []
        };
    } catch(e) {
        return { enabled: false, hideBalance: false, items: [] };
    }
}

function hasCoin(portfolioJson, coinId) {
    if (!portfolioJson || !coinId) return false;
    var cleanId = coinId.toLowerCase().trim();
    var pData = parsePortfolio(portfolioJson);
    if (!pData.enabled || !Array.isArray(pData.items)) return false;
    for (var i = 0; i < pData.items.length; i++) {
        if (pData.items[i] && pData.items[i].id && pData.items[i].id.toLowerCase().trim() === cleanId) {
            return (parseFloat(pData.items[i].amount) || 0) > 0;
        }
    }
    return false;
}

function calculatePortfolio(portfolioData, coinsData, vsCurrency) {
    var items = (portfolioData && Array.isArray(portfolioData.items)) ? portfolioData.items : [];
    var cur = (vsCurrency || "usd").toLowerCase();

    var totalCurrentValue = 0;
    var totalPrev24hValue = 0;
    var totalInvestedValue = 0;
    var hasBuyPrices = false;
    var evaluatedItems = [];

    for (var i = 0; i < items.length; i++) {
        var it = items[i];
        var cId = (it.id || "").toLowerCase();
        var amount = parseFloat(it.amount) || 0;
        var buyPrice = parseFloat(it.buyPrice) || 0;

        var coinInfo = (coinsData && coinsData[cId]) ? coinsData[cId] : null;
        var currentPrice = coinInfo ? (parseFloat(coinInfo[cur]) || 0) : 0;
        var change24hPct = coinInfo ? (parseFloat(coinInfo[cur + "_24h_change"]) || 0) : 0;

        var name = coinInfo && coinInfo.name ? coinInfo.name : (cId.charAt(0).toUpperCase() + cId.slice(1));
        var symbol = coinInfo && coinInfo.symbol ? coinInfo.symbol.toUpperCase() : cId.toUpperCase();
        var image = coinInfo ? (coinInfo.image || "") : "";

        var currentValue = amount * currentPrice;
        var prevPrice = currentPrice / (1 + (change24hPct / 100));
        var prevValue = amount * prevPrice;

        var invested = (buyPrice > 0) ? (amount * buyPrice) : 0;
        var pnlVal = (buyPrice > 0 && currentPrice > 0) ? (currentValue - invested) : 0;
        var pnlPct = (buyPrice > 0 && invested > 0) ? ((currentValue - invested) / invested * 100) : 0;

        if (buyPrice > 0) {
            hasBuyPrices = true;
            totalInvestedValue += invested;
        }

        totalCurrentValue += currentValue;
        totalPrev24hValue += prevValue;

        evaluatedItems.push({
            id: cId,
            name: name,
            symbol: symbol,
            image: image,
            amount: amount,
            buyPrice: buyPrice,
            currentPrice: currentPrice,
            currentValue: currentValue,
            change24hPct: change24hPct,
            invested: invested,
            pnlVal: pnlVal,
            pnlPct: pnlPct,
            index: i
        });
    }

    var totalChange24hVal = totalCurrentValue - totalPrev24hValue;
    var totalChange24hPct = totalPrev24hValue > 0 ? (totalChange24hVal / totalPrev24hValue * 100) : 0;

    var totalPnlVal = totalCurrentValue - totalInvestedValue;
    var totalPnlPct = totalInvestedValue > 0 ? (totalPnlVal / totalInvestedValue * 100) : 0;

    for (var j = 0; j < evaluatedItems.length; j++) {
        evaluatedItems[j].allocationPct = totalCurrentValue > 0 ? (evaluatedItems[j].currentValue / totalCurrentValue * 100) : 0;
    }

    evaluatedItems.sort(function(a, b) { return b.currentValue - a.currentValue; });

    return {
        totalCurrentValue: totalCurrentValue,
        totalPrev24hValue: totalPrev24hValue,
        totalChange24hVal: totalChange24hVal,
        totalChange24hPct: totalChange24hPct,
        totalInvestedValue: totalInvestedValue,
        totalPnlVal: totalPnlVal,
        totalPnlPct: totalPnlPct,
        hasBuyPrices: hasBuyPrices,
        items: evaluatedItems,
        itemsCount: evaluatedItems.length
    };
}
