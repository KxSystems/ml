// The functions contained in this file are intended in the first instance to show cases
// which will fail to produce a valid/operable graphs/pipelines in order to ensure that the
// catching mechanism for the creation of such workflows is reliable and fully understood

\l p.q
\l ml.q
\l graph/graph.q
\l graph/pipeline.q

g:.ml.createGraph[]
g:.ml.addCfg[g;`cfg1]`test`config!(til 10;5000)
g:.ml.addNode[g;`node1]`function`inputs`outputs!({x};"f";"!")

// Attempt to add a node and configuration with the same name again
0b~$[(::)~@[{.ml.addCfg[x;y]`a`b!1 2}[g;];`cfg1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.ml.addNode[x;y]`function`inputs`outputs!({x};"f";"!")}[g;];`testnode1;{[err]err;0b}];1b;0b]

// Connect an invalid edge between 2 nodes and check non validity
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]
0b~first exec valid from g[`edges] where dstNode=`node1,dstName=`input
g:.ml.disconnectEdge[g;`node1;`input]

// Attempt to disconnect an unconnected edge
0b~$[(::)~@[{.ml.disconnectEdge[x;y;z]}[g;`node1];`input;{[err]err;0b}];1b;0b]

// Attempt to delete a node that has not been populated
0b~$[(::)~@[{.ml.delNode[x;y]}[g;];`notanode;{[err]err;0b}];1b;0b]

// Update node1 such that it is valid for connection to cfg1, function errors on execution (for pipeline testing)
g:.ml.updNode[g;`node1]`function`inputs`outputs!({`e+1};"!";"!")
g:.ml.connectEdge[g;`cfg1;`output;`node1;`input]
1b~first exec valid from g[`edges] where dstNode=`node1,dstName=`input

// Create a second configuration and attempt to connect this to node1 (invalid due to previous connection)
g:.ml.addCfg[g;`cfg2]`test`config!10 20
0b~$[(::)~@[{.ml.connectEdge[x;y;`output;`node1;`input]}[g;];`input;{[err]err;0b}];1b;0b]

p:.ml.createPipeline[g]
// Execute pipeline with debug functionality inactive (returns a table with non complete rows)
not all exec complete from .ml.execPipeline[p]

// Check current debug status, update status and check update success
not .ml.graphDebug
.ml.updDebug[]
.ml.graphDebug

// Execute pipeline catching error with debug status activated
0b~$[(::)~@[{.ml.execPipeline[x]};p;{[err]err;0b}];1b;0b]

// Update delete cfg2, update node1 such that execution is valid and check validity of execution
g:.ml.delCfg[g;`cfg2]
g:.ml.updNode[g;`node1]`function`inputs`outputs!({x};"!";"!")
p1:.ml.createPipeline[g]
all exec complete from .ml.execPipeline[p1]

