---
hero: <i class="fa fa-share-alt"></i> Machine learning
author: Conor McCarthy
date: October 2018
keywords: machine learning, ml, feature extraction, feature selection, time series forecasting, utilities, interpolation, filling, statistics
---

# Machine-learning toolkit


The machine learning toolkit herein referred to as the ML-Toolkit contains a number of libraries and scripts. These have been produced with the aim of providing q/kdb+ users with general use functions and procedures to allow them to perform machine learning tasks on a wide variety of datasets.

This toolkit contains:

-   [Utility functions](utils.md) relating to important aspects of machine learning including data preprocessing and statistical testing, this also includes general use functions found to be useful in many machine learning applications.

-   An [implementation of the FRESH](fresh.md) (FeatuRe Extraction and Scalable Hypothesis testing) algorithm in q. This provides the q/kdb+ user with the ability to perform feature extraction and feature significance tests on structured time-series data in order to allow users to perform forecasting, regression and classification on time-series data.

Over time the machine-learning functionality in this library will be extended to include

-   q-specific implementations of machine-learning algorithms
-   more functionality

The toolkit is at:
<i class="fa fa-github"></i>
[KxSystems/ml-toolkit](https://github.com/kxsystems/ml-toolkit)

### Requirements
The following requirements cover all those needed to run the libraries within the current build of this toolkit.

-   [embedPy](../embedpy/)

A number of python dependencies also exist for the running of embedPy functions within both the the ML utils and FRESH libraries. These can be installed as outlined on the [KxSystems Github](https://github.com/kxsystems/ml-toolkit) using  pip via;

```bash
pip install -r requirements.txt
```
or via conda;
```bash
conda install --file requirements.txt
```

For the running of notebooks within the [Utilities](utils.md) and [FRESH](fresh.md) sections [JupyterQ](../jupyterq/) is required in addition to embedPy.