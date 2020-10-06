// This file includes the logic for requirement checks and loading of optional
// functionality within the framework, namely dependancies for deep learning/nlp models etc.

\d .automl

// import checks and statements
i.loadkeras:{
  $[0~checkimport[0];
    [loadfile`:code/models/lib_support/keras.q;loadfile`:code/models/lib_support/keras.p];
    [i.keraslist:();-1"Requirements for Keras models not satisfied. Keras and Tensorflow must be installed. Keras models will be excluded from model evaluation.";]]}

i.loadtorch:{
  $[0~checkimport[1];
    [loadfile`:code/models/lib_support/torch.q;loadfile`:code/models/lib_support/torch.p];
    [-1"Requirements for PyTorch models not satisfied. Torch must be installed. PyTorch models will be excluded from model evaluation.";]]}

i.loadnlp:{
  $[(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
   .nlp.loadfile`:init.q;
   [-1"Requirements for NLP models are not satisfied. gensim must be installed. NLP module will not be available.";]]}

i.loadlatex:{
  $[0~checkimport[2];
    [loadfile`:code/postproc/reports/latex.p;loadfile`:code/postproc/reports/latex.q];
    [-1"Requirements for latex report generation are not satisfied. Pylatex must be installed. Reportlab will be used for report generation.";]]}

i.sobolcheck:{
  $[0~checkimport[4];1b;
    ["Insufficient requirements for Sobol search.\nTo use Sobol search you must pip install sobol-seq.\nAutoML will default to random search if sobol is requested.";0b]]}

// Early exiting required if user tries to use unavailable functionality
i.nlpcheck:{
  if[not(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
   -1"In order to run an NLP task you must install the following package - gensim";
   '"Insufficient requirements"]}

/ allow multiprocess
.ml.loadfile`:util/mproc.q
if[0>system"s";
  .ml.mproc.init[abs system"s"]enlist("system[\"l automl/automl.q\"];
  system[\"d .automl\"];
  .automl.loadfile`:code/checking/checkimport.p;
  .automl.loadfile`:code/checking/check.q;
  .automl.i.loadkeras[];.automl.i.loadtorch[]")];

