/load in embedPy
\l p.q
/load in all the .q scripts within the ml library

\d .ml
version:@[{TOOLKITVERSION};0;`development]
sstring:{$[10=type x;;string]x}
loadfile:{$[.z.q;;-1]"Loading ",x:1_string hsym`$sstring x;system"l ",path,"/",x;}
path:{$[count u:@[{1_string first` vs hsym`$u -3+count u:get .z.s};`;""];u;"ml"]}[]

/ evenly spaced values between x and y in steps of length z.
arange:{x+z*til ceiling(y-x)%z}
/ z evenly spaced values between x and y
linspace:{x+til[z]*(y-x)%z-1}
/ identity matrix
eye:{@[x#0.;;:;1.]each til x}
/ shape of a list
shape:{-1_count each first scan x}
range:{max[x]-min x}

/ descriptive statistics of the table columns
describe:{`count`mean`std`min`q1`q2`q3`max!flip(count;avg;sdev;min;percentile[;.25];percentile[;.5];percentile[;.75];max)@\:/:flip(exec c from meta[x]where t in"hijefpmdznuvt")#x}
/ percentile y of list x
percentile:{r[0]+(p-i 0)*last r:0^deltas x iasc[x]i:0 1+\:floor p:y*-1+count x}

/ x predictions, y labels, z positive predicted label precision,sensitivity(recall), specificity
accuracy:{avg x=y}
precision:{sum[u&x=y]%sum u:x=z}
sensitivity:{sum[(x=z)&x=y]%sum y=z}
specificity:{sum[u&x=y]%sum u:y<>z}
/ sum squared and mean squared error
mse:{avg d*d:x-y} 
sse:{sum d*d:x-y}

EPS:1e-15
/x is the actual class should be 0 or 1; y should be the probability of belonging to class 0 or 1 for each instance
logloss:{neg avg log EPS|y@'x}
/ x is alist of unique class labels (0 = class 1, 1 = class 2 ... ); y is the probability of belonging to a class
crossentropy:logloss

/ t-score for a t test (one sample)
tscore:{[x;mu](avg[x]-mu)%sdev[x]%sqrt count x}
/ t-score for t-test (two independent samples, not equal varainces)
tscoreeq:{abs[avg[x]-avg y]%sqrt(svar[x]%count x)+svar[y]%count y}


/ covariance/correlation calculate upper triangle only
cvm:{(x+flip(not n=\:n)*x:(n#'0.0),'(x$/:'(n:til count x)_\:x)%count first x)-a*\:a:avg each x:"f"$x}
crm:{cvm[x]%u*/:u:dev each x}
/ correlation matrix, in dictionary format if input is a table
corrmat:{$[t;{x!x!/:y}cols x;]crm$[t:98=type x;value flip@;]x}
/ confusion matrix, x predicted class, y actual class
confmat:{cs:asc distinct y;exec 0^(count each group pred)cs by label from([]pred:x;label:y)}
/ dictionary of tp/tn/fp/fn from confusion matrix
confdict:{`tp`fn`fp`tn!raze value confmat[x;y]}


/ points in curve represented by (x,y), excluding colinear points
curvepts:{(x;y)@\:where(1_differ deltas[y]%deltas x),1b}
/ area under the curve with points of coordinates (x,y)
auc:{sum 1_deltas[x]*y-.5*deltas y}
/ increasing false positive rates and true negatives rates to get the ROC curve
roc:{[y;p]{x%last x}each value exec 1+i-y,y from(update sums y from`p xdesc([]y;p))where p<>next p}
/ area under the ROC curve. x is the actual class and p the probability of belonging to the positive class
rocaucscore:{[y;p]auc . curvepts . roc[y;p]}

