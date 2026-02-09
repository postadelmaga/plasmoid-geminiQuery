// gemini.js - Funzioni per interrogare l'API di Gemini

.pragma library

function queryGemini(apiKey, model, question, callback) {
    var xhr = new XMLHttpRequest();

    // Endpoint API di Gemini
    var url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent";

    // Prepara il payload
    var payload = {
        "contents": [{
            "parts": [{
                "text": question
            }]
        }]
    };

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);

                    // Estrai il testo dalla risposta di Gemini
                    if (response.candidates &&
                        response.candidates.length > 0 &&
                        response.candidates[0].content &&
                        response.candidates[0].content.parts &&
                        response.candidates[0].content.parts.length > 0) {

                        var text = response.candidates[0].content.parts[0].text;
                        callback(true, text);
                    } else {
                        callback(false, "Invalid response from API");
                    }
                } catch (e) {
                    callback(false, "Error parsing response: " + e.message);
                }
            } else {
                var errorMsg = "Error " + xhr.status;
                try {
                    var errorJson = JSON.parse(xhr.responseText);
                    if (errorJson.error && errorJson.error.message) {
                        errorMsg += ": " + errorJson.error.message;
                    } else {
                        errorMsg += ": " + xhr.responseText;
                    }
                } catch (e) {
                    errorMsg += ": " + xhr.statusText;
                }
                callback(false, errorMsg);
            }
        }
    };

    xhr.onerror = function () {
        callback(false, "Connection error. Check your internet connection.");
    };

    xhr.ontimeout = function () {
        callback(false, "Request timeout. Try again later.");
    };

    try {
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("x-goog-api-key", apiKey);
        xhr.timeout = 30000; // 30 secondi timeout
        xhr.send(JSON.stringify(payload));
    } catch (e) {
        callback(false, "Error sending request: " + e.message);
    }
}
