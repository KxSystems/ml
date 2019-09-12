#include "cure.h"
#include "kdtree.h"
#include <stdio.h>
#include <math.h>

#define we wf

// find whether any points in a leaf are closer than current nearest neighbor and not in the same cluster and update nearest if so

Z V cure_nnleafe2_F(K point,K leafi,J cluster,F* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  F dist,adist;  
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kF(point)[j]-kF(kK(reps)[leafinds[i]])[j];
        dist+=adist*adist;
      } 
      if(dist<*currdist){
        *currdist=dist;
        *curri=leafinds[i];
      }  
    }
  }
}

Z V cure_nnleafe_F(K point,K leafi,J cluster,F* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  F dist,adist,dist2;
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kF(point)[j]-kF(kK(reps)[leafinds[i]])[j];
        dist+=adist*adist;
      }
      dist2=sqrt(dist);

      if(dist2<*currdist){
        *currdist=dist2;
        *curri=leafinds[i];
      }
    }
  }
}

Z V cure_nnleafmd_F(K point,K leafi,J cluster,F* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  F dist,adist;
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kF(point)[j]-kF(kK(reps)[leafinds[i]])[j];
        dist+=fabs(adist);
      }
      if(dist<*currdist){
        *currdist=dist;
        *curri=leafinds[i];
      }
    }
  }
}


// closest point and distance to closest point, excludes points in same cluster
K cure_nn_F(K kpointind,K tree,K clusters,K reps,K df){
  J pointind=kpointind->j;                                 // this point
  J ddf=df->j;
  K point=kK(reps)[pointind];                              // actual values of point
  J cluster=kJ(clusters)[pointind];                        // cluster this point belongs to 
  J parent,curr;                                           // current parent index, current index in tree
  J* parents=kJ(kK(tree)[0]);                              // parent node indices
  G* left=kG(kK(tree)[1]);                                 // is node a left node?
  K* children=kK(kK(tree)[3]);                             // children of parent nodes, or indices into reps of points in leaves

  K vk=ktn(KG,kK(tree)[0]->n);G* v=kG(vk);                 // which nodes in the tree have been visited
  J i;                              
  for(i=0;i<vk->n;i++)v[i]=0;

  // initialise nni, and nndist with nearest neighbor in leaf
  F nndist=wf;J nni=-1;                                // current nearest distance and nearest neighbour index
  curr=kdtree_searchfrom_i_F(tree,kK(reps)[pointind],0); // start the search at the leaf the point would belong in
  if(ddf==1){
	cure_nnleafe2_F(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
  }else if(ddf==2){
	cure_nnleafe_F(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
  }else{cure_nnleafmd_F(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);};

  while(curr){                                             // loop upwards until we've reached the root of the tree
    v[curr]=1;
    parent=parents[curr];
    curr=kJ(children[parent])[left[curr]]; // peer
    if(!v[curr]){                                   // if already visited this node, skip to parent
      if(nndist>kdtree_rdist_F(point,tree,parent,ddf)){ // could there be anything closer in the peer branch of the tree?
        // jump to leaf in this subtree point would belong to
        curr=kdtree_searchfrom_i_F(tree,kK(reps)[pointind],curr);
        // update nearest if there's anything in the leaf closer than current best
        if(ddf==1){
            cure_nnleafe2_F(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
	}else if(ddf==2){
            cure_nnleafe_F(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
	}else{cure_nnleafmd_F(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);};

      }else{curr=parent;}
    }else{curr=parent;}
  }

  r0(vk); // cleanup
  R knk(2,kj(nni),kf(nndist)); // return nearest neighbor and distance to it
}

// distance from cluster1 to each of the clusters in cluster2list
K cure_cluster_dists_F(K cluster1,K cluster2list,K reps,K df){
  F ndist,dist,adist,dist2;            // nearest distance, cluster distance, axis aligned distance
  J ddf=df->j;
  K cluster2;                      // current cluster we're measuring the distance to
  J i,j,k,m,pl=kK(reps)[0]->n;     // some loop counters, and pl the dimensionality of the data
  K res=ktn(KF,cluster2list->n);
  for(m=0;m<cluster2list->n;m++){
    ndist=wf;                    // start with infinite nearest distance
    cluster2=kK(cluster2list)[m];
    for(i=0;i<cluster1->n;i++){    // measure distance between each point in cluster1 to each point in cluster2, keeping track of nearest along the way
      for(j=0;j<cluster2->n;j++){
        dist=0;
        for(k=0;k<pl;k++){
          adist=kF(kK(reps)[kJ(cluster1)[i]])[k]-kF(kK(reps)[kJ(cluster2)[j]])[k];  // raw axis distance
	  if(ddf<3){
             dist+=adist*adist;
          }else{dist+=fabs(adist);}
    	  
     }  
        if(ddf==2){
	  dist2=sqrt(dist);
	}else {dist2=dist;}

        if(dist2<ndist)ndist=dist2;                                                       // new nearest
        
      }
    }
    kF(res)[m]=ndist;
  }
  R res;
}


Z F edist2_F(K p1,K p2){ // euclidean distance squared
  F dist=0,adist;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kF(p1)[i]-kF(p2)[i];
    dist+=adist*adist;
  }

  R dist;
}
          
Z F edists_F(K p1,K p2){ // euclidean distance 
  F dist=0,adist,dist2;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kF(p1)[i]-kF(p2)[i];    
    dist+=adist*adist;
  }
  dist2=sqrt(dist);
  R dist2;
}


Z F mdist_F(K p1,K p2){ // euclidean distance 
  F dist=0,adist;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kF(p1)[i]-kF(p2)[i];
    dist+=fabs(adist);
  }
  R dist;
}

// pick kn representatives from a list of points, starting with the furthest from the centroid
K cure_cluster_reps_F(K pts,K kn,K cent,K df){
  J ddf=df->j;
  if(kn->j>=pts->n)R r1(pts); // fewer available points than requested representatives
  if(KF!=cent->t)R krr("type"); // check centroid type, if using reals a cast in q is required on the avg of all the points
  J i,j,n=kn->j,npts=pts->n,maxi;
  K res=ktn(0,n);
  K mdists=ktn(KF,npts);
  // initialise minimal distance to any representative point for each point 
  for(i=0;i<npts;i++)kF(mdists)[i]=wf;
  F maxd=0,mind;
  // first find distance between each point to the centroid and and pick furthest as first representative point
  for(i=0;i<npts;i++){ // first find distance between each point and the centroid
    if(ddf==1){
        mind=edist2_F(cent,kK(pts)[i]);
    }else if(ddf==2){
      mind=edists_F(cent,kK(pts)[i]);
    }else{mind=mdist_F(cent,kK(pts)[i]);}

    if(mind>maxd){
      maxi=i;
      maxd=mind;
    }
  }
  kK(res)[0]=r1(kK(pts)[maxi]);
  // loop until we have the requested number of representatives
  for(i=1;i<n;i++){
    // for each point, keep track of its minimal distance to any representative.
    for(j=0,maxd=0;j<npts;j++){
      // find distance between point and the new representative
      if(ddf==1){
         mind=edist2_F(kK(res)[i-1],kK(pts)[j]);
      }else if(ddf==2){
         mind=edists_F(kK(res)[i-1],kK(pts)[j]);
      }else{mind=mdist_F(kK(res)[i-1],kK(pts)[j]);}

      //mind=edist2_F(kK(res)[i-1],kK(pts)[j]);
      // maintain closest distance between this point and any representative point
      if(mind<kF(mdists)[j])kF(mdists)[j]=mind;
      // pick the point so far which is furthest from all the representatives 
      if(kF(mdists)[j]>maxd){
        maxi=j;
        maxd=kF(mdists)[j];
      }
    }
    // all points checked, pick furthest from current representatives
    kK(res)[i]=r1(kK(pts)[maxi]);
  }
  r0(mdists);
  R res;
}

// find whether any points in a leaf are closer than current nearest neighbor and not in the same cluster and update nearest if so

Z V cure_nnleafe2_E(K point,K leafi,J cluster,E* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  E dist,adist;  
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kE(point)[j]-kE(kK(reps)[leafinds[i]])[j];
        dist+=adist*adist;
      } 
      if(dist<*currdist){
        *currdist=dist;
        *curri=leafinds[i];
      }  
    }
  }
}

Z V cure_nnleafe_E(K point,K leafi,J cluster,E* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  E dist,adist,dist2;
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kE(point)[j]-kE(kK(reps)[leafinds[i]])[j];
        dist+=adist*adist;
      }
      dist2=sqrt(dist);

      if(dist2<*currdist){
        *currdist=dist2;
        *curri=leafinds[i];
      }
    }
  }
}

Z V cure_nnleafmd_E(K point,K leafi,J cluster,E* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  E dist,adist;
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kE(point)[j]-kE(kK(reps)[leafinds[i]])[j];
        dist+=fabs(adist);
      }
      if(dist<*currdist){
        *currdist=dist;
        *curri=leafinds[i];
      }
    }
  }
}


// closest point and distance to closest point, excludes points in same cluster
K cure_nn_E(K kpointind,K tree,K clusters,K reps,K df){
  J pointind=kpointind->j;                                 // this point
  J ddf=df->j;
  K point=kK(reps)[pointind];                              // actual values of point
  J cluster=kJ(clusters)[pointind];                        // cluster this point belongs to 
  J parent,curr;                                           // current parent index, current index in tree
  J* parents=kJ(kK(tree)[0]);                              // parent node indices
  G* left=kG(kK(tree)[1]);                                 // is node a left node?
  K* children=kK(kK(tree)[3]);                             // children of parent nodes, or indices into reps of points in leaves

  K vk=ktn(KG,kK(tree)[0]->n);G* v=kG(vk);                 // which nodes in the tree have been visited
  J i;                              
  for(i=0;i<vk->n;i++)v[i]=0;

  // initialise nni, and nndist with nearest neighbor in leaf
  E nndist=we;J nni=-1;                                // current nearest distance and nearest neighbour index
  curr=kdtree_searchfrom_i_E(tree,kK(reps)[pointind],0); // start the search at the leaf the point would belong in
  if(ddf==1){
	cure_nnleafe2_E(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
  }else if(ddf==2){
	cure_nnleafe_E(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
  }else{cure_nnleafmd_E(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);};

  while(curr){                                             // loop upwards until we've reached the root of the tree
    v[curr]=1;
    parent=parents[curr];
    curr=kJ(children[parent])[left[curr]]; // peer
    if(!v[curr]){                                   // if already visited this node, skip to parent
      if(nndist>kdtree_rdist_E(point,tree,parent,ddf)){ // could there be anything closer in the peer branch of the tree?
        // jump to leaf in this subtree point would belong to
        curr=kdtree_searchfrom_i_E(tree,kK(reps)[pointind],curr);
        // update nearest if there's anything in the leaf closer than current best
        if(ddf==1){
            cure_nnleafe2_E(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
	}else if(ddf==2){
            cure_nnleafe_E(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
	}else{cure_nnleafmd_E(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);};

      }else{curr=parent;}
    }else{curr=parent;}
  }

  r0(vk); // cleanup
  R knk(2,kj(nni),ke(nndist)); // return nearest neighbor and distance to it
}

// distance from cluster1 to each of the clusters in cluster2list
K cure_cluster_dists_E(K cluster1,K cluster2list,K reps,K df){
  E ndist,dist,adist,dist2;            // nearest distance, cluster distance, axis aligned distance
  J ddf=df->j;
  K cluster2;                      // current cluster we're measuring the distance to
  J i,j,k,m,pl=kK(reps)[0]->n;     // some loop counters, and pl the dimensionality of the data
  K res=ktn(KE,cluster2list->n);
  for(m=0;m<cluster2list->n;m++){
    ndist=we;                    // start with infinite nearest distance
    cluster2=kK(cluster2list)[m];
    for(i=0;i<cluster1->n;i++){    // measure distance between each point in cluster1 to each point in cluster2, keeping track of nearest along the way
      for(j=0;j<cluster2->n;j++){
        dist=0;
        for(k=0;k<pl;k++){
          adist=kE(kK(reps)[kJ(cluster1)[i]])[k]-kE(kK(reps)[kJ(cluster2)[j]])[k];  // raw axis distance
	  if(ddf<3){
             dist+=adist*adist;
          }else{dist+=fabs(adist);}
    	  
     }  
        if(ddf==2){
	  dist2=sqrt(dist);
	}else {dist2=dist;}

        if(dist2<ndist)ndist=dist2;                                                       // new nearest
        
      }
    }
    kE(res)[m]=ndist;
  }
  R res;
}


Z E edist2_E(K p1,K p2){ // euclidean distance squared
  E dist=0,adist;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kE(p1)[i]-kE(p2)[i];
    dist+=adist*adist;
  }

  R dist;
}
          
Z E edists_E(K p1,K p2){ // euclidean distance 
  E dist=0,adist,dist2;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kE(p1)[i]-kE(p2)[i];    
    dist+=adist*adist;
  }
  dist2=sqrt(dist);
  R dist2;
}


Z E mdist_E(K p1,K p2){ // euclidean distance 
  E dist=0,adist;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kE(p1)[i]-kE(p2)[i];
    dist+=fabs(adist);
  }
  R dist;
}

// pick kn representatives from a list of points, starting with the furthest from the centroid
K cure_cluster_reps_E(K pts,K kn,K cent,K df){
  J ddf=df->j;
  if(kn->j>=pts->n)R r1(pts); // fewer available points than requested representatives
  if(KE!=cent->t)R krr("type"); // check centroid type, if using reals a cast in q is required on the avg of all the points
  J i,j,n=kn->j,npts=pts->n,maxi;
  K res=ktn(0,n);
  K mdists=ktn(KE,npts);
  // initialise minimal distance to any representative point for each point 
  for(i=0;i<npts;i++)kE(mdists)[i]=wf;
  E maxd=0,mind;
  // first find distance between each point to the centroid and and pick furthest as first representative point
  for(i=0;i<npts;i++){ // first find distance between each point and the centroid
    if(ddf==1){
        mind=edist2_E(cent,kK(pts)[i]);
    }else if(ddf==2){
      mind=edists_E(cent,kK(pts)[i]);
    }else{mind=mdist_E(cent,kK(pts)[i]);}

    if(mind>maxd){
      maxi=i;
      maxd=mind;
    }
  }
  kK(res)[0]=r1(kK(pts)[maxi]);
  // loop until we have the requested number of representatives
  for(i=1;i<n;i++){
    // for each point, keep track of its minimal distance to any representative.
    for(j=0,maxd=0;j<npts;j++){
      // find distance between point and the new representative
      if(ddf==1){
         mind=edist2_E(kK(res)[i-1],kK(pts)[j]);
      }else if(ddf==2){
         mind=edists_E(kK(res)[i-1],kK(pts)[j]);
      }else{mind=mdist_E(kK(res)[i-1],kK(pts)[j]);}

      //mind=edist2_E(kK(res)[i-1],kK(pts)[j]);
      // maintain closest distance between this point and any representative point
      if(mind<kE(mdists)[j])kE(mdists)[j]=mind;
      // pick the point so far which is furthest from all the representatives 
      if(kE(mdists)[j]>maxd){
        maxi=j;
        maxd=kE(mdists)[j];
      }
    }
    // all points checked, pick furthest from current representatives
    kK(res)[i]=r1(kK(pts)[maxi]);
  }
  r0(mdists);
  R res;
}



