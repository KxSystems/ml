:: Standalone build
curl -fsSL -o k.h https://github.com/KxSystems/kdb/raw/master/c/c/k.h     || goto :error
curl -fsSL -o q.lib https://github.com/KxSystems/kdb/raw/master/w64/q.lib || goto :error
::keep original PATH, PATH may get too long otherwise
set OP=%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"

cl /LD /DKXVER=3 /Fecure.dll /Fekdtree.dll /O2 clust/ccode/cure.c clust/ccode/kdtree.c  q.lib                                  || goto :error


mv cure.dll kdtree.dll clust/ccode


set PATH=%OP%

if "%APPVEYOR_REPO_TAG%"=="true" (
 set ML_VERSION=%APPVEYOR_REPO_TAG_NAME%
) else (
 set ML_VERSION=%APPVEYOR_REPO_BRANCH%_%APPVEYOR_REPO_COMMIT%
)
set PATH=C:\Perl;%PATH%
perl -p -i.bak -e s/TOOLKITVERSION/`\$\"%ML_VERSION%\"/g ml.q


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


