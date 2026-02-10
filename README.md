# Gemini Query

**Gemini Query** is a lightweight KDE Plasma 6 widget that brings the intelligence of Google Gemini directly to your desktop. Designed for daily insights, motivational quotes, or quick technical facts, it performs recurring queries and keeps the results beautifully rendered on your panel or desktop.

![image showing main widget face](./examples/main.png) 

## ✨ Features

- **Latest Model Support**: Select from a wide range of Gemini models, including the cutting-edge **Gemini 2.5** and **Gemini 3 Preview**.
- **Rich Markdown Rendering**: Responses are rendered with full Markdown support, including headers, bold text, lists, and links.
- **Google Search Grounding**: Toggle **Google Search** in settings to allow Gemini to provide up-to-date information by searching the web.
- **Customizable Experience**: 
    - Set a custom title for the widget (e.g. "Quote of the Day").
    - Hide or show the original question to keep the interface clean.
- **Responsive Design**: Clean, modern interface that fits perfectly with the Breeze theme.

## 💾 Smart Caching System

Gemini Query features an efficient local caching system designed to save your API quota and ensure the widget feels instant:
- **Daily Persistance**: Your response is saved locally and survives system restarts.
- **Automatic Invalidation**: The cache is automatically cleared and a fresh query is triggered whenever you change your question or the selected model in the settings.
- **Manual Control**: Easily clear the cache at any time from the configuration window.

## 🚀 Installation

1. Download [last release](https://github.com/postadelmaga/plasmoid-geminiQuery/releases/latest/download/org.kde.plasma.geminiquery.plasmoid) and run `kpackagetool6 -t Plasma/Applet -i org.kde.plasma.geminiquery.plasmoid`
2. Obtain a free API Key from [Google AI Studio](https://aistudio.google.com/app/apikey).
3. Configure your desired question and select your preferred model.
4. Enjoy your AI-powered desktop!

![image showing configuration window](./examples/config.png)

---

**Developed with 🤖 Antigravity by Gemini.**
This project was implemented entirely using agentic AI technology to ensure high-quality code and modern design standards.
