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

REM Sync version from C++ header
REM Set path to Python executable (adjust if needed)
set PYTHON_EXE=python

REM Path to the C++ header
set HEADER_FILE=ims-lib\include\LibVersion.h

REM Run the Python script
%PYTHON_EXE% sync_version.py %HEADER_FILE%

REM Check for errors
IF ERRORLEVEL 1 (
    echo Failed to sync version!
    exit /b 1
)        

echo Building 64-bit wheel...
python -m build --wheel --outdir wheelhouse

echo All wheels are in .\wheelhouse
