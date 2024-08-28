\l automl/automl.q

.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// don't run tests if theano can't be loaded
if[not 0~.automl.checkimport[5];exit 0];

// Create feature and target data
nGeneral:100

featureDataNormal:([]nGeneral?1f;asc nGeneral?1f;nGeneral?`a`b`c)

targetBinary     :asc 100?0b

// language agnostic function for moving a file to a new location
.test.moveFiles:{[filePaths]
  os:.z.o like "w*";
  filePaths:{" "sv raze each x,/:y}[.automl.path;filePaths];
  if[os;filePaths:ssr[filePaths;"/";"\\"]];
  system $[os;"move ";"mv "],filePaths;
  }

// file paths to allow theano model tests to be added and reverted to original
.test.filePaths:(("/code/customization/models/libSupport/theano.q";"/code/customization/models/libSupport/oldTheano.q");
          ("/code/customization/models/libSupport/theano.p";"/code/customization/models/libSupport/oldTheano.p");
          ("/code/customization/models/modelConfig/models.json";"/code/customization/models/modelConfig/oldModels.json");
          ("/code/tests/files/theano/theano.q";"/code/customization/models/libSupport/theano.q");
          ("/code/tests/files/theano/theano.p";"/code/customization/models/libSupport/theano.p");
          ("/code/tests/files/theano/models.json";"/code/customization/models/modelConfig/models.json"));

.test.moveFiles each .test.filePaths;

// reload the library contents to ensure the correct theano files used
.automl.loadfile`:init.q

//Create function to ensure fit runs correctly
.test.checkFit:{[params]fitReturn:(key;value)@\:.automl.fit . params;type[first fitReturn],type each last fitReturn}

-1"\nTesting appropriate inputs to fit function for with theano models loaded\n";

passingTest[.test.checkFit;(featureDataNormal;targetBinary;`normal;`class;::);1b;11 99 104h]

// Revert to the default theano setup
.test.moveFiles each reverse each .test.filePaths rotate[3;til 6];

// Revert the automl library version to use 
.automl.loadfile`:init.q
