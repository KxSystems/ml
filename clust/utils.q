\d .ml

// Clustering Utilities

// Distance metric dictionary

// @private
// @kind function
// @category clustUtility
// @fileoverview Euclidean distance calculation
// @param data {float[][]} Points
// @return {float[]} Euclidean distances for data 
clust.i.df.edist:{[data]
  sqrt data wsum data
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview distance calculation
// @param data {float[][]} Points
// @return {float[]} Euclidean squared distances for data 
clust.i.df.e2dist:{[data]
  data wsum data
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Manhattan distance calculation
// @param data {float[][]} Points
// @return {float[]} Manhattan distances for data 
clust.i.df.mdist:{[data]
  sum abs data
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Chebyshev distance calculation
// @param data {float[][]} Points
// @return {float[]} Chebyshev distances for data 
clust.i.df.cshev:{[data]
  min abs data
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Negative euclidean squared distance calculation
// @param data {float[][]} Points
// @return {float[]} Negative euclidean squared distances for data 
clust.i.df.nege2dist:{[data]
  neg data wsum data
  }

// @private
// @kind dictionary
// @category clustUtility
// @fileoverview Linkage dictionary
clust.i.lf.single:min
clust.i.lf.complete:max
clust.i.lf.average:avg
clust.i.lf.centroid:raze
clust.i.lf.ward:{z*x*y%x+y}

// Distance calculations

// @private
// @kind function
// @category clustUtility
// @param data {float[][]} Points in `value flip` format
// @param df {func} Distance function
// @param pt {float[]} Current point
// @param idxs {long[]} Indices from data
// @return {float[]} Distances for data and pt
clust.i.dists:{[data;df;pt;idxs]
  clust.i.df[df]pt-data[;idxs]
  }

// @private
// @kind function
// @category clustUtility
// @param data {float[][]} Points in `value flip` format
// @param df {func} Distance function
// @param pt {float[]} Current point
// @param idxs {long[]} Indices from data
// @return {float[]} Distances for data and pt
clust.i.closest:{[data;df;pt;idxs]
  dists:clust.i.dists[data;df;pt;idxs];
  minIdx:idxs dists?minDist:min dists;
  `point`distance!(minIdx;minDist)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Reindex exemplars
// @param data {#any[]} Data points
// @return {long[]} List of indices
clust.i.reIndex:{[data]
  distinct[data]?data
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Convert data to floating value
// @param data {#any[]} Data points
// @return {err;float[]} Data converted to floating point values or
//   error if not possible
clust.i.floatConversion:{[data]
  @[{"f"$x};data;{'"Dataset not suitable for clustering. ",
    "Must be convertible to floats."}]
  }

// @private
// @kind dictionary
// @category clustUtility
// @fileoverview Error dictionary
clust.i.err.df:{'`$"invalid distance metric"}
clust.i.err.lf:{'`$"invalid linkage"}
clust.i.err.ward:{'`$"ward must be used with e2dist"}
clust.i.err.centroid:{'`$"centroid must be used with edist/e2dist"}
clust.i.err.kMeans:{'`$"kmeans must be used with edist/e2dist"}
clust.i.err.ap:{'`$"AP must be used with nege2dist"}

// Hierarchial Utilities

// @private
// @kind function
// @category clustUtility
// @fileoverview Check validity of inputs for cutting dendrograms
//   at position K when using .ml.clust.cutK >1
// @param cutK {int} The user provided number of clusters to be
//   retrieved when cutting the dendrogram
// @return {err} Returns nothing on successful invocation, will error
//   if a user provides an unsupported value
clust.i.checkK:{[cutK]
  if[cutK<=1;'"Number of requested clusters must be > 1."];
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Check validity of inputs for cutting dendrograms
//   at a distance. In order to be valid this must be > 0
// @param cutDist {float} The user provided cutting distance for
//   the dendrogram
// @return {err} Returns nothing on successful invocation, will error
//   if a user provides an unsupported value
clust.i.checkDist:{[cutDist]
  if[cutDist<=0;'"Cutting distance must be >= 0."];
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Prepare the config for prediction functionality
// @param config {dict} Clustering information returned from `fit`
// @param cutDist {dict} The key defines what cutting algo to use when
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {dict} `data`df`n`c`clt returned from .ml.clust.(cutK/cutDist)
clust.i.prepPred:{[config;cutDict]
  cutType:first key cutDict;
  if[not cutType in`k`cut;'"Cutting distance has to be 'k' or 'cut'"];
  $[cutType=`k;
    clust.cure.cutK;
    clust.cure.cutDist
    ][config;first value cutDict]
  }


// @private
// @kind function
// @category clustUtility
// @fileoverview Complete, Average, Ward (CAW) Linkage
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param k {long} Number of clusters
// @param dgram {bool} Generate dendrogram or not (1b/0b)
// @return {tab;long[]} Dendrogram or list of clusters
clust.i.hcCAW:{[data;df;lf;k;dgram]
  // Check distance function for ward
  if[(not df~`e2dist)&lf=`ward;clust.i.err.ward[]];
  // Create initial cluster table
  t0:clust.i.initCAW[data;df];
  // Create linkage matrix
  m:([]idx1:`int$();idx2:`int$();dist:`float$();n:`int$());
  // Merge clusters based on chosen algorithm
  r:{[k;r]k<count distinct r[0]`clust}[k]clust.i.algoCAW[data;df;lf]/(t0;m);
  // Return dendrogram or list of clusters
  $[dgram;clust.i.updDgram[r 0;r 1];clust.i.reindex r[0]`clust]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Single, Centroid, Cure (SCC) Linkage
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {func} Linkage function
// @param k {long} Number of clusters
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @param dgram {bool} Generate dendrogram or not (1b/0b)
// @return {long[]} Grouped clusters
clust.i.hcSCC:{[data;df;lf;k;n;c;dgram]
  if[(not df in`edist`e2dist)&lf=`centroid;clust.i.err.centroid[]];
  clustInit:clust.i.initSCC[data;df;k;n;c;dgram];
  clusts:(count[data 0]-k).[clust.i.algoSCC[data;df;lf]]/clustInit;
  validClusts:select from clusts[1]where valid;
  $[dgram;
    clust.i.dgramIdx last[clusts]0;
    enlist @[;;:;]/[count[data 0]#0N;validClusts`points;til count validClusts]
   ]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Update dendrogram for CAW with final cluster of all the points
// @param tab {tab} Cluster table
// @param linkMatrix {float[][]} Linkage matrix
// @return {float[][]} Updated linkage matrix
clust.i.updDgram:{[tab;linkMatrix]
  linkMatrix,:value exec first clust,first nnIdx,first nnDist,count repPt 
    from tab where nnDist=min nnDist;
  linkMatrix
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Predict clusters using hierarchical or CURE config
// @param name {sym} Namespace to use - `hc or `cure
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} Output of .ml.clust.(cutK/cutDist)
// @return {long[]} Predicted clusters
clust.i.hCCpred:{[name;data;config]
  data:clust.i.floatConversion[data];
  // Check correct namespace and clusters given
  if[not name in`hc`cure;'"Incorrect namespace - please use `hc or `cure"];
  if[not`clust in key config;
    '"Clusters must be contained within config - please run .ml.clust.",
    $[name~`hc;"hc";"cure"],".(cutK/cutDist)"];
  // Add namespace and linkage to config dictionary for cure
  if[name~`cure;config[`modelInfo;`inputs],:`name`lf!(name;`single)];
  // Recalculate representative point for training clusters in asc
  // order to ensure correct labels
  clusts:group config`clust; 
  clustKey:asc key clusts;
  repPts:clust.i.getRep[config]each clusts clustKey;
  // Training indices
  idxs:til each numPt:count each repPts[;0];
  // Return closest clusters to testing points
  clust.i.predClosest[data;config;repPts;numPt;idxs]each til count data 0
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Recalculate representative points from training clusters
// @param config {dict} Output of .ml.clust.(cutK/cutDist)
// @param idxs {long[][]} Training data indices
// @return {float[][]} Training data points
clust.i.getRep:{[config;idxs]
  config:config[`modelInfo];
  $[config[`inputs;`name]~`cure;
      flip(clust.i.cureRep . config[`inputs;`df`n`c])::;
    config[`inputs;`lf]in`ward`centroid;
      enlist each avg each;
    ]config[`data][;idxs]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Predict new cluster for given data point
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} Output of .ml.clust.(cutK/cutDist)
// @param repPt {float[][]} Representative points in matrix format
// @param numPts {long} Number of points in training clusters
// @param clustIdx {long[][]} Training data indices
// @param ptIdx {long[][]} Index of current data point
// @return {long[]} List of predicted clusters
clust.i.predClosest:{[data;config;repPt;c;clustIdx;ptIdx]
  config:config[`modelInfo];
  // Intra cluster distances
  dist:.ml.clust.i.dists[;config[`inputs]`df;data[;ptIdx];]'[repPt;clustIdx];
  // Apply linkage
  dist:$[`ward~lf:config[`inputs]`lf;
    2*clust.i.lf[lf][1]'[c;dist];
    clust.i.lf[lf]each dist
    ];
  // Find closest cluster
  iMin dist
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Initialize cluster table
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @return {tab} Distances, neighbors, clusters and representatives
clust.i.initCAW:{[data;df]
  // Create table with distances and nearest neighhbors noted
  tab:clust.i.nnCAW[data;df;data]each til count data 0;
  // Update each points cluster and representatives
  update clust:i,repPt:flip data from tab
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Find nearest neighbour index and distance
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param pt {float[][]} Points in `value flip` format
// @param idxs {long} Index of point in 'pt' to find nearest neighbour for
// @return {dict} Index of and distance to nearest neighbour
clust.i.nnCAW:{[data;df;pt;idxs]
  dists:@[;idxs;:;0w]clust.i.dists[data;df;pt;idxs];
  minDists:min dists;
  `nnIdx`nnDist!(dists?minDists;minDists)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview CAW algo
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf' 
// @param clustInfo {(table;float[][])} List with cluster table and 
//   linkage matrix
// @return {(table;float[][])} Updated cluster table and linkage matrix
clust.i.algoCAW:{[data;df;lf;clustInfo]
  tab:clustInfo 0;
  matrix:clustInfo 1;
  // Update linkage matrix
  matrix,:value exec first clust,first nnIdx,first nnDist,count repPt from tab
    where nnDist=min nnDist;
  // Merge closest clusters
  merge:distinct value first select clust,nnIdx from tab where nnDist=
    min nnDist;
  // Add new cluster and repPt into table
  tab:update clust:1+max tab`clust,repPt:count[i]#enlist sum[repPt]%count[i] 
    from tab where clust in merge;
  // Exec pts by cluster
  clustPts:exec pts:data[;i],n:count i,last repPt by clust from tab;
  // Find points initially closest to new cluster points
  chkPts:exec distinct clust from tab where nnIdx in merge;
  // Run specific algo and return updated table
  tab:clust.i.hcUpd[lf][clustPts;df;lf]/[tab;chkPts];
  // Return updated table and matrix
  (tab;matrix)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Complete linkage
// @param clustPts {float[][]} Points in each cluster
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param lf {sym} Linkage function name within '.ml.clust.i.lf' 
// @param tab {tab} Cluster table
// @param chkPts {long[]} Points to check
// @return {tab} Updated cluster table
clust.i.hcUpd.complete:{[clustPts;df;lf;tab;chkPts]
  // Calculate cluster distances using complete method
  dists:clust.i.completeDist[df;lf;clustPts;chkPts];
  // Find nearest neighbors
  nIdx:dists?nDist:min dists;
  // Update cluster table
  update nnIdx:nIdx,nnDist:nDist from tab where clust=chkPts
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Average linkage
// @param clustPts {float[][]} Points in each cluster
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param lf {sym} Linkage function name within '.ml.clust.i.lf' 
// @param tab {tab} Cluster table
// @param chkPts {long[]} Points to check
// @return {tab} Updated cluster table
clust.i.hcUpd.average:clust.i.hcUpd.complete

// @private
// @kind function
// @category clustUtility
// @fileoverview Ward linkage
// @param clustPts {float[][]} Points in each cluster
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param tab {tab} Cluster table
// @param chkPts {long[]} Points to check
// @return {tab} Updated cluster table
clust.i.hcUpd.ward:{[clustPts;df;lf;t;chkPts]
  // Calculate distances using ward method
  dists:clust.i.wardDist[df;lf;clustPts;chkPts];
  // Find nearest neighbors
  nIdx:dists?nDist:min dists;
  // Update cluster table and rep pts
  update nnIdx:nIdx,nnDist:nDist from t where clust=chkPts
  }

// @private	
// @kind function
// @category clustUtility
// @fileoverview Calculate distances between points based on specified
//   linkage and distance functions
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param data {float[][]} Points in each cluster
// @param idxs {long[]} Indices for which to produce distances
// @return {float[]} Distances between all data points and those in idxs
clust.i.completeDist:{[df;lf;data;idxs]
  clust.i.completeCalc[df;lf;data idxs]each data _ idxs
  }

// @private	
// @kind function
// @category clustUtility
// @fileoverview Calculate distances between points based on specified
//   linkage and distance functions
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param xdata {float[][]} X data points
// @param ydata {float[][]} Y data points
// @return {float[]} Distances between data points
clust.i.completeCalc:{[df;lf;xdata;ydata]
    dists:raze clust.i.df[df]xdata[`pts]-\:'ydata`pts;
    clust.i.lf[lf]dists
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate distances between points based on ward linkage and
//   specified distance function
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param data {float[][]} Points in each cluster
// @param idxs {long[]} Indices for which to produce distances
// @return {float[]} Distances between all data points and those in idxs
clust.i.wardDist:{[df;lf;data;idxs]
  clust.i.wardCalc[df;lf;data idxs]each data _ idxs
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate distances between points based on ward linkage and
//   specified distance function
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param xdata {float[][]} X data points
// @param ydata {float[][]} Y data points
// @return {float[]} Distances between data points
clust.i.wardCalc:{[df;lf;xdata;ydata]
    dists:clust.i.df[df]xdata[`repPt]-ydata`repPt;
    2*clust.i.lf[lf][xdata`n;ydata`n;dists]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Initialize SCC clusters
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param k {long} Number of clusters
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @return {(dict;long[];table;table)} Parameters, clusters, representative
//   points and the kdTree
clust.i.initSCC:{[data;df;k;n;c;dgram]
  numPts:count data 0;
  // Build kdTree
  kdTree:clust.kd.newTree[data]1000&ceiling .01*numPts;
  // Generate distance table with closest clusters identified
  dists:clust.i.genDistTab[kdTree;data;df;numPts];
  leafIdx:select raze idxs,self:self where count each idxs from kdTree 
    where leaf;
  rep2leaf:exec self idxs?til count i from leafIdx;
  // Create cluster table 
  clusts:select clustIdx:i,clust:i,valid:1b,repPts:enlist each i,
    points:enlist each i,closestDist,closestClust from dists;
  // Create table of representative points for each cluster
  repPts:select repPt:i,clust:i,leaf:rep2leaf,closestDist,closestClust 
    from dists;
  repPts:repPts,'flip(repCols:`$"x",'string til count data)!data;
  // Create list of important parameters to carry forward
  params:`k`n`c`repCols!(k;n;c;repCols);
  linkMat:([]idx1:`int$();idx2:`int$();dist:`float$();n:`int$());
  // Return as a list to be passed to algos
  (params;clusts;repPts;kdTree;(linkMat;dgram))
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Generate distance table indicating closest cluster
// @param kdTree {tab} Initial representation of the k-d tree
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param numPts {long} Number of points in the dataset 
// @return {tab} Distance table containing an indication of the closest cluster
clust.i.genDistTab:{[kdTree;data;df;numPts]
  // Generate the distance table
  genTab:{[kdTree;data;df;idx]
    clust.kd.nn[kdTree;data;df;idx;data[;idx]]
    }[kdTree;data;df]each til numPts;
  // Update naming convention
  update closestClust:closestPoint from genTab
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Representative points for Centroid linkage
// @param pts {float[][]} Data points
// @return {float[]} Representative point
clust.i.centRep:{[pts]
  enlist avg each pts
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Representative points for CURE
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @param pts {float[][]} Data points
// @return {float[][]} Representative points
clust.i.cureRep:{[df;n;c;pts]
  avgPt:avg each pts;
  repPts:1_first(n&count pts 0).[clust.i.repCalc[df]]/(enlist avgPt;pts);
  (repPts*1-c)+\:c*avgPt
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate single representative point
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param repPts {float[]} Representative points of the cluster
// @param pts {float[][]} Data points
// @return {float} Representative point
clust.i.repCalc:{[df;repPts;pts]
  i:iMax min clust.i.df[df]each pts-/:neg[1|-1+count repPts]#repPts;
  repPts,:enlist pts[;i];
  (repPts;.[pts;(::;i);:;0n])
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Update initial dendrogram structure to show path of merges so
//   that the dendrogram can be plotted with scipy
// @param dgram {tab} Dendrogram stucture produced using 
//   .ml.clust.hc[...;...;...;...;1b]
// @return {tab} Updated dendrogram
clust.i.dgramIdx:{[dgram]
  // Initial cluster indices, number of merges and loop counter
  clusts:raze dgram`idx1`idx2;n:count dgram;i:0;
  // Increment a cluster for every occurrence in the tree
  while[n>i+1;
    clustIdx:where[clusts=clusts i]except i;
    clusts[clustIdx]:1+max clusts;i+:1
    ];
  // Update dendrogram with new indices
  ![dgram;();0b;`idx1`idx2!n cut clusts]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Convert dendrogram table to clusters
// @param tab {tab} Dendrogram table
// @param k {long} Define splitting value in dendrogram table
// @return {long[]} List of clusters
clust.i.cutDgram:{[tab;k]
  if[k=0;
    '"User provided input encapsultes all datapoints, please ",
     "increase `k or reduce `cut to an appropriate value."
    ];
  // Get index of cluster made at cutting point k
  idx:(2*cntTab:count tab)-k-1;
  // Exclude any clusters made after point k
  i:raze neg[k]#'allClusts:tab`idx1`idx2;
  exClust:i where idx>i;
  // Extract indices within clusters made until k, excluding any outliers
  outliers:exClust where exClust<=cntTab;
  cutOff:exClust except outliers; 
  clust:{last{count x 0}clust.i.extractClust[x;y]/(z;())}
    [allClusts;cntTab+1]each cutOff;
  // Update points to the cluster they belong to
  @[;;:;]/[(1+cntTab)#0N;clust,enlist each outliers;til k+1]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Extract points within merged cluster
// @param clusts {long[]} Cluster indices
// @param cntTab {long} Count of dendrogram table 
// @param idxs {long[]} Index in list to search and indices points found within
//   that cluster
// @return {long[]} Next index to search, and additional points found 
//   within cluster
clust.i.extractClust:{[clusts;cntTab;idxs]
  // Extract the points that were merged at this point
  mrgClust:raze clusts[;idxs[0]-cntTab];
  // Store any single clusts, break down clusts more than single point
  nextIdx:mrgClust>=cntTab;
  otherIdxs:idxs[1],mrgClust where not nextIdx;
  (mrgClust where nextIdx;otherIdxs)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview SCC algo
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param lf {sym} Linkage function name within '.ml.clust.i.lf'
// @param params {dict} Parameters - k (no. clusts), n (no. repPts per clust),
//   repPts, kdTree
// @param clustTab {tab} Cluster table
// @param repPts {float[][]} Representative points and associated info
// @param kdTree {tab} k-dimensional tree storing points and distances
// @param linkMatrix {float[][]} Linkage matrix
// @return {(dict;long[];float[][];table)} Parameters dict, clusters, 
//   representative points and kdTree tables
clust.i.algoSCC:{[data;df;lf;params;clustTab;repPts;kdTree;linkMatrix]
  // Merge closest clusters
  clust0:exec clust{x?min x}closestDist from clustTab where valid;
  newMerge:clustTab clust0,clust1:clustTab[clust0]`closestClust;
  newMerge:update valid:10b,repPts:(raze repPts;0#0),points:(raze points;0#0)
    from newMerge;
  // Make dendrogram if required
  if[linkMatrix 1;
    matrix:linkMatrix 0;
    merge0:first newMerge;
    matrix,:newMerge[`clustIdx],merge0[`closestDist],count merge0`points;
    linkMatrix[0]:matrix
    ];
  // Keep track of old repPts
  oldRep:repPts newMerge[0]`repPts;
  // Find reps in new cluster
  $[single:lf~`single;
    // For single new reps=old reps -> no new points calculated 
    newRep:select repPt,clust:clust0 from oldRep;
    // Generate new representative points table 
    //  (centroid -> reps=avg; cure -> calc reps)
    [newRepFunc:$[lf~`centroid;
      clust.i.centRep;
      clust.i.cureRep[df;params`n;params`c]
      ];
    newRepKeys:params`repCols;
    newRepVals:flip newRepFunc data[;newMerge[0]`points];
    newRep:flip newRepKeys!newRepVals;
    newRep:update clust:clust0,repPt:count[i]#newMerge[0]`repPts from newRep;
    // New rep leaves
    updLeaf:clust.kd.findleaf[kdTree;;kdTree 0]each flip newRep params`repCols;
    newRep[`leaf]:updLeaf`self;
    newMerge[0;`repPts]:newRep`repPt;
    // Delete old points from leaf and update new point to new rep leaf
    kdTree:.[kdTree;(oldRep`leaf;`idxs);except;oldRep`repPt];
    kdTree:.[kdTree;(newRep`leaf;`idxs);union ;newRep`repPt]
    ]
    ];
  // Update clusters and repPts
  clustTab:@[clustTab;newMerge`clust;,;delete clust from newMerge];
  repPts:@[repPts;newRep`repPt;,;delete repPt from newRep];
  updRep:repPts newRep`repPt;
  // Nearest neighbour to clust
  if[single;updRep:select from updRep where closestClust in newMerge`clust];
  // Calculate and append to representative point table the nearest neighbours
  // of columns containing representative points
  updRepData:flip updRep params`repCols;
  updRepDataNN:clust.kd.nn
    [kdTree;repPts params`repCols;df;newMerge[0]`points] each updRepData;
  updRep:updRep,'updRepDataNN;
  updRep:update closestClust:repPts[closestPoint;`clust]from updRep;
  if[single;
    repPt:@[repPts;updRep`repPt;,;select closestDist,closestClust from updRep];
    updRep:repPt newRep`repPt
    ];
  // Update nearest neighbour of new clust  
  updRep@:raze iMin updRep`closestDist;
  clustTab:@[clustTab;updRep`clust;,;`closestDist`closestClust#updRep];
  $[single;
    // Single - nearest neighbour=new clust
    [clustTab:update closestClust:clust0 from clustTab where valid,
       closestClust=clust1;
     repPts:update closestClust:clust0 from repPts where closestClust=clust1
    ];
    // Else do nearest neighbour search
    if[count updClusts:select from clustTab where valid,closestClust in
        (clust0;clust1);
      nnClust:clust.kd.nn[kdTree;repPts params`repCols;df]/:'
        [updClusts`repPts;flip each repPts[updClusts`repPts]@\:params`repCols];
      updClusts:updClusts,'{x iMin x`closestDist}each nnClust;
      updClusts[`closestClust]:repPts[updClusts`closestPoint]`clust;
      clustTab:@[clustTab;updClusts`clust;,;select closestDist,closestClust 
        from updClusts]
      ]
   ];
  (params;clustTab;repPts;kdTree;linkMatrix)
  }


// Kmeans utilities

// @private
// @kind function
// @category clustUtility
// @fileoverview K-Means algorithm
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param k {long} Number of clusters
// @param config {dict} Configuration information containing the maximum 
//   iterations `iter, initialisation type `init and threshold for smallest
//   distance to move between the previous and new run `thresh
// @return {dict} Clusters or repPts depending on rep
clust.i.kMeans:{[data;df;k;config]
  // Check distance function
  if[not df in`e2dist`edist;clust.i.err.kMeans[]];
  // Initialize representative points
  initRepPts:$[config`init;
    clust.i.initKpp df;
    clust.i.initRandom
    ][data;k];
  // Run algo until maximum number of iterations reached or convergence
  repPts0:`idx`repPts`notConv!(0;initRepPts;1b);
  repPts1:clust.i.kMeansConverge[config]
    clust.i.updCenters[data;df;config]/repPts0;
  // Return representative points and clusters
  clust:clust.i.getClust[data;df;repPts1`repPts];
  `repPts`clust!(repPts1`repPts;clust)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Check to see if cluster centers are stable or 
//   if the maximum number of iterations allowable have been reached
// @param config {dict} Configuration information containing the maximum 
//   iterations `iter, initialisation type `init and threshold for smallest
//   distance to move between the previous and new run `thresh
// @param algoRun {dict} Information about the current run of the algorithm 
//   which can have an impact on early or on time stopping i.e. have the 
//   maximum number of iterations been exceeded or have the cluster centers 
//   not moved more than the threshold i.e. 'stationary'
// @return {bool} 0b indicates number of iterations has exceeded maximum and
clust.i.kMeansConverge:{[config;algoRun]
  check1:config[`iter]>algoRun`idx;
  check2:algoRun`notConv;
  check1&check2
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Update cluster centers
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param config {dict} Configuration information containing the maximum 
//   iterations `iter, initialisation type `init and threshold for smallest
//   distance to move between the previous and new run `thresh
// @param repPts {float[][];dict} Information relating to the representative 
//   points, in the case of fitting the model this is a dictionary containing
//   the current iteration index and if the data has converged in addition to
//   the representative points. In an individual update this is just the
//   representative points for the k means centers.
// @return {float[][]} Updated representative points  
clust.i.updCenters:{[data;df;config;repPts]
  // Projection used for calculation of representative points
  repPtFunc:clust.i.newRepPts[data;df;];
  if[99h=type repPts;
    repPts[`idx]+:1;
    prevPoint:repPts`repPts;
    repPts[`repPts]:repPtFunc repPts`repPts;
    repPts[`notConv]:config[`thresh]<max abs (raze/)prevPoint-repPts`repPts;
    :repPts
    ];
  repPtFunc repPts
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate new representative points based on new 
//   data and previous representatives
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param repPts {float[][]} Representative points in matrix format each row 
//   is an individual datapoint
// @return {float[][]} New representative points in matrix format each row 
//   is an individual datapoint
clust.i.newRepPts:{[data;df;repPts]
  avgFunc:{[data;j]avg each data[;j]};
  avgFunc[data]each value group clust.i.getClust[data;df;repPts]
  }      

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate final representative points
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param repPts {float[]} Representative points of each cluster
// @return {long} List of clusters
clust.i.getClust:{[data;df;repPts]
  distFunc:{[data;df;repPt]clust.i.df[df]repPt-data};
  dist:distFunc[data;df]each repPts;
  max til[count dist]*dist=\:min dist
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Random initialization of representative points
// @param data {float[][]} Each column of the data is an individual datapoint
// @param k {long} Number of clusters
// @return {float[][]} k representative points
clust.i.initRandom:{[data;k]
  flip data[;neg[k]?count data 0]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview K-Means++ initialization of representative points
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param data {float[][]} Each column of the data is an individual datapoint
// @param k {long} Number of clusters
// @return {float[][]} k representative points
clust.i.initKpp:{[df;data;k]
  info0:`point`dists!(data[;rand count data 0];0w);
  infos:(k-1)clust.i.kpp[data;df]\info0;
  infos`point
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview K-Means++ algorithm
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param info {dict} Points and distance info
// @return {dict} Updated info dictionary
clust.i.kpp:{[data;df;info]
  dists:clust.i.dists[data;df;info`point;::];
  sumDist:sums info[`dists]&:dists;
  idx:sumDist binr rand last sumDist;
  @[info;`point;:;data[;idx]]
  }

// dbscan utilities

// @private
// @kind function
// @category clustUtility
// @fileoverview Update the neighbourhood of a previously fit original dbscan 
//   model based on new data
// @param orig {tab} Original table of data with all points set as core points
// @param new {tab} Table generated from new data with the previously generated
//   model
// @param idx {long[]} Indices used to update the neighbourhood of the original 
//   table
// @return {tab} Table with neighbourhood updated appropriately for the newly 
//   introduced data
clust.i.updNbhood:{[orig;new;idx]
  update nbhood:{x,'y}[nbhood;idx]from orig where i in new`nbhood
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Predict clusters using DBSCAN config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} `data`inputs`clust returned from DBSCAN clustered 
//   training data
// @return {tab} Cluster table
clust.i.dbscanPredict:{[data;config]
  idx:count[config[`data]0]+til count data 0;
  // Create neighbourhood table
  tab:clust.i.nbhoodTab[config[`data],'data;;;;idx]. 
    config[`inputs;`df`minPts`eps];
  // Find which existing clusters new data belongs to
  update cluster:{x[`clust]first y}[config]each nbhood from tab where corePoint
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Create neighbourhood table for points at indices provided
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param minPts {long} Minimum number of points within the epsilon radius
// @param eps {float} Epsilon radius to search
// @param idx {long[]} Data indices to find neighbourhood for
// @return {tab} Neighbourhood table with columns `nbhood`cluster`corepoint
clust.i.nbhoodTab:{[data;df;minPts;eps;idx]
  // Calculate distances and find all points which are not outliers
  nbhood:clust.i.nbhood[data;df;eps]each idx;
  // Update outlier cluster to null
  update cluster:0N,corePoint:minPts<=1+count each nbhood from([]nbhood)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Find all points which are not outliers
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param eps {float} Epsilon radius to search
// @param idx {long} Index of current point
// @return {long[]} Indices of points within the epsilon radius
clust.i.nbhood:{[data;df;eps;idx]
  where eps>@[;idx;:;0w]clust.i.df[df]data-data[;idx]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Run DBSCAN algorithm and update cluster of each point
// @param t {tab} Cluster info table
// @return {tab} Updated cluster table with old clusters merged
clust.i.dbAlgo:{[tab]
  nbIdxs:.ml.clust.i.nbhoodIdxs[tab]/[first where tab`corePoint];
  update cluster:0|1+max tab`cluster,corePoint:0b from tab where i in nbIdxs
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Find indices in each points neighborhood
// @param tab {tab} Cluster info table
// @param idxs {long[]} Indices to search the neighborhood of
// @return {long[]} Indices in neighborhood
clust.i.nbhoodIdxs:{[tab;idxs]
  nbh:exec nbhood from tab[distinct idxs,raze tab[idxs]`nbhood]where corePoint;
  asc distinct idxs,raze nbh
  }

// Aprop utilities

// @private
// @kind function
// @category clustUtility
// @fileoverview Run affinity propagation algorithm
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param damp {float} Damping coefficient
// @param diag {func} Function applied to the similarity matrix diagonal
// @param idxs {long[]} Indicies to find distances for
// @param iter {dict} Max number of overall iterations and iterations 
//   without a change in clusters. (::) can be passed in where the defaults
//   of (`total`noChange!200 15) will be used
// @return {dict} Data, input variables, clusters and exemplars
clust.i.runAp:{[data;df;damp;diag;idxs;iter]
  // Check negative euclidean distance has been given
  if[df<>`nege2dist;clust.i.err.ap[]];
  // Calculate distances, availability and responsibility
  info0:clust.i.apInit[data;df;diag;idxs];
  // Initialize exemplar matrix and convergence boolean
  info0,:`exemMat`conv`iter!((count data 0;iter`noChange)#0b;0b;iter);
  // Run ap algo until maximum number of iterations completed or convergence
  info1:clust.i.apStop clust.i.apAlgo[damp]/info0;
  // Return data, inputs, clusters and exemplars
  inputs:`df`damp`diag`iter!(df;damp;diag;iter);
  exemplars:info1`exemplars;
  clust:$[info1`conv;clust.i.reIndex exemplars;count[data 0]#-1];
  `data`inputs`clust`exemplars!(data;inputs;clust;exemplars)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Initialize matrices
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param diag {func} Function applied to the similarity matrix diagonal
// @param idxs {long[]} Point indices
// @return {dict} Similarity, availability and responsibility matrices and 
//   keys for matches and exemplars to be filled during further iterations
clust.i.apInit:{[data;df;diag;idxs]
  // Calculate similarity matrix values
  dists:clust.i.dists[data;df;data]each idxs;
  // Update diagonal
  dists:@[;;:;diag raze dists]'[dists;k:til n:count data 0];
  // Create lists/matrices of zeros for other variables
  `matches`exemplars`similar`avail`r!(0;0#0;dists),(2;n;n)#0f
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Run affinity propagation algorithm
// @param damp {float} Damping coefficient
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return {dict} Updated inputs
clust.i.apAlgo:{[damp;info]
  // Update responsibility matrix
  info[`r]:clust.i.updR[damp;info];
  // Update availability matrix
  info[`avail]:clust.i.updAvail[damp;info];
  // Find new exemplars
  ex:iMax each sum info`avail`r;
  // Update `info` with new exemplars/matches
  info:update exemplars:ex,matches:?[exemplars~ex;matches+1;0]from info;
  // Update iter dictionary
  .[clust.i.apConv info;(`iter;`run);+[1]]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Check affinity propagation algorithm for convergence
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return {dict} Updated info dictionary
clust.i.apConv:{[info]
  // Iteration dictionary
  iter:info`iter;
  // Exemplar matrix
  exemMat:info`exemMat;
  // Existing exemplars
  exemDiag:0<sum clust.i.diag each info`avail`r;
  exemMat[;iter[`run]mod iter`noChange]:exemDiag;
  // Check for convergence
  if[iter[`noChange]<=iter`run;
    unConv:count[info`similar]<>sum(se=iter`noChange)+0=se:sum each exemMat;
    conv:$[(iter[`total]=iter`run)|not[unConv]&sum[exemDiag]>0;1b;0b]];
  // Return updated info
  info,`exemMat`conv!(exemMat;conv)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Retrieve diagonal from a square matrix
// @param matrix {any[][]} Square matrix
// @return {any[]} Matrix diagonal
clust.i.diag:{[matrix]
  {x y}'[matrix;til count matrix]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Update responsibility matrix
// @param damp {float} Damping coefficient
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return {float[][]} Updated responsibility matrix
clust.i.updR:{[damp;info]
  mx:clust.i.maxResp'[sum info`similar`avail;til count info`r];
  // Calculate new responsibility
  (damp*info`r)+(1-damp)*info[`similar]-mx
  }	

// @private
// @kind function
// @category clustUtility
// @fileoverview Create matrix with every points max responsibility
//   diagonal becomes -inf, current max becomes second max
// @param data {float[]} Sum of similarity and availability matrices
// @param i {long} Index of responsibility matrix
// @return {float[][]} Responsibility matrix
clust.i.maxResp:{[data;i]
  maxData:max data;
  maxI:data?maxData;
  @[count[data]#maxData;maxI;:;]max@[data;i,maxI;:;-0w]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Update availability matrix
// @param damp {float} Damping coefficient
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return {float[][]} Returns updated availability matrix
clust.i.updAvail:{[damp;info]
  // Sum values in positive availability matrix
  resp:0|info`r;
  k:til count info`avail;
  sumR:sum@[;;:;0f]'[resp;k];
  // Create a matrix using the negative values produced by the availability sum
  //  + responsibility diagonal - positive availability values
  avail:@[;;:;]'[0&(sumR+info[`r]@'k)-/:resp;k;sumR];
  // Calculate new availability
  (damp*info`avail)+avail*1-damp
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Stopping condition for affinity propagation algorithm
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return {bool} Indicates whether to continue or stop running AP (1/0b)
clust.i.apStop:{[info]
  (info[`iter;`total]>info[`iter]`run)&not 1b~info`conv
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Predict clusters using AP training exemplars
// @param centre {float[][]} Training cluster centres in matrix format, 
//   each column is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param pt {float[]} Current data point
// @return {long[]} Predicted clusters
clust.i.apPredDist:{[centre;df;pt]
  dists:clust.i.dists[centre;df;pt]each til count centre 0;
  iMax dists
  }

// KD Tree utilities

// @private
// @kind function
// @category kdtree
// @fileoverview Create tree table where each row represents a node
// @param data {float[][]} Each column of the data is an individual datapoint
// @param leafSize {long} Points per leaf (<2*number of representatives)
// @param node {dict} Info for a given node in the tree
// @return {tab} k-d tree table
clust.kd.i.tree:{[data;leafSize;node]
  if[leafSize<=.5*count node`idxs;
    xData:data[;node`idxs];
    varData:var each xData;
    split:xData<med xData@:ax:iMax varData;
    leftIdxs:where split;
    rightIdxs:where not split;
    if[all leafSize<=count each (leftIdxs;rightIdxs);
      leftNode:update left:1b,parent:self,self+1,idxs:idxs leftIdxs from node;
      n:count leftTree:.z.s[data;leafSize]leftNode;
      rightNode:update left:0b,parent:self,self+1+n,idxs:idxs rightIdxs 
        from node;
      rightTree:.z.s[data;leafSize]rightNode;
      node:select leaf,left,self,parent,children:self+1+(0;n),axis:ax,
        midVal:"f"$min xData rightIdxs,idxs:0#0 from node;
      :enlist[node],leftTree,rightTree
      ]
    ];
  enlist select leaf:1b,left,self,parent,children:0#0,axis:0N,midVal:0n,idxs 
    from node
  }

// @private
// @kind function
// @category kdtree
// @fileoverview Search each node and check nearest neighbors
// @param tree {tab} k-d tree table
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {func} Distance function
// @param xIdxs {long[][]} Points to exclude in search
// @param pt {long[]} Point to find nearest neighbor for
// @param nnInfo {dict} Nearest neighbor info of a point
// @return {dict} Updated nearest neighbor info
clust.kd.i.nnCheck:{[tree;data;df;xIdxs;pt;nnInfo]
  if[nnInfo[`node]`leaf;
    closest:clust.i.closest[data;df;pt]nnInfo[`node;`idxs]except xIdxs;
    if[closest[`distance]<nnInfo`closestDist;
      nnInfo[`closestPoint`closestDist]:closest`point`distance;
      ]
    ];
  childIdx:first nnInfo[`node;`children]except nnInfo`xNodes;
  if[not null childIdx;
    nnDist:clust.i.df[df]pt[nnInfo[`node]`axis]-nnInfo[`node]`midVal;
    childIdx:$[nnInfo[`closestDist]<nnDist;
      0N;
      clust.kd.findLeaf[tree;pt;tree childIdx]`self
      ]
    ];
  if[null childIdx;nnInfo[`xNodes],:nnInfo[`node]`self];
  nnInfo[`node]:tree nnInfo[`node;`parent]^childIdx;
  nnInfo
  }

// @private
// @kind function
// @category kdtree
// @fileoverview Find the next direction to take in the tree
// @param tree {tab} k-d tree table
// @param pt {float[]} Current point to put in tree
// @param node {dict} Current node to check
// @return {long} Next direction to take
clust.kd.i.findNext:{[tree;pt;node]
  tree node[`children]node[`midVal]<=pt node`axis
  }

// Scoring utilities

// @private
// @kind function
// @category clustUtility
// @fileoverview Entropy
// @param d {long[]} distribution
// @return {float} Entropy for d
clust.i.entropy:{[d]
  distrib:count each group d;
  n:sum distrib;
  neg sum(distrib%n)*(-). log(distrib;n)
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Maximum intra-cluster distance
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param data {float[][]} Each column of the data is an individual datapoint
// @return {float} Max intra-cluster distance
clust.i.maxIntra:{[df;data]
  max raze clust.i.intra[df;data;n]each n:til count first data
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate intra-cluster distance
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param data {float[][]} Each column of the data is an individual datapoint
// @param idxs {int[]} All indices of the data
// @param i {int} Single index within the data 
// @return {float} Intra-cluster distance
clust.i.intra:{[df;data;idxs;i]
  updIdx:idxs except til 1+i;
  clust.i.dists[data;df;data[;i];updIdx]
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Minimum inter-cluster distance
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param data {float[][]} Each column of the data is an individual datapoint
// @param idxs {long[]} Cluster indices
// @return {float} Min inter-cluster distance
clust.i.minInter:{[df;data;idxs]
   clust.i.inter[df;data;first idxs]each 1_idxs
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Calculate inter-cluster distance
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param data {float[][]} Each column of the data is an individual datapoint
// @param init {int[]} First index in the data
// @param i {int} Single index within the data 
// @return {float} Inter-cluster distance
clust.i.inter:{[df;data;init;i]
  (min/)clust.i.dists[data[init];df;data[i]]each til count data[init]0
  }

// @private
// @kind function
// @category clustUtility
// @fileoverview Silhouette coefficient
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param idxs {dict} Point indices grouped by cluster
// @param k {float} Coefficient to multiply by
// @param clusts {long} Cluster of current point
// @param pt {float} Current point
// @return {float} Silhouette coefficent for pt
clust.i.sil:{[data;df;idxs;k;clusts;pt]
  dists:clust.i.dists[data;df;pt]each idxs;
  split:dists@/:(key[idxs]except clusts;clusts);
  (%).((-).;max)@\:(min avg each;k[clusts]*sum@)@'split
  }

// @kind function
// @category clustUtility
// @fileoverview Davies-Bouldin of a single index
// @param avgDist {float} Average distance between clusters and average value
// @param avgClust {float} Average value of each cluster
// @param idx {int[]} All indices of cluster
// @param n {int} Single index of the cluster group
// @return {float} Davies Bouldin index of single point
clust.i.daviesBouldin:{[avgDist;avgClust;idx;n]
  dists:clust.i.dists[flip avgClust updIdx:idx _n;`edist;avgClust n;::];
  max(avgDist[n]+avgDist updIdx)%'dists
  }

// @private
// @kind function
// @category clust
// @fileoverview Elbow method
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df'
// @param k {long} Number of clusters to be fit for k-means
// @return {float[]} Score for single cluster k value
clust.i.elbow:{[data;df;k]
  clusts:clust.kmeans.fit[data;df;k;::][`modelInfo;`clust];
  dataClusts:{x[;y]}[data]each group clusts;
  sum raze clust.i.dists[;df;;::]'[dataClusts;avg@''dataClusts]
  }
