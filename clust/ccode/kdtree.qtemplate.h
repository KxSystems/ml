#define qtemplate RUN qc.q
#include "k.h"

qtemplate({
  "names":["kdtree_searchfrom_i","kdtree_rdist"],
  "types":["QT1"],
  "ptypes":{"QT1":["F","E"]}}|
J kdtree_searchfrom_i(K tree,K point,J i);
QT1 kdtree_rdist(K point,K tree,J parent);
)

K kdtree_searchfrom(K tree,K point,K start);
