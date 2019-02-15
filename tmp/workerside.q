\l p.q
gengsearch:{[x;dict;data]
 mdl:.p.import[`pickle][`:loads][x];
 algs:mkalg[dict;mdl];
 {x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;data]each algs}
kffitscore:{[x;data]
 mdl:.p.import[`pickle][`:loads][x];
 {x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[mdl;data]}
mkalg:{[dict;algo]$[1=count kd:key[dict];
 {x[(y 0) pykw z]}[algo;kd]each (value dict)0;
 algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}
