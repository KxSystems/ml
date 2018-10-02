# Machine-learning toolkit
## Introduction
This repository contains two distinct sections. First is an implementation of the FRESH (FeatuRe Extraction and Scalable Hypothesis testing) algorithm for use in the extraction of features from time series data and the reduction in the number of features through statistical testing. The second section is a number of scipts containing functions which are relevant for use in a variety of machine learning applications.

The contents of both sections are explained in greater depth within the [FRESH](https://code.kx.com/q/ml/toolkit/fresh) and [Utilities](https://code.kx.com/q/ml/toolkit/utils) documentation.

## Requirements

- embedPy

The python packages required to allow successful exectution of all functions within the Machine-learning toolkit can be installed via:

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```

*Running of the notebook examples contained within the FRESH and util sections of this library will require the installation of JupyterQ however this is not a dependancy for the running of functions at an individual level

## Installation

Place the library file in `$QHOME` and load into a q instance using `ml/ml.q`

This will load all the functions contained within the `.ml` namespace the  
```q
q)\l ml/ml.q
q).ml.loadfile`:fresh/init.q
```

## Documentation

Documentation for all sections of the Machine-learning toolkit are available [here](https://code.kx.com/q/ml/toolkit/).

## Status

The Machine-learning toolkit is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

