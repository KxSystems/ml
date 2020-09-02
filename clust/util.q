\d .ml

// Clustering Utilities

// Distance metric dictionary

// @kind function
// @category private
// @fileoverview Euclidean distance calculation
// @param data {float[][]} Points
// @return     {float[]}   Euclidean distances for data 
clust.i.dd.edist:{[data]
  sqrt data wsum data
  }

// @kind function
// @category private
// @fileoverview distance calculation
// @param data {float[][]} Points
// @return     {float[]}   Euclidean squared distances for data 
clust.i.dd.e2dist:{[data]
  data wsum data
  }

// @kind function
// @category private
// @fileoverview Manhattan distance calculation
// @param data {float[][]} Points
// @return     {float[]}   Manhattan distances for data 
clust.i.dd.mdist:{[data]
  sum abs data
  }

// @kind function
// @category private
// @fileoverview Chebyshev distance calculation
// @param data {float[][]} Points
// @return     {float[]}   Chebyshev distances for data 
clust.i.dd.cshev:{[data]
  min abs data
  }

// @kind function
// @category private
// @fileoverview Negative euclidean squared distance calculation
// @param data {float[][]} Points
// @return     {float[]}   Negative euclidean squared distances for data 
clust.i.dd.nege2dist:{[data]
  neg data wsum data
  }

// @kind dictionary
// @category private
// @fileoverview Linkage dictionary
clust.i.ld.single:min
clust.i.ld.complete:max
clust.i.ld.average:avg
clust.i.ld.centroid:raze
clust.i.ld.ward:{z*x*y%x+y}

// Distance calculations

// @kind function
// @category private
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param pt   {float[]}   Current point
// @param idxs {long[]}    Indices from data
// @return     {float[]}   Distances for data and pt
clust.i.dists:{[data;df;pt;idxs]
  clust.i.dd[df]pt-data[;idxs]
  }

// @kind function
// @category private
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param pt   {float[]}   Current point
// @param idxs {long[]}    Indices from data
// @return     {float[]}   Distances for data and pt
clust.i.closest:{[data;df;pt;idxs]
  `point`distance!(idxs dists?md;md:min dists:clust.i.dists[data;df;pt;idxs])
  }

// @kind function
// @category private
// @fileoverview Reindex exemplars
// @param  data {#any[]} Data points
// @return      {long[]} List of indices
clust.i.reindex:{[data]
  distinct[data]?data
  }

// @kind dictionary
// @category private
// @fileoverview Error dictionary
clust.i.err.dd:{'`$"invalid distance metric"}
clust.i.err.ld:{'`$"invalid linkage"}
clust.i.err.ward:{'`$"ward must be used with e2dist"}
clust.i.err.centroid:{'`$"centroid must be used with edist/e2dist"}
clust.i.err.kmeans:{'`$"kmeans must be used with edist/e2dist"}
