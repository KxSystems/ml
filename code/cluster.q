// code/cluster.q - Nlp clustering utilities
// Copyright (c) 2021 Kx Systems Inc
// 
// Clustering utilites for textual data 

\d .nlp

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Extract the keywords from a list of documents or keyword
//   dictionary
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @returns {dictionary[]} Keyword dictionaries
cluster.i.asKeywords:{[parsedTab]
  keyWords:$[-9=type parsedTab[0]`keywords;parsedTab;parsedTab`keywords];
  i.fillEmptyDocs keyWords
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Split the document into clusters using kmeans
// @param iters {long} The number of times to iterate the refining step
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param clusters {long} Cluster indices
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.i.bisect:{[iters;parsedTab;clusters]
  idx:i.minIndex cluster.MSE each parsedTab clusters;
  cluster:clusters idx;
  (clusters _ idx),cluster@/:cluster.kmeans[parsedTab cluster;2;iters]
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Apply k-means clustering to a document
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param clusters {long[]} Cluster indices
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.i.kmeans:{[parsedTab;clusters]
  centroids:(i.takeTop[3]i.fastSum@)each parsedTab clusters;
  value group i.maxIndex each centroids compareDocs\:/:parsedTab
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Find nearest neighbor of document
// @param centroids {dictionary[]} Centroids as keyword dictionaries
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @returns {long[][]} Document indices 
cluster.i.findNearestNeighbor:{[centroids;doc]
  similarities:compareDocs[doc] each centroids;
  m:max similarities;
  $[m>0f;similarities?m;0n]
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Merge any clusters with significant overlap into a single 
//   cluster
// @param clusters {any[][]} Cluster indices
// @returns {any[][]} Appropriate clusters merged together
cluster.i.mergeOverlappingClusters:{[clusters]
  counts:count each clusters;
  similar:cluster.i.similarClusters[clusters;counts]each til count clusters;
  // Merge any cluster that has at least one similar cluster
  // A boolean vector of which clusters will be getting merged
  merge:1<count each similar;
  // Filter out clusters of 1, and remove duplicates
  similarClusters:distinct desc each similar where merge;
  // Do the actual merging of the similar clusters
  newClusters:(distinct raze@)each clusters similarClusters;
  // Clusters not involved in any merge
  // This can't just be (not merge), as that only drops the larger cluster,
  // not the smaller one, in each merge
  untouchedClusters:(til count clusters)except raze similarClusters;
  clusters[untouchedClusters],newClusters
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Group together clusters that share over 50% of their elements
// @param clusters {any[][]} Cluster indices
// @param counts {long} Count of each cluster
// @param idx {long} Index of cluster
// @return {any[][]} Clusters grouped together
cluster.i.similarClusters:{[clusters;counts;idx]
  superset:counts=sum each clusters[idx]in/:clusters;
  similar:.5<=avg each clusters[idx]in/:clusters;
  notSmaller:(count clusters idx)>=count each clusters;
  where superset or(similar & notSmaller)
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Normalize the columns of a matrix so they sum to 1
// @param matrix {float[][]} Numeric matrix of values 
// @returns {float[][]} The normalized columns
cluster.i.columnNormalize:{[matrix]
  0f^matrix%\:sum matrix
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc Graph clustering that works on a similarity matrix
// @param matrix {boolean[][]} NxN adjacency matrix
// @returns {long[][]} Lists of indices in the corpus where each row 
//   is a cluster
cluster.i.similarityMatrix:{[matrix]
  matrix:"f"$matrix;
  // Make the matrix stochastic and run MCL until stable
  normMatrix:cluster.i.columnNormalize matrix;
  attractors:cluster.i.MCL/[normMatrix];
  // Use output of MCL to get the clusters
  clusters:where each attractors>0;
  // Remove empty clusters and duplicates
  distinct clusters where 0<>count each clusters
  }

// @private
// @kind function
// @category nlpClusteringUtility
// @desc SM Van Dongen's MCL clustering algorithm
// @param matrix {float[][]} NxN matrix
// @return {float[][]} MCL algorithm applied to matrix
cluster.i.MCL:{[matrix]
  // Expand matrix by raising to the nth power (currently set to 2)
  do[2-1;mat:{i.np[`:matmul;x;x]`}matrix];
  mat:cluster.i.columnNormalize mat*mat;
  @[;;:;0f] ./:flip(mat;where each(mat>0)&(mat<.00001))
  }

// @kind function
// @category nlpClustering
// @desc Uses the top ten keywords of each document in order to cluster
//   similar documents together  
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param k {long} The number of clusters to return
// @returns {long[][]} The documents' indices grouped into clusters
cluster.summarize:{[parsedTab;k]
  if[0=count parsedTab;:()];
  docs:i.takeTop[10]each cluster.i.asKeywords parsedTab;
  summary:i.fastSum[docs]%count docs;
  centroids:();
  do[k;
    // Find the document that summarizes the corpus best
    // and move that document to the centroid list
    centroids,:nearest:i.maxIndex docs[;i.maxIndex summary];
    summary-:docs nearest;
    summary:(where summary<0)_ summary
    ];
  cluster.groupByCentroids[docs centroids;docs]
  }

// @kind function
// @category nlpClustering
// @desc Use the top 50 keywords of each document to calculate the 
//   cohesiveness as measured by the mean sum of sqaures
// @param keywords {dictionary[]} A parsed document containing keywords and 
//   their associated significance scores
// @returns {float} The cohesion of the cluster
cluster.MSE:{[parsedTab]
  n:count parsedTab;
  if[(0=n)|0=sum count each parsedTab,(::);:0n];
  if[1=n;:1f];
  centroid:i.takeTop[50]i.fastSum parsedTab;
  docs:i.fillEmptyDocs parsedTab;
  // Don't include the current document in the centroid, or for small clusters
  // it just reflects its similarity to itself
  dists:0^compareDocToCentroid[centroid]each docs;
  avg dists*dists
  }

// @kind function
// @category nlpClustering
// @desc The bisecting k-means algorithm which uses k-means to 
//   repeatedly split the most cohesive clusters into two clusters
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param k {long} The number of clusters to return
// @param iters {long} The number of times to iterate the refining step
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.bisectingKMeans:{[parsedTab;k;iters]
  docs:cluster.i.asKeywords parsedTab;
  if[0=n:count docs;:()];
  (k-1)cluster.i.bisect[iters;docs]/enlist til n
  }

// @kind function
// @category nlpClustering
// @desc k-means clustering for documents
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param k {long} The number of clusters to return
// @param iters {long} The number of times to iterate the refining step
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.kmeans:{[parsedTab;k;iters]
  docs:cluster.i.asKeywords parsedTab;
  numDocs:count docs;
  iters cluster.i.kmeans[docs]/(k;0N)#neg[numDocs]?numDocs
  }

// @kind function
// @category nlpClustering
// @desc Given a list of centroids and a list of documents, match each
//   document to its nearest centroid
// @param centroids {dictionary[]} Centroids as keyword dictionaries
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @returns {long[][]} Lists of document indices where each list is a cluster
//   N.B. These don't line up with the number of centroids passed in,
//   and the number of lists returned may not equal the number of centroids.
//   There can be documents which match no centroids (all of which will end up 
//   in the same group), and centroids with no matching documents.
cluster.groupByCentroids:{[centroids;parsedTab]
  // If there are no centroids, everything is in one group
  if[not count centroids;:enlist til count parsedTab];
  value group cluster.i.findNearestNeighbor[centroids]each parsedTab
  }

// @kind function
// @category nlpClustering
// @desc Uses the Radix clustering algorithm and bins are taken from 
//   the top 3 terms of each document
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param k {long} The number of clusters desired, though fewer may
//   be returned. This must be fairly high to cover a substantial amount of the
//   corpus, as clusters are small
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.radix:{[parsedTab;k]
  docs:cluster.i.asKeywords parsedTab;
  // Bin on keywords, taking the 3 most significant keywords from each document
  // and dropping those that occur less than 3 times  
  reduced:{distinct 4#key desc x}each docs; 
  // Remove any keywords that occur less than 5 times
  keywords:where (count each group raze reduced) >= 5;
  keywords:keywords except `;
  clusters:{[reduced;keyword]where keyword in/:reduced}[reduced]each keywords;
  // Score clusters based on the harmonic mean of their cohesion and log(size)
  cohesion:i.normalize cluster.MSE each docs clusters;
  size:i.normalize log count each clusters;
  score:i.harmonicMean each flip(cohesion;size);
  // Take the n*2 highest scoring clusters, as merging will remove some
  // but don't run it on everything, since merging is expensive.
  // This may lead to fewer clusters than expected if a lot of merging happens
  clusters:clusters sublist[2*k]idesc score;
  sublist[k]cluster.i.mergeOverlappingClusters/[clusters]
  }

// @kind function
// @category nlpClustering
// @desc Uses the Radix clustering algorithm and bins by the most 
//   significant term
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param k {long} The number of clusters desired, though fewer may
//   be returned. This must be fairly high to cover a substantial amount of the
//   corpus, as clusters are small
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.fastRadix:{[parsedTab;k]
  docs:cluster.i.asKeywords parsedTab;
  // Group documents by their most significant term
  grouped:group i.maxIndex each docs;
  // Remove the entry for empty documents
  grouped:grouped _ `;
  // Remove all clusters containing only one element
  clusters:grouped where 1<count each grouped;
  // Score clusters based on the harmonic mean of their cohesion and log(size)
  cohesion:i.normalize cluster.MSE each docs clusters;
  size:i.normalize log count each clusters;
  score:i.harmonicMean each flip(cohesion;size);
  // Return the n highest scoring clusters
  clusters sublist[k]idesc score
  }

// @kind function
// @category nlpClustering
// @desc Cluster a subcorpus using graph clustering
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @param minimum {float} The minimum similarity that will be considered
// @param sample {boolean} If this is true, a sample of sqrt(n) documents is
//   used, otherwise all documanets are used
// @returns {long[][]} The documents' indices, grouped into clusters
cluster.MCL:{[parsedTab;minimum;sample]
  docs:cluster.i.asKeywords parsedTab;
  idx:$[sample;(neg"i"$sqrt count docs)?count docs;til count docs];
  keywords:docs idx;
  n:til count keywords;
  similarities:i.matrixFromRaggedList compareDocToCorpus[keywords]each n;
  // Find all the clusters
  clusters:cluster.i.similarityMatrix similarities>=minimum;
  clustersOfOne:1=count each clusters;
  if[not sample;:clusters where not clustersOfOne];
  // Any cluster of 1 documents isn't a cluster, so throw it out
  outliers:raze clusters where clustersOfOne;
  // Only keep clusters where the count is greater than one
  clusters@:where 1<count each clusters;
  // Find the centroid of each cluster
  centroids:avg each keywords clusters;
  // Move each non-outlier to the nearest centroid
  nonOutliers:(til count docs)except idx outliers;
  nonOutliers cluster.groupByCentroids[centroids;docs nonOutliers]
  }
