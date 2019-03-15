\l p.q
\l util/util.q
\l xval/xval.q
\l xval/tests/test.p
\l ml.q

py:.p.import[`sklearn.linear_model][`:LinearRegression][];
regr:.p.import[`sklearn.linear_model][`:ElasticNet];
regr2:.p.import[`sklearn.linear_model][`:ElasticNet][];
clf:.p.import[`sklearn.tree][`:DecisionTreeClassifier][];
dict:`max_iter`alpha!(100 200 1000;0.1 0.2);
sz:.2;
rnd:{.01*"j"$100*x};
m:10;
xf:flip value flip([]1000?100f;asc 1000?100f);
yf:asc 1000?100f;
xi:flip value flip([]1000?10000;asc 1000?10000);
yi:asc 1000?10000;
xb:flip value flip([]1000?0b;asc 1000?0b)
yb:1000?0b

o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (m,0N)#til count yf;
ii:1_(1 xprev k),'k:enlist each(m+1,0N)#til count yf;
split:.ml.xval.kfsplit[yf;3]


(rnd first .ml.xval.gridsearch[xf;yf;split;regr;dict])~rnd gridsearch[xf;yf]
(rnd first .ml.xval.gridsearch[xi;yi;split;regr;dict])~0.87
(rnd first .ml.xval.gridsearch[xb;yb;split;regr;dict])~rnd gridsearch[xb;yb]

(cols first .ml.xval.gridsearchfit[xf;yf;0.5;regr;dict])~`max_iter`alpha
(cols first .ml.xval.gridsearchfit[xi;yi;0.5;regr;dict])~`max_iter`alpha
(cols first .ml.xval.gridsearchfit[xb;yb;0.5;regr;dict])~`max_iter`alpha

(rnd .ml.xval.chainxval[xf;yf;m;py])~rnd avg crossval[xf;yf;first each o;last each o;m]
(rnd .ml.xval.chainxval[xi;yi;m;py])~rnd avg crossval[xi;yi;first each o;last each o;m]
(rnd .ml.xval.chainxval[xb;yb;m;py])~rnd avg crossval[xb;yb;first each o;last each o;m]

(rnd .ml.xval.kfoldx[xf;yf;split;regr2])~rnd avg kfold[xf;yf]
(rnd .ml.xval.kfoldx[xi;yi;split;regr2])~0.87
(rnd .ml.xval.kfoldx[xb;yb;split;regr2])~rnd avg kfold[xb;yb]


(rnd .ml.xval.kfsplit[xf;2])~rnd last each (.p.list kfsplit[xf;2])`
(rnd .ml.xval.kfsplit[xi;2])~rnd last each (.p.list kfsplit[xi;2])`
(rnd .ml.xval.kfsplit[xb;2])~rnd last each (.p.list kfsplit[xb;2])`

(floor rnd .ml.xval.rollxval[xf;yf;m;py])~floor rnd avg crossval[xf;yf;first each ii;last each ii;m]
(floor rnd .ml.xval.rollxval[xi;yi;m;py])~floor rnd avg crossval[xi;yi;first each ii;last each ii;m]
(floor rnd .ml.xval.rollxval[xb;yb;m;py])~floor rnd avg crossval[xb;yb;first each ii;last each ii;m]






