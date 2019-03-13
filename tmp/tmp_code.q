\l ../init.q

\d .ml

/ Correlation based Feature Selection:
/ This function is limited in scope, issues arise in horizontally large datasets
/ this is due to the need to produce all combinations of features possible on 2 separate
/ occasions (probably is a way to do once & map)
/ it however is much faster on large row data than fresh significance testing.
/ It may be used as part of a iterative procedure with another method to find the best possible features
/ .i.e if high correlation remove, add next best feature... repeat until desired number of features are present
/* t = table
/* tgt = target
cfs:{[t;tgt]
 t:$[99=type t;value t;t];
 fc:(flip t)cor\:tgt;
 pairs:cols[t] -1+util.combs[;n]each n:(1+til count fc);
 k:raze{count each x}each pairs;
 rff:1^raze{avg each x}each(({`$x} each string each p cross p:cols[l])!raze flip l:value corrmat[t])@{{util.combs[2;x]}each x}each pairs;
 rcf:1^raze{avg each x}each{x@y}[fc]each pairs;
 (key 1#desc raze[pairs]!{(x*y)%sqrt x+x*(x-1)*z}[k;rcf;rff])0}



/ The following is an attempt at an implementation of
/ forward step-wise variable selection a technique which 'loops' over
/ increasing numbers of 'features' to find the cutoff where adding features no
/ longer improves the score of a machine learning algorithm.
/ Note that this works best on non deterministic models such as lin-regress/logistic-regress/SVM for example.
/* data = entire dataset from which subsets are chosen
/* targets = target vector
/* py = python model being tested
/* sz = train-test split percentage
xval.fswselect:{[data;target;py;sz]
 system"S 1";
 tts:util.traintestsplit[data;target;sz];
 ascpval:asc sigfeat[data;target];
 pickfn:{x#key y};
 ifp:2;isp:3;
 fp:pickfn[ifp;ascpval];sp:pickfn[isp;ascpval];
 while[(py[`:fit][flip(tts`xtrain)fp;tts`ytrain][`:score][flip(tts`xtest)fp;tts`ytest]`)<=
       py[`:fit][flip(tts`xtrain)sp;tts`ytrain][`:score][flip(tts`xtest)sp;tts`ytest]`;
       fp:pickfn[ifp+:1;ascpval];sp:pickfn[isp+:1;ascpval]];
 fp}
/ On the assumption that this test of the function is being done within the temp folder
// q)n:1000
// q)x:([]n?100f;n?100f;n?100f;n?100f;n?100f;(n?1000f)+asc n?100f;asc n?100f;desc n?100f;n?100f;n?100f;n?100f)
// q)y:asc n?100f
// q)py:.p.import[`sklearn.linear_model][`:LinearRegression][]
// q)sz:0.2
// q).ml.xval.fswselect[x;y;py;sz]



/ The following is an implementation of backward step-wise feature selection.
/ The cutoff for p-value which will be considered as the maximum value is 0.157 (chosen arbitrarily but ubiqutous in stats).
/ All features up to this threshold are considered and I 1-drop from this at each iteration and 'save' the scores, then find
/ the model from this set that maximizes the score from the model.
xval.bswselect:{[data;target;py;sz]
 tts:util.traintestsplit[data;target;sz];
 ascpval:asc sigfeat[tts`xtrain;tts`ytrain];
 keyvals:where ascpval<0.157;
 vallist:(1#keyvals),\1_keyvals;
 scores:{z[`:fit][flip(x`xtrain)y;x`ytrain][`:score][flip(x`xtest)y;x`ytest]`}[tts;;py]each vallist;
 raze vallist where scores=max scores}
// q)n:1000000
// q)x:([]n?100f;n?100f;n?100f;n?100f;n?100f;(n?1000f)+asc n?100f;asc n?100f;desc n?100f;n?100f;n?100f;n?100f)
// q)y:asc n?100f
// q)py:.p.import[`sklearn.linear_model][`:LinearRegression][]
// q)sz:0.2
// q).ml.xval.bswselect[x;y;py;sz]



/ In this function p is the percent of entire dataset contained in the testing and validation sets
/ The only real constraint is that the first point in the training set must be at least
/ 2*p*count data from the end of the set to ensure that there is enough 'space' to make the 'frames'
xval.krandint:{[x;y;p;algo]
 const_ind:neg[1+2*sz:"i"$p*count y] _ y;
 strt_ind:1?count const_ind;
 trn_ind:first[strt_ind]+til sz;
 val_ind:last[trn_ind]+1+til sz;
 xtrain:x trn_ind;ytrain:y trn_ind;
 xval:x val_ind;yval: y val_ind;
 algo[`:fit][xtrain;ytrain];
 pred:algo[`:predict][xval]`;
 .ml.accuracy[pred;yval]}

/ The following is an implementation of a random search algorithm.
/ In this case the number of 'draws' required to be above y% of the optimum is
/ fn = 1-(1-0.05)^n > y, as such 60 random draws will have a 5% chance of finding
/ a value near the optimum for that grid. 
/ https://stats.stackexchange.com/questions/160479/practical-hyperparameter-optimization-random-vs-grid-search
/ It is unlikely to find local optima in general unlike fw-stepwise etc.
rand_gridsearch:{[x;y;sz;n;algo;dict]
                tts:.ml.util.traintestsplit[x;y;sz];
                vals:();rdict:();
                dvals:(cross/)value dict;
                do[n;rdict,:enlist rand dvals];
                hyp:{key[y]!$[1=count x;enlist;]x}[;dict]each rdict;
                alg:algo@'{pykwargs x}each hyp;
                l:{y[`:fit][x`xtrain;x`ytrain][`:score][x`xtest;x`ytest]`}[tts]each alg;
                (max l;hyp first where l=max l)}
// q)N:10000
// q)x:flip value flip([]asc N?100f;N?1000;desc N?100f;asc N?1000f)
// q)y:asc N?100f
// q)algo:.p.import[`sklearn.linear_model][`:ElasticNet]
// q)dict:`alpha`l1_ratio`max_iter!(0.1*1+til 10;1%1+til 5;"j"$10 xexp til 5)
// q)sz:0.2
// q)n:60
// q)rand_gridsearch[x;y;sz;n;algo;dict]
// 0.99978
// `alpha`l1_ratio`max_iter!(0.1;0.3333333;10000)


/ The following are metrics derived from the confusion matrices however if they are
/ suitable to be added to the main toolkit is suspect
PPV:{d:confdict[x;y];l%d[`fp]+l:d`tp}                                                           / Positive predictive value - useful only for binary classifiers
NPV:{d:confdict[x;y];d[`tn]%d[`tp]+d`fn}                                                        / Negative predictive value
FDR:{1-PPV[x;y]}                                                                                / False Discovery Rate
FOR:{1-NPV[x;y]}                                                                                / False Omission Rate


/ Removal of duplicate columns from a table
/ here duplicate means the same exact values at all rows of the table
/ it is not necessary that the columns have the same names
util.dupcols:{[tab]
 m:raze {[x;val;tab][cols tab] n where val[x]~/:val[n:x+1 _(til count val)]
	 }[;flip value flip tab;tab]each til count flip tab;
 $[0=count m;tab;![tab;();0b;m]]}

/adaboost is used to improve the scores of weak learners
/ xtrain,ytrain - the x and y training data
/ xtest - the data that you want to predict
/ clf - the weak model used
/ iter - the amount of iterations used
fresh.adaboost:{[xtrain;ytrain;xtest;clf;iter]
 ada:{x>last y}[iter]{[clf;xtrain;ytrain;xtest;X]
  clf[`:fit][xtrain;ytrain;`sample_weight pykw w:X[2]];
  predtrain:clf[`:predict][xtrain]`;
  predtest:clf[`:predict][xtest]`;
  miss:`long$predtrain<>ytrain;
  miss2:@[miss;where miss=0;-;1];
  w*:exp miss2*alpham:0.5*log (1-errm)%errm:sum w*miss%sum w;
  ptrain:sum each (ptrain:X[0]),'alpham*predtrain;
  ptest:sum each (ptest:X[1]),'alpham*predtest;
  (ptrain;ptest;w;1+l:X[3])
  }[clf;xtrain;ytrain;xtest]/(ptrain:(nt)#0;ptest:ptest:(count xtest)#0;w:w:((nt)#1)%nt:count xtrain;0);
 {$[x>0;1;x=0;0;-1]}each ada[1]
 }

//converts a table to a matrix of values
tab2mat:{flip value flip x}

/x: table
/y: axis (`row, `col)
/z: any or all
dropna:{$[y~`row;x where not z null flip x;flip l!x l:where not z null x]}

// equivalent to pivoting a table in pandas
pivot:{[t;idx;sym;val]?[t;();enlist[idx]!enlist idx;(!;sym;val)]}

//Used as a metric score for clusters 
//x=pred value,y=true value
homogeneityscore:{(value group x)~value group y}



