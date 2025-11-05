#!/bin/sh

# Define variables
IMAGE_NAME="nowis-android-builder"
CONTAINER_NAME="temp_nowis_android_builder"
DOCKERFILE_PATH="server/nowis/Dockerfile.android"
CONTEXT_PATH="server/nowis"
OUTPUT_BINARY="nowis-android"
OUTPUT_DIR="." # Current directory

echo "Starting Docker build process for Android ARM64..."

# 1. Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" -f "${DOCKERFILE_PATH}" "${CONTEXT_PATH}"
if [ $? -ne 0 ]; then
    echo "Docker image build failed."
    exit 1
fi
echo "Docker image built successfully."

# 2. Create a temporary container to access the build artifacts
echo "Creating temporary container: ${CONTAINER_NAME}..."
docker create --name "${CONTAINER_NAME}" "${IMAGE_NAME}"
if [ $? -ne 0 ]; then
    echo "Failed to create temporary container."
    exit 1
fi
echo "Temporary container created."

# 3. Copy the compiled binary out of the container to your local machine
echo "Copying compiled binary '${OUTPUT_BINARY}' from container..."
docker cp "${CONTAINER_NAME}:/app/bin/${OUTPUT_BINARY}" "${OUTPUT_DIR}/"
if [ $? -ne 0 ]; then
    echo "Failed to copy binary from container."
    docker rm "${CONTAINER_NAME}" # Attempt to clean up
    exit 1
fi
echo "Binary copied to ${OUTPUT_DIR}/${OUTPUT_BINARY}"

# 4. Remove the temporary container
echo "Removing temporary container: ${CONTAINER_NAME}..."
docker rm "${CONTAINER_NAME}"
if [ $? -ne 0 ]; then
    echo "Failed to remove temporary container. Please remove it manually: 'docker rm ${CONTAINER_NAME}'"
    exit 1
fi
echo "Temporary container removed."

echo "Android ARM64 executable '${OUTPUT_BINARY}' successfully built and available in your current directory."
echo "You can now push this binary to your Android ARM64 device."