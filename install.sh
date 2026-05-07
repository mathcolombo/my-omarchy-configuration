#!/bin/bash

# --- VARS ---

REPO_BASE="$HOME/Work/my-omarchy-configuration"

COMPONENT_WAYBAR="waybar"

COMPONENT_WLOGOUT="wlogout"

# --- GENERICS FUNCTIONS ---

# $1 = Action (ex: install, restore)
# $2 = Component name (ex: waybar, wlogout)
manage_config() {
    local ACTION=$1
    local COMPONENT=$2

    local TARGET_DIR="$HOME/.config/$COMPONENT"
    local REPO_DIR="$REPO_BASE/$COMPONENT"
    local BACKUP_DIR="${TARGET_DIR}_bak"

    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    
    if [ "$ACTION" == "install" ]; then
        echo "🚀 Instalando $COMPONENT..."
        
        # 1. Se a pasta real existe e NÃO é um link, cria o backup simples
        if [ -d "$TARGET_DIR" ] && [ ! -L "$TARGET_DIR" ]; then
            if [ ! -d "$BACKUP_DIR" ]; then
                mv "$TARGET_DIR" "$BACKUP_DIR"
                echo "📦 Backup criado: $BACKUP_DIR"
            else
                echo "⚠️  Backup já existente em $BACKUP_DIR. Removendo pasta atual para evitar perda de dados do backup."
                rm -rf "$TARGET_DIR"
            fi
        fi

        # 2. Se for um link antigo, remove para garantir o novo apontamento
        if [ -L "$TARGET_DIR" ]; then
            rm "$TARGET_DIR"
        fi

        # 3. Cria o link simbólico da pasta do repo
        ln -s "$REPO_DIR" "$TARGET_DIR"
        echo "🔗 Vinculado: $TARGET_DIR -> $REPO_DIR"

    else
        echo "🔄 Restaurando $COMPONENT..."
        
        # 1. Remove o link simbólico
        if [ -L "$TARGET_DIR" ]; then
            rm "$TARGET_DIR"
            echo "🗑️ Link simbólico removido."
        fi

        # 2. Volta a pasta de backup para o nome original
        if [ -d "$BACKUP_DIR" ]; then
            mv "$BACKUP_DIR" "$TARGET_DIR"
            echo "⏪ Pasta de backup restaurada para $TARGET_DIR"
        else
            echo "❌ Erro: Pasta de backup ($BACKUP_DIR) não encontrada."
        fi
    fi

    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
}

# --- MENUS ---

open_components_menu() {
    local MODE=$1 # install or restore

    clear
    echo "--- MODO: ${MODE^^} ---"
    echo "1) Waybar"
    echo "2) Wlogout"
    echo "3) All"
    echo "0) Back"
    read -p "Option: " OPT

    case $OPT in
        1)
            manage_config "$MODE" "$COMPONENT_WAYBAR"
            killall -SIGUSR2 waybar
            ;;
        2)
            manage_config "$MODE" "$COMPONENT_WLOGOUT" ;;
        3) 
            manage_config "$MODE" "$COMPONENT_WAYBAR"
            killall -SIGUSR2 waybar
            manage_config "$MODE" "$COMPONENT_WLOGOUT"
            ;;
        0)
            open_action_menu ;;
    esac
    
    read -p "Pressione Enter para continuar..."
    open_components_menu "$MODE"
}

open_action_menu() {
    clear
    echo "--- DOTFILES MANAGER ---"
    echo "1) Install"
    echo "2) Restore"
    echo "0) Exit"
    read -p "Option: " ACT
    
    case $ACT in
        1) open_components_menu "install" ;;
        2) open_components_menu "restore" ;;
        0) exit 0 ;;
        *) open_action_menu ;;
    esac
}

open_action_menu
