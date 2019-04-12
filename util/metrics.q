\d .ml

/ descriptive statistics
range:{max[x]-min x}
/ percentile y of list x
percentile:{r[0]+(p-i 0)*last r:0^deltas asc[x]i:0 1+\:floor p:y*-1+count x}
describe:{`count`mean`std`min`q1`q2`q3`max!flip(count;avg;sdev;min;percentile[;.25];percentile[;.5];percentile[;.75];max)@\:/:flip(exec c from meta[x]where t in"hijefpmdznuvt")#x}

/ classification scores (x predictions, y labels, z positive label)
accuracy:{avg x=y}
precision:  {sum[u&y =z]%sum u:x =z}
sensitivity:{sum[u&x =z]%sum u:y =z}
specificity:{sum[u&x<>z]%sum u:y<>z}
/ f1&fbeta scores
fbscore:{[x;y;z;b](sum[ap&pp]*1+b*b)%sum[pp:x=z]+b*b*sum ap:y=z}
f1score:fbscore[;;;1]
/ matthews correlation coefficient
matcorr:{.[-;prd raze[m](0 1;3 2)]%sqrt prd sum[m],sum each m:value confmat[x;y]}
/ confusion matrix
confmat:{(k!(2#count k)#0),0^((count each group@)each x group y)@\:k:$[1=type k:asc distinct x,y;01b;k]}
/ confusion dictionary
confdict:{`tn`fp`fn`tp!raze value confmat .(x;y)=z}
/ class report
classreport:{[x;y]k:asc distinct y;
 t:`precision`recall`f1_score`support!((precision;sensitivity;f1score;{sum y=z}).\:(x;y))@/:\:k;
 ([]class:`$string[k],enlist"avg/total")!flip[t],(avg;avg;avg;sum)@'t}

/ x list of class labels (0,1,...,n-1), y list of lists of (n) probabilities (one per class)
i.EPS:1e-15
crossentropy:logloss:{neg avg log i.EPS|y@'x}

/ regression scores (x predictions, y values)
mse:{avg d*d:x-y} 
sse:{sum d*d:x-y}
rmse:{sqrt mse[x;y]}
rmsle:{rmse . log(x;y)+1}
mae:{avg abs x-y}
mape:{100*avg abs 1-x%y}
smape:{100*avg abs[y-x]%abs[x]+abs y}
r2score:{1-sse[x;y]%sse[x]avg x}

/ t-score for a test (one sample)
tscore:{[x;mu](avg[x]-mu)%sdev[x]%sqrt count x}
/ t-score for t-test (two independent samples, not equal variances)
tscoreeq:{abs[avg[x]-avg y]%sqrt(svar[x]%count x)+svar[y]%count y}

/ covariance/correlation calculate upper triangle only
cvm:{(x+flip(not n=\:n)*x:(n#'0.0),'(x$/:'(n:til count x)_\:x)%count first x)-a*\:a:avg each x:"f"$x}
crm:{cvm[x]%u*/:u:dev each x}
/ correlation matrix, in dictionary format if input is a table
corrmat:{$[t;{x!x!/:y}cols x;]crm$[t:98=type x;value flip@;]x}

/ exclude colinear point 
i.curvepts:{(x;y)@\:where(1b,2_differ deltas[y]%deltas x),1b}
/ area under curve (x,y)
i.auc:{sum 1_deltas[x]*y-.5*deltas y}
/ ROC curve: y the actual class, p the positive probability
roc:{[y;p]{0.,x%last x}each value exec 1+i-y,y from(update sums y from`p xdesc([]y;p))where p<>next p}
/ area under ROC curve
rocaucscore:{[y;p]i.auc . i.curvepts . roc[y;p]}
