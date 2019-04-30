\d .ml

xval.i.shuffle:{neg[n]?n:count x}

xval.i.idx:{[k](0;k-1)_/:rotate[-1]\[til k]}
xval.i.splitidx:{[k;x](k;0N)#til count x}
xval.i.shuffidx:{[k;x](k;0N)#xval.i.shuffle x}
xval.i.stratidx:{[k;x]r@'xval.i.shuffle each r:(,'/)(k;0N)#/:value n@'xval.i.shuffle each n:group x}

xval.i.apply:{[idx;k;n;x;y;f]{[f;d]f d[]}[f]peach idx[k;n;x;y]}
xval.i.gen:{[f;g;k;n;x;y]raze n#enlist{{raze@''y}[;x]}each flip@'((x;y)@/:\:f[k;y])@\:/:g k}

xval.kfsplit:xval.i.apply xval.i.gen . xval.i`splitidx`idx
xval.kfshuff:xval.i.apply xval.i.gen . xval.i`shuffidx`idx
xval.kfstrat:xval.i.apply xval.i.gen . xval.i`stratidx`idx
xval.tsroll :xval.i.apply xval.i.gen[xval.i.splitidx]{[k]enlist@''0 1+/:til k-1}
xval.tschain:xval.i.apply xval.i.gen[xval.i.splitidx]{[k]flip(til each j;enlist@'j:1+til k-1)}
xval.mcsplit:xval.i.apply{[p;n;x;y]n#{[p;x;y;z](x;y)@\:/:(0,floor count[y]*1-p)_xval.i.shuffle y}[p;x;y]}

xval.gridsearch:{[f;x;y;algo;pd]p!f[x;y]peach algo@/:pykwargs@/:p:key[pd]!/:1_'(::)cross/value pd}
xval.gridsearchfit:{[f;x;y;algo;pd;pc]
  i:(0,floor count[y]*1-pc)_xval.i.shuffle y;
  pr:first key desc avg each r:xval.gridsearch[f;x i 0;y i 0;algo;pd];
  (pr;algo[pykwargs pr](x;y)@\:/:i)}

xval.fitscore:{[algo;p;d].[.[algo[p]`:fit;d 0]`:score;d 1]`}

/ allow multiprocess
loadfile`:util/mproc.q
loadfile`:util/pickle.q
if[0>system"s";mproc.init[abs system"s"]enlist".ml.loadfile`:util/pickle.q"];

xval.pickledump:{$[0<=system"s";;.p.i.isw x;.ml.pickledump;]x}
xval.pickleload:{$[4=type x;.ml.pickleload;]x}
