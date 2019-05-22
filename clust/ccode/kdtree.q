\d .ml

clust.kdtree.i.pivot:{[x;leafsize;inds]                                                / return 1b if at a leaf, or ((leftinds;rightinds);(pivot value;pivot axis)) if we can split further
 if[count[inds]<=2*leafsize;:1b];
 axis:u?max u:var each x[;inds];                                          / axis picked by one with max variance (somewhat arbitrary, we could pick another method)
 pivi:usi bin piv:avg(usi:u si:iasc u)floor .5*-1 0+count u:x[axis;inds]; / index in sort indices to split data
 if[pivi in -1+0,count usi;:1b];                                          / don't create leaf nodes with zero elements
 u:(0,pivi+1)cut inds si;                                                 / split inds for the left and right subtrees
 piv:min x[axis;u 1];                                                     / adjust the pivot value to the actual minimum value along the axis in the points in the right subtree
 (u;piv,axis)}

/ tree is (parent;isleft;isleaf;children|datainds;pivotvalue;pivotaxis)
/ somewhat general if f is adjusted
clust.kdtree.i.buildtree:{[f;p;o;left;x]
 if[1b~u:f x;:enlist each(p;left;1b;x;0n;0N)]; / leaf node
 l:.z.s[f;p+o;1;1b;u[0;0]];                    / left subtree
 r:.z.s[f;p+o;1+count l 0;0b;u[0;1]];          / right subtree
 (p;left;0b;enlist p+o+1+0,count l 0;u[1;0];u[1;1]),'l,'r}
clust.kdtree.i.searchfrom:(`$path,"/clust/ccode/./kdtree") 2:`kdtree_searchfrom,4
clust.kdtree.searchfrom:{[x;y;z;df]$[not type[y]~type x 4;'`type;i.searchfrom[x;y;z;df]]}

clust.kdtree.create:{[leafsize;x]clust.kdtree.i.buildtree[clust.kdtree.i.pivot[x;leafsize];-1;1;0b;til count x 0]}


