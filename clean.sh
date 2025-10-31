packages=(
  "apps/simon_web"
  "modules/simon"
  "packages/core"
  "packages/icons"
  "packages/l10n"
  "packages/platform_utils"
  "packages/utils"
)

for package in "${packages[@]}"
do
    (
    echo "🧹 Running flutter clean for $package ..."
    flutter clean
    echo "✅ Completed cleaning for $package"
    ) &
done

wait

echo ""
echo "🧹 Running flutter pub get..."
./get.sh
./gen.sh