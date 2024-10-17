// init.q - Initialise the main q functionality for the model registry
// Copyright (c) 2021 Kx Systems Inc

\d .ml

if[not @[get;".ml.registry.q.main.init";0b];
  loadfile`:registry/q/main/new.q;
  loadfile`:registry/q/main/log.q;
  loadfile`:registry/q/main/set.q;
  loadfile`:registry/q/main/delete.q;
  loadfile`:registry/q/main/get.q;
  loadfile`:registry/q/main/update.q;
  loadfile`:registry/q/main/query.q
  ]

registry.q.main.init:1b
