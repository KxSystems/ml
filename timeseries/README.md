# Time Series
In time series analysis, time series forecasting is the use of a model to predict the future values of a dataset based on historical observations. Forecasting can be achieved using a wide range of techniques from simple linear regression to complex neural network constructs. Use cases for time series forecasting vary from its use in the prediction of weather patterns, the forecasting of future product sales and the applications in the stock market.

## Features
This library contains the following statistical time series forecasting models:
- AutoRegressive (AR)
- AutoRegressive Conditional Heteroskedasticity (ARCH)
- AutoRegressive Moving Average (ARMA)
- AutoRegressive Integrated Moving Average (ARIMA)
- Seasonal AutoRegressive Integrated Moving Average (SARIMA)

In addition, this library includes feature engineering techniques to create lagged and windowed features from a time series dataset in order to make it suitable to be passed into a traditional machine learning model. 

## Requirements

- embedPy

The python dependencies for the Time Series library can be installed by following the instructions laid out in the ML-Toolkit level of this library.

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load the Time Series functionality into the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:timeseries/init.q
```

## Documentation

Documentation is available on the [timeseries](https://code.kx.com/v2/ml/toolkit/timeseries/) homepage.

## Status
  
The Time Series library is still in development and is available here as a beta release. Further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
