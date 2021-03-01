// graph/graph.q - Graph tools
// Copyright (c) 2021 Kx Systems Inc
//
// Create, update, and delete functionality for a graph.

\d .ml

// @kind function
// @category graph
// @desc Generate an empty graph
// @return {dictionary} Structure required for the generation of a connected 
//   graph. This includes a key for information on the nodes present within the
//   graph and edges outlining how the nodes within the graph are connected. 
createGraph:{[]
  nodeKeys:`nodeId``function`inputs`outputs;
  nodes:1!enlist nodeKeys!(`;::;::;::;::);
  edgeKeys:`destNode`destName`sourceNode`sourceName`valid;
  edges:2!enlist edgeKeys!(`;`;`;`;0b);
  `nodes`edges!(nodes;edges)
  }

// @kind function
// @category graph
// @desc Add a functional node to a graph
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param nodeId {symbol} Denotes the name associated with the functional node
// @param node {fn} A functional node
// @return {dictionary} The graph with the the new node added to the graph 
//   structure
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
  edgeKeys:`destNode`destName`sourceNode`sourceName`valid;
  edges:flip edgeKeys!(nodeId;key node`inputs;`;`;0b);
  graph:@[graph;`edges;,;edges];
  graph
  }

// @kind function
// @category graph
// @desc Update the contents of a functional node
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param nodeId {symbol} Denotes the name of a functional node to be updated
// @param node {fn} A functional node
// @return {dictionary} The graph with the named functional node contents 
//   overwritten
updNode:{[graph;nodeId;node]
  node,:(1#`)!1#(::);
  if[not nodeId in 1_exec nodeId from graph`nodes;'"invalid nodeId"];
  if[count key[node]except``function`inputs`outputs;'"invalid node"];
  oldNode:graph[`nodes]nodeId;
  if[`inputs in key node;
    if[(::)~node`inputs;node[`inputs]:(0#`)!""];
    if[-10h=type node`inputs;node[`inputs]:(1#`input)!enlist node`inputs];
    if[99h<>type node`inputs;'"invalid inputs"];
    inputEdges:select from graph[`edges]where destNode=nodeId,
      destName in key oldNode`inputs;
    graph:@[graph;`edges;key[inputEdges]_];
    inputEdges:flip[`destNode`destName!(nodeId;key node`inputs)]#inputEdges;
    graph:@[graph;`edges;,;inputEdges];
    inputEdges:select from inputEdges where not null sourceNode;
    graph:i.connectGraph/[graph;0!inputEdges];
    ];
  if[`outputs in key node;
    if[-10h=type node`outputs;
      node[`outputs]:(1#`output)!enlist node`outputs];
    if[99h<>type node`outputs;'"invalid outputs"];
    outputEdges:select from graph[`edges]where sourceNode=nodeId,
      sourceName in key oldNode`outputs;
    graph:@[graph;`edges;key[outputEdges]_];
    outputEdges:select from outputEdges where sourceName in key node`outputs;
    graph:@[graph;`edges;,;outputEdges];
    outputEdge:select sourceNode,sourceName,destName,destName from outputEdges;
    graph:i.connectGraph/[graph;0!outputEdge];
    ];
  if[`function in key node;
    if[(1#`output)~key graph[`nodes;nodeId]`outputs;
      node[`function]:((1#`output)!enlist@)node[`function]::];
    ];
  graph:@[graph;`nodes;,;update nodeId from node];
  graph
  }

// @kind function
// @category graph
// @desc Delete a named function node
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param nodeId {symbol} Denotes the name of a functional node to be deleted
// @return {dictionary} The graph with the named fucntional node removed
delNode:{[graph;nodeId]
  if[not nodeId in 1_exec nodeId from graph`nodes;'"invalid nodeId"];
  graph:@[graph;`nodes;_;nodeId];
  inputEdges:select from graph[`edges]where destNode=nodeId;
  graph:@[graph;`edges;key[inputEdges]_];
  outputEdges:select from graph[`edges]where sourceNode=nodeId;
  graph:@[graph;`edges;,;update sourceNode:`,sourceName:`,
    valid:0b from outputEdges];
  graph
  }

// @kind function
// @category graph
// @desc Add a configuration node to a graph
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param nodeId {symbol} Denotes the name associated with the configuration 
//   node
// @param config {fn} Any configuration information to be supplied to other
//   nodes in the graph
// @return {dictionary} A graph with the the new configuration added to the 
//   graph structure
addCfg:{[graph;nodeId;config]
  nodeKeys:``function`inputs`outputs;
  addNode[graph;nodeId]nodeKeys!(::;@[;config];::;"!")
  }

// @kind function
// @category graph
// @desc Update the contents of a configuration node
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param nodeId {symbol} Denotes the name of a configuration node to be 
//   updated
// @param config {fn} Any configuration information to be supplied to other
//   nodes in the graph
// @return {dictionary} The graph with the named configuration node contents 
//   overwritten
updCfg:{[graph;nodeId;config]
  updNode[graph;nodeId](1#`function)!enlist config
  }

// @kind function
// @category graph
// @desc Delete a named configuration node
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param nodeId {symbol} Denotes the name of a configuration node to be 
//   deleted
// @return {dictionary} The graph with the named fucntional node removed
delCfg:delNode

// @kind function
// @category graph
// @desc Connect the output of one node to the input to another
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param sourceNode {symbol} Denotes the name of a node in the graph which 
//   contains the relevant output
// @param sourceName {symbol} Denotes the name of the output to be connected to
//   an associated input node 
// @param destNode {symbol} Name of a node in the graph which contains the 
//   relevant input to be connected to
// @param destName {symbol} Name of the input which is connected to the output
//   defined by sourceNode and sourceName
// @return {dictionary} The graph with the relevant connection made between the 
//   inputs and outputs of two nodes
connectEdge:{[graph;sourceNode;sourceName;destNode;destName]
  srcOutputs:graph[`nodes;sourceNode;`outputs];  
  dstInputs:graph[`nodes;destNode;`inputs];
  if[99h<>type srcOutputs;'"invalid sourceNode"];
  if[99h<>type dstInputs;'"invalid destNode"];
  if[not sourceName in key srcOutputs;'"invalid sourceName"];
  if[not destName in key dstInputs;'"invalid destName"];
  edge:(1#`valid)!1#srcOutputs[sourceName]~dstInputs[destName];
  graph:@[graph;`edges;,;update destNode,destName,sourceNode,
    sourceName from edge];
  graph
  }

// @kind function
// @category graph
// @desc Disconnect an edge from the input of a node
// @param graph {dictionary} Graph originally generated using .ml.createGraph
// @param destNode {symbol} Name of the node containing the edge to be deleted
// @param destName {symbol} Name of the edge associated with a specific input 
//   to be disconnected
// @return {dictionary} The graph with the edge connected to the destination 
//   input removed from the graph.
disconnectEdge:{[graph;destNode;destName]
  if[not(destNode;destName)in key graph`edges;'"invalid edge"];
  edge:(1#`valid)!1#0b;
  graph:@[graph;`edges;,;update destNode,destName,sourceName:`,
    sourceNode:` from edge];
  graph
  }
