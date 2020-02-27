@echo off
echo.

:: Standalone build
curl -fsSL -o q.lib https://github.com/KxSystems/kdb/raw/master/w64/q.lib    || goto :error

::keep original PATH, PATH may get too long otherwise
set OP=%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
cl /LD /DKXVER=3 ../src/kdtree.def ../src/kdtree.c q.lib
cl /LD /DKXVER=3 ../src/cure.def ../src/cure.c q.lib kdtree.lib
set PATH=%OP%

move *.dll %QHOME%\w64

del *.exp *.lib *.obj

exit /b 0
:error
exit /b %errorLevel%
