\d .ml

createGraph:{[]
  nodes:1!enlist`nodeId``function`inputs`outputs!(`;::;::;::;::);
  edges:2!enlist`dstNode`dstName`srcNode`srcName`valid!(`;`;`;`;0b);
  `nodes`edges!(nodes;edges)}

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

delNode:{[graph;nodeId]
  if[not nodeId in 1_exec nodeId from graph`nodes;'"invalid nodeId"];
  graph:@[graph;`nodes;_;nodeId];
  inputEdges:select from graph[`edges]where dstNode=nodeId;
  graph:@[graph;`edges;key[inputEdges]_];
  outputEdges:select from graph[`edges]where srcNode=nodeId;
  graph:@[graph;`edges;,;update srcNode:`,srcName:`,valid:0b from outputEdges];
  graph}

addCfg:{[graph;nodeId;cfg]addNode[graph;nodeId]``function`inputs`outputs!(::;@[;cfg];::;"!")}
updCfg:{[graph;nodeId;cfg]updNode[graph;nodeId](1#`function)!enlist cfg}
delCfg:delNode

connectEdge:{[graph;srcNode;srcName;dstNode;dstName]
  if[99h<>type srcOutputs:graph[`nodes;srcNode;`outputs];'"invalid srcNode"];
  if[99h<>type dstInputs:graph[`nodes;dstNode;`inputs];'"invalid dstNode"];
  if[not srcName in key srcOutputs;'"invalid srcName"];
  if[not dstName in key dstInputs;'"invalid dstName"];
  edge:(1#`valid)!1#srcOutputs[srcName]~dstInputs[dstName];
  graph:@[graph;`edges;,;update dstNode,dstName,srcNode,srcName from edge];
  graph}

disconnectEdge:{[graph;dstNode;dstName]
  if[not(dstNode;dstName)in key graph`edges;'"invalid edge"];
  edge:(1#`valid)!1#0b;
  graph:@[graph;`edges;,;update dstNode,dstName,srcName:`,srcNode:` from edge];
  graph}

