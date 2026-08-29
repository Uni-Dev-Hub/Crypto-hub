.pragma library

function evaluateMarketSummary(globalData, fngData, marketCoinsData, vsCurrency, constants) {
    var res = {
        status: "Accumulation",
        icon: "⚖️",
        desc: "Market is range-bound in a low volatility consolidation phase.",
        shortDesc: "Market consolidation phase in progress.",
        isBearish: false,
        isBullish: false,
        isAltseason: false
    };

    if (!globalData || !fngData) {
        return res;
    }

    var fngVal = parseInt(fngData.value) || 50;
    var mcChange = (globalData.market_cap_change_percentage_24h_usd !== undefined) ? globalData.market_cap_change_percentage_24h_usd : 0.0;
    var btcDom = (globalData.market_cap_percentage && globalData.market_cap_percentage.btc) ? globalData.market_cap_percentage.btc : 50.0;

    // Паніка / Крах
    if (fngVal <= 25 || mcChange <= -5.0) {
        res.status = "Panic / Crash";
        res.icon = "🚨";
        res.desc = "Extreme fear in the market. Historic buying opportunity zone.";
        res.shortDesc = "Extreme market fear with high volatility and panic selling.";
        res.isBearish = true;
        return res;
    }

    // Корекція / Страх
    if (fngVal <= 45 || mcChange < 0.0) {
        res.status = "Correction / Fear";
        res.icon = "🐻";
        res.desc = "Market correction phase. Buyers show caution near support levels.";
        res.shortDesc = "Market correction phase. High caution among buyers.";
        res.isBearish = true;
        return res;
    }

    // Пік альтсезону
    if (btcDom < 45.0 && fngVal >= 60) {
        res.status = "Altseason Peak";
        res.icon = "⚡";
        res.desc = "Capital actively flowing into altcoins while BTC dominance decreases.";
        res.shortDesc = "Altseason in full swing as altcoins outperform BTC.";
        res.isAltseason = true;
        return res;
    }

    // Ралі / Бичий ринок
    if (fngVal >= 65 || mcChange >= 3.0) {
        res.status = "Rally / Bull Run";
        res.icon = "🚀";
        res.desc = "Strong bullish momentum across major assets.";
        res.shortDesc = "Strong market growth and active buying momentum.";
        res.isBullish = true;
        return res;
    }

    // Накопичення (за замовчуванням)
    res.status = "Accumulation";
    res.icon = "⚖️";
    res.desc = "Market is range-bound in a low volatility consolidation phase.";
    res.shortDesc = "Market is in an accumulation and consolidation range.";
    return res;
}
