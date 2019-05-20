\d .ml

/ build a k-d tree
/* d = data points
/* r = number of rep pts
clust.kd.buildtree:{[d;r]clust.kd.create[clust.kd.pivot[d;r];-1;1;0b;til count d 0]}

/ tree is (parent;isleft;isleaf;children|datainds;pivotvalue;pivotaxis)
/* f    = function -> clust.kd.pivot[d;r;] used above
/* p    = parent node
/* o    = 1, added to parent index, loop counter
/* left = boolean flag for left or right
/* idx  = data index
clust.kd.create:{[f;p;o;left;idx]
 if[1b~u:f idx;:enlist each(p;left;1b;idx;0n;0N)]; / leaf node
 l:.z.s[f;p+o;1;1b;u[0;0]];                        / left subtree
 r:.z.s[f;p+o;1+count l 0;0b;u[0;1]];              / right subtree
 (p;left;0b;enlist p+o+1+0,count l 0;u[1;0];u[1;1]),'l,'r}

/ return 1b if at a leaf, or ((leftinds;rightinds);(pivot value;pivot axis)) if we can split further
clust.kd.pivot:{[d;r;idx]                                                
 if[count[idx]<=2*r;:1b];
 axis:u?max u:var each d[;idx];                    / choose axis with max variance
 pivi:usi bin piv:avg(usi:u si:iasc u)floor .5*-1 0+count u:d[axis;idx]; / index in sort indices to split data
 if[pivi in -1+0,count usi;:1b];                   / don't create leaf nodes with zero elements
 u:(0,pivi+1)cut idx si;                           / split idx for the left and right subtrees
 piv:min d[axis;u 1];                              / adjust pivot val to min val along axis in points in the right subtree
 (u;piv,axis)}