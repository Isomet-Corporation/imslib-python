@echo off

if "%1"=="" goto noarg
if not exist %1\* goto noarg

rmdir /S /Q build

conan install . --profile default -s build_type=Release -s compiler.cppstd=17 --build=missing -of .
cd build
call generators\conanbuild.bat
cmake -S .. -B . -DCMAKE_TOOLCHAIN_FILE=generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
call generators\deactivate_conanbuild.bat
cd ..

copy python\imslib.py %1%\
copy python\_imslib.pyd %1%\

goto end

:noarg
echo "usage: build.bat <output folder>"
echo "e.g. build.bat .\venv"

:end
echo on
