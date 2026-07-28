function evaluateMarketSummary(globalData, fngData, marketCoinsData, vsCurrency, Constants, trFunc) {
    var tr = (typeof trFunc === "function") ? trFunc : (typeof i18n === "function" ? i18n : function(s) { return s; });

    if (!globalData || !fngData) {
        return {
            status: tr("Accumulation ⚖️"),
            desc: tr("Market is range-bound in a low volatility consolidation phase."),
            shortDesc: tr("Market consolidation phase in progress."),
            isBullish: false,
            isBearish: false,
            isAltseason: false
        };
    }

    var fngVal = parseInt(fngData.value || "50");
    var mcChange = globalData.market_cap_change_percentage_24h_usd || 0.0;
    var btcDom = (globalData.market_cap_percentage && globalData.market_cap_percentage["btc"]) ? globalData.market_cap_percentage["btc"] : 50.0;

    if (fngVal <= 25 && mcChange < -3.0) {
        return {
            status: tr("Panic / Crash 🚨"),
            desc: tr("Extreme fear in the market. Historic buying opportunity zone."),
            shortDesc: tr("Extreme market fear with high volatility and panic selling."),
            isBullish: false,
            isBearish: true,
            isAltseason: false
        };
    }

    if (fngVal >= 75 && mcChange > 2.0) {
        return {
            status: tr("Rally / Bull Run 🚀"),
            desc: tr("Strong bullish momentum across major assets."),
            shortDesc: tr("Strong market growth and active buying momentum."),
            isBullish: true,
            isBearish: false,
            isAltseason: false
        };
    }

    if (btcDom < 42.0 && fngVal > 60) {
        return {
            status: tr("Altseason Peak ⚡"),
            desc: tr("Capital actively flowing into altcoins while BTC dominance decreases."),
            shortDesc: tr("Altseason in full swing as altcoins outperform BTC."),
            isBullish: true,
            isBearish: false,
            isAltseason: true
        };
    }

    if (mcChange < -1.5 || fngVal < 40) {
        return {
            status: tr("Correction / Fear 🐻"),
            desc: tr("Market correction phase. Buyers show caution near support levels."),
            shortDesc: tr("Market correction phase. High caution among buyers."),
            isBullish: false,
            isBearish: true,
            isAltseason: false
        };
    }

    return {
        status: tr("Accumulation ⚖️"),
        desc: tr("Market is range-bound in a low volatility consolidation phase."),
        shortDesc: tr("Market is in an accumulation and consolidation range."),
        isBullish: false,
        isBearish: false,
        isAltseason: false
    };
}
