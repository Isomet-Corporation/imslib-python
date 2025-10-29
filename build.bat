pushd X:\09014\py_test

rmdir /S /Q build

conan install . --profile default -s build_type=Release -s compiler.cppstd=17 --build=missing -of .
cd build
call generators\conanbuild.bat
cmake -S .. -B . -DCMAKE_TOOLCHAIN_FILE=generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
call generators\deactivate_conanbuild.bat
cd ..

copy python\imslib.py venv\
copy python\_imslib.pyd venv\

popd
