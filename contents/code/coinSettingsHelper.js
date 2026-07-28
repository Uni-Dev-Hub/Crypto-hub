.pragma library

function loadFavoritesModel(favoritesString, favoritesModel, Database) {
    favoritesModel.clear();
    if (!favoritesString || favoritesString.trim() === "") return;
    var list = favoritesString.split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });

    for (var i = 0; i < list.length; i++) {
        var id = list[i];
        var info = Database.getCoinById ? Database.getCoinById(id) : null;
        var name = id;
        var symbol = id.toUpperCase();
        var thumb = "";

        if (info) {
            name = info.name || id;
            symbol = info.symbol ? info.symbol.toUpperCase() : id.toUpperCase();
            thumb = info.image || "";
        }

        favoritesModel.append({
            "coinId": id,
            "name": name,
            "symbol": symbol,
            "thumb": thumb
        });
    }
}

function serializeFavorites(favoritesModel) {
    var arr = [];
    for (var i = 0; i < favoritesModel.count; i++) {
        arr.push(favoritesModel.get(i).coinId);
    }
    return arr.join(",");
}

function performSearch(query, searchResultsModel, Database) {
    searchResultsModel.clear();
    var clean = query.trim();
    if (clean === "" || clean.indexOf(".") !== -1) return;

    var res = Database.searchCoins(clean, 5);
    for (var i = 0; i < res.length; i++) {
        searchResultsModel.append({
            "coinId": res[i].coinId,
            "name": res[i].name,
            "symbol": res[i].symbol
        });
    }
}

function addCoinIdToList(coinId, favoritesModel, Database) {
    var cleanId = coinId.trim().toLowerCase();
    if (cleanId === "") return false;

    for (var i = 0; i < favoritesModel.count; i++) {
        if (favoritesModel.get(i).coinId === cleanId) {
            return false;
        }
    }

    var info = Database.getCoinById ? Database.getCoinById(cleanId) : null;
    var name = cleanId;
    var symbol = cleanId.toUpperCase();
    var thumb = "";

    if (info) {
        name = info.name || cleanId;
        symbol = info.symbol ? info.symbol.toUpperCase() : cleanId.toUpperCase();
        thumb = info.image || "";
    }

    favoritesModel.append({
        "coinId": cleanId,
        "name": name,
        "symbol": symbol,
        "thumb": thumb
    });
    return true;
}

function handleAddAction(inputText, favoritesModel, searchResultsModel, activeIndex, Database) {
    var clean = inputText.trim();
    if (clean === "") return false;

    if (activeIndex >= 0 && activeIndex < searchResultsModel.count) {
        var selected = searchResultsModel.get(activeIndex);
        return addCoinIdToList(selected.coinId, favoritesModel, Database);
    }

    if (clean.indexOf(".") !== -1) {
        var parts = clean.split(".").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
        var added = false;
        for (var p = 0; p < parts.length; p++) {
            var resId = Database.resolveTicker(parts[p]);
            if (addCoinIdToList(resId, favoritesModel, Database)) {
                added = true;
            }
        }
        return added;
    }

    var resolvedId = Database.resolveTicker(clean);
    return addCoinIdToList(resolvedId, favoritesModel, Database);
}
