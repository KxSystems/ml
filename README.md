# Machine Learning Toolkit

The Machine Learning Toolkit is a comprehensive suite designed to empower kdb+/q users with advanced machine learning capabilities. It offers a robust and flexible framework for addressing a wide range of tasks, including time series analysis, natural language processing, and automated machine learning. By integrating seamlessly with kdb+/q, the toolkit facilitates efficient data handling and processing, leveraging both traditional machine learning techniques and modern NLP models.

The repository is structured as four modules: ml and nlp can each be used independently for their respective feature sets, [as further described below](#components); automl builds upon ml and nlp to deliver automated machine learning capabilities; and a utility shim which is used by the toolkit to load PyKX or EmbedPy, which ensure seamless interoperability between Python and kdb+/q in either environment.

## Getting started

To get up and running quickly, start by pulling the Docker image, which comes pre-installed with all dependencies specified in requirements_pinned.txt. This allows you to dive straight into trying out our [examples](examples/) and exploring the toolkit's capabilities without the need for additional setup.

```bash
git clone https://github.com/KxSystems/ml.git ml
docker pull <image>
docker run -itv ./ml:/ml -e QLIC_K4=$(cat $QHOME/k4.lic | base64 -w0) --entrypoint /bin/bash <image>

# Now within the container, source the initial environment setup script
cd /ml
source scripts/setup.sh
source scripts/pykx.sh # Switch from embedpy to pykx (optionally continue with embedpy)
source scripts/link.sh # Install the toolkit into your selected QHOME

# Now simply start q Load and work with the desired components in q
rlwrap q
q)\l nlp/nlp.q
q).nlp.loadfile`:init.q
Loading init.q
Loading code/utils.q
Loading code/regex.q
Loading code/sent.q
Loading code/parser.q
Loading code/time.q
Loading code/date.q
Loading code/email.q
Loading code/cluster.q
Loading code/nlp_code.q
q).nlp.findTimes"I went to work at 9:00am and had a coffee at 10:20"  # See examples/ for more advanced usage.
09:00:00.000 "9:00am" 18 24
10:20:00.000 "10:20"  45 50
q)
```

### Requirements

- kdb+ >= 3.5 64-bit

The Python packages required to allow successful execution of all functions within the machine learning toolkit can be installed via:

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```

Alternatively, use requirements_pinned.txt for a fully resolved, pinned & known working set of dependencies or module specific requirements.txt (eg ml/requirements.txt) when only utilizing a subset of the toolkit.

While the nlp framework may be used with other models, automl the nlp tests use en_core_web_sm. You can download this after installing the python requirements like so:
```bash
python -m spacy download en_core_web_sm
```

<!-- //! optional reqs for automl -->


### Installation

Run `scripts/link.sh` from the repo root to link the module folders into `$QHOME`. Alternatively, manually copy or link your desired subset.

The following will load **all** functionality into the `.automl`, `.ml` & `.nlp` namespaces.
```q
\l automl/automl.q
.automl.loadfile`:init.q
```

* Replace all instances of automl above with ml or nlp to load only those specific modules. All of which rely on the shim.

<!-- ### Examples   //! currently outdated

Examples showing implementations of several components of this toolkit can be found [here](https://github.com/KxSystems/mlnotebooks/). These notebooks include examples of the following sections of the toolkit.

*  Pre-processing functions
*  Implementations of the FRESH algorithm
*  Cross validation and grid search capabilities
*  Results Scoring functionality
*  Clustering methods applied to datasets
*  Timeseries modeling examples -->


## Components
### ml
This library contains functions that cover the following areas:
- An implementation of the FRESH (FeatuRe Extraction and Scalable Hypothesis testing) algorithm for use in the extraction of features from time series data and the reduction in the number of features through statistical testing.
- Cross-validation and grid-search functions allowing for testing of the stability of models to changes in the volume of data or the specific subsets of data used in training.
- Clustering algorithms used to group data points and to identify patterns in their distributions. The algorithms make use of a k-dimensional tree to store points and scoring functions to analyze how well they performed.
- Statistical timeseries models and feature-extraction techniques used for the application of machine learning to timeseries problems. These models allow for the forecasting of the future behavior of a system under various conditions.
- Numerical techniques for calculating the optimal parameters for an objective function.
- A graphing and pipeline library for the creation of modularized executable workflow based on a structure described by a mathematical directed graph.
- Utility functions relating to areas including statistical analysis, data preprocessing and array manipulation.
- A multi-processing framework to parallelize work across many cores or nodes.

These sections are explained in greater depth within the [FRESH](ml/docs/fresh.md), [cross validation](ml/docs/xval.md), [clustering](ml/docs/clustering/algos.md), [timeseries](ml/docs/timeseries/README.md), [optimization](ml/docs/optimize.md), [graph/pipeline](ml/docs/graph/README.md) and [utilities](ml/docs/utilities/metric.md) documentation.


### nlp

The Natural language processing (NLP) module allows users to parse dataset using the spacy model from python in which it runs tokenisation, Sentence Detection, Part of speech tagging and Lemmatization. In addition to parsing, users can cluster text documents together using different clustering algorithms like MCL, K-means and radix. You can also run sentiment analysis which indicates whether a word has a positive or negative sentiment.

<!-- //! docs? old link is dead: Documentation is available on the [nlp](https://code.kx.com/v2/ml/nlp/) homepage.-->


### automl

The automated machine learning library described here is built on top of ml & nlp. The purpose of this framework is help you automate the process of applying machine learning techniques to real-world problems. In the absence of expert machine-learning engineers this handles the following processes within a traditional workflow.

- Data preprocessing
- Feature engineering and feature selection
- Model selection
- Hyperparameter Tuning
- Report generation and model persistence

Each of these steps is outlined in depth within the [documentation](automl/docs).


### shim
A utility module that loads either PyKX or embedpy and provides helper functions to write cross compatible code.

## Building the docker images

### preflight
You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with `git clone https://github.com/KxSystems/ml.git`.

### building

To build the project locally:

```bash //! improve
docker build -t registry.gitlab.com/kxdev/kxinsights/data-science/ml-tools/automl:embedpy-gcc-deb12 -f docker/Dockerfile .
docker build -t myimage:mytag -f docker/Dockerfile .
```

<!-- **N.B.** if you wish to use an alternative source for [embedPy](https://github.com/KxSystems/embedPy) then you can append `--build-arg embedpy_img=embedpy` to your argument list. -->

<!-- Other build arguments are supported and you should browse the `Dockerfile` to see what they are. -->

Once built, you should have a local image which you can run with as shown in the "Getting started" section above.

<!-- ### Deploy //! outdated

[travisCI](https://travis-ci.org/) is configured to monitor when tags of the format `/^[0-9]+\./` are added to the [GitHub hosted project](https://github.com/KxSystems/ml), a corresponding Docker image is generated and made available on [Docker Cloud](https://cloud.docker.com/)

This is all done server side as the resulting image is large.

To do a deploy, you simply tag and push your releases as usual:
```bash
git push
git tag 0.7
git push --tag
``` -->


## Status

The Machine Learning Toolkit is provided here under an Apache 2.0 license.

If you find issues with the interface or have feature requests, please [raise an issue](https://github.com/KxSystems/ml/issues).

To contribute to this project, please follow the [contributing guide](CONTRIBUTING.md).
