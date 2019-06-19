:: Standalone build
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

echo $(python --version)

(cd clust/ccode && call "make.bat")


