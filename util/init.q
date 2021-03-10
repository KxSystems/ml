// util/init.q - Load utilities library
// Copyright (c) 2021 Kx Systems Inc

.ml.loadfile`:util/utils.q
.ml.loadfile`:util/utilities.q
.ml.loadfile`:util/metrics.q
.ml.loadfile`:util/preproc.q
.ml.loadfile`:fresh/utils.q
.ml.loadfile`:stats/init.q

.ml.i.deprecWarning`util
