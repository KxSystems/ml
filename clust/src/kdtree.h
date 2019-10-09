#define qtemplate RUN qc.q
#include "k.h"


J kdtree_searchfrom_i_F(K tree,K point,J i);
F kdtree_rdist_F(K point,K tree,J parent,J df);

J kdtree_searchfrom_i_E(K tree,K point,J i);
E kdtree_rdist_E(K point,K tree,J parent,J df);


K kdtree_searchfrom(K tree,K point,K start);

