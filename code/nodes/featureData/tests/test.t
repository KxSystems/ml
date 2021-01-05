\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

-1"\nTesting inappropriate Feature data types";

// Generate data vectors for testing of the target data ingestion function
genData:{@[;0;string]x#/:prd[x]?/:(`6;`6;0Ng;.Q.a),("befhijxpdznuvt"$\:0)}
inapprArray     :genData[enlist 50]
inapprMatrix    :genData[(5;50)]
inapprDict      :(neg[5]?`5)!first inapprMatrix
inapprPandas    :.p.import[`pandas][`:DataFrame]flip inapprDict
procInapprDict  :`typ`data!`process,enlist inapprDict
procInapprPandas:`typ`data!`process,enlist inapprPandas
procInapprArray :{x!y}[`typ`data]each `process,/:enlist each inapprArray
procInapprMatrix:{x!y}[`typ`data]each `process,/:enlist each inapprMatrix

// Expected error message
errMsg:"Feature dataset must be a simple table for use with Automl"

// Testing of all inappropriately typed target data
failingTest[.automl.featureData.node.function;procInapprDict;1b;errMsg]
all failingTest[.automl.featureData.node.function;;1b;errMsg]each procInapprArray
all failingTest[.automl.featureData.node.function;;1b;errMsg]each procInapprMatrix


-1"\nTesting appropriate target data types";

// Generate appropriate data to be loaded from process
apprTable    :flip inapprDict
procApprTable:`typ`data!(`process;apprTable)

// Testing of all supported target data values
all passingTest[.automl.featureData.node.function;procApprTable;1b;apprTable]

