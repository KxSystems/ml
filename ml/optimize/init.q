// optimize/init.q - Load optimize library
// Copyright (c) 2021 Kx Systems Inc
// 
// The .ml.optimize namespace contains functions that relate to 
// the application of numerical optimization techniques. Such 
// techniques are used to find local or global minima of user-provided 
// objective functions and are central to many statistical models.

\d .ml
loadfile`:util/utils.q
loadfile`:util/utilities.q
loadfile`:optimize/utils.q
loadfile`:optimize/optimize.q

.ml.i.deprecWarning`optimize
