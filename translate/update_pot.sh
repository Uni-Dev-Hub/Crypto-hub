#!/usr/bin/env bash
# Скрипт збору усіх текстових рядків i18n з QML та JS у шаблон template.pot

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

mkdir -p translate/po

echo "🔍 Збір усіх текстових рядків i18n з QML та JS..."

xgettext \
    --from-code=UTF-8 \
    --language=C++ \
    --keyword=i18n \
    --keyword=i18nc:1c,2 \
    --keyword=i18np:1,2 \
    --output=translate/template.pot \
    $(find contents -type f \( -name "*.qml" -o -name "*.js" \))

echo "✅ Шаблон створено: translate/template.pot"

if [ -f translate/po/uk.po ]; then
    echo "🔄 Оновлення translate/po/uk.po..."
    msgmerge --update translate/po/uk.po translate/template.pot
fi
