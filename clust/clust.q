\d .ml

/hierarchical clustering
/* d  = data
/* k  = number of clusters
/* df = distance function/metric   
/* lf = linkage function
clust.hc:{[d;k;df;lf]
 werr:`$"ward must be used with e2dist";
 t:$[b:lf in`complete`average`ward;clust.i.buildtab[d;df];clust.kd.buildtree[flip d;r:ceiling count[d]%100]]; 
 clust.i.rtab[d]$[b;clust.i.cn[k]clust.i.algocaw[df;lf]/$[lf~`ward;$[df<>`e2dist;'werr;@[t;`nnd;%;2]];t];
                  clust.i.algoscc[d;k;df;r;lf;0b;t;()]]}

/linkage matrix
clust.lkg:{[d;df;lf]
 m:([]i1:`int$();i2:`int$();dist:`float$();n:`int$());
 t:$[b:lf in`centroid`single;clust.kd.buildtree[flip d;r:ceiling count[d]%100];clust.i.buildtab[d;df]];
 $[b;clust.i.algoscc[d;1;df;r;lf;0b;t;m];({98h=type x 0}clust.i.algolkg[df;lf]/(t;m))1]}

/CURE algorithm
/* r = number of representative points
/* c = compression
/* b = boolean flag indicating whether to use C (1b) or q (0b) implementation
clust.ccure:{[d;k;df;r;c;b]
 t:clust.kd.buildtree[flip d;r];
 $[b;clust.i.rtabc[d]clust.cure.cure[r;c;k;flip d;df];clust.i.algoscc[d;k;df;r;c;1b;t;()]]}

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

/----streaming----\
/cluster new points
/* x = current table with `idx`pts`clt
/* y = new points to be clustered
clust.clustnew:{cl:x[`clt]{clust.i.imin sum each k*k:y-/:x}[x`pts]each y;([]pts:y;clt:cl)}