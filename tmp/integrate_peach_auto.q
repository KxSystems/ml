\d .ml
\l ml/init.q

workers:{.z.pd:`u#hopen each prt}

/ data-splitting
kfshuff:xval.kfshuff:{(y,0N)#shuffle x}
xval.kfsplit:{(y,0N)#til count x}
xval.kfstrat:{(,'/){(y,0N)#x}[;y]each value n@'shuffle each n:group x shuffle x}

/ k-fold cross validation
kfoldx:xval.kfoldx:{[x;y;i;algo]
	data:distrib[x;i],'distrib[y;i];
	algo:$[1<count .z.W;pickledump[algo];algo];
	vals:kffitscore[algo]peach data;
	$[1=count shape vals;avg vals;avg each (,'/)vals]}
/ cross-validated grid-searches
gridsearch:{[x;y;i;algo;dict]
	alg:$[1<count .z.W;pickledump[algo];mkalg[dict;algo]];
	data:distrib[x;i],'distrib[y;i];
	vals:$[4h=type alg;gengsearch[alg;dict];fitscore[alg]]peach data;
	aver:$[1=count shape vals;avg vals;avg each (,'/)vals];
	kd:key[dict];l:1=count kd;
	pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
	(max aver;$[l;$[1<count pos;(kd)0;kd];kd]!$[l;pos;flip pos])}
gridsearchfit:{[x;y;sz;algo;dict]
	t:util.traintestsplit[x;y;sz];
	alg:$[1<count .z.W;pickledump[algo];mkalg[dict;algo]];
	i:xval.kfshuff[t`ytrain;5];
	trdata:distrib[t`xtrain;i],'distrib[t`ytrain;i];
	vals:$[4h=type alg;gengsearch[alg;dict];fitscore[alg]]peach trdata;
	aver:$[1=count shape vals;avg vals;avg each (,'/)vals];
	l:1=count kd:key dict;
	pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
	bst:$[l;$[1<count pos;kd 0;kd];kd]!$[l;pos;flip pos];
	bfit:kd!value first each bst;
	bo:mkalg[bfit;algo];
	fitfn:{y[`:fit][x`xtrain;x`ytrain];y[`:score][x`xtest;x`ytest]`};
	(bfit;fitfn[t;$[1<count bst;bo 0;bo]])}

/ time-series based cross-validation
rollxval:{[x;y;n;algo]
	alg:$[1<count .z.W;pickledump[algo];mkalg[dict;algo]];
	i:1_(1 xprev k),'k:enlist each(n+1,0N)#til count y;
	data:(x@i),'y@i;
	avg kffitscore[alg]peach data}
chainxval:{[x;y;n;algo]
	algo:$[1<count .z.W;pickledump[algo];algo];
	o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (n,0N)#til count y;
 	data:(x@o),'y@o;
	avg kffitscore[algo]peach data}

/ looped/repeated cross-validation
// it should be noted here that these appear slower on the
// single processed version rather than when peached...
repkfval:{[x;y;n;k;algo]
	algo:$[1<count .z.W;pickledump[algo];algo];
	i:();do[n;i,:enlist kfshuff[y;k]];
	avg kfoldpd[x;y;;algo]peach i}
repkfstrat:{[x;y;n;k;algo]
        algo:$[1<count .z.W;pickledump[algo];algo];
        i:();do[n;i,:enlist xval.kfstrat[y;k]];
        avg kfoldpd[x;y;;algo]peach i}

/ utils
distrib:{{(raze x _ y;x y)}[x y;]each til count y}
shuffle:{neg[n]?n:count x}
pickledump:{.p.import[`pickle][`:dumps;<][x]}
fitscore:{{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;y]each x}

mkalg:{[dict;algo]$[1=count kd:key[dict];
	{x[(y 0) pykw z]}[algo;kd]each (value dict)0;
	algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}
kffitscore:{[x;data]
	mdl:$[4h=type x;.p.import[`pickle][`:loads][x];x];
	{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[mdl;data]}
gengsearch:{[x;dict;data]
	mdl:.p.import[`pickle][`:loads][x];
	algs:mkalg[dict;mdl];
	{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;data]each algs}
kfoldpd:{[x;y;i;fn]
	data:distrib[x;i],'distrib[y;i];
	mdl:$[4h=type fn;.p.import[`pickle][`:loads][fn];fn];
	vals:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[mdl]each data;
	$[1=count shape vals;avg vals;avg each ('/)vals]}

/ set-up for execution on slave processes
n:rand 3000+til 10000
prt:n+til slvs:abs system"s"
/ system execution for opening ports
system each ("q ml/tmp/workerside.q -p "),/:string[prt];

