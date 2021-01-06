\d .ml

// @kind function
// @category graph
// @fileoverview Generate an empty graph
// @return {dict} The structure required for the generation of a connected.
//   This includes a key for information on the nodes present within the graph
//   and edges outlining how the nodes within the graph are connected. 
createGraph:{[]
  nodes:1!enlist`nodeId``function`inputs`outputs!(`;::;::;::;::);
  edges:2!enlist`dstNode`dstName`srcNode`srcName`valid!(`;`;`;`;0b);
  `nodes`edges!(nodes;edges)}


// @kind function
// @category graph
// @fileoverview Add a functional node to a graph
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param nodeId {sym} A symbol unique to the graph denoting the name to be
//   associated with the functional node
// @param node {func} A functional node
// @return {dict} A graph with the the new node added to the graph structure
addNode:{[graph;nodeId;node]
  node,:(1#`)!1#(::);
  if[nodeId in exec nodeId from graph`nodes;'"invalid nodeId"];
  if[not``function`inputs`outputs~asc key node;'"invalid node"];
  if[(::)~node`inputs;node[`inputs]:(0#`)!""];
  if[-10h=type node`inputs;node[`inputs]:(1#`input)!enlist node`inputs];
  if[99h<>type node`inputs;'"invalid inputs"];
  if[-10h=type node`outputs;
    node[`outputs]:(1#`output)!enlist node`outputs;
    node[`function]:((1#`output)!enlist@)node[`function]::;
  ];
  if[99h<>type node`outputs;'"invalid outputs"];
  graph:@[graph;`nodes;,;update nodeId from node];
  edges:flip`dstNode`dstName`srcNode`srcName`valid!(nodeId;key node`inputs;`;`;0b);
  graph:@[graph;`edges;,;edges];
  graph}


// @kind function
// @category graph
// @fileoverview Update the contents of a functional node
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param nodeId {sym} Denoting the name of a functional node to be updated
// @param node {func} A functional node
// @return {dict} The graph with the named functional node contents overwritten
updNode:{[graph;nodeId;node]
  node,:(1#`)!1#(::);
  if[not nodeId in 1_exec nodeId from graph`nodes;'"invalid nodeId"];
  if[count key[node]except``function`inputs`outputs;'"invalid node"];
  oldnode:graph[`nodes]nodeId;
  if[`inputs in key node;
    if[(::)~node`inputs;node[`inputs]:(0#`)!""];
    if[-10h=type node`inputs;node[`inputs]:(1#`input)!enlist node`inputs];
    if[99h<>type node`inputs;'"invalid inputs"];
    inputEdges:select from graph[`edges]where dstNode=nodeId,dstName in key oldnode`inputs;
    graph:@[graph;`edges;key[inputEdges]_];
    inputEdges:flip[`dstNode`dstName!(nodeId;key node`inputs)]#inputEdges;
    graph:@[graph;`edges;,;inputEdges];
    inputEdges:select from inputEdges where not null srcNode;
    graph:{[graph;edge]connectEdge[graph]. edge`srcNode`srcName`dstNode`dstName}/[graph;0!inputEdges];
  ];
  if[`outputs in key node;
    if[-10h=type node`outputs;
      node[`outputs]:(1#`output)!enlist node`outputs;
    ];
    if[99h<>type node`outputs;'"invalid outputs"];
    outputEdges:select from graph[`edges]where srcNode=nodeId,srcName in key oldnode`outputs;
    graph:@[graph;`edges;key[outputEdges]_];
    outputEdges:select from outputEdges where srcName in key node`outputs;
    graph:@[graph;`edges;,;outputEdges];
    outputEdges:select srcNode,srcName,dstNode,dstName from outputEdges;
    graph:{[graph;edge]connectEdge[graph]. edge`srcNode`srcName`dstNode`dstName}/[graph;0!outputEdges];
  ];
  if[`function in key node;
    if[(1#`output)~key graph[`nodes;nodeId]`outputs;node[`function]:((1#`output)!enlist@)node[`function]::];
  ];
  graph:@[graph;`nodes;,;update nodeId from node];
  graph}


// @kind function
// @category graph
// @fileoverview Delete a named function node
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param nodeId {sym} Denoting the name of a functional node to be deleted
// @return {dict} The graph with the named fucntional node removed
delNode:{[graph;nodeId]
  if[not nodeId in 1_exec nodeId from graph`nodes;'"invalid nodeId"];
  graph:@[graph;`nodes;_;nodeId];
  inputEdges:select from graph[`edges]where dstNode=nodeId;
  graph:@[graph;`edges;key[inputEdges]_];
  outputEdges:select from graph[`edges]where srcNode=nodeId;
  graph:@[graph;`edges;,;update srcNode:`,srcName:`,valid:0b from outputEdges];
  graph}

// @kind function
// @category graph
// @fileoverview Add a configuration node to a graph
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param nodeId {sym} A symbol unique to the graph denoting the name to be
//   associated with the configuration node
// @param config {func} Any configuration information to be supplied to other
//   nodes in the graph
// @return {dict} A graph with the the new configuration added to the graph 
//   structure
addCfg:{[graph;nodeId;config]
   addNode[graph;nodeId]``function`inputs`outputs!(::;@[;config];::;"!")}


// @kind function
// @category graph
// @fileoverview Update the contents of a configuration node
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param nodeId {sym} Denoting the name of a configuration node to be updated
// @param config {func} Any configuration information to be supplied to other
//   nodes in the graph
// @return {dict} The graph with the named configuration node contents 
//   overwritten
updCfg:{[graph;nodeId;config]updNode[graph;nodeId](1#`function)!enlist config}


// @kind function
// @category graph
// @fileoverview Delete a named configuration node
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param nodeId {sym} Denoting the name of a configuration node to be deleted
// @return {dict} The graph with the named fucntional node removed
delCfg:delNode

// @kind function
// @category graph
// @fileoverview Connect the output of one node to the input to another
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param srcName {sym} Denoting the name of the output to be connected to an
//   associated input node 
// @param destNode {sym} Denoting the name of a node in the graph which 
//   contains the relevant input to be connected to
// @param destName {sym} Denoting the name of the input which is connected
//   to the output defined by srcNode and srcName
// @return {dict} The graph with the relevant connection made between the 
//   inputs and outputs of two nodes.
connectEdge:{[graph;srcNode;srcName;dstNode;dstName]
  if[99h<>type srcOutputs:graph[`nodes;srcNode;`outputs];'"invalid srcNode"];
  if[99h<>type dstInputs:graph[`nodes;dstNode;`inputs];'"invalid dstNode"];
  if[not srcName in key srcOutputs;'"invalid srcName"];
  if[not dstName in key dstInputs;'"invalid dstName"];
  edge:(1#`valid)!1#srcOutputs[srcName]~dstInputs[dstName];
  graph:@[graph;`edges;,;update dstNode,dstName,srcNode,srcName from edge];
  graph}


// @kind function
// @category graph
// @fileoverview Disconnect an edge from the input of a node
// @param graph {dict} Graph originally generated using .ml.createGraph
// @param destNode {sym} Name of the node containing the edge to be deleted
// @param destName {sym} Name of the edge associated with a specific input to
//   be disconnected
// @return {dict} The graph with the edge connected to the destination input 
//   removed from the graph.
disconnectEdge:{[graph;destNode;destName]
  if[not(destNode;destName)in key graph`edges;'"invalid edge"];
  edge:(1#`valid)!1#0b;
  graph:@[graph;`edges;,;update destNode,destName,srcName:`,
    srcNode:` from edge];
  graph}

