// code/nodes/saveReport/init.q - Load saveReport node
// Copyright (c) 2021 Kx Systems Inc
//
// Load code for saveReport node 

\d .automl

loadfile`:code/nodes/saveReport/saveReport.q
loadfile`:code/nodes/saveReport/funcs.q
loadfile`:code/nodes/saveReport/reportlab/utils.q
loadfile`:code/nodes/saveReport/reportlab/reportlab.q
if[0~checkimport[2];
  loadfile`:code/nodes/saveReport/latex/latex.p;
  loadfile`:code/nodes/saveReport/latex/utils.q;
  loadfile`:code/nodes/saveReport/latex/latex.q
  ]
