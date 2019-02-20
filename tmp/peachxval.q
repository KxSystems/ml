/ The purpose of this script is to act as a initial test of the use of peach
/ in the context of a cross validation functions

\l p.q
\l ml/init.q

/ initialize the main process to connect w. worker ports
// q)workers[]
workers:{.z.pd:`u#hopen each prt}

/ peached k-fold cross validation
kfoldpd:{[x;y;i;algo]
 alg:picklealg[algo];
 data:distrib[x;i],'distrib[y;i];
 xfunc:{kffitscore[x;y]};
 vals:xfunc[alg;]peach data;
 aver:$[1=count .ml.shape vals;avg vals;avg each (,'/)vals]}

/ distributed cross-validated fitted grid searches
gridsearchpd:{[x;y;i;algo;dict]
 alg:picklealg[algo];
 data:distrib[x;i],'distrib[y;i];
 vals:gengsearch[alg;dict]peach data;
 aver:$[1=count .ml.shape vals;avg vals;avg each (,'/)vals];
 kd:key[dict];
 l:1=count kd;
 pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
 (max aver;$[l;$[1<count pos;(kd)0;kd];kd]!$[l;pos;flip pos])}
gridsearchfitpd:{[x;y;sz;algo;dict]
 alg:picklealg[algo];
 t:.ml.util.traintestsplit[x;y;sz];
 i:.ml.xval.kfshuff[t`ytrain;5];
 trdata:distrib[t`xtrain;i],'distrib[t`ytrain;i];
 vals:gengsearch[alg;dict]peach trdata;
 aver:$[1=count .ml.shape vals;avg vals;avg each (,'/)vals];
 l:1=count kd:key dict;
 pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
 bst:$[l;$[1<count pos;kd 0;kd];kd]!$[l;pos;flip pos];
 bfit:kd!value first each bst;
 bo:mkalg[bfit;algo];
 fitfn:{y[`:fit][x`xtrain;x`ytrain];y[`:score][x`xtest;x`ytest]`};
 (bfit;fitfn[t;$[1<count bst;bo 0;bo]])}

/ time-series specific peached cross-validations
chainxvalpd:{[x;y;n;algo]
 alg:picklealg[algo];
 o:reverse{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (n,0N)#til count y;
 dataset:(x@o),'y@o;
 avg kffitscore[alg]peach dataset}
rollxvalpd:{[x;y;n;algo]
 alg:picklealg[algo];
 i:reverse 1_(1 xprev k),'k:enlist each(n+1,0N)#til count y;
 dataset:(x@i),'y@i;
 avg kffitscore[alg]peach dataset}

/ looped/repeated cross-validation functions
mcxvalpd:{[x;y;sz;algo;n]
 alg:picklealg[algo];
 val:();trn:();
 do[n;val,:enlist neg[k:"j"$sz*count i]#i:shuffle y;trn,:enlist neg[k]_i];
 dsplit:{[x;y;z;val;trn](x trn z; x val z;y trn z;y val z)}[x;y;;val;trn]each til n;
 avg kffitscore[alg]peach dsplit}
repkfvalpd:{[x;y;n;k;algo]
 alg:picklealg[algo];
 i:();do[n;i,:enlist .ml.xval.kfshuff[y;k]];
 avg kfoldx2[x;y;;alg]peach i}
repkfstratpd:{[x;y;n;k;algo]
 alg:picklealg[algo];
 i:();do[n;i,:enlist .ml.xval.kfstrat[y;k]];
 avg kfoldx2[x;y;;alg]peach i}

/ utils
distrib:{{(raze x _ y;x y)}[x y;]each til count y}
picklealg:{.p.import[`pickle][`:dumps;<][x]}
mkalg:{[dict;algo]$[1=count kd:key[dict];
 {x[(y 0) pykw z]}[algo;kd]each (value dict)0;
 algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}
gengsearch:{[x;dict;data]mdl:.p.import[`pickle][`:loads][x];
 algs:mkalg[dict;mdl];
 {x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;data]each algs}
kffitscore:{[x;data]
  mdl:.p.import[`pickle][`:loads][x];
  {x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[mdl;data]}
shuffle:{neg[n]?n:count x}
kfoldx2:{[x;y;i;fn]
 alg:.p.import[`pickle][`:loads][fn];
 data:distrib[x;i],'distrib[y;i];
 vals:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[alg]each data;
 $[1=count shape vals;avg vals;avg each (,'/)vals]}

n:rand 3000+til 10000                                       / set random port to start opening
prt:n+til slvs:abs system"s"	                            / get correct number of ports
/ system execution for opening ports,  and logs to the ports
system each ("q ml/tmp/workerside.q -p "),/:string[prt];
