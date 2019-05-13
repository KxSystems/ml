#include "k.h"
qtemplate({
  "names":["cure_nnleaf","cure_nn","cure_cluster_dists","edist2","cure_cluster_reps"],
  "types":["QT1"],
  "ptypes":{"QT1":["F","E"]}}|
// find whether any points in a leaf are closer than current nearest neighbor and not in the same cluster and update nearest if so
Z V cure_nnleaf(K point,K leafi,J cluster,QT1* currdist,J* curri,J* clusters,K reps);
// closest point and distance to closest point, excludes points in same cluster
K cure_nn(K kpointind,K tree,K clusters,K reps);
// distance from cluster1 to each of the clusters in cluster2list
K cure_cluster_dists(K cluster1,K cluster2list,K reps);
// euclidean distance squared
Z QT1 edist2(K p1,K p2);
// pick kn representatives from a list of points, starting with the furthest from the centroid
K cure_cluster_reps(K pts,K kn,K cent);
)
