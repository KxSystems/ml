\d .ml

// @kind function
// @category multiProcess
// @fileoverview If the multiProc key is not already loaded in set .`z.pd` and 
//   N to 0
// @return {null} `.z.pd` and N are set to 0
if[not`multiProc in key .ml;.z.pd:`u#0#0i;multiProc.N:0]

// @kind function
// @category multiProcess
// @fileoverview Define what happens when the connection is closed
// @param func Value of `.z.pc` function 
// @param proc {int} Handle to the worker process
// @return {null} Appropriate handles are closed
.z.pc:{[func;proc]
  .z.pd:`u#.z.pd except proc;
  func proc
  }@[value;`.z.pc;{{}}]

// @kind function
// @category multiProcess
// @fileoverview Register the handle and pass any functions required to the
//   worker processes
// @return {null} The handle is registered and function is passed to process
multiProc.reg:{
  .z.pd,:.z.w;
  neg[.z.w]@/:multiProc.cmds
  }

// @kind function
// @category multiProcess
// @fileoverview Distributes functions to worker processes
// @param n {int} Number of processes open
// @param func {str} Function to be passed to the process
// @return {null} Each of the `n` worker processes evaluate `func`
multiProc.init:{[n;func]
  if[not p:system"p";'"set port to multiprocess"];
  neg[.z.pd]@\:/:func;
  multiProc.cmds,:func;
  do[0|n-multiProc.N;system"q ",path,"/util/mprocw.q -pp ",string p];
  multiProc.N|:n;
  }
