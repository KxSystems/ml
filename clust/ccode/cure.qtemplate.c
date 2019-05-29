#include "cure.h"
#include "kdtree.h"
#include <stdio.h>
#include <math.h>

#define we wf
qtemplate({
  "names":["cure_nnleafe2","cure_nnleafe","cure_nnleafmd","cure_nn","cure_cluster_dists","edist2","edists","mdist","cure_cluster_reps"],
  "types":["QT1"],
  "ptypes":{"QT1":["F","E"]}}|
// find whether any points in a leaf are closer than current nearest neighbor and not in the same cluster and update nearest if so

Z V cure_nnleafe2(K point,K leafi,J cluster,QT1* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  QT1 dist,adist;  
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kQT1(point)[j]-kQT1(kK(reps)[leafinds[i]])[j];
        dist+=adist*adist;
      } 
      if(dist<*currdist){
        *currdist=dist;
        *curri=leafinds[i];
      }  
    }
  }
}

Z V cure_nnleafe(K point,K leafi,J cluster,QT1* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  QT1 dist,adist,dist2;
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kQT1(point)[j]-kQT1(kK(reps)[leafinds[i]])[j];
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

Z V cure_nnleafmd(K point,K leafi,J cluster,QT1* currdist,J* curri,J* clusters,K reps){
  J i,j,candi;
  QT1 dist,adist;
  J* leafinds=kJ(leafi);
  for(i=0;i<leafi->n;i++){
    if(cluster!=clusters[leafinds[i]]){ // if in same cluster cannot be a nearest neighbor
      for(j=0,dist=0;j<point->n;j++){
        adist=kQT1(point)[j]-kQT1(kK(reps)[leafinds[i]])[j];
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
K cure_nn(K kpointind,K tree,K clusters,K reps,K df){
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
  QT1 nndist=wqt1;J nni=-1;                                // current nearest distance and nearest neighbour index
  curr=kdtree_searchfrom_i_QT1(tree,kK(reps)[pointind],0); // start the search at the leaf the point would belong in
  if(ddf==1){
	cure_nnleafe2_QT1(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
  }else if(ddf==2){
	cure_nnleafe_QT1(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
  }else{cure_nnleafmd_QT1(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);};

  while(curr){                                             // loop upwards until we've reached the root of the tree
    v[curr]=1;
    parent=parents[curr];
    curr=kJ(children[parent])[left[curr]]; // peer
    if(!v[curr]){                                   // if already visited this node, skip to parent
      if(nndist>kdtree_rdist_QT1(point,tree,parent,ddf)){ // could there be anything closer in the peer branch of the tree?
        // jump to leaf in this subtree point would belong to
        curr=kdtree_searchfrom_i_QT1(tree,kK(reps)[pointind],curr);
        // update nearest if there's anything in the leaf closer than current best
        if(ddf==1){
            cure_nnleafe2_QT1(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
	}else if(ddf==2){
            cure_nnleafe_QT1(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);
	}else{cure_nnleafmd_QT1(kK(reps)[pointind],children[curr],cluster,&nndist,&nni,kJ(clusters),reps);};

      }else{curr=parent;}
    }else{curr=parent;}
  }

  r0(vk); // cleanup
  R knk(2,kj(nni),kqt1(nndist)); // return nearest neighbor and distance to it
}

// distance from cluster1 to each of the clusters in cluster2list
K cure_cluster_dists(K cluster1,K cluster2list,K reps,K df){
  QT1 ndist,dist,adist,dist2;            // nearest distance, cluster distance, axis aligned distance
  J ddf=df->j;
  K cluster2;                      // current cluster we're measuring the distance to
  J i,j,k,m,pl=kK(reps)[0]->n;     // some loop counters, and pl the dimensionality of the data
  K res=ktn(KQT1,cluster2list->n);
  for(m=0;m<cluster2list->n;m++){
    ndist=wqt1;                    // start with infinite nearest distance
    cluster2=kK(cluster2list)[m];
    for(i=0;i<cluster1->n;i++){    // measure distance between each point in cluster1 to each point in cluster2, keeping track of nearest along the way
      for(j=0;j<cluster2->n;j++){
        dist=0;
        for(k=0;k<pl;k++){
          adist=kQT1(kK(reps)[kJ(cluster1)[i]])[k]-kQT1(kK(reps)[kJ(cluster2)[j]])[k];  // raw axis distance
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
    kQT1(res)[m]=ndist;
  }
  R res;
}


Z QT1 edist2(K p1,K p2){ // euclidean distance squared
  QT1 dist=0,adist;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kQT1(p1)[i]-kQT1(p2)[i];
    dist+=adist*adist;
  }

  R dist;
}
          
Z QT1 edists(K p1,K p2){ // euclidean distance 
  QT1 dist=0,adist,dist2;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kQT1(p1)[i]-kQT1(p2)[i];    
    dist+=adist*adist;
  }
  dist2=sqrt(dist);
  R dist2;
}


Z QT1 mdist(K p1,K p2){ // euclidean distance 
  QT1 dist=0,adist;
  J i;
  for(i=0;i<p1->n;i++){
    adist=kQT1(p1)[i]-kQT1(p2)[i];
    dist+=fabs(adist);
  }
  R dist;
}

// pick kn representatives from a list of points, starting with the furthest from the centroid
K cure_cluster_reps(K pts,K kn,K cent,K df){
  J ddf=df->j;
  if(kn->j>=pts->n)R r1(pts); // fewer available points than requested representatives
  if(KQT1!=cent->t)R krr("type"); // check centroid type, if using reals a cast in q is required on the avg of all the points
  J i,j,n=kn->j,npts=pts->n,maxi;
  K res=ktn(0,n);
  K mdists=ktn(KQT1,npts);
  // initialise minimal distance to any representative point for each point 
  for(i=0;i<npts;i++)kQT1(mdists)[i]=wf;
  QT1 maxd=0,mind;
  // first find distance between each point to the centroid and and pick furthest as first representative point
  for(i=0;i<npts;i++){ // first find distance between each point and the centroid
    if(ddf==1){
        mind=edist2_QT1(cent,kK(pts)[i]);
    }else if(ddf==2){
      mind=edists_QT1(cent,kK(pts)[i]);
    }else{mind=mdist_QT1(cent,kK(pts)[i]);}

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
         mind=edist2_QT1(kK(res)[i-1],kK(pts)[j]);
      }else if(ddf==2){
         mind=edists_QT1(kK(res)[i-1],kK(pts)[j]);
      }else{mind=mdist_QT1(kK(res)[i-1],kK(pts)[j]);}

      //mind=edist2_QT1(kK(res)[i-1],kK(pts)[j]);
      // maintain closest distance between this point and any representative point
      if(mind<kQT1(mdists)[j])kQT1(mdists)[j]=mind;
      // pick the point so far which is furthest from all the representatives 
      if(kQT1(mdists)[j]>maxd){
        maxi=j;
        maxd=kQT1(mdists)[j];
      }
    }
    // all points checked, pick furthest from current representatives
    kK(res)[i]=r1(kK(pts)[maxi]);
  }
  r0(mdists);
  R res;
}
)

