\l ml.q
.ml.loadfile`:clust/tests/passfail.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q

// Initialize Datasets

\S 10

// Datasets
d1:(til 5;3 2 5 1 4)
d2:(2#"F";",")0:`:clust/tests/data/sample1.csv

// Indices
idxs1:til count d1 0
idxs2:til count d2 0

// K-D trees
tree:.ml.clust.kd.newtree[d1;1]
tree2:.ml.clust.kd.newtree[d2;2]

// Configurations
iter:`run`total`nochange!0 200 15
info:.ml.clust.i.apinit[d1;`e2dist;max;idxs1]
info,:`emat`conv`iter!((count d1 0;iter`nochange)#0b;0b;iter)

// q Utilities
specificRes :{(x . z)y}
closestPoint:specificRes[.ml.clust.i.closest;`point]
newTreeRes  :specificRes[.ml.clust.kd.newtree]
nnRes       :specificRes[.ml.clust.kd.nn]


// K-D Tree using C 

// Expected Results
kdKey:`leaf`left`self`parent`children`axis`midval`idxs
kdRes1:kdKey!(1b;0b;3;1;0#0;0N;0n;enlist 1)
kdRes2:kdKey!(1b;1b;2;1;0#0;0N;0n;enlist 0)
kdRes3:kdKey!(1b;0b;3;1;0#0;0N;0n;1 3 4)
kdRes4:kdKey!(1b;1b;2;1;0#0;0N;0n;0 2)

passingTest[.ml.clust.i.dists  ;(d1;`e2dist;4 2;1 2 3);0b;9 13 2]
passingTest[.ml.clust.i.dists  ;(d1;`e2dist;8 2;til 5);0b;65 49 45 26 20]
passingTest[.ml.clust.i.closest;(d1;`e2dist;1 2;til 5);0b;`point`distance!(1;0)]
passingTest[closestPoint       ;(d2;`e2dist;3 6;reverse til 5);1b;2]
passingTest[newTreeRes`left  ;(d1;2);1b;010b]
passingTest[newTreeRes`leaf  ;(d1;2);1b;011b]
passingTest[newTreeRes`midval;(d1;2);1b;2 0n 0n]
passingTest[newTreeRes`parent;(d1;2);1b;0N 0 0]
passingTest[newTreeRes`idxs  ;(d1;2);1b;(0#0;0 1;2 3 4)]
passingTest[newTreeRes`axis  ;(d1;2);1b;0 0N 0N]
passingTest[newTreeRes`left  ;(d2;3);1b;010b]
passingTest[newTreeRes`leaf  ;(d2;3);1b;011b]
passingTest[newTreeRes`idxs  ;(d2;3);1b;(0#0;til 5;5 6 7 8 9)]
passingTest[newTreeRes`parent;(d2;3);1b;0N 0 0]
passingTest[newTreeRes`idxs  ;(d2;3);1b;(0#0;til 5;5+til 5)]
passingTest[nnRes`closestPoint;(tree;d1;`edist;0;d2[;2]);1b;2]
passingTest[nnRes`closestPoint;(tree2;d2;`edist;1 2 3;d1[;1]);1b;0]
passingTest[nnRes`closestPoint;(tree2;d2;`edist;1 5 2;d1[;3]);1b;3]
passingTest[nnRes`closestPoint`closestDist;(tree;d1;`mdist;1;7 9f);1b;(4;8f)]
passingTest[nnRes`closestPoint`closestDist;(tree2;d2;`edist;0;d2[;2]);1b;(2;0f)]
passingTest[.ml.clust.kd.findleaf;(tree;d1[;1];tree 0);0b;kdRes1]
passingTest[.ml.clust.kd.findleaf;(tree;d2[;4];tree 2);0b;kdRes2]
passingTest[.ml.clust.kd.findleaf;(tree2;d2[;1];tree2 1);0b;kdRes3]
passingTest[.ml.clust.kd.findleaf;(tree2;d1[;0];tree2 2);0b;kdRes4]


// K-D Tree using q

// Expected Results
kdRes5:kdKey!(1b;0b;3;1;0#0;0N;0n;enlist 1)
kdRes6:kdKey!(1b;1b;2;1;0#0;0N;0n;enlist 0)
kdRes7:kdKey!(1b;0b;3;1;0#0;0N;0n;1 3 4)
kdRes8:kdKey!(1b;1b;2;1;0#0;0N;0n;0 2)

// Change to q implementation
.ml.clust.kd.qC[1b];

passingTest[nnRes`closestPoint;(tree;d1;`edist;0;d2[;2]);1b;2]
passingTest[nnRes`closestPoint;(tree2;d2;`edist;1 2 3;d1[;1]);1b;0]
passingTest[nnRes`closestPoint;(tree2;d2;`edist;1 5 2;d1[;3]);1b;3]
passingTest[nnRes`closestPoint`closestDist;(tree;d1;`mdist;1 2 3 4;d1[;1]);1b;0 2]
passingTest[nnRes`closestPoint`closestDist;(tree;d1;`mdist;1;7 9f);1b;(4;8f)]
passingTest[nnRes`closestPoint`closestDist;(tree2;d2;`edist;0;d2[;2]);1b;(2;0f)]
passingTest[.ml.clust.kd.findleaf;(tree;d1[;1];tree 0);0b;kdRes5]
passingTest[.ml.clust.kd.findleaf;(tree;d2[;4];tree 2);0b;kdRes6]
passingTest[.ml.clust.kd.findleaf;(tree2;d2[;1];tree2 1);0b;kdRes7]
passingTest[.ml.clust.kd.findleaf;(tree2;d1[;0];tree2 2);0b;kdRes8]


// K-Means

passingTest[.ml.clust.i.getclust;(d2;`e2dist;flip d2[;1 2]);0b;1 0 1 0 0 0 0 0 0 0]
passingTest[.ml.clust.i.getclust;(d2;`e2dist;flip d2[;1 2 3]);0b;1 0 1 2 2 2 2 2 2 2]
passingTest[.ml.clust.i.getclust;(d1;`e2dist;flip d1[;2 3]);0b;0 1 0 1 0]
passingTest[.ml.clust.i.getclust;(d1;`edist;flip d1[;3 4]);0b;0 0 1 0 1]


// DBSCAN

passingTest[.ml.clust.i.nbhood;("f"$d1;`edist;10;4);0b;0 1 2 3]
passingTest[.ml.clust.i.nbhood;(d2;`e2dist;0.1;1);0b; 0 3]
passingTest[.ml.clust.i.nbhood;(d2;`edist;0.3;3);0b;0 1]


// Affinity Propagation

// Expected Results
d1S:(0 2 8 13 17;2 0 10 5 13;8 10 0 17 5 ;13 5 17 0 10;17 13 5 10 0)
s01:(17 2 8 13 17;2 17 10 5 13;8 10 17 17 5;13 5 17 17 10;17 13 5 10 17)
a01:"f"$(3.24 0 0 0 0;0 0 0 0 0;0 0 3.24 0 0;0 0 0 0 0;0 0 0 0 0)
AP1:(0 -12 -7.2 -3.2 0;-12 3.2 -5.6 -9.6 -3.2;-7.2 -5.6 0 0 -9.6;-3.2 -9.6 3.2 0 -5.6;3.2  -3.2 -9.6 -5.6 0)
AP2:(0 -13.5 -8.1 -3.6 0;-13.5 3.6 -6.3 -10.8 -3.6;-8.1 -6.3 0 0 -10.8;-3.6 -10.8 3.6 0 -6.3;3.6 -3.6 -10.8 -6.3 0)

passingTest[specificRes[.ml.clust.i.apinit;`s`a`r`matches];(d1;`e2dist;min;idxs1);1b;(d1S;5 5#0f;5 5#0f;0)]
passingTest[specificRes[.ml.clust.i.apalgo;`exemplars`s`a];(.1;info);1b;(0 1 2 2 0;s01;a01)]
passingTest[.ml.clust.i.updr;(.2;info);0b;AP1]
passingTest[.ml.clust.i.updr;(.1;info);0b;AP2]
passingTest[.ml.clust.i.upda;(.5;info);0b;5 5#0f]
passingTest[.ml.clust.i.upda;(.9;info);0b;5 5#0f]
