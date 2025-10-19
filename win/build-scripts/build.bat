@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
cmake --build ./build --target "%1_All" --config RelWithDebInfo --parallel 6 -j 6