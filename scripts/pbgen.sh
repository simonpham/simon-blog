# Generate a .pb.go file from a .proto file in each services/*/protobuf directory.
# This script is intended to be run from the root of the repository. Not use GOPATH.
# Usage: ./gpb.sh

# Find all .proto files in protobuf/* directories.
echo "🔎 Finding .proto files"
PROTO_FILES=$(find protobuf -name '*.proto')

echo "👉 Found total count of .proto files: ${#PROTO_FILES[@]}"

echo "🧹 Cleaning up generated files"
rm -rf generated/dart/protobuf
rm -rf generated/go/protobuf
mkdir -p generated/dart
mkdir -p generated/go

# Generate .pb.go files for each .proto file.
echo "🪄 Generating .pb.go files"
for PROTO_FILE in $PROTO_FILES; do
  echo "Generating $PROTO_FILE"
  protoc ./"$PROTO_FILE" --proto_path=protobuf/nowis --proto_path=protobuf/auth --go_out=generated/go --go-grpc_out=generated/go --dart_out=grpc:generated/dart
done

# Copy all generated files to the packages/core_remote_data_pb/lib/generated/protobuf directory.
echo "🚚 Replacing generated files to packages/core_remote_data_pb/lib/generated/protobuf"
rm -rf packages/core_remote_data_pb/lib/generated/protobuf
mkdir -p packages/core_remote_data_pb/lib/generated/protobuf
cp -R generated/dart/* packages/core_remote_data_pb/lib/generated/protobuf/

echo "🚚 Replacing generated files to server/nowis/protobuf"
rm -rf server/nowis/protobuf
mkdir -p server/nowis/protobuf
cp -R generated/go/protobuf/* server/nowis/protobuf/generated

echo "🧹 Cleaning up generated files"
rm -rf generated

echo "✅ Done."
