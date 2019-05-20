\d .ml

/hierarchical clustering
/* d  = data
/* k  = number of clusters
/* df = distance function/metric
/* lf = linkage function
clust.hc:{[d;k;df;lf]
 if[b:lf in`complete`average`ward;t:clust.i.buildtab[d;df]]; 
 clust.i.rtab[d]$[lf~`ward;$[df<>`e2dist;'`$"ward must be used with e2dist";clust.i.cn[k]clust.i.algocaw[df;lf]/@[t;`nnd;%;2]];                       b;clust.i.cn[k]clust.i.algocaw[df;lf]/t;clust.i.algoscc[flip d;k;df;ceiling count[d]%100;lf;0b]]}

/linkage matrix
clust.lkg:{[d;df;lf]
 t:clust.i.buildtab[d;df];
 m:([]i1:`int$();i2:`int$();dist:`float$();n:`int$());
 ({98h=type x 0}clust.i.algolkg[df;lf]/(t;m))1}

/CURE algorithm
/* r = number of representative points
/* c = compression
clust.ccure:{[d;k;df;r;c;b]
 $[b;[cst:clust.cure.cure[r;c;k;flip d];([]idx:til count d;clt:{where y in'x}[cst]each til count d;pts:d)];
   clust.i.algoscc[flip d;k;df;r;c;1b]]}

/DBSCAN algorithm
/* p = minimum number of points per cluster
/* e = epsilon value
clust.dbscan:{[d;df;p;e]
 dm:clust.i.distmat[df;e;flip d]'[d;k:til count d];
 t:([]idx:k;dist:dm;clt:0N;valid:1b);
 clust.i.rtabdb[d]{0N<>x 1}clust.i.algodb[p]/(t;0;0)}

/k-means algorithm
/* n = number of iterations
/* i = initialisation type - 1b use points in dataset or 0b random initialisation
clust.kmeans:{[d;k;n;i;df]
 dm:clust.i.typecast dm:flip d;
 init:$[i;clust.i.kpp[dm;k];clust.i.randinit[dm;k]];
 centers:n{{avg each x@\:y}[x]each value group clust.i.mindist[x;y;z]}[dm;;df]/init;
 clust.i.rtabkm[d]clust.i.mindist[dm;centers;df]}


/--streaming---
/cluster new points
/
clust.clustnew:{
 cl:$[z;raze clust.i.whichcl[x;exec idx from x where dir=2]each y;
  x[`clt]{clust.i.imin sum each k*k:y-/:x}[x`pts]each y];
 ([]pts:y;clt:cl)}
\
clust.clustnew:{cl:x[`clt]{clust.i.imin sum each k*k:y-/:x}[x`pts]each y;([]pts:y;clt:cl)}
