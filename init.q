// init.q - Load ml libraries
// Copyright (c) 2021 Kx Systems Inc

path:{string`ml^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
system"l ",path,"/","ml.q"

.ml.loadfile`:util/init.q
.ml.loadfile`:stats/init.q
.ml.loadfile`:fresh/init.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:xval/init.q
.ml.loadfile`:graph/init.q
.ml.loadfile`:optimize/init.q
.ml.loadfile`:timeseries/init.q
