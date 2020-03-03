if defined QLIC_KC (
        pip -q install -r requirements.txt
	echo getting test.q from embedpy
        git clone https://github.com/KxSystems/ml.git
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
        q test.q -q
)
