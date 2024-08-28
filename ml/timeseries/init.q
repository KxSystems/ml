// timeseries/init.q - Load timeseries library
// Copyright (c) 2021 Kx Systems Inc
// 
//  Timeseries forecasting is the use of a model to predict 
//  the future values of a dataset based on historical observations. 

.ml.loadfile`:optimize/init.q
.ml.loadfile`:timeseries/utils.q
.ml.loadfile`:fresh/extract.q
.ml.loadfile`:timeseries/fit.q
.ml.loadfile`:timeseries/predict.q
.ml.loadfile`:timeseries/misc.q

.ml.loadfile`:util/utils.q
.ml.i.deprecWarning`timeSeries
