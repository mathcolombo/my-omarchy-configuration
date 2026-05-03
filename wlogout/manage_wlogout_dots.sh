#!/bin/bash

# --- VARS ---
REPO_DIR="$HOME/Work/my-omarchy-configuration/wlogout"
TARGET_DIR="$HOME/.config/wlogout"
FILES=("layout" "style.css")

# --- FUNCTIONS ---

install_configs() {
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    echo "🚀 Iniciando a instalação das configurações..."

    mkdir -p "$TARGET_DIR"

    for FILE in "${FILES[@]}"; do
        if [ -f "$TARGET_DIR/$FILE" ] && [ ! -L "$TARGET_DIR/$FILE" ]; then
            if [ ! -f "$TARGET_DIR/$FILE.bak" ]; then
                echo "📦 Criando backup de: $FILE"
                cp "$TARGET_DIR/$FILE" "$TARGET_DIR/$FILE.bak"
            fi
        fi

        echo "🔗 Vinculando: $FILE"
        ln -sf "$REPO_DIR/$FILE" "$TARGET_DIR/$FILE"
    done
    echo "✅ Pronto! Wlogout atualizado."
}

restore_defaults() {
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    echo "🔄 Restaurando configurações originais..."

    for FILE in "${FILES[@]}"; do
        if [ -f "$TARGET_DIR/$FILE.bak" ]; then
            echo "⏪ Restaurando: $FILE"
            rm "$TARGET_DIR/$FILE"
            mv "$TARGET_DIR/$FILE.bak" "$TARGET_DIR/$FILE"
        else
            echo "⚠️ Nenhum backup encontrado para $FILE"
        fi
    done
    echo "✅ Padrões restaurados."
}

# --- MENU ---
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "Selecione uma opção:"
echo "1) Instalar (Linkar arquivos do Repo)"
echo "2) Restaurar (Voltar para o Padrão/Backup)"
read -p "Opção: " OPT

case $OPT in
    1) install_configs ;;
    2) restore_defaults ;;
    *) echo "Opção inválida." ;;
esac

# --- WAYBAR RESTART ---
#killall -SIGUSR2 waybar