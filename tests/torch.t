\d .automl
\l automl.q

// load the library to retrieve checkimport function
loadfile`:init.q


// don't run tests if torch can't be loaded
if[not 0~checkimport[1];exit 0];


// generate data for testing
tgt_f  :asc 100?1f;
tgt_b  :100?0b;
tgt_mul:100?3;
normtab1:([]100?1f;100?0b;asc 100?`1;100?100);
normtab2:([]100?0Ng;100?1f;asc 100?1000;100?`1);
freshtab1:([]5000?100?0p;asc 5000?100?1f;5000?1f;desc 5000?10f;5000?0b);
freshtab2:([]5000?100?0p;5000?0Ng;desc 5000?1f;asc 5000?1f;5000?`1);


// language agnostic function for moving a file to a new location
moveFiles:{[filePaths]
  os:.z.o like "w*";
  filePaths:{" "sv raze each x,/:y}[.automl.path;filePaths];
  if[os;filePaths:ssr[filePaths;"/";"\\"]];
  system $[os;"move ";"mv "],filePaths;
  }


// file paths to allow torch model tests to be added and reverted to original
filePaths:(("/code/models/lib_support/torch.q";"/code/models/lib_support/oldtorch.q");
          ("/code/models/lib_support/torch.p";"/code/models/lib_support/oldtorch.p");
          ("/code/models/models/classmodels.txt";"/code/models/models/oldclassmodels.txt");
          ("/tests/files/torch.q";"/code/models/lib_support/torch.q");
          ("/tests/files/torch.p";"/code/models/lib_support/torch.p");
          ("/tests/files/classmodels.txt";"/code/models/models/classmodels.txt"));

moveFiles each filePaths;

// reload the library contents to ensure the correct torch files used
loadfile`:init.q

// Run tests to ensure nothing is failing when running with only a pytorch model

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;::];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;::];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;::];};normtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;::];};normtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;::];};normtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;::];};normtab2;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;::];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;::];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;::];};freshtab1;{[err]err;0b}];1b;0b]
  
$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;::];};freshtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;::];};freshtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;::];};freshtab2;{[err]err;0b}];1b;0b]


// Revert to the default torch setup
moveFiles each reverse each filePaths rotate[3;til 6];

// Revert the automl library version to use 
loadfile`:init.q

