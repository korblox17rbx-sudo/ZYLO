#!/usr/bin/env bash
# Превращает официальный исходник Telegram для Android в ZYLO
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$ROOT/Telegram" ]; then
  git clone --depth 1 https://github.com/DrKLO/Telegram.git "$ROOT/Telegram"
fi
cd "$ROOT/Telegram"

# 1. Название приложения
for f in $(find . -path "*/res/values*/strings.xml" -o -path "*/res/values*/strings_*.xml" | grep -v build/); do
  sed -i -E 's#(<string name="AppName"[^>]*>)[^<]*(</string>)#\1𝒵𝒴𝐿𝒪\2#' "$f"
  sed -i -E 's#(<string name="app_name"[^>]*>)[^<]*(</string>)#\1𝒵𝒴𝐿𝒪\2#' "$f"
done

# 2. Новое имя пакета (чтобы не конфликтовало с Telegram)
find . -name build.gradle -not -path "*/build/*" -exec sed -i -E 's#applicationId ?"?[a-zA-Z0-9_.]*"#applicationId "com.zylo.app"#' {} \;

# 3. Круглая иконка
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  for res in $(find . -type d -name "mipmap-$d" -not -path "*/build/*"); do
    cp "$ROOT/icons/mipmap-$d/ic_launcher.png" "$res/"
    cp "$ROOT/icons/mipmap-$d/ic_launcher_round.png" "$res/"
    for n in $(ls "$res" | grep -E '^(icon|ic_launcher).*\.png$'); do
      cp "$ROOT/icons/mipmap-$d/ic_launcher.png" "$res/$n"
    done
  done
done
# убрать adaptive-иконки (они перебивают PNG)
find . -type d -name "mipmap-anydpi*" -not -path "*/build/*" -exec sh -c 'rm -f "$1"/ic_launcher*.xml "$1"/icon*.xml' _ {} \;

echo "Готово: Telegram -> ZYLO"
