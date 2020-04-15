#include <math.h>
#include "k.h"

// Distance Functions

enum DistFuncs{ edist , e2dist , mdist , cshev , nege2dist };
typedef F (*distFuncType)(K);

static F kd_i_dist_e2dist(K p){
  F tot=0;
  for(J i=0; i<p->n; ++i)
    tot += kF(p)[i] * kF(p)[i];
  return tot;
}

static F kd_i_dist_edist(K p){
  return sqrt(kd_i_dist_e2dist(p));
}

static F kd_i_dist_mdist(K p){
  F tot=0;
  for(J i=0; i<p->n; ++i)
    tot += fabs(kF(p)[i]);
  return tot;
}

static F kd_i_dist_cshev(K p){
  F x, tot=wf;
  for(J i=0; i<p->n; ++i)
    if(tot > (x = fabs(kF(p)[i])))
       tot = x;
  return tot;
}

static F kd_i_dist_nege2dist(K p){
  return -1*kd_i_dist_e2dist(p);
}

static distFuncType getDistFunc(I dff){
  switch(dff){
    case     edist: return kd_i_dist_edist;
    case    e2dist: return kd_i_dist_e2dist;
    case     mdist: return kd_i_dist_mdist;
    case     cshev: return kd_i_dist_cshev;
    case nege2dist: return kd_i_dist_nege2dist;
    default       : return 0;
  }
}

// KD Tree Functions

enum KdTreeCols{ leafCol, leftCol, selfCol, prntCol, chldCol, axisCol, mvalCol, idxsCol};

static J kd_i_findleaf(K tree, K point, J idx){
  K tvals = kK(tree->k)[1];
  J nrows = kK(tvals)[0]->n;
  G* leafVec = kG(kK(tvals)[leafCol]);
  G* leftVec = kG(kK(tvals)[leftCol]);
  J* selfVec = kJ(kK(tvals)[selfCol]);
  J* prntVec = kJ(kK(tvals)[prntCol]);
  K* chldVec = kK(kK(tvals)[chldCol]);
  J* axisVec = kJ(kK(tvals)[axisCol]);
  F* mvalVec = kF(kK(tvals)[mvalCol]);
  K* idxsVec = kK(kK(tvals)[idxsCol]);

  while(!leafVec[idx]){
    F pval = kF(point)[axisVec[idx]];
    F mval = mvalVec[idx];
    idx=kJ(chldVec[idx])[pval>=mval];
  }
  return idx;
}

static void kd_i_nnleaf(K point, K data, K idxs, K xidxs, distFuncType distFunc, F *nndst, J *nnidx){
  J idx, chk;
  F dst;
  K dpoint = ktn(KF, data->n);
  for(J i=0; i<idxs->n; ++i){
    idx = kJ(idxs)[i];
    chk = 0;
    for(J k=0; k<xidxs->n; ++k){
      if(idx == kJ(xidxs)[k]){
	chk += 1;
        break;
      }
    }
    if(chk)
      continue;
    for(J j=0; j<data->n; ++j){
      kF(dpoint)[j] = kF(point)[j] - kF(kK(data)[j])[idx];
    }
    dst = distFunc(dpoint);
    if(dst < *nndst){
      *nndst=dst;
      *nnidx=idx;
    }
  }
  r0(dpoint);
}

// Find correct leaf, for point, from node (kidx)

K kd_findleaf(K tree,K point,K kidx){
  return kj(kd_i_findleaf(tree, point, kidx->j));
}

// Find nearest neighbour for point

K kd_nn(K tree, K data, K dfidx, K xidxs, K point){
  K tvals = kK(tree->k)[1];
  J nrows = kK(tvals)[0]->n;
  G* leafVec = kG(kK(tvals)[leafCol]);
  G* leftVec = kG(kK(tvals)[leftCol]);
  J* selfVec = kJ(kK(tvals)[selfCol]);
  J* prntVec = kJ(kK(tvals)[prntCol]);
  K* chldVec = kK(kK(tvals)[chldCol]);
  J* axisVec = kJ(kK(tvals)[axisCol]);
  F* mvalVec = kF(kK(tvals)[mvalCol]);
  K* idxsVec = kK(kK(tvals)[idxsCol]);

  distFuncType distFunc=getDistFunc(dfidx->j);
  if(!distFunc) return krr("invalid distance function");

  K xnodes = ktn(KJ, nrows);
  G *xnode = kG(xnodes);
  for(J i=0; i<nrows; ++i) xnode[i]=0;

  F nndst = wf;
  J nnidx = nj;

  J prnt, curr;
  F pval, mval;
  K dval = ktn(KF, 1);

  curr = kd_i_findleaf(tree, point, 0);
  kd_i_nnleaf(point, data, idxsVec[curr], xidxs, distFunc, &nndst, &nnidx);

  while(curr){
    xnode[curr] = 1;
    prnt = prntVec[curr];
    curr = kJ(chldVec[prnt])[leftVec[curr]];
    if(!xnode[curr]){
      pval = kF(point)[axisVec[prnt]];
      mval = mvalVec[prnt];
      kF(dval)[0]=pval-mval;
      if(nndst > distFunc(dval)){
        curr = kd_i_findleaf(tree, point, curr);
        kd_i_nnleaf(point, data, idxsVec[curr], xidxs, distFunc, &nndst, &nnidx);
      }else{curr = prnt;}
    }else{curr = prnt;}
  }

  r0(xnodes);

  return knk(2,  kj(nnidx), kf(nndst));
}
