\d .nlp

// Run on either docs or keyword dicts
cluster.i.asKeywords:{i.fillEmptyDocs $[-9=type x[0]`keywords;x;x`keywords]}

// Get cohesiveness of cluster as measured by mean sum of squares error
cluster.MSE:{[docs]
  $[0=n:count docs;0n;1=n;1.;0=sum count each docs;0n;
    avg d*d:0^compareDocToCentroid[i.takeTop[50]i.fastSum docs]each i.fillEmptyDocs docs]}

// Bisecting k-means algo (repeatedly splits largest cluster in 2)
cluster.bisectingKMeans:{[docs;k;n]
  if[0=n:count docs:cluster.i.asKeywords docs;:()];
  (k-1){[n;docs;clusters]
    cluster:clusters idx:i.minIndex cluster.MSE each docs clusters;
    (clusters _ idx),cluster@/:cluster.kmeans[docs cluster;2;n]
  }[n;docs]/enlist til n}

// k-means clustering for docs
cluster.kmeans:{[docs;k;n]
  n{[docs;clusters]
    centroids:(i.takeTop[3]i.fastSum@)each docs clusters;
    value group i.maxIndex each centroids compareDocs\:/:docs
  }[docs]/(k;0N)#neg[nd]?nd:count docs:cluster.i.asKeywords docs}

// Match each doc to nearest centroid
cluster.groupByCentroids:{[centroids;docs]
  value group{[centroids;doc]$[0<m:max s:compareDocs[doc]each centroids;s?m;0n]}[centroids]each docs}

// Merge any clusters with significant overlap into a single cluster
cluster.i.mergeOverlappingClusters:{[clusters]
  similarClusters:{[clusters;counts;idx]
    superset:counts=sum each clusters[idx]in/:clusters;
    similar:.5<=avg each clusters[idx]in/:clusters;
    notSmaller:(count clusters idx)>=count each clusters;
    where superset or(similar & notSmaller)
  }[clusters;count each clusters]each til count clusters;
  merge:1<count each similarClusters;
  similarClusters:distinct desc each similarClusters where merge;
  newClusters:(distinct raze@)each clusters similarClusters;
  untouchedClusters:(til count clusters)except raze similarClusters;
  clusters[untouchedClusters],newClusters}

// Extremely fast clustering algo for large datasets (produces small but cohesive clusters)
cluster.radix:{[docs;n]
  reduced:{distinct 4#key desc x}each docs:cluster.i.asKeywords docs;
  keywords:(where 5<=count each group raze reduced)except`;
  clusters:{[reduced;keyword]where keyword in/:reduced}[reduced]each keywords;
  cohesion:i.normalize cluster.MSE each docs clusters;
  size:i.normalize log count each clusters;
  score:i.harmonicMean each flip(cohesion;size);
  sublist[n]cluster.i.mergeOverlappingClusters/[clusters sublist[2*n]idesc score]}

cluster.fastRadix:{[docs;n]
  docs:cluster.i.asKeywords docs;
  grouped:(group i.maxIndex each docs)_`;
  clusters:grouped where 1<count each grouped;
  cohesion:i.normalize cluster.MSE each docs clusters;
  size:i.normalize log count each clusters;
  score:i.harmonicMean each flip(cohesion;size);
  clusters sublist[n]idesc score}

// Cluster a subcorpus using graph clustering
cluster.MCL:{[docs;mn;sample]
  docs:cluster.i.asKeywords docs;
  keywords:docs idx:$[sample;(neg"i"$sqrt count docs)?count docs;til count docs];
  similarities:i.matrixFromRaggedList i.compareDocToCorpus[keywords]each til count keywords;
  // Find all the clusters
  clustersOfOne:1=count each clusters:cluster.i.similarityMatrix similarities>=mn;
  if[not sample;:clusters where not clustersOfOne];
  // Any cluster of 1 documents isn't a cluster, so throw it out
  outliers:raze clusters where clustersOfOne;
  // Only keep clusters where the count is greater than one
  clusters@:where 1<count each clusters;
  // Find the centroid of each cluster
  centroids:avg each keywords clusters;
  // Move each non-outlier to the nearest centroid
  nonOutliers:(til count docs)except idx outliers;
  nonOutliers cluster.groupByCentroids[centroids;docs nonOutliers]}

// Graph clustering that works on a similarity matrix
cluster.i.columnNormalize:{[mat]0f^mat%\:sum mat}
cluster.i.similarityMatrix:{[mat]
  matrix:"f"$mat;
  // SM Van Dongen's MCL clustering algorithm
  MCL:{[mat]
    // Expand matrix by raising to the nth power (currently set to 2)
    do[2-1;mat:{i.np[`:matmul;x;x]`}mat];
    mat:cluster.i.columnNormalize mat*mat;
    @[;;:;0f] ./:flip(mat;where each(mat>0)&(mat<.00001))};
  // Make the matrix stochastic and run MCL until stable
  attractors:MCL/[cluster.i.columnNormalize mat];
  // Use output of MCL to get the clusters
  clusters:where each attractors>0;
  // Remove empty clusters and duplicates
  distinct clusters where 0<>count each clusters}

// Subtracts most representive elements from centroid & iterate until number of clusters reached
cluster.summarize:{[docs;n]
  if[0=count docs;:()];
  docs:i.takeTop[10]each cluster.i.asKeywords docs;
  summary:i.fastSum[docs]%count docs;
  centroids:();
  do[n;
    centroids,:nearest:i.maxIndex docs[;i.maxIndex summary];
    summary-:docs nearest;
    summary:(where summary<0)_ summary];
  cluster.groupByCentroids[docs centroids;docs]}
