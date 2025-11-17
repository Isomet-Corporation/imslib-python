@echo off
setlocal enabledelayedexpansion

echo Installing build dependencies...
python -m pip install --upgrade pip
python -m pip install build scikit-build-core ninja cmake conan swig

mkdir wheelhouse

echo Building 64-bit wheel...
python -m build --wheel --outdir wheelhouse

echo All wheels are in .\wheelhouse
pause
