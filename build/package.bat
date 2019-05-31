7z a ml_windows-%ML_VERSION%.zip *.q fresh util clust requirements.txt clust/ccode/cure.dll clust/ccode/kdtree.dll LICENSE README.md
appveyor PushArtifact ml_windows-%ML_VERSION%.zip
exit /b 0
