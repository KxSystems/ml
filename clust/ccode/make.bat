set PATH=%OP%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
cl /LD /DKXVER=3 kdtree.def kdtree.c q.lib
cl /LD /DKXVER=3 cure.def cure.c q.lib kdtree.lib
