#!/bin/bash
set -e
mkdir -p wheelhouse

# If not already installed, install system build tools:
# sudo apt install python3 python3-venv python3-pip cmake ninja-build swig gcc-multilib g++-multilib

echo "Activating virtual environment"
python3 -m venv build-env
source build-env/bin/activate

echo "Installing build dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install setuptools build scikit-build-core ninja cmake conan swig cibuildwheel

# Add conan default profile to container
# Auto-detect profile if it doesn't exist
if ! conan profile list | grep -q "default"; then
    conan profile detect -f
fi

OS="$(uname)"
echo "Detected OS: $OS"
CIBW_USE_DOCKER="0"     # Build on host

if [[ "$OS" == "Linux" ]]; then
    echo "Building Linux wheels for x86_64, i686, aarch64..."
    CIBW_PLATFORM=linux \
    CIBW_ARCHS="x86_64 i686 aarch64" \
    python3 -m cibuildwheel --output-dir wheelhouse .

elif [[ "$OS" == "Darwin" ]]; then
    echo "Building macOS wheels for x86_64 and arm64..."
    CIBW_PLATFORM=macos \
    CIBW_ARCHS="x86_64 arm64" \
    python3 -m cibuildwheel --output-dir wheelhouse .
else
    echo "Unsupported OS for this script"
    exit 1
fi

echo "All wheels are in ./wheelhouse"

echo "Deactivating virtual environment"
deactivate

