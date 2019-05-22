#include "k.h"
#define qtemplate(x,y) y
K1(add1){
 R kj(1+x->j);
 }
qtemplate(name:add1gen|types:T%S|ptypes:T=J&F&E%S=I&J&H,
K2(add1gen){
 R kT(1+x->T+y->S);
 }
)

qtemplate(name:add2gen|types:TYPE1|ptypes:TYPE1=J&I,
K2(add2gen){
 R ktype1(1+x->i+y->TYPE1);
 })
