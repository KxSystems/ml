if defined QLIC_KC (
        pip -q install -r requirements.txt
	git clone https://github.com/KxSystems/ml.git
	git clone https://github.com/KxSystems/nlp.git
	pip -q install -r nlp/requirements.txt
	python -m spacy download en
	pip install gensim
	pip install sobol-seq
	pip install keras
	pip install tensorflow
	pip install torch
	pip install theano
	echo getting test.q from embedpy
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
	env:PYTHONHASHSEED=0
        call "code\tests\testFiles.bat"

)
