\d .automl

// Load in the machine learning toolkit which should be located in $QHOME
// also load in some updates to the toolkit to be integrated at a later date
\l ml/ml.q
.ml.loadfile`:init.q
loadfile`:code/updml.q

// Checking functionality for optional use-cases
loadfile`:code/checking/checkimport.p
loadfile`:code/checking/check.q

// Load all approriate components of the automl platform
loadfile`:code/preproc/utils.q
loadfile`:code/preproc/preproc.q
loadfile`:code/preproc/create.q
loadfile`:code/preproc/normal/utils.q
loadfile`:code/preproc/nlp/utils.q
loadfile`:code/preproc/normal/create.q
loadfile`:code/preproc/fresh/create.q
loadfile`:code/preproc/nlp/create.q
loadfile`:code/preproc/significance.q

loadfile`:code/proc/utils.q
loadfile`:code/proc/proc.q
loadfile`:code/proc/xvgs.q

loadfile`:code/postproc/plots.q
loadfile`:code/postproc/saving.q
loadfile`:code/postproc/reports/report.q
loadfile`:code/postproc/utils.q

// Attempt to load keras/pytorch/latex functionality
i.loadkeras[]
i.loadtorch[]
i.loadlatex[]

// set boolean indicating if sobol is available
i.usesobol:i.sobolcheck[]

loadfile`:code/utils.q
loadfile`:code/aml.q

// Attempt to load nlp functionality, namespace change ensures .automl.path
// is not overwritten
\d .nlp
.automl.i.loadnlp[]
\d .automl

