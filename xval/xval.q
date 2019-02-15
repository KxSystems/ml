\d .ml

/ data-splitting
kfshuff:xval.kfshuff:{(y,0N)#shuffle x}
xval.kfsplit:{(y,0N)#til count x}
xval.kfstrat:{(,'/){(y,0N)#x}[;y]each value n@'shuffle each n:group x shuffle x}

/ k-fold cross validation
kfoldx:xval.kfoldx:{[x;y;i;fn]
 data:distrib[x;i],'distrib[y;i];
 vals:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[fn]each data;
 $[1=count shape vals;avg vals;avg each (,'/)vals]}

/ cross-validated grid-searches
xval.gridsearch:{[x;y;i;algo;dict]
 alg:mkalg[dict;algo];
 data:distrib[x;i],'distrib[y;i];
 vals:{{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;y]each x}[alg]each data;
 aver:$[1=count shape vals;avg vals;avg each (,'/)vals];
 l:1=count kd:key dict;
 pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
 (max aver;$[l;$[1<count pos;(kd)0;kd];kd]!$[l;pos;flip pos])}
xval.gridsearchfit:{[x;y;sz;algo;dict]
 t:util.traintestsplit[x;y;sz];
 alg:mkalg[dict;algo];
 i:xval.kfshuff[t`ytrain;5];
 trdata:distrib[t`xtrain;i],'distrib[t`ytrain;i];
 vals:{{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;y]each x}[alg]each trdata;
 aver:$[1=count shape vals;avg vals;avg each (,'/)vals];
 l:1=count kd:key dict;
 pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
 bst:$[l;$[1<count pos;kd 0;kd];kd]!$[l;pos;flip pos];
 bfit:kd!value first each bst;
 bo:mkalg[bfit;algo];
 fitfn:{y[`:fit][x`xtrain;x`ytrain];y[`:score][x`xtest;x`ytest]`};
 (bfit;fitfn[t;$[1<count bst;bo 0;bo]])}

/ time-series based cross-validation
xval.rollxval:{[x;y;n;algo]
 i:1_(1 xprev k),'k:enlist each(n+1,0N)#til count y;
 data:x@i;tar:y@i;
 avg{[x;y;z;k]x[`:fit][(y k)0;(z k)0];x[`:score][(y k)1;(z k)1]`}[algo;data;tar]each til n}
xval.chainxval:{[x;y;n;algo]
 o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (n,0N)#til count y;
 data:x@o; tar:y@o;
 avg{[x;y;z;k]x[`:fit][(y k)0;(z k)0];x[`:score][(y k)1;(z k)1]`}[algo;data;tar]each til n-1}

/ looped/repeated cross-validations
xval.mcxval:{[x;y;sz;algo;n]
 val:();trn:();
 do[n;val,:enlist neg[k:"j"$sz*count i]#i:shuffle y;trn,:enlist neg[k]_i];
 dsplit:{[x;y;z;val;trn](x trn z; x val z;y trn z;y val z)}[x;y;;val;trn]each til n;
 avg{[x;y;z]x[`:fit][(y z)0;(y z)2];x[`:score][(y z)1;(y z)3]`}[algo;dsplit]each til n}
xval.repkfval:{[x;y;n;k;algo]pred:();do[n;i:xval.kfshuff[y;k];pred,:kfoldx[x;y;i;algo]];avg pred}
xval.repkfstrat:{[x;y;n;k;algo]pred:();do[n;i:xval.kfstrat[y;k];pred,:kfoldx[x;y;i;algo]];avg pred}


/ utils
distrib:{{(raze x _ y;x y)}[x y;]each til count y}
shuffle:{neg[n]?n:count x}
mkalg:{[dict;algo]$[1=count kd:key[dict];
 {x[(y 0) pykw z]}[algo;kd]each (value dict)0;
 algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}
