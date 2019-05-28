cd %~dp0\..
mkdir w64
mkdir src\lib
mkdir src\include
curl -fsSL -o src\include\k.h https://github.com/KxSystems/kdb/raw/master/c/c/k.h
curl -fsSL -o src\lib\q.lib https://github.com/KxSystems/kdb/raw/master/w64/q.lib
cl /LD /DKXVER=3 /Feml.dll q.lib

