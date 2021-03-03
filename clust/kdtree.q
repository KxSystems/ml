// clust/kdtree.q - K dimensional tree
// Copyright (c) 2021 Kx Systems Inc
// 
// A k-dimensional tree (k-d tree) is a special case of the 
// binary search tree data structure, commonly used in computer 
// science to organize data points in k-dimensional space. 
// Each leaf node in the tree contains a set of k-dimensional points, 
// while each non-leaf node generates a splitting hyperplane
// which divides the surrounding space.

\d .ml

// K-Dimensional (k-d) Tree

// @kind function
// @category clust
// @desc Create new k-d tree
// @param data {float[][]} Each column of the data is an individual datapoint
// @param leafSize {long} Number of points per leaf (<2*number of reppts)
// @return {table} k-d tree
clust.kd.newTree:{[data;leafSize]
  args:`leaf`left`parent`self`idxs!(0b;0b;0N;0;til count data 0);
  clust.kd.i.tree[data;leafSize]args
  }

// @kind function
// @category clust
// @desc Find nearest neighhbors in k-d tree
// @param tree {table} k-d tree
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {symbol} Distance function name within '.ml.clust.df'
// @param xIdxs {long[][]} Points to exclude in search
// @param pt {long[]} Point to find nearest neighbor for
// @return {dictionary} Nearest neighbor dictionary with closest point,
//   distance, points searched and points to search
clust.kd.q.nn:clust.kd.nn:{[tree;data;df;xIdxs;pt]
  nnInit:(0N;0w;0#0;clust.kd.findLeaf[tree;pt;tree 0]);
  start:`closestPoint`closestDist`xNodes`node!nnInit;
  stop:{[nnInfo]not null nnInfo[`node;`self]};
  2#stop clust.kd.i.nnCheck[tree;data;df;xIdxs;pt]/start
  }

// @kind function
// @category kdtree
// @desc Find the leaf node point belongs to
// @param tree {table} k-d tree table
// @param pt {float[]} Point to search
// @param node {dictionary} Node in the k-d tree to start the search 
// @return {dictionary} The index (row) of the kd-tree that the datapoint 
//   belongs to
clust.kd.q.findLeaf:clust.kd.findleaf:{[tree;pt;node]
  {[node]not node`leaf}clust.kd.i.findNext[tree;pt]/node
  }

// @kind function
// @category kdtree
// @desc Sets k-d tree q or C functions
// @param typ {boolean} Type of code to use q or C (1/0b)
// @return  {::} No return. Updates nn and findLeaf functions.
clust.kd.qC:{[typ]
  funcTyp:not(112=type clust.kd.c.nn)&112=type clust.kd.c.findLeaf;
  func:$[typ|funcTyp;`q;`c];
  clust.kd[`nn`findLeaf]:(clust.kd[func]`nn;clust.kd[func]`findLeaf)
  }

// @kind function
// @category kdtree
// @desc Get nearest neighbor in C
// @param tree {table} k-d tree table
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {fn} Distance function
// @param xIdxs {long[][]} Points to exclude in search
// @param pt {long[]} Point to find nearest neighbor for
// @return {dictionary} Nearest neighbor information
clust.kd.c.nn:{[tree;data;df;xIdxs;pt]
  data:clust.i.floatConversion[data];
  pt:clust.i.floatConversion[pt];
  args:(tree;data;(1_key clust.i.df)?df;@[count[data 0]#0b;xIdxs;:;1b];pt);
  `closestPoint`closestDist!clust.kd.c.nnFunc . args
  };

// @kind function
// @category kdtree
// @desc Find the leaf node point belongs to using C
// @param tree {table} k-d tree table
// @param pt {float[]} Point to search
// @param node {dictionary} Node in the k-d tree to start the search 
// @return {dictionary} The index (row) of the kd-tree that the 
//   datapoint belongs to
clust.kd.c.findLeaf:{[tree;point;node]
    point:clust.i.floatConversion[point];
    tree clust.kd.c.findLeafFunc[tree;point;node`self]
    }


// @kind function
// @category kdtree
// @desc Load in C functionality
clust.kd.c.nnLoadFunc:.[2:;(`:kdnn;(`kd_nn;5));::];
clust.kd.c.findLeafFunc:.[2:;(`:kdnn;(`kd_findleaf;3));::];


// Default to C implementations

clust.kd.qC[0b];
