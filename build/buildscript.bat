:: Standalone build
if "%APPVEYOR_REPO_TAG%"=="true" (
 set ML_VERSION=%APPVEYOR_REPO_TAG_NAME%
) else (
 set ML_VERSION=%APPVEYOR_REPO_BRANCH%_%APPVEYOR_REPO_COMMIT%
)
set PATH=C:\Perl;%PATH%
perl -p -i.bak -e s/TOOLKITVERSION/`\$\"%ML_VERSION%\"/g ml.q

set PATH=%OP%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
cl /LD /DKXVER=3 clust/ccode/kdtree.def clust/ccode/kdtree.c clust/ccode/q.lib
cl /LD /DKXVER=3 clust/ccode/cure.def clust/ccode/cure.c clust/ccode/q.lib clust/ccode/kdtree.lib
set PATH=%OP%

(cd clust/ccode && call "make.bat")

if not defined QLIC_KC (
 goto :nokdb
)
call "build\getkdb.bat" || goto :error

set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%PATH%
mkdir embedpy
cd embedpy
echo getembedpy"latest" | q ..\build\getembedpy.q -q || goto :error
cd ..
echo p)print('embedpy runs') | q -q || goto :error
exit /b 0

:error
echo failed with error 
exit /b 

:nokdb
echo no kdb
exit /b 0


