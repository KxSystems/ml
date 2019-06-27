\d .ml

xval.i.shuffle:{neg[n]?n:count x}

xval.i.splitidx:{[k;x](k;0N)#til count x}
xval.i.shuffidx:{[k;x](k;0N)#xval.i.shuffle x}
xval.i.stratidx:{[k;x]r@'xval.i.shuffle each r:(,'/)(k;0N)#/:value n@'xval.i.shuffle each n:group x}
xval.i.groupidx:{[k](0;k-1)_/:rotate[-1]\[til k]}
xval.i.idx1:{[f;g;k;x;y]{{raze@''y}[;x]}each flip@'((x;y)@/:\:f[k;y])@\:/:g k}
xval.i.idxR:{[f;g;k;n;x;y]raze n#enlist xval.i.idx1[f;g;k;x;y]}
xval.i.idxN:{[f;g;k;n;x;y]raze xval.i.idx1[f;g;;x;y]each n#k}

xval.i.apply:{[idx;k;n;x;y;a;f]{[a;f;d]f[a[]]d[]}[xval.i.picklewrap a;f]peach idx[k;n;x;y]}

xval.kfsplit:xval.i.apply xval.i.idxR . xval.i`splitidx`groupidx
xval.kfshuff:xval.i.apply xval.i.idxN . xval.i`shuffidx`groupidx
xval.kfstrat:xval.i.apply xval.i.idxN . xval.i`stratidx`groupidx
xval.tsroll :xval.i.apply xval.i.idxR[xval.i.splitidx]{[k]enlist@''0 1+/:til k-1}
xval.tschain:xval.i.apply xval.i.idxR[xval.i.splitidx]{[k]flip(til each j;enlist@'j:1+til k-1)}
xval.pcsplit:xval.i.apply{[p;n;x;y]n#{[p;x;y;z](x;y)@\:/:(0,floor n*1-p)_til n:count y}[p;x;y]}
xval.mcsplit:xval.i.apply{[p;n;x;y]
 n#{[p;x;y;z](x;y)@\:/:(0,floor count[y]*1-p)_{neg[n]?n:count x}y}[p;x;y]}

xval.i.defaults:`xval`n`k`test`shuffle!(xval.pcsplit;1;.2;.2;0b)
xval.gridsearch:{[x;y;a;f;p;d]
 d:xval.i.defaults,$[d~(::);();d];
 p!(d[`xval][d`k;d`n][x;y;a]f pykwargs@)@'p:key[p]!/:1_'(::)cross/value p}
xval.gridsearchfit:{[x;y;a;f;p;d]
 d:xval.i.defaults,$[d~(::);();d];
 i:(0,floor count[y]*1-d`test)_$[d`shuffle;xval.i.shuffle;til count@]y;
 pr:first key desc avg each xval.gridsearch[x i 0;y i 0;a;f;p;d];
 (pr;f[pykwargs pr;a](x;y)@\:/:i)}

xval.fitscore:{[p;a;d].[.[a[p]`:fit;d 0]`:score;d 1]`}

/ multiprocess
loadfile`:util/mproc.q
loadfile`:util/pickle.q
if[0>system"s";mproc.init[abs system"s"]enlist".ml.loadfile`:util/pickle.q"];
xval.i.picklewrap:{picklewrap[(0>system"s")&.p.i.isw x]x}
