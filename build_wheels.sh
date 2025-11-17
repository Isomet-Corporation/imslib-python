#!/bin/bash
set -e
mkdir -p wheelhouse

# If not already installed, install system build tools:
# sudo apt install python3 python3-dev python3-venv python3-pip cmake ninja-build swig gcc-multilib g++-multilib

echo "Activating virtual environment"
python3 -m venv build-env
source build-env/bin/activate

echo "Installing build dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install setuptools build scikit-build-core ninja cmake conan swig

# Add conan default profile to container
# Auto-detect profile if it doesn't exist
if ! conan profile list | grep -q "default"; then
    conan profile detect -f
fi

OS="$(uname)"
echo "Detected OS: $OS"

if [[ "$OS" == "Linux" ]]; then
    echo "Building Linux wheels for $(arch)"
    python3 -m build --wheel --outdir wheelhouse .

elif [[ "$OS" == "Darwin" ]]; then
    echo "Building macOS wheels for $(arch)"
    python3 -m build --wheel --outdir wheelhouse .
else
    echo "Unsupported OS for this script"
    exit 1
fi

echo "All wheels are in ./wheelhouse"

echo "Deactivating virtual environment"
deactivate

