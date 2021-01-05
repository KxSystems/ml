\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

-1"\nTesting inappropriate target data types";

// Generate data vectors for testing of the target data ingestion function
inapprDict       :`a`b!(til 10;10?1f)
inapprTable      :([]10?1f;10?1f)
inapprArray      :{@[;0;string]x#/:prd[x]?/:(`6;0Ng;.Q.a),("xpdznuvt"$\:0)}[enlist 50]
inapprEmbedPy    :.p.import[`numpy][`:array][50?10];
procInapprDict   :`typ`data!`process,enlist inapprDict
procInapprTable  :`typ`data!`process,enlist flip inapprDict
procInapprEmbedPy:`typ`data!`process,enlist inapprEmbedPy
procInapprArray  :{x!y}[`typ`data]each `process,/:enlist each inapprArray

// Expected error message
errMsg:"Dataset not of a suitable type only 'befhijs' currently supported"

// Testing of all inappropriately typed target data
failingTest[.automl.targetData.node.function;procInapprDict ;1b;errMsg]
failingTest[.automl.targetData.node.function;procInapprTable;1b;errMsg]
failingTest[.automl.targetData.node.function;procInapprEmbedPy;1b;errMsg]
all failingTest[.automl.targetData.node.function;;1b;errMsg]each procInapprArray


-1"\nTesting appropriate target data types";

// Generate appropriate data to be loaded from process
apprData    :{x#/:prd[x]?/:(`6),("befhij"$\:0)}[enlist 50]
procApprData:{x!y}[`typ`data]each `process,/:enlist each apprData

// Testing of all supported target data values
all passingTest[.automl.targetData.node.function;;1b;]'[procApprData;apprData]

