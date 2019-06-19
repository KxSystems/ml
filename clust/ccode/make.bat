set PATH=%OP%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
call ":\Program Files (x86)\Windows Kits\10\Include\"
cl /LD /DKXVER=3 kdtree.def kdtree.c q.lib
cl /LD /DKXVER=3 cure.def cure.c q.lib kdtree.lib
set PATH=%OP%
