// The functions contained in this file are intended in the first instance to show cases
// which will fail to produce a valid/operational graph/pipeline in order to ensure that the
// catching mechanism for the creation of such workflows is reliable and fully understood

\l ml.q
\l graph/utils.q
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


// Generate a graph with a number of basic nodes
g:.ml.createGraph[]
g:.ml.addCfg[g;`cfg1]`test`config!(til 10;5000)
g:.ml.addNode[g;`node1]`function`inputs`outputs!({x};"f";"!")

// Valid node configuration
nodeConfig:`function`inputs`outputs!({x};"f";"!")

// Configuration nodes with various issues
extraKey  :`function`inputs`outputs`extrakey!({x};"f";"!";1f)
inputType :`function`inputs`outputs!({x};enlist 1f;"!")
outputType:`function`inputs`outputs!({x};"f";enlist 1f)


-1"\nTesting addNode/addCfg";

// Attempt to add a configuration with a non unique name
failingTest[.ml.addCfg;(g;`cfg1;`a`b!1 2);0b;"invalid nodeId"]

// Attempt to add a node with a non unique name
failingTest[.ml.addNode;(g;`node1;nodeConfig);0b;"invalid nodeId"]

// Attempt to add a node with an additional node configuration key
failingTest[.ml.addNode;(g;`failingNode;extraKey);0b;"invalid node"]

// Attempt to add a node with an unsuitable configuration input
failingTest[.ml.addNode;(g;`failingNode;inputType);0b;"invalid inputs"]

// Attempt to add a node with an unsuitable configuration output
failingTest[.ml.addNode;(g;`failingNode;outputType);0b;"invalid outputs"]


-1"\nTesting updNode/updCfg";

// Attempt to update a node which does not exist
failingTest[.ml.updNode;(g;`notanode;nodeConfig);0b;"invalid nodeId"]

// Attempt to update a node with an additional node configuration key
failingTest[.ml.updNode;(g;`node1;extraKey);0b;"invalid node"]

// Attempt to update a node with an unsuitable configuration input
failingTest[.ml.updNode;(g;`node1;inputType);0b;"invalid inputs"]

// Attempt to update a nodee with an unsuitable configuration output
failingTest[.ml.updNode;(g;`node1;outputType);0b;"invalid outputs"]


-1"\nTesting connectEdge/disconnectEdge";

// Connect an invalid edge between 2 nodes and check that this is not valid
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]
0b~first exec valid from g[`edges] where destNode=`node1,destName=`input
g:.ml.disconnectEdge[g;`node1;`input]

// Attempt to disconnect a node that doesn't exist
failingTest[.ml.disconnectEdge;(g;`node;`input);0b;"invalid edge"]

// Attempt to disconnect an edge that doesn't exist on a valid node
failingTest[.ml.disconnectEdge;(g;`node1;`test);0b;"invalid edge"]

// Attempt to connect an edge with a non existent source node
failingTest[.ml.connectEdge;(g;`nocfg;`output;`node1;`input);0b;"invalid sourceNode"]

// Attempt to connect an edge from an existent source node but non existent source name
failingTest[.ml.connectEdge;(g;`cfg1;`nosourceName;`node1;`input);0b;"invalid sourceName"]

// Attempt to connect an edge from an non existent destination node
failingTest[.ml.connectEdge;(g;`cfg1;`output;`nosrcnode;`input);0b;"invalid destNode"]

// Attempt to connect an edge from an existent destination node but non existent destination name
failingTest[.ml.connectEdge;(g;`cfg1;`output;`node1;`noinput);0b;"invalid destName"]


-1"\nTesting delNode";
// Attempt to delete a node that does not exist
failingTest[.ml.delNode;(g;`notanode);0b;"invalid nodeId"]
// Add a node to be immediately deleted
g:.ml.addNode[g;`tempNode]`function`inputs`outputs!({x};"f";"!");
`tempNode in exec nodeId from g[`nodes]
g:.ml.delNode[g;`tempNode]
not `tempNode in exec nodeId from g[`nodes]


-1"\nTesting valid edge connection";
// Update node1 such that it is valid for connection to cfg1,
// but function errors on execution (for pipeline testing)
g:.ml.updNode[g;`node1]`function`inputs`outputs!({`e+1};"!";"!")
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]
1b~first exec valid from g[`edges] where destNode=`node1,destName=`input


-1"\nTesting failing pipeline execution without debug mode active";
p:.ml.createPipeline[g]
// Execute pipeline with debug functionality inactive (returns a table with non complete rows)
not all exec complete from .ml.execPipeline[p]


// Check current debug status, update status and check update success
-1"\nTesting graph debug activation functionality";
not .ml.graphDebug
.ml.updDebug[]
.ml.graphDebug


-1"\nTesting graph debug mode is triggered appropriately";
// Execute pipeline catching error with debug status activated
failingTest[.ml.execPipeline;p;1b;"type"]

-1"\nTesting pipeline generation error being appropriately triggered on disconnected edges";
// disconnect a valid edge, test this causes failure in pipeline generation and reconnect edge
g:.ml.disconnectEdge[g;`node1;`input]
failingTest[.ml.createPipeline;g;1b;"disconnected edges"]
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]

-1"\nTesting fully valid graph execution";
// Test that a valid graph operates as expected 
g:.ml.updNode[g;`node1]`function`inputs`outputs!({x};"!";"!")
p1:.ml.createPipeline[g]
all exec complete from .ml.execPipeline[p1]

