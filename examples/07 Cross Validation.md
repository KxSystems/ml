# ml toolkit q examples 07: Cross-Validation

Cross-validation is a model validation technique that is used to assess how well the results produced by a model generalise to independent datasets. The aim of performing this technique is to train the algorithm using a variety of validation datasets in order to limit future problems with prediction, such as overfitting or underfitting.

The toolkit is used throughout this notebook and can be loaded using the below syntax.
```q
\l ml/ml.q
.ml.loadfile`:init.q
```

## Breast Cancer Data
The [Wisconsin Breast Cancer Dataset](https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+%28Diagnostic%29) is a set of 569 samples of fine needle aspirate (FNA) of breast mass. Each sample contains features describing characteristics of the cell nuclei, along with a classification of the sample as either benign or malignant.

### Load data
In the cells below, we load in the breast cancer data required for this notebook. The diagnosis column is removed from the dataset and used as the target vector as this is the feature we want to predict.
```q
targets:select diagnosis from data:("FS",30#"F";(),",")0:`:data.csv
show 5#data:delete diagnosis from data
-1"\nShape of data is: ",(" x "sv string .ml.shape data),"\n";
show targets`diagnosis
```
```
id          radius_mean texture_mean perimeter_mean area_mean smoothness_mean compactness_mean co..
-------------------------------------------------------------------------------------------------..
842302      17.99       10.38        122.8          1001      0.1184          0.2776           0...
842517      20.57       17.77        132.9          1326      0.08474         0.07864          0...
8.43009e+07 19.69       21.25        130            1203      0.1096          0.1599           0...
8.43483e+07 11.42       20.38        77.58          386.1     0.1425          0.2839           0...
8.43584e+07 20.29       14.34        135.1          1297      0.1003          0.1328           0...

Shape of data is: 569 x 31

`M`M`M`M`M`M`M`M`M`M`M`M`M`M`M`M`M`M`M`B`B`B`M`M`M`M`M`M`M`M`M`M`M`M`M`M`M`B`M`M`M`M`M`M`M`M`B`M`..
```

### Target values
One hot encoding is used on the target data to convert symbols into a numerical representation.
```q
show targets:exec diagnosis_M from .ml.oneHot.fitTransform[targets;cols targets]
```
```
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 0 1 0..
```

### Prepare data
In the cells below, polynomial features are produced from the original data table to allow for interactions between terms in the system. This allows us to study both individual and combined features.
```q
/ target classifications should be agnostic of the id column
5#table:(cols[data]except`id)#data
```
```
radius_mean texture_mean perimeter_mean area_mean smoothness_mean compactness_mean concavity_mean..
-------------------------------------------------------------------------------------------------..
17.99       10.38        122.8          1001      0.1184          0.2776           0.3001        ..
20.57       17.77        132.9          1326      0.08474         0.07864          0.0869        ..
19.69       21.25        130            1203      0.1096          0.1599           0.1974        ..
11.42       20.38        77.58          386.1     0.1425          0.2839           0.2414        ..
20.29       14.34        135.1          1297      0.1003          0.1328           0.198         ..
```

```q
/ add second order polynomial features to the table
5#table:table^.ml.polyTab[table;2]
```
```
radius_mean texture_mean perimeter_mean area_mean smoothness_mean compactness_mean concavity_mean..
-------------------------------------------------------------------------------------------------..
17.99       10.38        122.8          1001      0.1184          0.2776           0.3001        ..
20.57       17.77        132.9          1326      0.08474         0.07864          0.0869        ..
19.69       21.25        130            1203      0.1096          0.1599           0.1974        ..
11.42       20.38        77.58          386.1     0.1425          0.2839           0.2414        ..
20.29       14.34        135.1          1297      0.1003          0.1328           0.198         ..
```

```q
/ complete standard scaling of the dataset to avoid biases due to orders of magnitude in the data
5#table:.ml.minMaxScaler.fitTransform table
```
```
radius_mean texture_mean perimeter_mean area_mean smoothness_mean compactness_mean concavity_mean..
-------------------------------------------------------------------------------------------------..
0.5210374   0.0226581    0.5459885      0.3637328 0.5937528       0.7920373        0.7031396     ..
0.6431445   0.2725736    0.6157833      0.5015907 0.2898799       0.181768         0.2036082     ..
0.6014956   0.3902604    0.5957432      0.4494168 0.5143089       0.4310165        0.4625117     ..
0.2100904   0.3608387    0.2335015      0.1029056 0.8113208       0.8113613        0.5656045     ..
0.6298926   0.1565776    0.6309861      0.4892895 0.4303512       0.3478928        0.4639175     ..
```

```q
/ complete a train-test-split on the data - below 20% of data is used in the test set
show tts:.ml.trainTestSplit[table;targets;.2]
```
```
xtrain| +`radius_mean`texture_mean`perimeter_mean`area_mean`smoothness_mean`compactness_mean`conc..
ytrain| 1 1 0 0 0 1 1 1 0 1 0 0 0 1 0 0 0 1 0 1 1 0 0 0 0 0 0 0 1 1 0 0 1 0 1 1 0 0 1 1 0 0 1 1 0..
xtest | +`radius_mean`texture_mean`perimeter_mean`area_mean`smoothness_mean`compactness_mean`conc..
ytest | 0 0 0 1 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 1 0 1 1 1 1 1 0 0 0 1 1 0 0 1 1 1 0 0 0 0 1 0 1 1..
```

### Cross-Validation
Below a Random Forest Classifier model is initialized in order to classify tumours as malignant or benign. We can perform consistency checks on this model by performing cross validation techniques on the training data. In the first cell, cross-validation is applied in 5 folds.

```q
k:5  / number of folds
n:1  / number of repetitions

xtrain:flip value flip tts`xtrain
ytrain:tts`ytrain

/ function with algorithm
a:{.p.import[`sklearn.ensemble][`:RandomForestClassifier]}

/ scoring function which takes a function, parameters to apply to that function and data as arguments
score_func:.ml.xv.fitScore[a][`n_estimators pykw 500]

/ split data into k-folds and train/validate the model
s1:.ml.xv.kfSplit[k;n;xtrain;ytrain;score_func]  / sequentially split
s2:.ml.xv.kfShuff[k;n;xtrain;ytrain;score_func]  / randomized split
s3:.ml.xv.kfStrat[k;n;xtrain;ytrain;score_func]  / stratified split

-1"Average Model Scores:";
-1"----------------------------------------------------------------------------";
-1"Sequential split indices with basic k-fold cross validation: ",string avg s1;
-1"Random split indices with basic k-fold cross validation: ",string avg s2;
-1"Stratified split indices with basic k-fold cross validation: ",string avg s3;
```
```
Average Model Scores:
----------------------------------------------------------------------------
Sequential split indices with basic k-fold cross validation: 0.9714286
Random split indices with basic k-fold cross validation: 0.9758242
Stratified split indices with basic k-fold cross validation: 0.9670553
```

Another option is to use repeated forms of cross validation, such as monte-carlo or repeated k-fold cross validation. These methods have the benefit of allowing a user to evaluate the consistency and robustness of the models produced. Below 5 folds are again used, this time with 5 repetitions.

```q
p:.2  / percentage of data in validation set
n: 5  / number of repetitions

r1:.ml.xv.mcSplit[p;n;xtrain;ytrain;score_func]
r2:.ml.xv.kfShuff[k;n;xtrain;ytrain;score_func]
r3:.ml.xv.kfSplit[k;n;xtrain;ytrain;score_func]

-1"Average Model Scores:";
-1"----------------------------------------------------------------------------";
-1"Monte-Carlo cross validation with 5 repetitions and training size of 80%: ",string avg r1;
-1"Repeated stratified cross validation, 5 fold, 5 repetitions: ",string avg r2;
-1"Repeated sequential cross validation, 5 fold, 5 repetitions: ",string avg r3;
```
```
Average Model Scores:
----------------------------------------------------------------------------
Monte-Carlo cross validation with 5 repetitions and training size of 80%: 0.9714286
Repeated stratified cross validation, 5 fold, 5 repetitions: 0.9687912
Repeated sequential cross validation, 5 fold, 5 repetitions: 0.9718681
```

### Hyperparameter Search
The ML-Toolkit contains functionality required to perform grid, random and Sobol-random search (more information on Sobol can be found [here](https://en.wikipedia.org/wiki/Sobol_sequence)). Grid search functionality is contained within the .ml.gs namespace, while all random functionality is contained within .ml.rs. All three methods of hyperparameter search allow users to define and test a hyperparameter space in order to find the optimal model parameters.

#### Grid Search
For grid search functions provided in the toolkit, users must provide a dictionary containing hyperparameter names and all the possible values they wish to search. Grid search can be completed on the training data to find the best parameters which are then be applied to the model. Predictions are then made and scored using the unseen testing data.

In the cell below we start by defining a scoring function and dictionary of grid search hyperparameters.
```q
/ new scoring function
sf:.ml.xv.fitScore[a]

/ dictionary of parameters
gs_hp:`n_estimators`criterion`max_depth!(10 50 100 500;`gini`entropy;2 5 10 20 30)
```

In the grid search function below, the final argument is a float value denoting the size of the holdout set used in a fitted gridsearch where the best model is fit to holdout data. If 0 is used (shown below) the function will return scores for each fold for the given hyperparameters.

```q
-1"Grid search: hyperparameters and resulting score from each fold:\n";
show gr:.ml.gs.kfSplit[k;n;xtrain;ytrain;sf;gs_hp;0]
```
```
n_estimators criterion max_depth|                                                                ..
--------------------------------| ---------------------------------------------------------------..
10           gini      2        | 0.9450549 0.989011 0.9230769 0.978022 0.956044 0.9340659 0.9670..
10           gini      5        | 0.967033  0.956044 0.9340659 0.967033 0.967033 0.9340659 0.9890..
10           gini      10       | 0.956044  0.978022 0.9450549 0.989011 0.978022 0.956044  0.9890..
10           gini      20       | 0.9450549 0.967033 0.956044  0.967033 0.978022 0.956044  0.9890..
10           gini      30       | 0.9450549 1        0.9450549 0.967033 1        0.9450549 0.9890..
10           entropy   2        | 0.9230769 0.967033 0.9340659 0.967033 0.967033 0.956044  0.9890..
10           entropy   5        | 0.956044  0.967033 0.956044  0.956044 0.978022 0.967033  0.9670..
10           entropy   10       | 0.9450549 0.989011 0.978022  0.978022 0.978022 0.9450549 1     ..
10           entropy   20       | 0.967033  1        0.9450549 0.967033 0.989011 0.967033  0.9780..
10           entropy   30       | 0.9450549 0.989011 0.9230769 0.978022 0.978022 0.9450549 0.9890..
50           gini      2        | 0.9340659 1        0.956044  0.967033 0.967033 0.9450549 0.9670..
50           gini      5        | 0.9450549 0.989011 0.956044  0.989011 0.989011 0.9450549 0.9780..
50           gini      10       | 0.9450549 0.989011 0.956044  0.967033 0.978022 0.956044  1     ..
50           gini      20       | 0.9450549 0.978022 0.967033  0.989011 0.978022 0.956044  0.9780..
50           gini      30       | 0.956044  0.989011 0.9450549 0.978022 0.989011 0.9450549 0.9890..
50           entropy   2        | 0.9340659 0.978022 0.9340659 0.967033 0.989011 0.9340659 0.9670..
50           entropy   5        | 0.956044  0.989011 0.9450549 0.967033 0.989011 0.967033  1     ..
50           entropy   10       | 0.978022  0.989011 0.967033  0.978022 0.978022 0.956044  1     ..
50           entropy   20       | 0.967033  0.989011 0.9450549 0.967033 0.978022 0.956044  0.9890..
50           entropy   30       | 0.967033  0.989011 0.956044  0.967033 0.978022 0.967033  0.9890..
100          gini      2        | 0.9230769 0.978022 0.956044  0.967033 0.956044 0.956044  0.9670..
100          gini      5        | 0.9450549 1        0.967033  0.978022 0.978022 0.956044  0.9780..
100          gini      10       | 0.956044  0.978022 0.967033  0.978022 0.989011 0.9450549 0.9780..
100          gini      20       | 0.9450549 0.989011 0.978022  0.967033 0.978022 0.956044  0.9780..
100          gini      30       | 0.956044  0.989011 0.956044  0.978022 0.978022 0.956044  0.9780..
100          entropy   2        | 0.9230769 0.978022 0.9450549 0.978022 0.967033 0.9230769 1     ..
100          entropy   5        | 0.967033  0.989011 0.956044  0.978022 0.989011 0.978022  0.9890..
100          entropy   10       | 0.967033  1        0.9450549 0.967033 0.989011 0.956044  0.9890..
100          entropy   20       | 0.956044  0.989011 0.956044  0.978022 0.978022 0.956044  0.9890..
100          entropy   30       | 0.967033  0.989011 0.956044  0.978022 0.989011 0.967033  1     ..
500          gini      2        | 0.9340659 0.989011 0.956044  0.967033 0.978022 0.9340659 0.9890..
500          gini      5        | 0.956044  0.989011 0.967033  0.978022 0.989011 0.956044  0.9780..
500          gini      10       | 0.967033  0.978022 0.967033  0.978022 0.989011 0.956044  0.9780..
500          gini      20       | 0.956044  0.978022 0.967033  0.967033 0.978022 0.9450549 0.9780..
500          gini      30       | 0.9450549 0.978022 0.956044  0.978022 0.989011 0.956044  0.9780..
500          entropy   2        | 0.9230769 1        0.9450549 0.967033 0.967033 0.9230769 0.9890..
500          entropy   5        | 0.967033  1        0.956044  0.967033 0.989011 0.967033  1     ..
500          entropy   10       | 0.967033  0.978022 0.956044  0.978022 0.989011 0.956044  1     ..
500          entropy   20       | 0.956044  0.989011 0.956044  0.967033 0.978022 0.967033  0.9890..
500          entropy   30       | 0.978022  0.989011 0.956044  0.978022 0.978022 0.967033  1     ..
```

We can now fit this best model on our training set and test how well it generalises to new data.
```q
bstmdl:.p.import[`sklearn.ensemble][`:RandomForestClassifier][pykwargs first where a=max a:avg each gr]
bstmdl[`:fit][xtrain;ytrain];
br:bstmdl[`:score][flip value flip tts`xtest;tts`ytest]`
-1"Score for the 'best model' on the testing set was: ",string br;
```
```
Score for the 'best model' on the testing set was: 0.9561404
```

Alternatively, the previous two cells can be compressed within a fitted grid search procedure. As explained above, this is done by using a float for the final parameter.
```q
-2#.ml.gs.kfSplit[k;n;flip value flip table;targets;sf;gs_hp;.2]
```
```
`n_estimators`criterion`max_depth!(500;`entropy;30)
0.9824561
```

The grid search function can also be passed a negative value for the final parameter. This means that data will be shuffled prior to designation of the holdout set.
```q
-2#.ml.gs.kfSplit[k;n;flip value flip table;targets;sf;gs_hp;-.2]
```
```
`n_estimators`criterion`max_depth!(50;`entropy;30)
0.9824561
```

#### Random and Sobol-Random Search
The random and sobol searching methods follow the same syntax as grid search, with the exception of the p parameter. In order to perfom these two searching methods extra information is needed, where the parameter dictionary must have the format:

- `typ` is the type of random search to perform as a symbol - random or sobol
- `random_state` is the seed to apply during cross validation. If a null character, (::), is passed the default seed, 42, will be applied.
- `n` is the number of hyperparameter sets to produce. Note: for sobol this number must equal 2^n, eg 4, 8, 16, etc.
- `p` is a dictionary of hyperparameters to be searched which must have the following forms:

    - Numerical:

        ``enlist[`hyperparam_name]!enlist(space_type;lower_bound;upper_bound;hp_type)``

        where `space_type` is `uniform` or `loguniform`, `lower_upper` and `upper_bound` are the limits of the hyperparameter space and `hp_typ` is the type to cast the hyperparameters to.

    - Symbol:

        ``enlist[`hyperparam_name]!enlist(`symbol;symbols_to_search)``

        where symbol is given as the type followed by the list of possible symbol values.

    - Boolean:

        ``enlist[`hyperparam_name]!enlist`boolean``

##### Random example
```q
typ:`random     / type of hyperparameter search
random_state:42 / seed
n:10            / number of trials

/ dictionary of parameters
p:`n_estimators`criterion`max_depth!((`uniform;10;500;"j");(`symbol;`gini`entropy);(`uniform;2;30;"j"))

/ combine into random hyperparameter dictionary
rdm_hp:`typ`random_state`n`p!(typ;random_state;n;p)

-2#.ml.rs.kfSplit[k;n;flip value flip table;targets;sf;rdm_hp;.2]
```
```
`n_estimators`criterion`max_depth!(403;`entropy;4)
0.9824561
```


##### Sobol example
```q
typ:`sobol / type of hyperparameter search
n:16       / number of trials must equal 2^n for sobol

/ combine into random hyperparameter dictionary
sbl_hp:`typ`random_state`n`p!(typ;random_state;n;p)

-2#.ml.rs.kfSplit[k;n;flip value flip table;targets;sf;sbl_hp;.2]
```
```
`n_estimators`criterion`max_depth!(378;`entropy;9)
0.9824561
```

### Conclusions
Cross validation is a useful technique to determine how well a model will generalize to new data. It is possible to carry out cross validation in a number of ways depending on the chosen dataset. Above we displayed how to perform cross validation using a range methods, which split data in a sequential, randomized or stratified manner, as well as using monte-carlo methods.

It is clear that if the aim is to trial a range of hyperparameters on a model, then grid, random and Sobol search are robust ways to test a chosen range of parameters and return the ones which allow the model to generalize best to new data.



