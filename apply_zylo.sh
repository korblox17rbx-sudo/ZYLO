#!/usr/bin/env bash
set -e
export ROOT="$(cd "$(dirname "$0")" && pwd)"
[ -d "$ROOT/Telegram" ] || git clone --depth 1 https://github.com/DrKLO/Telegram.git "$ROOT/Telegram"
cd "$ROOT/Telegram"

for f in $(find . -path "*/res/values*/strings*.xml" | grep -v build/); do
  sed -i -E 's#(<string name="AppName"[^>]*>)[^<]*(</string>)#\1𝒵𝒴𝐿𝒪\2#' "$f"
  sed -i -E 's#(<string name="app_name"[^>]*>)[^<]*(</string>)#\1𝒵𝒴𝐿𝒪\2#' "$f"
done

find . -name build.gradle -not -path "*/build/*" -exec sed -i -E 's#applicationId ?"?[a-zA-Z0-9_.]*"#applicationId "com.zylo.app"#' {} \;

python3 - <<'PY'
import os, glob
from PIL import Image
src = Image.open(os.environ['ROOT'] + '/zylo_512_round.png')
sizes = {'mdpi':48,'hdpi':72,'xhdpi':96,'xxhdpi':144,'xxxhdpi':192}
for d, n in sizes.items():
    for res in glob.glob('**/mipmap-' + d, recursive=True):
        for f in glob.glob(res + '/*.png'):
            b = os.path.basename(f)
            if b.startswith(('ic_launcher', 'icon')):
                src.resize((n, n), Image.LANCZOS).save(f)
PY

find . -type d -name "mipmap-anydpi*" -not -path "*/build/*" -exec sh -c 'rm -f "$1"/ic_launcher*.xml "$1"/icon*.xml' _ {} \;

f=TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java
if [ -n "$TG_API_ID" ]; then
  sed -i -E "s#APP_ID = [0-9]+#APP_ID = $TG_API_ID#" "$f"
  sed -i -E "s#APP_HASH = \"[^\"]*\"#APP_HASH = \"$TG_API_HASH\"#" "$f"
fi

find . -name google-services.json -not -path "*/build/*" -exec sed -i -E 's#"package_name": *"[^"]*"#"package_name": "com.zylo.app"#' {} \;
echo "Готово"
