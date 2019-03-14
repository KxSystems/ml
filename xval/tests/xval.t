\l p.q
\l util/util.q
\l xval/xval.q
\l ml.q
\l xval/tests/test.p


py:.p.import[`sklearn.linear_model][`:LinearRegression][];
regr:.p.import[`sklearn.linear_model][`:ElasticNet];
regr2:.p.import[`sklearn.linear_model][`:ElasticNet][];
clf:.p.import[`sklearn.tree][`:DecisionTreeClassifier][];
dict:`max_iter`alpha!(100 200 1000;0.1 0.2);
sz:.2;
rnd:{.01*"j"$100*x};
m:10;
xexample:flip value flip([]10000?100f;asc 10000?100f);
yexample:asc 10000?100f;

o:o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (m,0N)#til count yexample;
ii:1_(1 xprev k),'k:enlist each(m+1,0N)#til count yexample;
split:.ml.xval.kfsplit[yexample;3];


(rnd first .ml.xval.gridsearch[xexample;yexample;split;regr;dict])~rnd gridsearch[xexample;yexample]

(rnd .ml.xval.chainxval[xexample;yexample;m;py])~rnd avg crossval[xexample;yexample;first each o;last each o;m]

(rnd .ml.xval.kfoldx[xexample;yexample;split;regr2])~rnd avg kfold[xexample;yexample]

(rnd .ml.xval.kfsplit[xexample;2])~rnd last each (.p.list kfsplit[xexample;2])`

(floor 10*rnd .ml.xval.rollxval[xexample;yexample;m;py])~floor 10*rnd avg crossval[xexample;yexample;first each ii;last each ii;m]






