 WEB_OUTPUT_DIR=../../apps/simon_web/web
 cd packages/l10n && flutter gen-l10n &
 cd packages/core_remote_data_pb && dart run isolate_manager:generate -o $WEB_OUTPUT_DIR &
 cd packages/icons && dart run build_runner build --delete-conflicting-outputs
