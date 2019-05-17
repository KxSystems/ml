\d .ml

/splitting dimensions of co-ordinates + next splitting dimension
clust.i.dim:{count first x}

/valid entries of a kd-tree
clust.i.val:{select from x where valid}

/true if number of clusters in a kd-tree > desired number of clusters (cl)
clust.i.cn1:{x<exec count distinct clt from y}
clust.i.cn2:{x<count distinct exec cltidx from y where valid}

/same output
clust.i.cl2tab:{`idx xasc flip`idx`clt!raze each(x;(count each x)#'min each x:exec distinct cltidx from x where valid)}
clust.i.rtab:  {update pts:x from @[clust.i.cl2tab;y;{[x;y]`idx`clt`pts#y}[;y]]}
clust.i.rtabdb:{update pts:x from select idx,clt from y 0}
clust.i.rtabkm:{([]idx:til count x;clt:y;pts:x)}


/2 closest clusters in a kd-tree
clust.i.closclust:{ 
 a:first select from x where nnd=min nnd;
 b:first exec clt from x where idx=a`nni;
 select from x where clt in(b,a`clt)}

/index of nearest neighbours in kd-tree to cluster
clust.i.nnidx:{[t;cl]exec initi except cl`initi from t where nni in cl`idx} 

/distance calulation (x) between clusters
clust.i.distc:{[lf;df;x;y]clust.kd.i.ld[lf]each clust.kd.i.dd[df]@'/:raze each x-/:\:/:y`pts}
clust.i.distcw:{[lf;df;x;y]clust.kd.i.ld[lf][x`n]'[y`n;clust.kd.i.dd[df]each x[`pts]-/:y`pts]}
clust.i.epdistmat:{[df;e;x;y;n]where e>=@[;n;:;0w]clust.kd.i.dd[df]x-y}
clust.i.mindist:{{k:@[x;where x=0;:;0n];k?min k}each(,'/)clust.kd.i.dd[z]each x-/:y}

/representative points for a cluster using CURE - get most spread out and apply compression
/* d  = data points
/* cl = cluster
/* r  = number of representative points
/* c  = compression

clust.i.curerep:{[d;idxs;r;c]
 mean:avg d idxs;
 maxp:idxs clust.kd.i.imax sum each{x*x}mean-/:d idxs;
 rp:d r{z,m clust.kd.i.imax{min{sum k*k:x[z]-x[y]}[x;y]each z}[x;;z]each m:y except z}[d;idxs]/maxp;
 (rp*1-c)+\:c*mean}

/representative points for cluster using hierarchical clustering
clust.i.hcrep:{[d;cl;lf]
 rp:{enlist avg x y}[d;idxs:distinct raze cl`cltidx];
 (rp;idxs;cl`initi)}

/initial cluster table for complete/average linkage
clust.i.buildtab:{
 d:{(d i;i:first 1_iasc d:clust.kd.i.dd[z]each x-/:y)}[;x;y]each x;
 flip`idx`pts`clt`nni`nnd!(i;x;i:til count x;d[;1];d[;0])}

/find new nearest cluster
clust.i.hcupd:{[df;lf;t;cl]
 dm:$[lf=`ward;clust.i.distcw[lf;df;cl;t:select clt,n,pts from t where clt<>cl`clt];
      clust.i.distc[lf;df;cl`pts;t:0!select pts by clt from t where clt<>cl`clt]];
 (cl`clt;(dm;t`clt)@\:clust.kd.i.imin dm)}

/update rep pts
clust.i.repupd:{[t;newp;df;r;c]
  nd:newp,select pts,clt from t where valid;
  rp:clust.i.curerep[nd`pts;;r;c]each exec i by clt from nd;
  cl:raze value[cn]#'key cn:count each rp;
  clust.kd.buildtree[raze value rp;cl;clust.i.dim rp;df]
 }

/cl idx,minpts,(table;pts idx to search)
clust.i.dbclust:{[c;p;l]
 ncl:{[t;p;s]raze{[t;p;i]
  if[p<=count cl:t[i]`dist;:exec idx from t where idx in cl,valid]
  }[t;p]each exec idx from t where idx in s,valid}[t:l 0;p]each s:l 1;
 t:update clt:c,valid:0b from t where idx in distinct raze s;
 (t;ncl)}

/cluster new points
clust.i.whichcl:{ind:@[;2]{0<count x 1}clust.kd.bestdist[x;z;0n;`e2dist]/(0w;y;y;y);exec clt from x where idx=ind}

/kmeans
clust.i.kpp:{clust.i.kpp2[flip x;y]}
clust.i.kpp2:{[m;n](n-1){y,x clust.i.iwrand[1]{x x?min x}each flip{sqrt sum x*x-:y}[flip x]'[y]}[m]/1?m}
clust.i.iwrand:{[n;w]s binr n?last s:sums w}

/kmeans random initialisation
clust.i.randinitf:{flip x@\:neg[y]?til count x 0}
clust.i.randinit:{x@\:neg[y]?til count x 0}

/cast table/dictionary to matrix
clust.i.typecast:{$[98=type x;value flip x;99=type x;value x;0=type x;x;'`type]}


/clustering algos
/CURE/centroid - merge two closest clusters and update distances/indices
/* x1 = r (CURE) or df (centroid)
/* x2 = c (CURE) or lf (centroid)
/* sd = splitting dimension
/* b  = 1b (CURE) or 0b (centroid)
 
clust.i.algocc:{[d;df;x1;x2;sd;b;t]
 cl:clust.i.closclust clust.i.val t;
 rep:$[b;(clust.i.curerep[d;idxs;x1;x2];idxs:distinct raze cl`cltidx;cl`initi);clust.i.hcrep[d;cl;x2]];
 t:clust.kd.insertcl[sd]/[t;rp;ii:first idxs;(count rp:rep 0)#enlist idxs:rep 1];
 t:clust.kd.deletecl[df]/[t;rep 2];
 clust.kd.distcalc[df]/[t;exec idx from t where clt in ii,valid]}
 
/Single - merge two closest clusters and update distances/indices
clust.i.algos:{[d;df;lf;sd;t]
 cl:clust.i.closclust t;
 i0:first idxs:distinct raze cl`cltidx;
 t:update clt:i0 from t where idx in cl`idx;
 t:clust.kd.distcalc[df]/[t;cl`idx];
 {[c;t;j]update cltidx:c from t where initi=j,valid}[enlist idxs]/[t;idxs]}

/Complete/average - merge two closest clusters and update distances/indices
clust.i.algoca:{[df;lf;t]
 cd:c,(t c:clust.kd.i.imin t`nnd)`nni;
 t:update clt:min cd from t where clt=max cd;
 nn:0!select pts by clt from t where nni in cd;
 du:clust.i.hcupd[df;lf;t]each nn;
 {[t;x]![t;enlist(=;`clt;x 0);0b;`nnd`nni!x 1]}/[t;du]}
 
/Ward - merge two closest clusters and update distances/indices
clust.i.algow:{[df;lf;t]
 cd:c,d:(t c:clust.kd.i.imin t`nnd)`nni;
 t:update clt:min cd from t where clt=max cd;
 p:sum exec count[i]*first pts by pts from t where clt=min cd;
 t:update pts:count[i]#enlist[p%count[i]]by clt from t where clt=min cd;
 ct:0!select n:count i,first pts,nn:any nni in cd by clt from t;
 du:clust.i.hcupd[df;lf;ct]each select from ct where nn;
 {[t;x]![t;enlist(=;`clt;x 0);0b;`nnd`nni!x 1]}/[t;du]}

/DBSCAN
clust.i.algodb:{[p;l]
 cl:{0<>sum type each x 1}clust.i.dbclust[c:l 2;p]/(l 0;l 1); 
 nc:first exec idx from t:cl 0 where valid;
 (t;nc;1+c)}
