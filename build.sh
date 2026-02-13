#!/bin/bash

# Creazione del file .plasmoid
echo "Creazione di Ai-Query.plasmoid..."

zip -r Ai-Query.plasmoid Ai-Query/ \
  -x "Ai-Query/.git/*"

# Verifica che il file sia stato creato
if [ -f "Ai-Query.plasmoid" ]; then
    echo "✓ File Ai-Query.plasmoid creato con successo!"
else
    echo "✗ Errore nella creazione del file .plasmoid"
    exit 1
fi