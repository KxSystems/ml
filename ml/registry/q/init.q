// init.q - Initialise q functionality related to the model registry
// Copyright (c) 2021 Kx Systems Inc
//
// Functionality relating to all basic interactions with the registry

\d .ml

if[not @[get;"registry.q.init";0b];
  // Load all utilities
  loadfile`:registry/q/main/utils/init.q;
  // Load all functionality;
  loadfile`:registry/q/main/init.q;
  loadfile`:registry/q/local/init.q;
  /loadfile`:registry/q/cloud/init.q;
  ]

registry.q.init:1b
