\d .ml

// @kind function
// @category metric
// @fileoverview Accuracy of classification results
// @param pred {int[];bool[];str[]} A vector/matrix of predicted labels 
// @param true {int[];bool[];str[]} A vector/matrix of true labels 
// @returns {float} The accuracy of predictions made
accuracy:{[pred;true]
  avg pred=true
  }

// @kind function
// @category metric
// @fileoverview Precision of a binary classifier
// @param pred {bool[]} A vector of predicted labels 
// @param true {bool[]} A vector of true labels
// @param posClass {bool} The positive class 
// @returns {float} A measure of the precision
precision:{[pred;true;posClass]
  predPos:pred=posClass;
  truePos:predPos&true=posClass;
  sum[truePos]%sum predPos
  }

// @kind function
// @category metric
// @fileoverview Sensitivity of a binary classifier
// @param pred {bool[]} A vector of predicted labels 
// @param true {bool[]} A vector of true labels
// @param posClass {bool} The positive class 
// @returns {float} A measure of the sensitivity
sensitivity:{[pred;true;posClass]
  realPos:true=posClass;
  truePos:realPos&pred=posClass;
  sum[truePos]%sum realPos
  }

// @kind function
// @category metric
// @fileoverview Specificity of a binary classifier
// @param pred {bool[]} A vector of predicted labels 
// @param true {bool[]} A vector of true labels
// @param posClass {bool} The positive class 
// @returns {float} A measure of the specificity
specificity:{[pred;true;posClass]
  allNeg:true<>posClass;
  trueNeg:allNeg&pred<>posClass;
  sum[trueNeg]%sum allNeg
  }

// @kind function
// @category metric
// @fileoverview F-beta score for classification results
// @param pred {num[];bool[]} A vector of predicted labels 
// @param true {num[];bool[]} A vector of true labels
// @param posClass {num;bool} The positive class
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
// @fileoverview F-1 score for classification results
// @param pred {int[];bool[];str[]} A vector of predicted labels 
// @param true {int[];bool[];str[]} A vector of true labels
// @param posClass {num;bool} The positive class
// @returns {float} The F-1 score between predicted and true labels
f1Score:fBetaScore[;;;1]

// @kind function
// @category metric
// @fileoverview Matthews-correlation coefficient
// @param pred {int[];bool[];str[]} A vector of predicted labels 
// @param true {int[];bool[];str[]} A vector of true labels
// @returns {float} The Matthews-correlation coefficient between predicted
//   and true values
matthewCorr:{[true;pred]
  confMat:value confMatrix[true;pred];
  sqrtConfMat:sqrt prd sum[confMat],sum each confMat;
  .[-;prd raze[confMat](0 1;3 2)]%sqrtConfMat
  }

// @kind function
// @category metric
// @fileoverview Confusion matrix
// @param pred {int[];bool[];str[]} A vector of predicted labels 
// @param true {int[];bool[];str[]} A vector of true labels
// @returns {dict} A confusion matrix
confMatrix:{[pred;true]
  classes:asc distinct pred,true;
  if[1=type classes;classes:01b];
  classDict:classes!(2#count classes)#0;
  groupClass:0^((count each group@)each pred group true)@\:classes;
  classDict,groupClass
  }

// @kind function
// @category metric
// @fileoverview True/false positives and true/false negatives
// @param pred {int[];bool[];str[]} A vector of predicted labels 
// @param true {int[];bool[];str[]} A vector of true labels
// @param posClass {num;bool} The positive class
// @returns {dict} The count of true positives (tp), true negatives (tn),
//   false positives (fp) and false negatives (fn) 
confDict:{[pred;true;posClass]
  confKeys:`tn`fp`fn`tp;
  confVals:raze value confMatrix .(pred;true)=posClass;
  confKeys!confVals
  }

// @kind function
// @category metric
// @fileoverview Statistical information about classification result
// @param pred {int[];bool[];str[]} A vector of predicted labels 
// @param true {int[];bool[];str[]} A vector of true labels
// @returns {tab} The accuracy, precision, f1 scores and the support 
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
// @fileoverview Logarithmic loss
// @param class {bool[]} Class labels
// @param prob {float[]} Representing the probability of belonging to 
//   each class
// @returns {float} Total logarithmic loss
crossentropy:logLoss:{[class;prob]
  EPS:1e-15;
  neg avg log EPS|prob@'class
  }

// @kind function
// @category metric
// @fileoverview Mean square error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The mean squared error between predicted values and
//   the true values
mse:{[pred;true]
  avg diff*diff:pred-true
  } 

// @kind function
// @category metric
// @fileoverview Sum squared error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The sum squared error between predicted values and
//   the true values
sse:{[pred;true]
  sum diff*diff:pred-true
  }

// @kind function
// @category metric
// @fileoverview Root mean squared error 
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The root mean squared error between predicted values 
//   and the true values
rmse:{[pred;true]
  sqrt mse[pred;true]
  }

// @kind function
// @category metric
// @fileoverview Root mean squared log error 
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The root mean squared log error between predicted values
//   and the true values
rmsle:{[pred;true]
  rmse . log(pred;true)+1
  }

// @kind function
// @category metric
// @fileoverview Residual squared error 
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
// @fileoverview Mean absolute error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The mean absolute error between predicted values
//   and the true values
mae:{[pred;true]
  avg abs pred-true
  }

// @kind function
// @category metric
// @fileoverview Mean absolute percentage error
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @returns {float} The mean absolute percentage error between predicted values
//   and the true values
mape:{[pred;true]
  100*avg abs 1-pred%true
  }

// @kind function
// @category metric
// @fileoverview Symmetric mean absolute percentage error
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
// @fileoverview R2-score for regression model validation
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
// @fileoverview R2 adjusted score for regression model validation
// @param pred {float[]} A vector of predicted labels 
// @param true {float[]} A vector of true labels
// @param p {long} Number of independent regressors, i.e. the number of 
//   variables in your model, excluding the constant
// @returns {float} The R2 adjusted score between the true and predicted values.
//   Values close to 1 indicate good prediction, while negative values 
//   indicate poor predictors of the system behavior
r2AdjScore:{[pred;true;p]
  n:count pred;
  r2:r2Score[pred;true];
  1-(1-r2)*(n-1)%(n-p)-1
  }

// @kind function
// @category metric
// @fileoverview One-sample t-test score
// @param sample {num[]} A set of samples from a distribution
// @param mu {float} The population mean
// @returns {float} The one sample t-score for a distribution with less than 
//   30 samples. 
tScore:{[sample;mu]
  (avg[sample]-mu)%sdev[sample]%sqrt count sample
  }

// @kind function
// @category metric
// @fileoverview T-test for independent samples with equal variances 
//   and equal sample size
// @param sample1 {num[]} A sample from a distribution
// @param sample1 {num[]} A sample from a distribution
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
// @fileoverview Calculate the covariance of a matrix
// @param matrix {num[]} A sample from a distribution
// @returns {num[]} The covariance matrix 
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
// @fileoverview Calculate the correlation of a matrix
// @param matrix {num[]} A sample from a distribution
// @returns {num[]} The covariance matrix 
corrMatrix:{[matrix]
  devMatrix:dev each matrix;
  covMatrix[matrix]%devMatrix*/:devMatrix
  }

// not documented

// @kind function
// @category metric
// @fileoverview Table-like correlation matrix for a simple table
// @param data {tab;num[]} Numerical values
// @returns {dict} A correlation matrix in tabular format 
corrMat:{[data]
  dataTab:98=type data;
  matrix:$[dataTab;value flip@;]data;
  corrMat:corrMatrix matrix;
  $[dataTab;{x!x!/:y}cols data;]corrMat
  }

// @kind function
// @category metric
// @fileoverview X- and Y-axis values for an ROC curve
// @param label {num[];bool[]} Label associated with a prediction
// @param prob {float[]} Probability that each prediction belongs to 
//   the positive class
// @returns {num[]} The coordinates of the true-positive and false-positive 
//   values associated with the ROC curve
roc:{[label;prob]
  tab:(update sums label from`prob xdesc([]label;prob));
  probDict:exec 1+i-label,label from tab where prob<>next prob;
  {0.,x%last x}each value probDict
  }

// @kind function
// @category metric
// @fileoverview Area under an ROC curve
// @param label {num[];bool[]} Label associated with a prediction
// @param prob {float[]} Probability that each prediction belongs to 
//   the positive class
// @returns {float} The area under the ROC curve
rocAucScore:{[label;prob]
  i.auc . i.curvePts . roc[label;prob]
  }
