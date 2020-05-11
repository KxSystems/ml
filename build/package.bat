7z a automl_windows-%AUTOML_VERSION%.zip *.q requirements.txt code/ LICENSE README.md
appveyor PushArtifact automl_windows-%AUTOML_VERSION%.zip
exit /b 0
