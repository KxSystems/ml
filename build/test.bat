if defined QLIC_KC (
        pip -q install -r requirements.txt
        python -m spacy download en
        q test.q 
)
