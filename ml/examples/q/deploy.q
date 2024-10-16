\l init.q

// Retrieve command line arguments and ensure a user is
// cognizant that they will delete the current registry
// if they invoke the example by accident
cmdLine:.Q.opt .z.x
if[not `run in key cmdLine;
  -1"This example will delete the registry",
    " in your current folder, use '-run' command line arg";
  exit 1;
  ];

.[.ml.registry.delete.registry;(::;::);{}]

// All models solving the clustering problem are associated with the
// "cluster" experiment
experiment:enlist[`experimentName]!enlist "cluster"

// Generate and format the dataset

skldata:.p.import`sklearn.datasets
blobs:skldata[`:make_blobs;<]
dset:blobs[`n_samples pykw 1000;`centers pykw 2;`random_state pykw 500]

// Generate two separate Affinity Propagation models using the ML Toolkit
qmdl :.ml.clust.ap.fit[flip dset 0;`nege2dist;0.8;min;::]
qmdl2:.ml.clust.ap.fit[flip dset 0;`nege2dist;0.5;min;::]

// Add the two q models to the KX_ML_REGISTRY
.ml.registry.set.model[::;"cluster";qmdl ;"qAPmodel";"q";enlist[`axis]!enlist 1b]
.ml.registry.set.model[::;"cluster";qmdl2;"qAPmodel";"q";enlist[`axis]!enlist 1b]

// Generate equivalent Affinity Propagation models using Scikit-Learn
skmdl :.p.import[`sklearn.cluster][`:AffinityPropagation][`damping pykw 0.8][`:fit]dset 0
skmdl2:.p.import[`sklearn.cluster][`:AffinityPropagation][`damping pykw 0.5][`:fit]dset 0

// Add the two models to the KX_ML_REGISTRY with the second model version 2.0 not 1.1
.ml.registry.set.model[::;"cluster";skmdl ;"skAPmodel";"sklearn";::]
.ml.registry.set.model[::;"cluster";skmdl2;"skAPmodel";"sklearn";enlist[`major]!enlist 1b]

// Generate and fit two Keras models adding these to the registry
if[@[{.p.import[x];1b};`keras;0b];
  seq  :.p.import[`keras.models][`:Sequential];
  dense:.p.import[`keras.layers][`:Dense];
  nparray:.p.import[`numpy]`:array;

  kerasModel:seq[];
  kerasModel[`:add]dense[4;pykwargs `input_dim`activation!(2;`relu)];
  kerasModel[`:add]dense[4;`activation pykw `relu];
  kerasModel[`:add]dense[1;`activation pykw `sigmoid];
  kerasModel[`:compile][pykwargs `loss`optimizer!`binary_crossentropy`adam];
  kerasModel[`:fit][nparray dset 0;dset 1;pykwargs `epochs`verbose!200 0];

  kerasModel2:seq[];
  kerasModel2[`:add]dense[4;pykwargs `input_dim`activation!(2;`relu)];
  kerasModel2[`:add]dense[4;`activation pykw `relu];
  kerasModel2[`:add]dense[1;`activation pykw `sigmoid];
  kerasModel2[`:compile][pykwargs `loss`optimizer!`mse`adam];
  kerasModel2[`:fit][nparray dset 0;dset 1;pykwargs `epochs`verbose!10 0];

  // Add the two models to the KX_ML_REGISTRY
  .ml.registry.set.model[::;"cluster";kerasModel ;"kerasModel";"keras";::];
  .ml.registry.set.model[::;"cluster";kerasModel2;"kerasModel";"keras";::];
  ];


// Generate and add two Python functions to the KX_ML_REGISTRY.
// These are not associated with a named experiment or solve the problem that
// the above do, they are purely for demonstration
if[@[{.p.import x;1b};`statsmodels;0b];
  pyModel :.p.import[`statsmodels.api][`:OLS];
  pyModel2:.p.import[`statsmodels.api][`:WLS];

  // Add the two functions to the KX_ML_REGISTRY.
  .ml.registry.set.model[::;::;pyModel ;"pythonModel";"python";::];
  .ml.registry.set.model[::;::;pyModel2;"pythonModel";"python";::]
  ]


// Online/out-of-core Models

// Generate and add two q 'online' models to the KX_ML_REGISTRY.
// These models contain an 'update' key which allows the models to
// be updated as new data becomes available
online1:.ml.online.clust.sequentialKMeans.fit[2 200#400?1f;`e2dist;3;::;::]
online2:.ml.online.sgd.linearRegression.fit[100 2#400?1f;100?1f;1b;::]
online3:.ml.online.sgd.logClassifier.fit[100 2#400?1f;100?0b;1b;::]

.ml.registry.set.model[::;::;online1;"onlineCluster"   ;"q";::]
.ml.registry.set.model[::;::;online2;"onlineRegression";"q";::]
.ml.registry.set.model[::;::;online3;"onlineClassifier";"q";::]

// Generate and add two Python 'online' models to the KX_ML_REGISTRY.
// These models must contain a 'partial_fit' method in order to be
// considered suitable for retrieval as update functions

sgdClass:.p.import[`sklearn.linear_model][`:SGDClassifier]
sgdModel:sgdClass[pykwargs `max_iter`tol!(1000;0.003) ][`:fit] . dset 0 1

.ml.registry.set.model[::;::;sgdModel;"SklearnSGD";"sklearn";::]

exit 0
