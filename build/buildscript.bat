if "%APPVEYOR_REPO_TAG%"=="true" (
 set AUTOML_VERSION=%APPVEYOR_REPO_TAG_NAME%
) else (
 set autoML_VERSION=%APPVEYOR_REPO_BRANCH%_%APPVEYOR_REPO_COMMIT%
)
set PATH=C:\Perl;%PATH%
perl -p -i.bak -e s/AUTOMLVERSION/`\$\"%AUTOML_VERSION%\"/g automl.q


if not defined QLIC_KC (
 goto :nokdb
)


set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%PATH%
conda config --set always_yes yes --set changeps1 no
call "build\getkdb.bat" || goto :error

exit /b 0

:error
echo failed with error 
exit /b 

:nokdb
echo no kdb
exit /b 0

