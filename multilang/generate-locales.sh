#!/bin/bash
# generate-locales.sh — generates all locales for Lychee OS
LOCALES=(
  "bn_BD.UTF-8 UTF-8"    # Bengali Bangladesh
  "bn_IN.UTF-8 UTF-8"    # Bengali India
  "en_US.UTF-8 UTF-8"    # English US
  "ar_SA.UTF-8 UTF-8"    # Arabic
  "hi_IN.UTF-8 UTF-8"    # Hindi
  "zh_CN.UTF-8 UTF-8"    # Simplified Chinese
  "ja_JP.UTF-8 UTF-8"    # Japanese
  "ko_KR.UTF-8 UTF-8"    # Korean
)

for locale in "${LOCALES[@]}"; do
    localedef -i ${locale%% *} -f UTF-8 ${locale%% *}
done
echo "Locales generated successfully."
