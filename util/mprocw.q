if[not`pp in key .Q.opt .z.x;exit 1];
if[not count .Q.opt[.z.x]`pp;exit 2];
if[not h:@[hopen;"J"$first .Q.opt[.z.x]`pp;0];exit 3];
@[system;"l ml/ml.q";{exit 4}]
neg[h]`.ml.mproc.reg`
