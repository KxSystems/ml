// util/metrics.q - Metrics 
// Copyright (c) 2021 Kx Systems Inc
//
// Metrics for scoring ml models

\d .ml

// @kind function
// @category metric
// @desc Accuracy of classification results
// @param pred {int[]|boolean[]|string[]} A vector/matrix of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector/matrix of true labels 
// @returns {float} The accuracy of predictions made
accuracy:{[pred;true]
  avg pred=true
  }

// @kind function
// @category metric
// @desc Precision of a binary classifier
// @param pred {boolean[]} A vector of predicted labels 
// @param true {boolean[]} A vector of true labels
// @param posClass {boolean} The positive class 
// @returns {float} A measure of the precision
precision:{[pred;true;posClass]
  predPos:pred=posClass;
  truePos:predPos&true=posClass;
  sum[truePos]%sum predPos
  }

// @kind function
// @category metric
// @desc Sensitivity of a binary classifier
// @param pred {boolean[]} A vector of predicted labels 
// @param true {boolean[]} A vector of true labels
// @param posClass {boolean} The positive class 
// @returns {float} A measure of the sensitivity
sensitivity:{[pred;true;posClass]
  realPos:true=posClass;
  truePos:realPos&pred=posClass;
  sum[truePos]%sum realPos
  }

// @kind function
// @category metric
// @desc Specificity of a binary classifier
// @param pred {boolean[]} A vector of predicted labels 
// @param true {boolean[]} A vector of true labels
// @param posClass {boolean} The positive class 
// @returns {float} A measure of the specificity
specificity:{[pred;true;posClass]
  allNeg:true<>posClass;
  trueNeg:allNeg&pred<>posClass;
  sum[trueNeg]%sum allNeg
  }

// @kind function
// @category metric
// @desc F-beta score for classification results
// @param pred {number[]|boolean[]} A vector of predicted labels 
// @param true {number[]|boolean[]} A vector of true labels
// @param posClass {number|boolean} The positive class
// @param beta {float} The value of beta
// @returns {float} The F-beta score between predicted and true labels
fBetaScore:{[pred;true;posClass;beta]
  realPos:true=posClass;
  predPos:pred=posClass;
  minPos:realPos&predPos;  
  (sum[minPos]*1+beta*beta)%sum[predPos]+beta*beta*sum realPos
  }

// @kind function
// @category metric
// @desc F-1 score for classification results
// @param pred {int[]|boolean[]|string[]} A vector of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector of true labels
// @param posClass {number|boolean} The positive class
// @returns {float} The F-1 score between predicted and true labels
f1Score:fBetaScore[;;;1]

// @kind function
// @category metric
// @desc Matthews-correlation coefficient
// @param pred {int[]|boolean[]|string[]} A vector of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector of true labels
// @returns {float} The Matthews-correlation coefficient between predicted
//   and true values
matthewCorr:{[true;pred]
  confMat:value confMatrix[true;pred];
  sqrtConfMat:sqrt prd sum[confMat],sum each confMat;
  .[-;prd raze[confMat](0 1;3 2)]%sqrtConfMat
  }

// @kind function
// @category metric
// @desc Confusion matrix
// @param pred {int[]|boolean[]|string[]} A vector of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector of true labels
// @returns {dictionary} A confusion matrix
confMatrix:{[pred;true]
  classes:asc distinct pred,true;
  if[1=type classes;classes:01b];
  classDict:classes!(2#count classes)#0;
  groupClass:0^((count each group@)each pred group true)@\:classes;
  classDict,groupClass
  }

// @kind function
// @category metric
// @desc True/false positives and true/false negatives
// @param pred {int[]|boolean[]|string[]} A vector of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector of true labels
// @param posClass {number|boolean} The positive class
// @returns {dictionary} The count of true positives (tp), true negatives (tn),
//   false positives (fp) and false negatives (fn) 
confDict:{[pred;true;posClass]
  confKeys:`tn`fp`fn`tp;
  confVals:raze value confMatrix .(pred;true)=posClass;
  confKeys!confVals
  }

// @kind function
// @category metric
// @desc Statistical information about classification result
// @param pred {int[]|boolean[]|string[]} A vector of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector of true labels
// @returns {table} The accuracy, precision, f1 scores and the support 
//   (number of occurrences) of each class.
classReport:{[pred;true]
  trueClass:asc distinct true;
  dictCols:`precision`recall`f1_score`support;
  funcs:(precision;sensitivity;f1Score;{sum y=z});
  dictVals:(funcs .\:(pred;true))@/:\:trueClass;
  dict:dictCols!dictVals;
  classTab:([]class:`$string[trueClass],enlist"avg/total");
  classTab!flip[dict],(avg;avg;avg;sum)@'dict
  }

// @kind function
// @category metric
// @desc Logarithmic loss
// @param class {boolean[]} Class labels
// @param prob {float[]} Representing the probability of belonging to 
//   each class
// @returns {float} Total logarithmic loss
crossEntropy:logLoss:{[class;prob]
  // Formerly EPS:1e-15, new value from print(np.finfo(prob.dtype).eps)
  // Updated post scikit learn 1.5.1
  EPS:2.220446049250313e-16;
  neg avg log EPS|prob@'class
  }

// @kind function
// @category metric
// @desc Mean square error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The mean squared error between predicted values and
//   the true values
mse:{[pred;true]
  avg diff*diff:pred-true
  } 

// @kind function
// @category metric
// @desc Sum squared error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The sum squared error between predicted values and
//   the true values
sse:{[pred;true]
  sum diff*diff:pred-true
  }

// @kind function
// @category metric
// @desc Root mean squared error 
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The root mean squared error between predicted values 
//   and the true values
rmse:{[pred;true]
  sqrt mse[pred;true]
  }

// @kind function
// @category metric
// @desc Root mean squared log error 
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The root mean squared log error between predicted values
//   and the true values
rmsle:{[pred;true]
  rmse . log(pred;true)+1
  }

// @kind function
// @category metric
// @desc Residual squared error 
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @param n {long} The degrees of freedom of the residual
// @returns {float} The residual squared error between predicted values
//   and the true values
rse:{[pred;true;n]
  sqrt sse[pred;true]%n
  }
 
// @kind function
// @category metric
// @desc Mean absolute error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The mean absolute error between predicted values
//   and the true values
mae:{[pred;true]
  avg abs pred-true
  }

// @kind function
// @category metric
// @desc Mean absolute percentage error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The mean absolute percentage error between predicted values
//   and the true values
mape:{[pred;true]
  100*avg abs 1-pred%true
  }

// @kind function
// @category metric
// @desc Symmetric mean absolute percentage error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The symmetric-mean absolute percentage between predicted
//   and true values
smape:{[pred;true]
  sumAbsVals:abs[pred]+abs true;
  100*avg abs[true-pred]%sumAbsVals
  }

// @kind function
// @category metric
// @desc R2-score for regression model validation
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The R2-score between the true and predicted values.
//   Values close to 1 indicate good prediction, while negative values 
//   indicate poor predictors of the system behavior
r2Score:{[pred;true]
  1-sse[true;pred]%sse[true]avg true
  }

// @kind function
// @category metric
// @desc R2 adjusted score for regression model validation
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @param p {long} Number of independent regressors, i.e. the number of 
//   variables in your model, excluding the constant
// @returns {float} The R2 adjusted score between the true and predicted 
//   values. Values close to 1 indicate good prediction, while negative values 
//   indicate poor predictors of the system behavior
r2AdjScore:{[pred;true;p]
  n:count pred;
  r2:r2Score[pred;true];
  1-(1-r2)*(n-1)%(n-p)-1
  }

// @kind function
// @category metric
// @desc One-sample t-test score
// @param sample {number[]} A set of samples from a distribution
// @param mu {float} The population mean
// @returns {float} The one sample t-score for a distribution with less than 
//   30 samples. 
tScore:{[sample;mu]
  (avg[sample]-mu)%sdev[sample]%sqrt count sample
  }

// @kind function
// @category metric
// @desc T-test for independent samples with equal variances 
//   and equal sample size
// @param sample1 {number[]} A sample from a distribution
// @param sample1 {number[]} A sample from a distribution
// sample1&2 are independent with equal variance and sample size
// @returns {float} Their t-test score 
tScoreEqual:{[sample1;sample2]
  count1:count sample1;
  count2:count sample2;
  absAvg:abs avg[sample1]-avg sample2;
  absAvg%sqrt(svar[sample1]%count1)+svar[sample2]%count2
  }

// @kind function
// @category metric
// @desc Calculate the covariance of a matrix
// @param matrix {number[]} A sample from a distribution
// @returns {number[]} The covariance matrix 
covMatrix:{[matrix]
  matrix:"f"$matrix;
  n:til count matrix;
  avgMat:avg each matrix;
  upperTri:matrix$/:'n _\:matrix;
  diag:not n=\:n;
  matrix:(n#'0.0),'upperTri%count first matrix;
  multiplyMat:matrix+flip diag*matrix;
  multiplyMat-avgMat*\:avgMat
  }

// @kind function
// @category metric
// @desc Calculate the correlation of a matrix or table
// @param data {table|number[]} A sample from a distribution
// @returns {dictionary|number[]} The covariance of the data 
corrMatrix:{[data]
  dataTab:98=type data;
  matrix:$[dataTab;value flip@;]data;
  corrMat:i.corrMatrix matrix;
  $[dataTab;{x!x!/:y}cols data;]corrMat
  }

// @kind function
// @category metric
// @desc X- and Y-axis values for an ROC curve
// @param label {number[]|boolean[]} Label associated with a prediction
// @param prob {float[]} Probability that each prediction belongs to 
//   the positive class
// @returns {number[]} The coordinates of the true-positive and false-positive 
//   values associated with the ROC curve
roc:{[label;prob]
  if[not 1h=type label;label:label=max label];
  tab:(update sums label from`prob xdesc([]label;prob));
  probDict:exec 1+i-label,label from tab where prob<>next prob;
  0^{0.,x%last x}each value probDict
  }

// @kind function
// @category metric
// @desc Area under an ROC curve
// @param label {number[]|boolean[]} Label associated with a prediction
// @param prob {float[]} Probability that each prediction belongs to 
//   the positive class
// @returns {float} The area under the ROC curve
rocAucScore:{[label;prob]
  i.auc . i.curvePts . roc[label;prob]
  }

// @kind function
// @category metric
// @desc Sharpe ratio anualized based on daily predictions
// @param pred {int[]|boolean[]|string[]} A vector/matrix of predicted labels 
// @param true {int[]|boolean[]|string[]} A vector/matrix of true labels 
// @returns {float} The sharpe ratio of predictions made
sharpe:{[pred;true]
  sqrt[252]*avg[pred*true]%dev pred*true
  }

