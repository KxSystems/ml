\d .ml

// Execution of a pipeline will not default to enter q debug mode but should be possible to overwrite
graphDebug:0b
updDebug:{[x]graphDebug::not graphDebug}

createPipeline:{[graph]
  if[not all exec 1_valid from graph`edges;'"disconnected edges"];
  outputs:ungroup select srcNode:nodeId,srcName:key each outputs from 1_graph`nodes;
  endpoints:exec distinct srcNode from outputs except select srcNode,srcName from graph`edges;
  optimalpath:distinct raze paths idesc count each paths:i.getOptimalPath[graph]each endpoints;
  pipeline:([]nodeId:optimalpath)#graph`nodes;
  nodeinputs:key each exec inputs from pipeline;
  pipeline:update inputs:count[i]#enlist(1#`)!1#(::),outputtypes:outputs,inputorder:nodeinputs from pipeline;
  pipeline:select nodeId,complete:0b,error:`,function,inputs,outputs:inputs,outputtypes,inputorder from pipeline;
  pipeline:pipeline lj select outputmap:([]srcName;dstNode;dstName)by nodeId:srcNode from graph`edges;
  1!pipeline}

execPipeline:{[pipeline]i.execCheck i.execNext/pipeline}


// Pipeline creation utilities
i.getDeps:{[graph;node]exec distinct srcNode from graph[`edges]where dstNode=node}
i.getAllDeps:{[graph;node]$[count depNodes:i.getDeps[graph]node;distinct node,raze .z.s[graph]each depNodes;node]}
i.getAllPaths:{[graph;node]$[count depNodes:i.getDeps[graph]node;node,/:raze .z.s[graph]each depNodes;raze node]}
i.getLongestPath:{[graph;node]paths first idesc count each paths:reverse each i.getAllPaths[graph;node]}
i.getOptimalPath:{[graph;node]distinct raze reverse each i.getAllDeps[graph]each i.getLongestPath[graph;node]}

i.execNext:{[pipeline]
  node:first 0!select from pipeline where not complete;
  -1"Executing node: ",string node`nodeId;
  if[not count inputs:node[`inputs]node[`inputorder];inputs:1#(::)];
  res:`complete`error`outputs!$[graphDebug;
      .[(1b;`;)node[`function]::;inputs];
      .[(1b;`;)node[`function]::;inputs;{[err](0b;`$err;::)}]
  ];
  / compare outputs to outputtypes ?
  if[not null res`error;-2"Error: ",string res`error];
  if[res`complete;
    res[`inputs]:(1#`)!1#(::);
    outputmap:update data:res[`outputs]srcName from node`outputmap;
    res[`outputs]:((1#`)!1#(::)),(exec distinct srcName from outputmap)_ res`outputs;
    pipeline:{[pipeline;map]pipeline[map`dstNode;`inputs;map`dstName]:map`data;pipeline}/[pipeline;outputmap];
  ];
  pipeline,:update nodeId:node`nodeId from res;
  pipeline}

i.execCheck:{[pipeline]
  if[any not null exec error from pipeline;:0b];
  if[all exec complete from pipeline;:0b];
  1b}
