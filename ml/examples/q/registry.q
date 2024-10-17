// Initialize all relevant functionality
\l init.q

// Set the screen width/lengths for better display
\c 200 200

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

-1"Generate a model registry and retrieve the 'modelStore'";
.ml.registry.new.registry[::;::];
.ml.registry.get.modelStore[::;::];
show modelStore;

-1"\nAdd several 'basic q models' to the registry\n";
modelName:"basic-model"
// Incrementing versions from '1.0'
.ml.registry.set.model[::;{x}  ;modelName;"q";::]
.ml.registry.set.model[::;{x+1};modelName;"q";::]
.ml.registry.set.model[::;{x+2};modelName;"q";::]

// Set major version and increment from '2.0'
.ml.registry.set.model[::;{x+3};modelName;"q";enlist[`major]!enlist 1b]
.ml.registry.set.model[::;{x+4};modelName;"q";::]

// Add another version of '1.x'
.ml.registry.set.model[::;{x+5};modelName;"q";enlist[`majorVersion]!enlist 1]

-1"Display the modelStore following model addition";
show modelStore;

-1"\nAdd models associated with an experiment\n";
modelName:"new-model"
experiment:enlist[`experimentName]!enlist "testExperiment"
// Incrementing versions from '1.0'
.ml.registry.set.model[::;{x}  ;modelName;"q";experiment]
.ml.registry.set.model[::;{x+1};modelName;"q";experiment,enlist[`major]!enlist 1b]
.ml.registry.set.model[::;{x+2};modelName;"q";experiment]

-1"Display the modelStore following experiment addition";
show modelStore;

-1"\nRetrieve version 1.1 of the 'basic-model':\n";
.ml.registry.get.model[::;::;"basic-model";1 1]`model

-1"\nRetrieve the most up to date model associated with the 'testExperiment':\n";
.ml.registry.get.model[::;"testExperiment";"new-model";::]`model

-1"\nRetrieve the last model added to the registry:\n";
.ml.registry.get.model[::;::;::;::]`model

-1"\nDelete the experiment from the registry";
.ml.registry.delete.experiment[::;"testExperiment"]

-1"\nDisplay the modelStore following experiment deletion";
show modelStore

-1"\nDelete version 1.3 of the 'basic-model'";
.ml.registry.delete.model[::;::;"basic-model";1 3];

-1"\nDisplay the modelStore following deletion of 1.3 of the 'basic-model'";
show modelStore

-1"\nDelete all models associated with the 'basic-model'";
.ml.registry.delete.model[::;::;"basic-model";::]

-1"\nDisplay the modelStore following deletion of 'basic-model'";
show modelStore

// Delete the registry
.ml.registry.delete.registry[::;::]

exit 0
