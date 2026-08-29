// Модуль отримання індексу страху та жадібності
function fetchFearAndGreed(callback) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://api.alternative.me/fng/?limit=1", true);
    xhr.timeout = 10000;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var json = JSON.parse(xhr.responseText);
                    if (json && json.data && json.data.length > 0) {
                        callback(json.data[0]);
                        return;
                    }
                } catch (e) {
                    console.warn("Fear and Greed parsing error:", e);
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
