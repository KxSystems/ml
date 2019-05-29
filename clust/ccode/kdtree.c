#include "kdtree.h"
#include <stdio.h>
#include <math.h>


// tree is (parent;isleft;isleaf;children;pivval;pivaxis) count[tree[0]]~num nodes
J kdtree_searchfrom_i_F(K tree,K point,J i){
  G* isleaf=kG(kK(tree)[2]);
  K children=kK(tree)[3];
  F* pivots=kF(kK(tree)[4]);
  J* axes=kJ(kK(tree)[5]);
  // go left or right at each node until a leaf is hit
  while(!isleaf[i])
    i=kJ(kK(children)[i])[(I)(kF(point)[axes[i]]>=pivots[i])];
  R i;
}
// min distance between point and (parent nodes) i.e. the distance from the pivot point along the pivot axis
F kdtree_rdist_F(K point,K tree,J parent,J df){
  F dist;
  F pv=kF(kK(tree)[4])[parent]; // pivot value
  J pa=kJ(kK(tree)[5])[parent];   // pivot axis
  F u=pv-kF(point)[pa];       // distance along axis
  if(df==1){
      dist=u*u;
  }else if(df==2){
      dist=sqrt(u*u);
  }else{dist=fabs(u);}
  R dist;
}

// tree is (parent;isleft;isleaf;children;pivval;pivaxis) count[tree[0]]~num nodes
J kdtree_searchfrom_i_E(K tree,K point,J i){
  G* isleaf=kG(kK(tree)[2]);
  K children=kK(tree)[3];
  E* pivots=kE(kK(tree)[4]);
  J* axes=kJ(kK(tree)[5]);
  // go left or right at each node until a leaf is hit
  while(!isleaf[i])
    i=kJ(kK(children)[i])[(I)(kE(point)[axes[i]]>=pivots[i])];
  R i;
}
// min distance between point and (parent nodes) i.e. the distance from the pivot point along the pivot axis
E kdtree_rdist_E(K point,K tree,J parent,J df){
  E dist;
  F pv=kE(kK(tree)[4])[parent]; // pivot value
  J pa=kJ(kK(tree)[5])[parent];   // pivot axis
  E u=pv-kE(point)[pa];       // distance along axis
  if(df==1){
      dist=u*u;
  }else if(df==2){
      dist=sqrt(u*u);
  }else{dist=fabs(u);}
  R dist;
}


K kdtree_searchfrom(K tree,K point,K start){
  R KF==point->t ? kj(kdtree_searchfrom_i_F(tree,point,start->j)) :
    KE==point->t ? kj(kdtree_searchfrom_i_E(tree,point,start->j)) :
    krr("type");
}

