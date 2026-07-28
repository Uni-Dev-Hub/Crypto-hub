#!/bin/bash

# Автоматичний перехід у директорію скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🪙 Встановлення / Оновлення віджета Crypto-hub для KDE Plasma 6..."

# 1. Автоматична компіляція всіх локалей (.po -> .mo)
echo "🌐 Компіляція перекладів..."
if [ -d "translate/po" ]; then
    for po_file in translate/po/*.po; do
        if [ -f "$po_file" ]; then
            lang=$(basename "$po_file" .po)
            mkdir -p "contents/locale/$lang/LC_MESSAGES"
            msgfmt "$po_file" -o "contents/locale/$lang/LC_MESSAGES/plasma_applet_org.kde.cryptohub.mo"
            echo "  ✓ Скомпільовано мову: $lang"
        fi
    done
else
    echo "⚠️ Папку translate/po не знайдено, пропускаємо компіляцію мов."
fi

# 2. Встановлення або оновлення віджета у системі Plasma 6
echo "📦 Інсталяція плазмоїда через kpackagetool6..."
if kpackagetool6 -t Plasma/Applet -i . 2>/dev/null; then
    echo "✅ Crypto-hub успішно встановлено!"
else
    echo "🔄 Оновлення існуючого віджета Crypto-hub..."
    kpackagetool6 -t Plasma/Applet -u .
    echo "✅ Crypto-hub успішно оновлено!"
fi

echo "🎉 Готово! Тепер ви можете додати Crypto-hub на панель або робочий стіл."
