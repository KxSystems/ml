// clust/score.q - Scoring metrics for clustering
// Copyright (c) 2021 Kx Systems Inc
// 
// Scoring metrics allow you to validate the performance 
// of your clustering algorithms

\d .ml

// Cluster Scoring Algorithms

// Unsupervised Learning

// @kind function
// @category clust
// @desc Davies-Bouldin index - Euclidean distance only (edist)
// @param data {float[][]} Each column of the data is an individual datapoint
// @param clusts {long[]} Clusters produced by .ml.clust algos
// @return {float} Davies Bouldin index of clusts
clust.daviesBouldin:{[data;clusts]
  dataClust:{x[;y]}[data]each group clusts;
  avgClust:avg@''dataClust;
  avgDist:avg each clust.i.dists[;`edist;;::]'[dataClust;avgClust];
  n:count avgClust;
  dbScore:clust.i.daviesBouldin[avgDist;avgClust;t]each t:til n;
  sum[dbScore]%n
  }

// @kind function
// @category clust
// @desc Dunn index
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {symbol} Distance function name within '.ml.clust.i.df'
// @param clusts {long[]} Clusters produced by .ml.clust algos
// @return {float} Dunn index of clusts
clust.dunn:{[data;df;clusts]
  dataClust:{x[;y]}[data]each group clusts;
  mx:clust.i.maxIntra[df]each dataClust;
  upperTri:-2_({1_x}\)til count dataClust;
  mn:min raze clust.i.minInter[df;dataClust]each upperTri;
  mn%max raze mx
  }

// @kind function
// @category clust
// @desc Silhouette score
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {symbol} Distance function name within '.ml.clust.i.df'
// @param clusts {long[]} Clusters produced by .ml.clust algos
// @param isAvg {boolean} Are all scores (0b) or the average score (1b)
//   to be returned
// @return {float} Silhouette score of clusts
clust.silhouette:{[data;df;clusts;isAvg]
  k:1%(count each group clusts)-1;
  $[isAvg;avg;]clust.i.sil[data;df;group clusts;k]'[clusts;flip data]
  }

// Supervised Learning

// @kind function
// @category clust
// @desc Homogeneity Score
// @param pred {long[]} Predicted cluster labels
// @param true {long[]} True cluster labels
// @return {float} Homogeneity score for true
clust.homogeneity:{[pred;true]
  if[count[pred]<>n:count true;
    '"pred and true must have equal lengths"
    ];
  if[not ent:clust.i.entropy true;:1.];
  confMat:value confMatrix[pred;true];
  nm:(*\:/:).((count each group@)each(pred;true))@\:til count confMat;
  mi:(sum/)0^confMat*.[-;log(n*confMat;nm)]%n;
  mi%ent
  }

// Optimum number of clusters

// @kind function
// @category clust
// @desc Elbow method
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {symbol} Distance function name within '.ml.clust.i.df'
// @param k {long} Max number of clusters
// @return {float[]} Score for each k value - plot to find elbow
clust.elbow:{[data;df;k]
  clust.i.elbow[data;df]each 2+til k-1
  }
