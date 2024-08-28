// clust/init.q - Load clustering library
// Copyright (c) 2021 Kx Systems Inc
// 
// Clustering algorithms including affinity propagation, 
// cure, dbscan, hierarchical, and k-means clustering

\d .ml

// required for use of .ml.confmat in score.q
loadfile`:util/init.q

// load clustering files
loadfile`:clust/utils.q
loadfile`:clust/kdtree.q
loadfile`:clust/kmeans.q
loadfile`:clust/aprop.q
loadfile`:clust/dbscan.q
loadfile`:clust/hierarchical.q
loadfile`:clust/score.q

.ml.i.deprecWarning`clust
