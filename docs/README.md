# Machine Learning Toolkit



The toolkit contains libraries and scripts that provide kdb+/q users with general-use functions and procedures to perform machine-learning tasks on a wide variety of datasets.

The toolkit contains:

-   Utility functions relating to important aspects of machine-learning including [data preprocessing](utilities/preproc.md), [statistical metrics](utilities/metric.md), and various other functionality useful in many machine-learning applications contained under [utils](utilities/util.md). 
-   An implementation of the [FRESH](fresh.md) (FeatuRe Extraction and Scalable Hypothesis testing) algorithm in q. This lets a kdb+/q user perform feature-extraction and feature-significance tests on structured time-series data for forecasting, regression and classification. 
-   Implementations of a number of [cross validation](xval.md) and hyperparameter search procedures. These allow kdb+/q users to validate the performance of machine learning models when exposed to new data, test the stability of models over time or find the best hyper-parameters for tuning their models.
- [Clustering algorithms](clustering/algos.md) used to group data points and to identify patterns in their distributions. The algorithms make use of a [k-dimensional tree](clustering/kdtree.md) to store points and [scoring functions](clustering/score.md) to analyze how well they performed.
- [Graph and Pipeline](graph/index.md) library containing a framework to develop code following a structure similar to a directed mathematical graph. This is intended to provide a scalable development methodology for complex code bases in q/kdb+.

Over time the machine-learning functionality in this library will be extended to include;

-   q-specific implementations of machine-learning algorithms
-   broader functionality


## Requirements

The following requirements cover all those needed to run the libraries in the current build of the toolkit.

-   [embedPy](https://github.com/KxSystems/embedPy)

A number of Python dependencies also exist for the running of embedPy functions within both the the machine-learning utilities and FRESH libraries. 

:point_right:
[Installation](https://github.com/KxSystems/ml#installation)

using Pip:
```bash
pip install -r requirements.txt
```

or Conda:

```bash
conda install --file requirements.txt
```

> :warning: **Running notebooks**
> 
> Running notebooks within the [FRESH](fresh.md) section requires both [JupyterQ](https://github.com/KxSystems/JupyterQ) and embedPy.
> However this is not a requirement for the toolkit itself.


## Installation

Install and load all libraries.

```q
q)\l ml/ml.q
q).ml.loadfile`:init.q
```

This can be achieved by one command.
Copy a link to the library into `$QHOME`.
Then:

```q
q)\l ml/init.q
```
