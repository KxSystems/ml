if defined QLIC_KC (
        pip -q install -r requirements.txt
	echo getting test.q from embedpy
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
        q test.q util\tests fresh\tests tests xval\tests q 
)
