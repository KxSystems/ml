\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

\S 10

// Features and targets
featData :([]100?1f;100?1f;asc 100?1f)
targClass:asc 100?0b
targMulti:asc 100?`a`b`c
targReg  :asc 100?1f

// Configuration
cfg:enlist[`significantFeatures]!enlist`.automl.featureSignificance.significance

// Main node function

-1"\nTesting all appropriate inputs for featureSignificance node";

// Gnerate testing function
sigFunction:{[cfg;feats;tgt] 
  sigFeats:.automl.featureSignificance.node.function[cfg;feats;tgt];
  (type sigFeats;key sigFeats)
  }

// Expected output from testing
expectedOutput:(99h;`sigFeats`features)

// Testing appropriate input values for feature significance node
passingTest[sigFunction;(cfg;featData;targClass);0b;expectedOutput]
passingTest[sigFunction;(cfg;featData;targMulti);0b;expectedOutput]
passingTest[sigFunction;(cfg;featData;targReg  );0b;expectedOutput]

// funcs.q functions

-1"\nTesting all appropriate inputs for feature significance function"; 

passingTest[.automl.featureSignificance.significance;(featData;targClass);0b;enlist`x2]
passingTest[.automl.featureSignificance.significance;(featData;targMulti);0b;enlist`x2]
passingTest[.automl.featureSignificance.significance;(featData;targReg  );0b;enlist`x2]

-1"\nTesting all appropriate inputs for correlation function";

// Generate correlation tables
corrTable1:([]asc 100?100;asc 100?100;asc 100?100;100?1f)
corrTable2:([]asc 100?100;asc 100?100;100?1f)
corrTable3:([]100?1f;100?3;100?0b)

// Test appropriate inputs for correlation function
passingTest[.automl.featureSignificance.correlationCols;corrTable1;1b;`x`x3   ]
passingTest[.automl.featureSignificance.correlationCols;corrTable2;1b;`x`x2   ]
passingTest[.automl.featureSignificance.correlationCols;corrTable3;1b;`x`x1`x2]
