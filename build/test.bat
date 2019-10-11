if defined QLIC_KC (
        apt-get install libhunspell-dev
        pip -q install -r requirements.txt
        python -m spacy download en
        echo getting test.q from embedpy
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
 	q test.q -q
)
