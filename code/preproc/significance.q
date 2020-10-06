\d .automl

// The current implementation of feature significance testing within the AutoML library
// makes use of the functionality contained within the machine learning toolkit
// specifically the the FRESH feature significance functionality. In this case the top 25%
// of features deemed important are selected. If no features are deemed important in accordance
// with this test then for the time being all features are passed into the model

prep.freshsignificance:{[t;tgt]
  $[0<>count k:.ml.fresh.significantfeatures[t;tgt;.ml.fresh.percentile 0.25];
    k;[-1 i.runout`nosig;cols t]]}