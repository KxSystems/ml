// The functions contained in this file are intended in the first instance to show cases
// which will fail to produce a valid/operational graph/pipeline in order to ensure that the
// catching mechanism for the creation of such workflows is reliable and fully understood

\l p.q
\l ml.q
\l graph/graph.q
\l graph/pipeline.q

// Test utilities
failingTest:{[function;data;applyType;error]
  // Is function to be applied unary or multivariable
  applyType:$[applyType;@;.];
  // Failure capture function
  failureFunction:{[err;ret](`TestFailing;err~ret)}[error;];
  error:applyType[function;data;failureFunction];
  $[`TestFailing~first error;last error;0b]
  }

passingTest:{[function;data;applyType;expectedReturn]
  // Is function to be applied unary or multivariable
  applyType:$[applyType;@;.];
  // Failure capture function
  failureFunction:{[err]0N!err;(`TestFailing;0b)};
  functionReturn:applyType[function;data;failureFunction];
  if[`TestFailing~first functionReturn;:0b];
  expectedReturn~functionReturn
  }


g:.ml.createGraph[]
g:.ml.addCfg[g;`cfg1]`test`config!(til 10;5000)
g:.ml.addNode[g;`node1]`function`inputs`outputs!({x};"f";"!")

-1"\nTesting addNode/addCfg";

// Attempt to add a configuration with a non unique name
nodeConfig:`a`b!1 2
failingTest[.ml.addCfg;(g;`cfg1;nodeConfig);0b;"invalid nodeId"]

// Attempt to add a node with a non unique name
nodeConfig:`function`inputs`outputs!({x};"f";"!")
failingTest[.ml.addNode;(g;`node1;nodeConfig);0b;"invalid nodeId"]

// Attempt to add a node with an addition node configuration key
nodeConfig:`function`inputs`outputs`extrakey!({x};"f";"!";1f)
failingTest[.ml.addNode;(g;`failingNode;nodeConfig);0b;"invalid node"]

// Attempt to add a node with an unsuitable configuration input
nodeConfig:`function`inputs`outputs!({x};enlist 1f;"!")
failingTest[.ml.addNode;(g;`failingNode;nodeConfig);0b;"invalid inputs"]

// Attempt to add a node with an unsuitable configuration output
nodeConfig:`function`inputs`outputs!({x};"f";enlist 1f)
failingTest[.ml.addNode;(g;`failingNode;nodeConfig);0b;"invalid outputs"]

-1"\nTesting updNode/updCfg";
// Attempt to update 


-1"\nTesting connectEdge/disconnectEdge";
// Connect an invalid edge between 2 nodes and check that this is not valid
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]
0b~first exec valid from g[`edges] where dstNode=`node1,dstName=`input
g:.ml.disconnectEdge[g;`node1;`input]

// Attempt to disconnect a node that doesn't exist
failingTest[.ml.disconnectEdge;(g;`node;`input);0b;"invalid edge"]

// Attempt to disconnect an edge that doesn't exist on a valid node
failingTest[.ml.disconnectEdge;(g;`node1;`test);0b;"invalid edge"]

-1"\nTesting delNode";
// Attempt to delete a node that does not exist
failingTest[.ml.delNode;(g;`notanode);0b;"invalid nodeId"]

// Update node1 such that it is valid for connection to cfg1,
// but function errors on execution (for pipeline testing)
g:.ml.updNode[g;`node1]`function`inputs`outputs!({`e+1};"!";"!")
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]
1b~first exec valid from g[`edges] where dstNode=`node1,dstName=`input

p:.ml.createPipeline[g]
// Execute pipeline with debug functionality inactive (returns a table with non complete rows)
not all exec complete from .ml.execPipeline[p]

// Check current debug status, update status and check update success
-1"\nTesting graph debug";
not .ml.graphDebug
.ml.updDebug[]
.ml.graphDebug

// Execute pipeline catching error with debug status activated
failingTest[.ml.execPipeline;p;1b;"type"]

g:.ml.updNode[g;`node1]`function`inputs`outputs!({x};"!";"!")
p1:.ml.createPipeline[g]
all exec complete from .ml.execPipeline[p1]

