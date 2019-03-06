\l p.q
\l xval/init.q
\l xval/test/xval/p

n:10000
py:.p.import[`sklearn.linear_model][`:LinearRegression][]
regr:.p.import[`sklearn.linear_model][`:ElasticNet]
regr2:.p.import[`sklearn.linear_model][`:ElasticNet][]
clf:.p.import[`sklearn.tree][`:DecisionTreeClassifier][]
xg:flip value flip([]n?100f;asc n?100f)
yg:asc n?100f
dict:`max_iter`alpha!(100 200 1000;0.1 0.2)
split:.ml.xval.kfsplit[yg;3]
sz:0.2
rnd:{0.001*"j"$100*x}
m:10
o:o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (m,0N)#til count yg
i:1_(1 xprev k),'k:enlist each(m+1,0N)#til count yg



(rnd .ml.xval.chainxval[xg;yg;m;py])~rnd avg crossval[xg;yg;first each o;last each o;m]

(rnd first .ml.xval.gridsearch[xg;yg;split;regr;dict])~rnd gridsearch[xg;yg]


(rnd .ml.xval.kfoldx[xg;yg;split;regr2])~rnd avg kfold[xg;yg]


.ml.xval.kfsplit[xg;2]~last each (.p.list kfsplit[xg;2])`

(rnd .ml.xval.rollxval[xg;yg;m;py])~rnd avg crossval[xg;yg;first each i;last each i;m]






