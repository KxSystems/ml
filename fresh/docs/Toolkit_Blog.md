# The Machine Learning Toolkit applied to Feature Extraction and Selection in kdb+: An implementation of the FRESH algorithm

By Conor McCarthy

The Kx machine learning team has an ongoing project of periodically releasing useful machine learning libraries and notebooks for kdb+. These libraries and notebooks act as a foundation to our users, allowing them to use the ideas presented and the code provided and get access to the exciting world of machine learning with Kx.

The latest library to be released is a Machine Learning Toolkit (ML-Toolkit) which includes both utility functions for general use and an implementation of the FRESH (Feature Extraction based on Scalable Hypothesis tests) algorithm[1]. The ML-Toolkit is available in its entirety on the Kx ML-Toolkit GitHub [here](https://github.com/kxsystems/ml-toolkit). The full archive of previously released Kx JupyterQ notebooks relating to machine learning applications is available on the KxSystems GitHub [here](https://github.com/kxsystems/mlnotebooks). A list of blog articles relating to these notebooks is provided at the end of this article.

As with all the libraries released from the Kx Machine Learning Team the ML-Toolkit and it's constituent sections are available open source, Apache 2 software, and are supported for our clients.

## Introduction

The machine learning team have recently released the second of our machine learning application libraries. This follows from the release of the Natural Language Processing library in May of this year. As mentioned above this library at present includes both general use functions and an implementation of the FRESH algorithm. Each of these constitute distinct sections of the toolkit and can be integrated to allow users to perform machine learning tasks on structured time-series data and provides the opportunity to perform time-series forecasting through an integration of q and embedPy.

The first section contains general used utility functions which are outlined in depth [here](https://code.kx.com/q/ml/toolkit/utils) and are contained in a `.ml.utils` namespace, these relate presently to three distinct aspects of common use utilities in machine learning applications;
1. Statistical testing (covariance matrices/mean square error/log-loss etc.)
2. Data-preprocessing (data filling/min-max scaling/ etc.)
3. General use functions (train-test split/table-to-matrix conversion/array production etc.)

A detailed explanation of each of the functions contained in the utils of the ML-Toolkit are not presented here as the provided utilities will be continuously updated and a detailed explanation of each is presented on code.kx

The second aspect of this release is an implementation of the FRESH algorithm. This provides kdb+ users with the ability to perform feature extraction and selection procedures on time-series data as is explained in detail below. Use-case examples are provided in the form of notebooks and a console application within the [FRESH](http://code.kx.com/q/ml/toolkit/fresh/) section of the toolkit.
 
## Background

As outlined in a previous kx blog by Fionnula Carr [2], feature engineering is a central component of many machine learning pipelines. The FRESH algorithm in conjunction with the functions contained in the utils section of the machine learning toolkit provides the opportunity to explore structured datasets in depth with the goal of extracting the most useful features for predicting a target vector.

Feature extraction at a basic level is the process by which, from an initial dataset we build derived values/features which may be informative when passed to a machine learning algorithm. It allows for information which may be pertinent to the prediction of an attribute of the system under investigation to be extracted. This information is often easier to interpret than the time series in its raw form. It also offers the chance to apply less complex machine learning models to our data as the important trends in the data do not have to be extracted via a complex algorithms such as a neural network, the output from which may not be easily interpretable.

Following feature extraction, statistical significance tests between the feature and target vectors can be performed. This is advantageous as within the features extracted from the initial data there may only be a small subsection of features which are important to the prediction of the target vector. Once statistical tests have been completed to find their relevance to prediction the Benjamini-Hochberg-Yekutieli procedure is applied to set a threshold for the features which will be kept for application to machine learning algorithms later in a pipeline.

The purposes of feature selection from the standpoint of improving the accuracy of a machine learning algorithm are as follows

- Simplify the models being used, thus making them easier to interpret.
- Shorten the time needed to train a model.
- Helps to avoid the curse of dimensionality.
- Reduces variance in the dataset to help reduce the chance of overfitting.

The application of both feature extraction and feature significance to data provides the opportunity to improve the accuracy and efficiency of machine learning algorithms as applied to time-series data, this is the overall goal of the FRESH library.

### Technical Description

At its core the FRESH algorithm is an intuitive model with three primary steps;
1. Time series data, segmented based on a unique 'ID' column (hour/date/test run etc.) is passed to the feature extraction procedure which calculates 1000s of features for each ID.
2. The table containing the extracted features is then passed to a set of feature significance hypothesis tests to calculate their p-values.
3. Given these p-values which give a representation of the potential importance of a feature to the prediction of the target complete the Benjamini-Hochberg-Yekutieli procedure to filter out statistically insignificant features.

#### **Feature Creation**
Among the features calculated in the feature extraction procedure are kurtosis, number of peaks, system entropy and skewness of the dataset. These in conjunction with ~50 other functions applied to the individual time series, results in the creation of potentially thousands of features based on hyperparameter inputs which can be passed to a machine learning algorithm. 

The function which operates on the dataset to create these features is defined by;

`.ml.fresh.createfeatures[table;id;cnames;funcs]`

This function takes as its arguments the table containing the pertinent data,an ID column on which the features will be calculated `id`, column names on which the features are to be calculated `cnames` and a dictionary of the functions which will be calculated contained in the .ml.fresh.feat namespace `funcs`.

The application of these functions to a sample table below shows how the data is modified;
```q
q)table
ID        Feat1     Feat2    
------------------------
01-02-18  0.1      5        
01-02-18  0.2      12        
01-02-18  0.2      5         
02-02-18  0.2      1         
02-02-18  0.3      6        

q)5#funcs:.ml.fresh.feats      /these are the functions to be applied to the table
                 | ::
absenergy        | {x wsum x}
abssumchange     | {sum abs 1_deltas x}
autocorr         | {(avg(x-m)*xprev[y;x]-m:avg x)%var x}
binnedentropy    | {neg sum p*log p:hist["f"$x;y][0]%count x}

q)show tabval:.ml.fresh.createfeatures[table;`ID;1_cols table;funcs]
ID         |   Feat1_min   Feat2_min    …    Feat1_hasdup   Feat2_hasdup
-----------|------------------------------------------------------------
01-02-18   |   0.1         5            …    0b             1b             
02-02-18   |   0.2         1            …    0b             0b               
```
Clearly in the above example the data has been manipulated such that the feature creation procedure applied to the table has, for each column applied the functions within the .ml.fresh.feat to the data and produced 1 value per ID for each feature and column.  
#### **Feature Significance Tests**
Once the features have been extracted we compare each of the features to the targets. The statistical tests which are used within the pipeline are as follows.
- Real feature and real target: Kendall tau-b test
- Real feature and binary target: Kolmogorov-Smirnov test.
- Binary feature and real target: Kolmogorov-Smirnov test.
- Binary feature and binary target: Fisher’s exact test.

Each of these statistical tests returns a p-value which compares the statistical significance of the features to the target vector, the tests performed are dependent on the characteristics of each of the features and targets respectively.

Following calculation of the the p-values we employ the Benjamini-Hochberg-Yekutieli procedure which controls the features which are deemed to be statistically significant to prediction of the target vector.

The significance tests and feature selection procedures described above are contained within the function 

`.ml.fresh.significantfeatures[table;targets]` 

in this case table relates to the unkeyed representation of the table shown in the feature creation section above, while targets is the vector of values which are intended to be predicted from the created features. Here it is important to note that count targets must equal count table.

This will return a new table from which features that are deemed to be statistically insignificant have been removed. The data from this final table can then be passed to a machine learning algorithm for either forecasting or classification depending on the use case. The following is an example implementation of this function, as applied to the table produced from the create features function;

```q
q)show tab2:key[tabval]!.ml.fresh.significantfeatures[value tabval;targets]
ID         |   Feat1_min   Feat2_avg    …    Feat2_count   Feat2_hasdup
-----------|------------------------------------------------------------
01-02-18   |   0.1         11           …    3             1b             
02-02-18   |   0.2         3.5          …    2             0b            

q)-1 "The number of columns in the unfiltered dataset is: ",string count cols tabraw;
The number of columns in the unfiltered dataset is: 201
q)-1 "The number of columns in the filtered dataset is: ",string count cols tabreduced;
The number of columns in the filtered dataset is: 45
```

As mentioned in the introduction notebook examples showing the application of the FRESH algorithm to time series data, namely its use in time-series forecasting and classification problems are available within the FRESH section of the ML-Toolkit.

If you would like to further investigate the uses of the FRESH library or any of the functions contained in the ML-Toolkit, check out the files on our GitHub [here](https://github.com/kxsystems/ml-toolkit) and visit https://code.kx.com/q/ml/toolkit to find documentation and the complete list of the functions that are available within the ML-Toolkit. 

For steps regarding the set up of your machine learning environment see the installation guide available at http://code.kx.com/q/ml/setup which details the installarion of kdb+, embedPy and JupyterQ.

Please don’t hesitate to contact ai@kx.com if you have any suggestions or queries.

**Other articles in our ongoing JupyterQ series of blogs by the Kx Machine Learning Team:**

[Natural Language Processing in kdb](https://kx.com/blog/natural-language-processing-in-kx/) by Fionnuala Carr

[Neural Networks in kdb+](https://kx.com/blog/neural-networks-in-kdb-2/) by Esperanza López Aguilera

[Dimensionality Reduction in kdb+](https://kx.com/blog/dimensionality-reduction-in-kdb/) by Conor McCarthy

[Classification Using k-Nearest Neighbors in kdb+](https://kx.com/blog/classification-using-k-nearest-neighbors-in-kdb/) by Fionnuala Carr

[Feature Engineering in kdb+](https://kx.com/blog/feature-engineering-in-kdb/) by Fionnuala Carr

[Decision Trees in kdb+](https://kx.com/blog/decision-trees-in-kdb/) by Conor McCarthy

## References:

1. M. Christ et al., Time Series FeatuRe Extraction on basis of Scalable Hypothesis tests Neurocomputing (2018) 
2. Feature Engineering in kdb+. Available [here](https://kx.com/blog/feature-engineering-in-kdb/)

