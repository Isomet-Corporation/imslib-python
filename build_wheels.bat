@echo off
setlocal enabledelayedexpansion

echo Installing build dependencies...
python -m pip install --upgrade pip
python -m pip install setuptools build scikit-build-core ninja cmake conan swig

REM Check if Conan default profile exists
conan profile list | findstr /C:"default" >nul
IF ERRORLEVEL 1 (
    echo Conan default profile not found. Detecting...
    conan profile detect -f
) ELSE (
    echo Conan default profile already exists
)

mkdir wheelhouse

echo Building 64-bit wheel...
python -m build --wheel --outdir wheelhouse

echo All wheels are in .\wheelhouse
