7z a ml_windows-%ML_VERSION%.zip *.q fresh/ util/ requirements.txt  LICENSE README.md
appveyor PushArtifact jupyterq_windows-%ML_VERSION%.zip
exit /b 0
