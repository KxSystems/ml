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
 pos:gridsearchmain[x;y;i;algo;dict];
 l:1=count kd:key dict;
 (max pos 0;$[l;$[1<count pos 1;kd 0;kd];kd]!$[l;pos 1;flip pos 1])}
gridsearchfit:{[x;y;sz;algo;dict]
 t:util.traintestsplit[x;y;sz];
 i:xval.kfshuff[t`ytrain;5];
 pos:gridsearchmain[t`xtrain;t`ytrain;i;algo;dict];
 l:1=count kd:key dict;
 bst:$[l;$[1<count pos 1;kd 0;kd];kd]!$[l;pos 1;flip pos 1];
 bfit:kd!$[l;enlist$[1<count value bst;first value bst;value bst];value first each bst];
 bo:mkalg[bfit;algo];
 fitfn:{y[`:fit][x`xtrain;x`ytrain][`:score][x`xtest;x`ytest]`};
 (bfit;fitfn[t;$[1<count bfit;bo 0;bo]])}

/ time-series based cross-validation
rollxval:{[x;y;n;algo]
 i:1_(1 xprev k),'k:enlist each(n+1,0N)#til count y;
 tseriesmain[x;y;i;algo]}
chainxval:{[x;y;n;algo]
 o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (n,0N)#til count y;
 tseriesmain[x;y;o;algo]}

/ looped/repeated cross-validation
// it should be noted here that these appear slower on the
// single processed version rather than when peached...
repkfval:{[x;y;n;k;algo]i:kfshuff[y;k];repfnmain[x;y;n;i;algo]}
repkfstrat:{[x;y;n;k;algo]i:xval.kfstrat[y;k];repfnmain[x;y;n;i;algo]}

/ code refactoring functions
tseriesmain:{[x;y;i;algo]
 algo:$[1<count .z.W;pickledump[algo];algo];
 data:(x@i),'y@i;
 avg kffitscore[algo]peach data}
repfnmain:{[x;y;n;k;algo]
 algo:$[1<count .z.W;pickledump[algo];algo];
 i:();do[n;i,:enlist k];
 avg kfoldpd[x;y;;algo]peach i} 

gridsearchmain:{[x;y;i;algo;dict]
 alg:$[1<count .z.W;pickledump[algo];mkalg[dict;algo]];
 data:distrib[x;i],'distrib[y;i];
 vals:$[4h=type alg;gengsearch[alg;dict];fitscore[alg]]peach data;
 aver:$[1=count shape vals;avg vals;avg each (,'/)vals];
 (aver;$[1=count key dict;(value dict)0;((cross/)value dict)] where aver=max aver)}
/ utils
distrib:{{(raze x _ y;x y)}[x y;]each til count y}
shuffle:{neg[n]?n:count x}
pickledump:{.p.import[`pickle][`:dumps;<][x]}
fitscore:{{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;y]each x}

/ these functions are called in the worker file -> worker processes but must be defined here currently

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
