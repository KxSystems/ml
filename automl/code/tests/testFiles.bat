q test.q -q code/tests/ code/nodes/configuration/tests/ code/nodes/featureData/tests/ code/nodes/targetData/tests/ code/nodes/dataCheck/tests/ code/nodes/modelGeneration/tests/ code/nodes/featureDescription/tests/ code/nodes/labelEncode/tests/ code/nodes/dataPreprocessing/tests/ code/nodes/featureCreation/tests/ code/nodes/featureSignificance/tests/ code/nodes/trainTestSplit/tests/ code/nodes/runModels/tests/ code/nodes/selectModels/tests/ code/nodes/optimizeModels/tests/ code/nodes/preprocParams/tests/ code/nodes/predictParams/tests/ code/nodes/pathConstruct/tests/ code/nodes/saveGraph/tests/ code/nodes/saveMeta/tests/ code/nodes/saveReport/tests/ code/nodes/saveModels/tests

q automl.q -config code/tests/files/cli/testCSV.json -run -test
q automl.q -config code/tests/files/cli/testBinary.json -run -test
q automl.q -config code/tests/files/cli/testBinaryCSV.json -run -test
