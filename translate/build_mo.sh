#!/usr/bin/env bash
# Скрипт компіляції локалей суто всередині каталогу проєкту

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

for po_file in translate/po/*.po; do
    if [ -f "$po_file" ]; then
        lang=$(basename "$po_file" .po)

        target_dir="contents/locale/${lang}/LC_MESSAGES"
        mkdir -p "$target_dir"
        msgfmt -o "${target_dir}/plasma_applet_org.kde.cryptohub.mo" "$po_file"

        echo "✅ Локальний переклад [${lang}] збережено у ${target_dir}"
    fi
done
