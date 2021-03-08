// init.q - Load ml libraries
// Copyright (c) 2021 Kx Systems Inc

\d .ml

path:{string`ml^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
system"l ",path,"/","ml.q"

loadfile`:util/init.q
loadfile`:stats/init.q
loadfile`:fresh/init.q
loadfile`:clust/init.q
loadfile`:xval/init.q
loadfile`:graph/init.q
loadfile`:optimize/init.q
loadfile`:timeseries/init.q
