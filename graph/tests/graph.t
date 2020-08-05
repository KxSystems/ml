// The functions contained in this file are intended in the first instance to show cases
// which will fail to produce a valid/operable graphs/pipelines in order to ensure that the
// catching mechanism for the creation of such workflows is reliable and fully understood

\l p.q
\l ml.q
\l graph/graph.q
\l graph/pipeline.q

g:.ml.createGraph[]
g:.ml.addCfg[g;`cfg1]`test`config!(til 10;5000)
g:.ml.addNode[g;`testnode1]`function`inputs`outputs!({x};"f";"!")

// Attempt to add a node and configuration with the same name again
0b~$[(::)~@[{.ml.addCfg[x;y]`a`b!1 2}[g;];`cfg1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.ml.addNode[x;y]`function`inputs`outputs!({x};"f";"!")}[g;];`testnode1;{[err]err;0b}];1b;0b]

// Connect an edge between 2 nodes and check it is invalid
g:.ml.connectEdge[g;`cfg1;`output;`testnode1;`input]
0b~first exec valid from g where dstNode=`node1,dstName=`input
.ml.disconnectEdge[g;`node1;`input]

