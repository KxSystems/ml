\d .ml


/ User Functions
clust.hc:{[d;k;df;lf;c]
 d:`float$d;w:clust.i.errchk[df;lf];
 if[b:lf in`complete`average`ward;t:clust.i.buildtab[d;df]];
 clust.i.rtab[d]$[b;clust.i.cn[k]clust.i.algocaw[df;lf]/$[w;@[;`nnd;%;2];]t;(::)]}

/ Utilities
clust.i.algocaw:{[df;lf;t]
 cd:value first select i,clt,nni from t where nnd=min nnd;
 clust.i.updtab . clust.i.newmin[lf;df;lf;t;cd]}
clust.i.buildtab:{
 d:{(d i;i:first 1_iasc d:clust.i.dd[z]each x-/:y)}[;x;y]each x;
 flip`idx`pts`clt`nni`nnd!(i;x;i:til count x;d[;1];d[;0])}
clust.i.cln:{
 {![x;enlist(=;`clt;z);0b;enlist[`clt]!enlist y]}/[x;til count cl;cl:exec distinct clt from x]}
clust.i.cn:{x<exec count distinct clt from y}
clust.i.dd:`e2dist`edist`mdist`cshev`nege2dist!
 ({x wsum x};{sqrt x wsum x};{sum abs x};{min abs x};{neg x wsum x})
clust.i.distca:{[lf;df;x;y]clust.i.ld[lf]each clust.i.dd[df]@'/:raze each x-/:\:/:y`pts}
clust.i.distcw:{[lf;df;x;y]clust.i.ld[lf][x`n]'[y`n;clust.i.dd[df]each x[`pts]-/:y`pts]}
clust.i.err:`dist`link`ward`kmns!
 (`$"invalid distance metric - must be in .ml.clust.i.dd";
  `$"invalid linkage - must be in .ml.clust.i.ld";
  `$"ward must be used with e2dist";
  `$"kmeans must be used with edist/e2dist")
clust.i.errchk:{[df;lf]
 $[not df in key clust.i.dd;'clust.i.err`dist;
   not lf in key clust.i.ld;'clust.i.err`link;
   (df<>`e2dist)&w:lf~`ward;'clust.i.err`ward;w]}
clust.i.hcupd:{[df;lf;t;cl]
 dm:$[lf=`ward;clust.i.distcw[lf;df;cl;t:select clt,n,pts from t where clt<>cl`clt];
  clust.i.distca[lf;df;cl`pts;t:0!select pts by clt from t where clt<>cl`clt]];
 (cl`clt;(dm;t`clt)@\:clust.i.imin dm)}
clust.i.imin:{x?min x}
clust.i.ld:`single`complete`average`centroid`ward!(min;max;avg;raze;{z%(1%y)+1%x})
clust.i.nmca:{[df;lf;t;cd]
 t:update clt:(1+exec max clt from t)from t where clt in cd;
 nn:0!select pts by clt from t where nni in cd;
 du:clust.i.hcupd[df;lf;t]peach nn;
 (t;du)}
clust.i.nmw:{[df;lf;t;cd]
 t:update clt:(1+exec max clt from t)from t where clt in cd;
 p:sum exec count[i]*first pts by pts from t where clt=max clt;
 t:update pts:count[i]#enlist[p%count[i]]by clt from t where clt=max clt;
 ct:0!select n:count i,first pts,nn:any nni in cd by clt from t;
 du:clust.i.hcupd[df;lf;ct]each select from ct where nn;
 (t;du)}
clust.i.newmin:`average`complete`ward!(2#clust.i.nmca),clust.i.nmw
clust.i.rtab:{update pts:x from @[clust.i.cln;`idx`clt`pts#y;y]}
clust.i.updtab:{[t;x]![t;enlist(=;`clt;x 0);0b;`nnd`nni!x 1]}/