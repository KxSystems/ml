\d .ml

if[not `mproc in key .ml;.z.pd:`u#0#0i;mproc.N:0]
.z.pc:{.z.pd:`u#.z.pd except x}
mproc.reg:{.z.pd,:.z.w;neg[.z.w]@/:mproc.cmds}
mproc.init:{[n;x]
  if[not p:system"p";'"set port to multiprocess"];
  neg[.z.pd]@\:/:x;
  mproc.cmds,:x;
  do[0|n-mproc.N;system"q ",path,"/util/mprocw.q -pp ",string p];
  mproc.N|:n;}
