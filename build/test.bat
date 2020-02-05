if defined QLIC_KC (
        pip -q install -r requirements.txt
	echo getting test.q from embedpy
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
        q test.q fresh/tests/ util/tests/ xval/xtests/ clust/tests/ -q
)
