#!/bin/bash
set -e
mkdir -p wheelhouse

echo "Installing build dependencies..."
python -m pip install --upgrade pip
python -m pip install build scikit-build-core ninja cmake conan swig cibuildwheel

OS="$(uname)"
echo "Detected OS: $OS"

if [[ "$OS" == "Linux" ]]; then
    echo "Building Linux wheels for x86_64, i686, aarch64..."
    CIBW_PLATFORM=linux \
    CIBW_ARCHS="x86_64 i686 aarch64" \
    python -m cibuildwheel --output-dir wheelhouse .

elif [[ "$OS" == "Darwin" ]]; then
    echo "Building macOS wheels for x86_64 and arm64..."
    CIBW_PLATFORM=macos \
    CIBW_ARCHS="x86_64 arm64" \
    python -m cibuildwheel --output-dir wheelhouse .
else
    echo "Unsupported OS for this script"
    exit 1
fi

echo "All wheels are in ./wheelhouse"
