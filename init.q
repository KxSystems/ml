\d .automl

// Load in the machine learning toolkit which should be located in $QHOME
// also load in some updates to the toolkit to be integrated at a later date
\l ml/ml.q
.ml.loadfile`:init.q
loadfile`:code/updml.q

// Load all approriate components of the automl platform
loadfile`:code/preproc/checkimport.p
loadfile`:code/preproc/utils.q
loadfile`:code/preproc/preproc.q
loadfile`:code/preproc/featextract.q
loadfile`:code/proc/utils.q
loadfile`:code/proc/proc.q
loadfile`:code/proc/xvgs.q
$[0~checkimport[];
  loadfile`:code/models/kerasmdls.q;
  [-1"Requirements for deep learning models not available, these will not be run";]]
loadfile`:code/postproc/plots.q
loadfile`:code/postproc/report.q
loadfile`:code/postproc/utils.q
loadfile`:code/utils.q
loadfile`:code/aml.q
