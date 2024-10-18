// init.q - Initialise main q utilities for the model registry
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities relating to all basic interactions with the registry

\d .ml

// Load all utilties
if[not @[get;".ml.registry.q.main.utils.init";0b];
  loadfile`:registry/q/main/utils/requirements.q;
  loadfile`:registry/q/main/utils/check.q;
  loadfile`:registry/q/main/utils/create.q;
  loadfile`:registry/q/main/utils/copy.q;
  loadfile`:registry/q/main/utils/delete.q;
  loadfile`:registry/q/main/utils/misc.q;
  loadfile`:registry/q/main/utils/path.q;
  loadfile`:registry/q/main/utils/search.q;
  loadfile`:registry/q/main/utils/set.q;
  loadfile`:registry/q/main/utils/update.q;
  loadfile`:registry/q/main/utils/load.q;
  loadfile`:registry/q/main/utils/get.q;
  loadfile`:registry/q/main/utils/query.q
  ]

registry.q.main.utils.init:1b
