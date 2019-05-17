\d .ml

/hierarchical clustering
/* d  = data
/* k  = number of clusters
/* df = distance function/metric
/* lf = linkage function

clust.hc:{[d;k;df;lf]
 t:$[b:lf in`complete`average`ward;clust.i.buildtab[d;df];clust.kd.buildtree[d;til count d;sd:clust.i.dim d;df]];
 clust.i.rtab[d]$[lf~`ward;$[df<>`e2dist;'`$"ward must be used with e2dist";clust.i.cn1[k]clust.i.algow[df;lf]/@[t;`nnd;%;2]];b;clust.i.cn1[k]clust.i.algoca[df;lf]/t;
  lf~`single;clust.i.cn2[k]clust.i.algos[d;df;lf;sd]/t;clust.i.cn2[k]clust.i.algocc[d;df;df;lf;sd;0b]/t]}

/CURE algorithm
/* r = number of representative points
/* c = compression

clust.ccure:{[d;k;df;r;c;b;s]
 $[b;[cst:clust.cure.cure[r;c;k;flip d];
 ([]idx:til count d;clt:{where y in'x}[cst]each til count d;pts:d)];
 [t:clust.kd.buildtree[d;til count d;sd:clust.i.dim d;df];
 $[s;{select from x where valid};clust.i.rtab[d]]clust.i.cn2[k]clust.i.algocc[d;df;r;c;sd;1b]/t]]}

/DBSCAN algorithm
/* p = minimum number of points per cluster
/* e = epsilon value

clust.dbscan:{[d;df;p;e]
 dm:clust.i.epdistmat[df;e;flip d]'[d;k:til count d];
 t:([]idx:k;dist:dm;clt:0N;valid:1b);
 clust.i.rtabdb[d]{0N<>x 1}clust.i.algodb[p]/(t;0;0)}

/k-means algorithm
/* n = number of iterations
/* i = initialisation type - 1b use points in dataset or 0b random initialisation

clust.kmeans:{[d;k;n;i;df]
 dm:clust.i.typecast dm:flip d;
 init:$[i;clust.i.kpp[dm;k];clust.i.randinitf[dm;k]];
 centers:n{{avg each x@\:y}[x]each value group clust.i.mindist[x;y;z]}[dm;;df]/init;
 clust.i.rtabkm[d]clust.i.mindist[dm;centers;df]}

/cluster new points
clust.clustnew:{
 cl:$[z;raze clust.i.whichcl[x;exec idx from x where dir=2]each y;
  x[`clt]{clust.kd.i.imin sum each k*k:y-/:x}[x`pts]each y];
 ([]pts:y;clt:cl)}
