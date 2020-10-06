\d .ml

// Cluster Scoring Algorithms

// Unsupervised Learning

// @kind function
// @category clust
// @fileoverview Davies-Bouldin index - Euclidean distance only (edist)
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param clt  {long[]}    List of clusters produced by .ml.clust algos
// @return     {float}     Davies Bouldin index of clt
clust.daviesbouldin:{[data;clt]
  a:avg@''p:{x[;y]}[data]each group clt;
  s:avg each clust.i.dists[;`edist;;::]'[p;a];
  db:{[s;a;x;y]max(s[y]+s e)%'clust.i.dists[flip a e:x _y;`edist;a y;::]};
  (sum db[s;a;t]each t:til n)%n:count a
  }

// @kind function
// @category clust
// @fileoverview Dunn index
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param clt  {long[]}    List of clusters produced by .ml.clust algos
// @return     {float}     Dunn index of clt
clust.dunn:{[data;df;clt]
  mx:clust.i.maxintra[df]each p:{x[;y]}[data]each group clt;
  mn:min raze clust.i.mininter[df;p]each -2_({1_x}\)til count p;
  mn%max raze mx
  }

// @kind function
// @category clust
// @fileoverview Silhouette score
// @param data  {float[][]} Data in matrix format, each column is an individual datapoint
// @param df    {symbol}    Distance function name within '.ml.clust.df'
// @param clt   {long[]}    List of clusters produced by .ml.clust algos
// @param isavg {bool}      List of scores or the average score (1/0b)
// @return      {float}     Silhouette score of clt
clust.silhouette:{[data;df;clt;isavg]
  k:1%(count each group clt)-1;
  $[isavg;avg;]clust.i.sil[data;df;group clt;k]'[clt;flip data]
  }

// Supervised Learning

// @kind function
// @category clust
// @fileoverview Homogeneity Score
// @param pred {long[]} Predicted cluster labels
// @param true {long[]} True cluster labels
// @return     {float}  Homogeneity score for true
clust.homogeneity:{[pred;true]
  if[count[pred]<>n:count true;
    '`$"distinct lengths - lenght of lists has to be the same"];
  if[not e:clust.i.entropy true;:1.];
  cm:value confmat[pred;true];
  nm:(*\:/:).((count each group@)each(pred;true))@\:til count cm;
  mi:(sum/)0^cm*.[-;log(n*cm;nm)]%n;
  mi%e
  }

// Optimum number of clusters

// @kind function
// @category clust
// @fileoverview Elbow method
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param k    {long}      Max number of clusters
// @return     {float[]}   Score for each k value - plot to find elbow
clust.elbow:{[data;df;k]
  {[data;df;k]
    clt:clust.kmeans.fit[data;df;k;::]`clt;
    sum raze clust.i.dists[;df;;::]'[p;a:avg@''p:{x[;y]}[data]each group clt]
    }[data;df]each 2+til k-1
  }

// Utilities

// @kind function
// @category private
// @fileoverview Entropy
// @param d {long[]} distribution
// @return  {float} Entropy for d
clust.i.entropy:{[d]
  neg sum(p%n)*(-). log(p;n:sum p:count each group d)
  }

// @kind function
// @category private
// @fileoverview Maximum intra-cluster distance
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @return     {float}     Max intra-cluster distance
clust.i.maxintra:{[df;data]
  max raze{[df;data;x;y]
    clust.i.dists[data;df;data[;y];x except til 1+y]
    }[df;data;n]each n:til count first data
  }

// @kind function
// @category private
// @fileoverview Minimum inter-cluster distance
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param idxs {long[]}    Cluster indices
// @return     {float}     Min inter-cluster distance
clust.i.mininter:{[df;data;idxs]
  {[df;data;i;j]
    (min/)clust.i.dists[data[i];df;data[j]]each til count data[i]0
    }[df;data;first idxs]each 1_idxs
  }

// @kind function
// @category private
// @fileoverview Silhouette coefficient
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param idxs {dict}      Point indices grouped by cluster
// @param k    {float}     Coefficient to multiply by
// @param clt  {long}      Cluster of current point
// @param pt   {float}     Current point
// @return     {float}     Silhouette coefficent for pt
clust.i.sil:{[data;df;idxs;k;clt;pt]
  d:clust.i.dists[data;df;pt]each idxs;
  (%).((-).;max)@\:(min avg each;k[clt]*sum@)@'d@/:(key[idxs]except clt;clt)
  }
