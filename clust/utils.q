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
clust.i.clvars:{[d;k;df;t;ns]
 r2l:((pc:count d)#0N){[t;x;y]@[x;t[3]y;:;y]}[t]/where t 2;
 c2p:enlist each r2c:til pc;
 ndists:flip ns[`kd][`i][`nns][;t;r2c;d;df]each r2c;
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

/error dictionary for initial input checks
clust.i.errors:`derr`lerr`werr!(`$"invalid distance metric - must be in .ml.clust.i.dd";
               `$"invalid linkage - must be in .ml.clust.i.ld";`$"ward must be used with e2dist")

/get left or right child depending on direction 
/* x = rep pts
/* y = tree
/* z = index in tree
clust.i.findl:{y[3;z]first`int$y[4;z]<=x y[5;z]}

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

/find distances to update for complete/average linkage
/* lf = linkage function
/* t  = table with distances
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

/kmeans random initialisation
clust.i.randinit:{flip x@\:neg[y]?til count x 0}

/return tables for all algos in the same format
clust.i.rtab:  {update pts:x from @[clust.i.cln;`idx`clt`pts#y;y]}
clust.i.rtabc: {([]idx:til count x;clt:{where y in'x}[y]each til count x;pts:x)}
clust.i.rtabdb:{update pts:x from select idx,clt from y 0}
clust.i.rtabkm:{([]idx:til count x;clt:y;pts:x)}

/cast table/dictionary to matrix
clust.i.typecast:{$[98=type x;value flip x;99=type x;value x;0=type x;x;'`type]}

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

/dendrogram
/* x = list with (tree;dgram/linkage matrix)
clust.i.algodgram:{[df;lf;x]
 t:x 0;m:x 1;
 cd:value first select nnd,clt,nni from t where nnd=min nnd;
 m,:(cd 1;cd 2;cd 0;count select from t where clt in 1_cd);
 (.[clust.i.updtab;clust.i.newmin[lf;df;lf;t;1_cd];(::)];m)}

/DBSCAN
/* p = minimum number of points per cluster
/* l = list with (table;next cluster idx;counter)
clust.i.algodb:{[p;l]
 cl:{0<>sum type each x 1}clust.i.dbclust[c:l 2;p]/(l 0;l 1); 
 nc:first exec idx from t:cl 0 where valid;
 (t;nc;1+c)}

/Hierarchical - complete/average/ward
clust.i.algocaw:{[df;lf;t]
 cd:value first select i,clt,nni from t where nnd=min nnd;
 clust.i.updtab . clust.i.newmin[lf;df;lf;t;cd]}

/k-means
/* x = distance matrix
/* y = number of clusters
clust.i.kpp:{clust.i.kpp2[flip x;y]}
clust.i.kpp2:{[m;n](n-1){y,x clust.i.iwrand[1]{x x?min x}each flip{sqrt sum x*x-:y}[flip x]'[y]}[m]/1?m}

/Single,Centroid & Cure
/* m = dgram/linkage matrix
clust.i.algoscc:{[d;k;df;r;c;m;ns;b]
 t:clust.kd.buildtree[flip d;r];
 v:clust.i.clvars[d;k;df;t;ns];                                              / variables
 if[l:98h=type m;v[`ilm]:v`r2c];                                            / add variable for linkage matrix
 i:0;N:v[`pc]-k;                                                            / counter and n iterations
 while[i<N;
  mci:u,v[`ndists;0;u:clust.i.imin v[`ndists]1];                            / clusts to merge
  orl:v[`r2l]ori:raze v[`c2r]mci;                                           / old reps and their leaf nodes
  m,:v[`ilm;mci],v[`ndists;1;u],count ori;                                  / update linkage matrix
  npi:raze v[`c2p] mci;
  $[c~`single;nri:ori;
   [nreps:$[not c~`centroid;ns[`i][`curerep][v[`oreps];df;npi;r;c];enlist avg v[`oreps]npi]; / reps of new clust
  d[nri:(count nreps)#ori]:nreps;                                           / overwrite any old reps w/ new ones
  v[`r2l;nri]:nrl:ns[`kd][`searchfrom][t;;0]each nreps;        / leaf nodes for new reps, update tree
  t:.[t;(3;distinct orl);{y except x}ori];                                  / update tree w/ new reps, delete old reps
  t:t{.[x;(3;y 0);{y,x}y 1]}/flip(nrl;nri)]];                               / add new reps
  v[`r2c;nri]:v[`r2c]ori 0;                                                 / new clust is 1st of old clusts
  if[l;v[`ilm;nri]:1+max v`ilm];                                            / update indeces for linkage matrix
  v:{.[x;y;:;z]}/[v;flip(`c2p`c2r`gone;(mci;mci;mci 1));((npi;0#0);(nri;0#0);1b)];
  cnc:ns[`kd][`nnc][nri;t;v`r2c;d;df];
  w:(where v[`ndists;0]in mci)except wg:where v[`gone];
  $[c~`single;v[`ndists;0;w]:mci 0;[v[`ndists;0 1;w]:$[count w;
    flip ns[`kd][`nnc][;t;v`r2c;d;df]each v[`c2r]w;(0#0;0#0f)]]];
  / update all for clust d and closest clust, nearest clust and dist to new clust
  v[`ndists]:{.[x;y;:;z]}/[v`ndists;((::;mci 0);(::;mci 1));(cnc;(0N;0w))];
  i+:1];
  $[b;`reps`tree`r2c`r2l!(d ii;.[t;(3;j);:;{x?y}[ii]each t[3;]j:where t[2;]];{x?y}[distinct c]each c:v[`r2c]ii;v[`r2l]ii:raze v`c2r);
    $[l;m;([]idx:u;clt:raze{where y in'x}[v[`c2p]where not v`gone]each u:til count v`oreps;pts:v`oreps)]]}
