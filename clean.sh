packages=(
  "apps/simon_web"
  "modules/simon"
  "packages/core"
  "packages/core_remote_data"
  "packages/core_remote_data_pb"
  "packages/design_system"
  "packages/icons"
  "packages/ide_layout"
  "packages/l10n"
  "packages/platform_utils"
  "packages/ui_file_tree"
  "packages/ui_markdown"
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