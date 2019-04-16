\d .ml

.z.pd:`u#0#0i
.z.pc:{.z.pd:`u#.z.pd except x}
mproc.reg:{.z.pd,:.z.w;neg[.z.w]@/:mproc.cmds}
mproc.init:{[n;x]
  if[not p:system"p";'"set port to multiprocess"];
  mproc.cmds:x;
  do[n;system"q ",path,"/util/mprocw.q -pp ",string p];}
