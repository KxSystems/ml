\d .automl

loadfile`:code/nodes/featureCreation/featureCreation.q
loadfile`:code/nodes/featureCreation/normal/init.q
loadfile`:code/nodes/featureCreation/fresh/init.q
if[not checkimport[3];
  loadfile`:code/nodes/featureCreation/nlp/init.q
  ]
