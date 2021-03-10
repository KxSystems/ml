// graph/init.q - Load graph library
// Copyright (c) 2021 Kx Systems Inc
//
// Graph and Pipeline is a structural framework for developing 
// q/kdb+ solutions, based on a directed acyclic graph.

.ml.loadfile`:graph/utils.q
.ml.loadfile`:graph/graph.q
.ml.loadfile`:graph/pipeline.q
.ml.loadfile`:graph/modules/saving.q
.ml.loadfile`:graph/modules/loading.q

.ml.loadfile`:util/utils.q
.ml.i.deprecWarning`graph
