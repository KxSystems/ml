\d .ml

/----Utilities----

/decide which direction to go in at a node
/* t  = k-d tree
/* bd = best distance
/* os = points already searched
/* df = distance metric
/* ns = point to be searched
/* p  = points to compare
/* rp = rep points
clust.i.axdist:{[t;bd;os;df;ns;p;rp]
 raze{[t;bd;os;df;ns;p;rp]
  $[t[2]p;p;bd>=clust.i.dd[df]rp[ns;t[5]p]-t[4]p;t[3]p;(raze clust.i.findl[rp ns;t;p])except os]
  }[t;bd;os;df;ns;;rp]each p}

/initial cluster table for complete/average/ward linkage
/* x = data
/* y = distance function/metric
clust.i.buildtab:{
 d:{(d i;i:first 1_iasc d:clust.i.dd[z]each x-/:y)}[;x;y]each x;
 flip`idx`pts`clt`nni`nnd!(i;x;i:til count x;d[;1];d[;0])}

/update table distances
/* x = data
/* y = index and distance of the new NN
clust.i.updtab:{[t;x]![t;enlist(=;`clt;x 0);0b;`nnd`nni!x 1]}/

/find minimum distance and index
/* pts = points (multiple)
/* p   = single point
/* rp  = rep points
clust.i.calc:{[df;pts;p;rp]im:min mm:clust.i.dc[df;rp;p;pts];ir:p mm?im;(first ir;im)}

/convert clusters in table (x) to table for final output
clust.i.cln:{{![x;enlist(=;`clt;z);0b;enlist[`clt]!enlist y]}/[x;til count cl;cl:exec distinct clt from x]}

/variables for while loop
/* d  = data points
/* k = number of clusters
/* r = number of representative points
clust.i.clvars:{[d;k;df;r;t]
 r2l:((pc:count d)#0N){[t;x;y]@[x;t[3]y;:;y]}[t]/where t 2;
 c2p:enlist each r2c:til pc;
 ndists:flip clust.i.nns[;d;t;r2c;r2l;::;df]each r2c;
 `oreps`r2l`r2c`gone`c2r`c2p`ndists`pc!(d;r2l;r2c;pc#0b;c2p;c2p;ndists;pc)}

/true if number of clusters in a kd-tree (y) > desired number of clusters (x)
clust.i.cn:{x<exec count distinct clt from y}

/representative points for a cluster using CURE - get most spread out and apply compression
/* x  = point indices
/* r  = number of representative points
/* c  = compression
clust.i.curerep:{[d;df;x;r;c]
 maxp:x clust.i.imax clust.i.dd[df]each d[x]-\:m:avg d x;
 rp:d(r-1){[d;df;x;p]p,i clust.i.imax{[d;df;i;p]min{[d;df;i;p]clust.i.dd[df]d[p]-d[i]
  }[d;df;i]each p}[d;df;;p]each i:x except p}[d;df;x]/maxp;
 (rp*1-c)+\:c*m}

/distance between points
/* i  = index of multiple points
/* j  = index of single point
clust.i.dc:{[df;rp;i;j]{[df;rp;i;j]clust.i.dd[df]rp[i]-rp[j]}[df;rp;;j]each i}

/distance metric dictionary
clust.i.dd:`e2dist`edist`mdist`cshev!({x wsum x};{sqrt x wsum x};{sum abs x};{min abs x})

/create clusters for DBSCAN
/* c = cluster index
/* p = minimum number of points per cluster
/* l = list with (table;pt inds to search)
clust.i.dbclust:{[c;p;l]
 ncl:{[t;p;s]raze{[t;p;i]
  if[p<=count cl:t[i]`dist;:exec idx from t where idx in cl,valid]
  }[t;p]each exec idx from t where idx in s,valid}[t:l 0;p]each s:l 1;
 t:update clt:c,valid:0b from t where idx in distinct raze s;
 (t;ncl)}

/distance calulation between clusters
clust.i.distca: {[lf;df;x;y]clust.i.ld[lf]each clust.i.dd[df]@'/:raze each x-/:\:/:y`pts}
clust.i.distcw: {[lf;df;x;y]clust.i.ld[lf][x`n]'[y`n;clust.i.dd[df]each x[`pts]-/:y`pts]}
clust.i.distmat:{[df;e;x;y;n]where e>=@[;n;:;0w]clust.i.dd[df]x-y}

/get left or right child depending on direction 
/* x = rep pts
/* y = tree
/* z = index in tree
clust.i.findl:{y[3;z]first`int$y[4;z]<=x y[5;z]}

/take average of points in cluster for centroid linkage
clust.i.hcrep:{enlist avg x y}

/find new nearest cluster for ward,complete and average
clust.i.hcupd:{[df;lf;t;cl]
 dm:$[lf=`ward;clust.i.distcw[lf;df;cl;t:select clt,n,pts from t where clt<>cl`clt];
      clust.i.distca[lf;df;cl`pts;t:0!select pts by clt from t where clt<>cl`clt]];
 (cl`clt;(dm;t`clt)@\:clust.i.imin dm)}

/min/max indices
clust.i.imax:{x?max x}
clust.i.imin:{x?min x}

/random indicies
clust.i.iwrand:{[n;w]s binr n?last s:sums w}

/linkage dictionary
clust.i.ld:`single`complete`average`centroid`ward!(min;max;avg;raze;{z%(1%y)+1%x})

/return min distance between points and cluster centres
clust.i.mindist:{{k:@[x;where x=0;:;0n];k?min k}each(,'/)clust.i.dd[z]each x-/:y}

/calculating distances in the tree to get nearest neighbour
/* s  = index of node being searched
/* cp = points in the same cluster as s
/* l  = list with (next node to be search;closest point and distance;points already searched)
clust.i.nn:{[t;df;s;rp;cp;l]
 dist:{not min x[2;y]}[t]clust.i.axdist[t;l[1;1];raze l 2;df;s;;rp]/first l 0;
 bdist:$[0=min(count nn:raze[t[3;dist]]except cp;count dist);l 1;
         first[l[1;1]]>m:min mm:raze clust.i.dc[df;rp;nn;s];(nn mm?m;m);l 1];
 (t[0]l 0;bdist;l[2],l 0)}

/same as `clust.i.nn`, but returns cluster closest point belongs to
clust.i.nnc:{[x;y;z;cl;rl;g;d]nn:clust.i.nns[x;y;z;cl;rl;g;d];(cl[nn 0];nn 1)}

/search nearest neighbours
/* cl = list linking points to its clusters it belongs in
/* rl = list linkage points to its leaf in the tree
/* nv = points that are not valid
clust.i.nns:{[s;rp;t;cl;rl;nv;df]
 clt:where cl=cl s;
 leaves:(where rl=rl s)except clt,nv;
 lmin:$[count leaves;clust.i.calc[df;s;leaves;rp];(s;0w)];
 ({0<=first x 0}clust.i.nn[t;df;s;rp;clt]/(par;lmin;rl[s],par:t[0]rl s))[1]}

/kmeans random initialisation
clust.i.randinit:{flip x@\:neg[y]?til count x 0}

/return tables for all algos in the same format
clust.i.rtab:  {update pts:x from @[clust.i.cln;`idx`clt`pts#y;y]}
clust.i.rtabdb:{update pts:x from select idx,clt from y 0}
clust.i.rtabkm:{([]idx:til count x;clt:y;pts:x)}

/cast table/dictionary to matrix
clust.i.typecast:{$[98=type x;value flip x;99=type x;value x;0=type x;x;'`type]}

/find distances to update for complete/average linkage
/* df = distance metric
/* lf = distance linkage
/* t = table with distances
/* cd = clusters to merge
clust.i.nmca:{[df;lf;t;cd]
 t:update clt:(1+exec max clt from t)from t where clt in cd;
 nn:0!select pts by clt from t where nni in cd;
 du:clust.i.hcupd[df;lf;t]peach nn;
 (t;du)}

/find distances to update for ward linkage
clust.i.nmw:{[df;lf;t;cd]
 t:update clt:(1+exec max clt from t)from t where clt in cd;
 p:sum exec count[i]*first pts by pts from t where clt=max clt;
 t:update pts:count[i]#enlist[p%count[i]]by clt from t where clt=max clt;
 ct:0!select n:count i,first pts,nn:any nni in cd by clt from t;
 du:clust.i.hcupd[df;lf;ct]each select from ct where nn;
 (t;du)}

/dictionary of functions to find distances
clust.i.newmin:`average`complete`ward!(2#clust.i.nmca),clust.i.nmw


/----Streaming Notebook----

/update rep pts
clust.i.repupd:{[t;newp;df;r;c]
  nd:newp,select pts,clt from t where valid;
  rp:clust.i.curerep[nd`pts;;r;c]each exec i by clt from nd;
  cl:raze value[cn]#'key cn:count each rp;
  clust.kd.buildtree[raze value rp;cl;clust.i.dim rp;df]}

/cluster new points
clust.i.whichcl:{ind:@[;2]{0<count x 1}clust.kd.bestdist[x;z;0n;`e2dist]/(0w;y;y;y);exec clt from x where idx=ind}

/----Algorithms----

/linkage matrix
clust.i.algolkg:{[df;lf;x]
 t:x 0;m:x 1;
 cd:value first select nnd,clt,nni from t where nnd=min nnd;
 m,:(cd 1;cd 2;cd 0;count select from t where clt in 1_cd);
 (.[clust.i.updtab;clust.i.newmin[lf;df;lf;t;1_cd];(::)];m)}

/DBSCAN
clust.i.algodb:{[p;l]
 cl:{0<>sum type each x 1}clust.i.dbclust[c:l 2;p]/(l 0;l 1); 
 nc:first exec idx from t:cl 0 where valid;
 (t;nc;1+c)}

/Hierarchical - complete/average/ward
clust.i.algocaw:{[df;lf;t]
 cd:value first select i,clt,nni from t where nnd=min nnd;
 clust.i.updtab . clust.i.newmin[lf;df;lf;t;cd]}

/k-means
clust.i.kpp:{clust.i.kpp2[flip x;y]}
clust.i.kpp2:{[m;n](n-1){y,x clust.i.iwrand[1]{x x?min x}each flip{sqrt sum x*x-:y}[flip x]'[y]}[m]/1?m}

/Single,Centroid & Cure - WIP
clust.i.algoscc:{[d;k;df;r;c;b;t;m]
 v:clust.i.clvars[d;k;df;r;t];                                                  / loop variables
 if[l:98h=type m;v[`ilm]:v`r2c];                                                / add variable for linkage matrix   
 i:0;N:v[`pc]-k;                                                                / loop counter and num of iterations required
 while[i<N;
  mci:u,v[`ndists;0;u:clust.i.imin v[`ndists]1];                                / clusts to merge
  orl:v[`r2l]ori:raze v[`c2r]mci;                                               / old reps and leaf nodes they belong to
  m,:v[`ilm;mci],v[`ndists;1;u],count ori;                                              / update linkage matrix  
  npi:raze v[`c2p]mci;
  $[c~`single;nri:ori;
    [nreps:$[b;clust.i.curerep[v`oreps;df;npi;r;c];clust.i.hcrep[v`oreps;npi]]; / reps of new clust
  d[nri:(count nreps)#ori]:nreps;                                               / overwrite any old reps w/ new ones
  v[`r2l;nri]:nrl:{{not x y}[x 2]clust.i.findl[y;x]/0}[t]each d nri;            / leaf nodes for new reps, update tree
  t:.[t;(3;distinct orl);{y except x}ori];                                      / update tree w/ new reps, delete old reps
  t:t{.[x;(3;y 0);{y,x}y 1]}/flip(nrl;nri)]];                                   / add new reps
  v[`r2c;nri]:v[`r2c]ori 0;                                                     / new clust is 1st of old clusts
  if[l;v[`ilm;nri]:1+max v`ilm];                                                / update indeces for linkage matrix
  v[`c2p;mci]:(npi;0#0);v[`c2r;mci]:(nri;0#0);                                  / update clust -> points and reps
  v[`gone;mci 1]:1b;                                                            / mark 2nd of merged clusts as removed
  cnc1:clust.i.nnc[;d;t;v`r2c;v`r2l;wg:where v`gone;df]each nri;                / update all for clust d and closest clust
  cnc:raze cnc1 clust.i.imin cnc1[;1];                                          / nearest clust and dist to new clust
  $[c~`single;v[`ndists;0;(where v[`ndists;0]in mci 1)except wg]:mci 0;
    [invalid:(where v[`ndists;0]in mci)except wg;
    v[`ndists;0 1;invalid]:$[count invalid;flip{[x;y;z;r;g;d;pi]raze c1 clust.i.imin(c1:clust.i.nnc[;x;y;z;r;g;d]each pi)[;1]
    }[d;t;v`r2c;v`r2l;wg;df]each v[`c2r]invalid;(0#0;0#0f)]]];
  v[`ndists;;mci 0]:cnc;
  v[`ndists;;mci 1]:(0N;0w);
  i+:1];
  $[l;m;([]idx:u;clt:{where y in'x}[v[`c2p]where not v`gone]each u:til count v`oreps;pts:v`oreps)]}
