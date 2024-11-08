\d .ml

restinit:0b;  //Not applicable functionality

if[not @[get;".ml.registry.init";0b];
  /loadfile`:src/analytics/util/init.q;
  registry.config.init:.Q.opt .z.x;
  loadfile`:registry/config/utils.q;
  loadfile`:registry/config/config.q;
  loadfile`:registry/q/init.q;
  if[restinit;
    loadfile`:registry/q/rest/init.q
    ]
  ]

.ml.registry.init:1b
