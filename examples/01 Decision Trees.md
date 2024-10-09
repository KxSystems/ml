# ml toolkit q examples 01: Classification Using Decision Trees

Decision trees are a simple yet effective algorithm used for supervised classification and regression problems.

A decision tree is made up of a collection of simple hierarchical decision rules, classifying datapoints into categories by splitting them based on feature values. The task of fitting a decision tree to data therefore involves finding the sequence of feature splits and the optimal split values.

Decision trees can:
- Manage a mixture of discrete, continuous and categorical inputs.
- Use data with no normalization/preprocessing (including missing data).
- Produce a highly interpretable output, which can be easily explained and visualized.

Further discussion of decision trees can be found in the Wikipedia article Decision tree or Sci-Kit Learn documentation.

### Breast Cancer Data
The Wisconsin Breast Cancer Dataset is a set of 569 samples of fine needle aspirate (FNA) of breast mass. Each sample contains features describing characteristics of the cell nuclei, along with a classification of the sample as either benign or malignant.
```q
// load toolkit
\l ml/ml.q
.ml.loadfile`:init.q

.util.round:{[val;round] round*"j"$val%round}

// load data
data:.p.import[`sklearn.datasets;`:load_breast_cancer][]
feat:data[`:data]`
targ:data[`:target]`

// inspect data
-1"Shape of feature data is: ",(" x "sv string .ml.shape feat),"\n";
show 5#feat
-1"\nDistribution of target values:\n";
show update pcnt:.util.round[;.01]100*num%sum num from select num:count i by target from([]target:targ);
```
```
Shape of feature data is: 569 x 30

17.99 10.38 122.8 1001  0.1184  0.2776  0.3001 0.1471  0.2419 0.07871 1.095  0.9053 8.589 153.4 ..
20.57 17.77 132.9 1326  0.08474 0.07864 0.0869 0.07017 0.1812 0.05667 0.5435 0.7339 3.398 74.08 ..
19.69 21.25 130   1203  0.1096  0.1599  0.1974 0.1279  0.2069 0.05999 0.7456 0.7869 4.585 94.03 ..
11.42 20.38 77.58 386.1 0.1425  0.2839  0.2414 0.1052  0.2597 0.09744 0.4956 1.156  3.445 27.23 ..
20.29 14.34 135.1 1297  0.1003  0.1328  0.198  0.1043  0.1809 0.05883 0.7572 0.7813 5.438 94.44 ..

Distribution of target values:

target| num pcnt
------| ---------
0     | 212 37.26
1     | 357 62.74
```

The output above shows that classes are quite unbalanced:
- 37% are malignant (0)
- 63% are benign (1)

### Prepare data
Before we can train a model we need to split the original data into training and testing sets. Below we select 50% to be present in the testing set.
```q
\S 123  / random seed
show count each datadict:.ml.trainTestSplit[feat;targ;.5]
```
```
xtrain| 284
ytrain| 284
xtest | 285
ytest | 285
```

### Build and train the model
At this stage it is possible to fit the data to a decision tree classifier model, restricting the tree to a maximum depth of 3.
```q
clf:.p.import[`sklearn.tree]`:DecisionTreeClassifier
clf:clf[`max_depth pykw 3]
clf[`:fit][datadict`xtrain;datadict`ytrain];
```

The decision tree classifier produces a highly interpretable model which can be visualized and understood even by those with a less technical knowledge.

The algorithm finds the best tree by following a greedy strategy where it looks for the feature (mean concave points) and split value (0.052) that most effectively partitions the data.

This divides the dataset of 284 samples into two subsets of 176 samples and 108 samples:
- Of the 176 samples, 7 (4%) are malignant and 169 (96%) are benign.
- Of the 108 samples, 95 (88%) are malignant and 13 (12%) are benign.

The algorithm continues splitting the dataset at each node, by finding the feature and split value that most effectively partitions the benign from the malignant samples.


### Evaluate model
The output of the decision tree is a class assignment.

We take a previously unseen sample and pass it through the decision tree. Following the appropriate branch at each split (based on the feature values of the test point), we eventually end up at a leaf node, at the bottom of the tree. At this point, we assign the test point the class value of the majority of the training examples included in that leaf.

We can therefore evaluate the performance of the decision tree on the held-out test data.

```q
/ make predictions
yprob:clf[`:predict_proba;<]datadict`xtest
ypred:yprob?'max each yprob
ytest:"j"$datadict`ytest

/ calculate performance metrics
dtloss:.ml.logLoss[ytest;yprob]
dtacc:.ml.accuracy[ypred;ytest]

-1"Performance of the classifier";
-1"log loss: ",string[dtloss],"\naccuracy: ",string dtacc;
```
```
Performance of the classifier
log loss: 1.431222
accuracy: 0.9263158
```
The decision tree classifier achieves 93% accuracy on the test set, a strong performance from such a simple classifier.

### Confusion matrix
```q
show cnfM:.ml.confMatrix[ypred;ytest]
```
```
0| 92 10
1| 11 172
```
NB: We are using "positive" here to denote the malignant case, which actually has the label 0, rather than 1 in the Wisconsin dataset.

With a Confusion Matrix, we can inspect the interaction between the following:
- True positives (92)
- True negatives (172)
- False positives (10)
- False negatives (11)

Therefore, the classifier has:
- True Positive Rate: TPR = TP/(TP+FN) = 92/(92+11) = 89%
- False Positive Rate: FPR = FP/(FP+TN) = 10/(10+172) =  5%
