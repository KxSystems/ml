// init.q - Initialise functionality for local FS interactions
// Copyright (c) 2021 Kx Systems Inc
//
// Functionality relating to all interactions with local
// file system storage

\d .ml

if[not @[get;".ml.registry.q.local.init";0b];
  // Load all utilities
  loadfile`:registry/q/local/utils/init.q;
  // Load all functionality
  loadfile`:registry/q/local/new.q;
  loadfile`:registry/q/local/set.q;
  loadfile`:registry/q/local/update.q;
  loadfile`:registry/q/local/delete.q
  ]

registry.q.local.init:1b
