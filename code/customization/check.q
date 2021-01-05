\d .automl

// This file includes the logic for requirement checks and loading of optional
//   functionality within the framework, namely dependencies for deep learning
//   or NLP models etc.

// Check if keras module along with appropriate backend functionality can be 
//   loaded into the process
check.keras:{
  if[0~checkimport 0;
    backend:.p.import[`keras.backend][`:backend][]`;
    if[(backend~"tensorflow")&not checkimport 4;:1b];
    if[(backend~"theano"    )&not checkimport 5;:1b];
    ];
   :0b
   }

// Import checks and statements
check.loadkeras:{
  $[check.keras[];
    [loadfile`:code/customization/models/libSupport/keras.p;
     loadfile`:code/customization/models/libSupport/keras.q
     ];
    [-1"Requirements for Keras models not satisfied. Keras along with ",
     "Tensorflow or Theano must be installed. Keras models will be excluded ",
     "from model evaluation."
     ];
    ]
  }

check.loadtorch:{
  $[0~checkimport 1;
    [loadfile`:code/customization/models/libSupport/torch.p;
     loadfile`:code/customization/models/libSupport/torch.q
     ];
    [-1"Requirements for PyTorch models not satisfied. Torch must be ",
     "installed. PyTorch models will be excluded from model evaluation."
     ];
    ]
  }

check.loadlatex:{
  $[0~checkimport 2;
    [loadfile`:code/nodes/saveReport/latex/latex.p;
     loadfile`:code/nodes/saveReport/latex/latex.q
     ];
    -1"Requirements for Latex report generation not satisfied. ",
     "Reports will be generated using reportlab.";
    ]
  }

check.loadtheano:{
  $[0~checkimport 5;
    [loadfile`:code/customization/models/libSupport/theano.p;
     loadfile`:code/customization/models/libSupport/theano.q
     ];
    [-1"Requirements for Theano models not satisfied. Theano must be ",
     "installed. Theano models will be excluded from model evaluation."
     ];
    ]
  }

