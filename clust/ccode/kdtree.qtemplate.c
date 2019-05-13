#include "kdtree.h"
qtemplate({
  "names":["kdtree_searchfrom_i","kdtree_rdist"],
  "types":["QT1"],
  "ptypes":{"QT1":["F","E"]}}|
// tree is (parent;isleft;isleaf;children;pivval;pivaxis) count[tree[0]]~num nodes
J kdtree_searchfrom_i(K tree,K point,J i){
  G* isleaf=kG(kK(tree)[2]);
  K children=kK(tree)[3];
  QT1* pivots=kQT1(kK(tree)[4]);
  J* axes=kJ(kK(tree)[5]);
  // go left or right at each node until a leaf is hit
  while(!isleaf[i])
    i=kJ(kK(children)[i])[(I)(kQT1(point)[axes[i]]>=pivots[i])];
  R i;
}
// min distance between point and (parent nodes) i.e. the distance from the pivot point along the pivot axis
QT1 kdtree_rdist(K point,K tree,J parent){
  F pv=kQT1(kK(tree)[4])[parent]; // pivot value
  J pa=kJ(kK(tree)[5])[parent];   // pivot axis
  QT1 u=pv-kQT1(point)[pa];       // distance along axis
  R u*u;
}
)

K kdtree_searchfrom(K tree,K point,K start){
  R KF==point->t ? kj(kdtree_searchfrom_i_F(tree,point,start->j)) :
    KE==point->t ? kj(kdtree_searchfrom_i_E(tree,point,start->j)) :
    krr("type");
}
