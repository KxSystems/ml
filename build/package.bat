7z a nlp_windows-%NLP_VERSION%.zip *.q requirements.txt  LICENSE README.md
appveyor PushArtifact nlp_windows-%NLP_VERSION%.zip
exit /b 0

