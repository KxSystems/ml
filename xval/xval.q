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

xv.i.search:{[sf;k;n;x;y;f;p;t]
 if[t=0;:sf[k;n;x;y;f;p]];i:(0,floor count[y]*1-abs t)_$[t<0;xv.i.shuffle;til count@]y;
 (r;pr;f[pykwargs pr:first key desc avg each r:sf[k;n;x i 0;y i 0;f;p]](x;y)@\:/:i)}
xv.i.xvpf:{[pf;xv;k;n;x;y;f;p]p!(xv[k;n;x;y]f pykwargs@)@'p:pf p}
gs:1_xv.i.search@'xv.i.xvpf[{[p]key[p]!/:1_'(::)cross/value p}]@'xv.j
rs:1_xv.i.search@'xv.i.xvpf[{[p]hp.hpgen p}]@'xv.j

xv.fitscore:{[f;p;d].[.[f[][p]`:fit;d 0]`:score;d 1]`}

hp.hpgen:{
  if[(::)~n:x`n;n:16];
  if[(`sobol=x`typ)&k<>floor k:xlog[2]n;'"trials must equal 2^n for sobol search"];
  num:where any`uniform`loguniform=\:first each p:x`p;
  system"S ",string$[(::)~x`random_state;42;x`random_state];
  pysobol:.p.import[`sobol_seq;`:i4_sobol_generate;<];
  genpts:$[`sobol~typ:x`typ;enlist each flip pysobol[count num;n];`random~typ;n;'"hyperparam type not supported"];
  prms:distinct flip hp.i.hpgen[typ;n]each p,:num!p[num],'genpts;
  if[n>dst:count prms;
    if[`sobol=x`typ;dst:"j"$xexp[2]floor xlog[2]dst;prms:neg[dst]?prms];
    -1"Number of distinct hp sets less than n, returning ",string[dst]," sets."];
  prms}
hp.i.hpgen:{[ns;n;p]
  p:@[;0;first](0;1)_p,();
  $[(typ:p 0)~`boolean;n?0b;
    typ in`rand`symbol;n?(),p[1]0;
    typ~`uniform;hp.i.uniform[ns]. p 1;
    typ~`loguniform;hp.i.loguniform[ns]. p 1;
    '"please enter a valid type"]}
hp.i.uniform:{[ns;lo;hi;typ;p]if[hi<lo;'"upper bound must be greater than lower bound"];hp.i[ns][`uniform][lo;hi;typ;p]}
hp.i.loguniform:xexp[10]hp.i.uniform::
hp.i.random.uniform:{[lo;hi;typ;n]lo+n?typ$hi-lo}
hp.i.sobol.uniform:{[lo;hi;typ;seq]typ$lo+(hi-lo)*seq}

/ multiprocess
loadfile`:util/mproc.q
loadfile`:util/pickle.q
if[0>system"s";mproc.init[abs system"s"]enlist".ml.loadfile`:util/pickle.q"];
xv.picklewrap:{picklewrap[(0>system"s")&.p.i.isw x]x}