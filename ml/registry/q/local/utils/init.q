// init.q - Initialise Utilities for local FS interactions
// Copyright (c) 2021 Kx Systems Inc
//
// Utilties relating to all interactions with local file
// system storage

\d .ml

if[not @[get;".ml.registry.q.local.util.init";0b];
  loadfile`:registry/q/local/utils/check.q
  ]

registry.q.local.util.init:1b
