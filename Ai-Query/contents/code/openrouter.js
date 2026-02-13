// openrouter.js - Functions to query the OpenRouter API

.pragma library

function queryOpenRouter(apiKey, model, question, callback) {
    var xhr = new XMLHttpRequest();

    // OpenRouter API Endpoint
    var url = "https://openrouter.ai/api/v1/chat/completions";

    // Prepare the payload
    var payload = {
        "model": model,
        "messages": [
            {
                "role": "user",
                "content": question
            }
        ]
    };

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);

                    // Extract text from OpenRouter response (OpenAI compatible)
                    if (response.choices &&
                        response.choices.length > 0 &&
                        response.choices[0].message &&
                        response.choices[0].message.content) {

                        var text = response.choices[0].message.content;
                        callback(true, text);
                    } else {
                        callback(false, "Invalid response from OpenRouter API");
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
        xhr.setRequestHeader("Authorization", "Bearer " + apiKey);
        xhr.setRequestHeader("HTTP-Referer", "https://github.com/postadelmaga/plasmoid-geminiQuery"); // Replace with actual repo URL if known
        xhr.setRequestHeader("X-Title", "Ai Query");
        xhr.timeout = 30000; // 30 seconds timeout
        xhr.send(JSON.stringify(payload));
    } catch (e) {
        callback(false, "Error sending request: " + e.message);
    }
}
