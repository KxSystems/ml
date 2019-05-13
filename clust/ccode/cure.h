#include "k.h"

// find whether any points in a leaf are closer than current nearest neighbor and not in the same cluster and update nearest if so
Z V cure_nnleaf_F(K point,K leafi,J cluster,F* currdist,J* curri,J* clusters,K reps);
// closest point and distance to closest point, excludes points in same cluster
K cure_nn_F(K kpointind,K tree,K clusters,K reps);
// distance from cluster1 to each of the clusters in cluster2list
K cure_cluster_dists_F(K cluster1,K cluster2list,K reps);
// euclidean distance squared
Z F edist2_F(K p1,K p2);
// pick kn representatives from a list of points, starting with the furthest from the centroid
K cure_cluster_reps_F(K pts,K kn,K cent);

// find whether any points in a leaf are closer than current nearest neighbor and not in the same cluster and update nearest if so
Z V cure_nnleaf_E(K point,K leafi,J cluster,E* currdist,J* curri,J* clusters,K reps);
// closest point and distance to closest point, excludes points in same cluster
K cure_nn_E(K kpointind,K tree,K clusters,K reps);
// distance from cluster1 to each of the clusters in cluster2list
K cure_cluster_dists_E(K cluster1,K cluster2list,K reps);
// euclidean distance squared
Z E edist2_E(K p1,K p2);
// pick kn representatives from a list of points, starting with the furthest from the centroid
K cure_cluster_reps_E(K pts,K kn,K cent);


