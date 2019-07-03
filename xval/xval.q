\d .ml

xv.i.shuffle:{neg[n]?n:count x}
xv.i.splitidx:{[k;x](k;0N)#til count x}
xv.i.shuffidx:{[k;x](k;0N)#xv.i.shuffle x}
xv.i.stratidx:{[k;x]r@'xv.i.shuffle each r:(,'/)(k;0N)#/:value n@'xv.i.shuffle each n:group x}
xv.i.groupidx:{[k](0;k-1)_/:rotate[-1]\[til k]}
xv.i.idx1:{[f;g;k;x;y]{{raze@''y}[;x]}each flip@'((x;y)@/:\:f[k;y])@\:/:g k}
xv.i.idxR:{[f;g;k;n;x;y]n#enlist xv.i.idx1[f;g;k;x;y]}
xv.i.idxN:{[f;g;k;n;x;y]xv.i.idx1[f;g;;x;y]@'n#k}

xv.j.kfsplit:xv.i.idxR . xv.i`splitidx`groupidx
xv.j.kfshuff:xv.i.idxN . xv.i`shuffidx`groupidx
xv.j.kfstrat:xv.i.idxN . xv.i`stratidx`groupidx
xv.j.tsrolls:xv.i.idxR[xv.i.splitidx]{[k]enlist@''0 1+/:til k-1}
xv.j.tschain:xv.i.idxR[xv.i.splitidx]{[k]flip(til each j;enlist@'j:1+til k-1)}
xv.j.pcsplit:{[p;n;x;y]n#{[p;x;y;z](x;y)@\:/:(0,floor n*1-p)_til n:count y}[p;x;y]}
xv.j.mcsplit:{[p;n;x;y]n#{[p;x;y;z](x;y)@\:/:(0,floor count[y]*1-p)_{neg[n]?n:count x}y}[p;x;y]}

xv,:xv.j,:1_{[idx;k;n;x;y;f]{[f;d]f d[]}[f]peach raze idx[k;n;x;y]}@'xv.j
gs:1_{[gs;k;n;x;y;f;p;t]
 if[t=0;:gs[k;n;x;y;f;p]];i:(0,floor count[y]*1-abs t)_$[t<0;xv.i.shuffle;til count@]y;
 (r;pr;f[pykwargs pr:first key desc avg each r:gs[k;n;x i 0;y i 0;f;p]](x;y)@\:/:i)
 }@'{[xv;k;n;x;y;f;p]p!(xv[k;n;x;y]f pykwargs@)@'p:key[p]!/:1_'(::)cross/value p}@'xv.j

xv.fitscore:{[f;p;d].[.[f[][p]`:fit;d 0]`:score;d 1]`}

/ multiprocess
loadfile`:util/mproc.q
loadfile`:util/pickle.q
if[0>system"s";mproc.init[abs system"s"]enlist".ml.loadfile`:util/pickle.q"];
xv.picklewrap:{picklewrap[(0>system"s")&.p.i.isw x]x}
