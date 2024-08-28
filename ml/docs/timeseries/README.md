# Timeseries forecasting


In timeseries analysis, timeseries forecasting is the use of a model to predict the future values of a dataset based on historical observations. Forecasting can be achieved using a wide range of techniques from simple linear regression to complex neural network constructs. 

Use cases for timeseries forecasting vary from the prediction of weather patterns, forecasting future product sales, and applications in the stock market.

The Machine Learning Toolkit implements commonly-used statistical [forecasting algorithms](models.md), including

-   AutoRegressive (AR)
-   AutoRegressive Conditional Heteroskedasticity (ARCH)
-   AutoRegressive Moving Average (ARMA)
-   AutoRegressive Integrated Moving Average (ARIMA)
-   Seasonal AutoRegressive Moving Average (SARIMA)

Several feature-extraction techniques to generate lagged values and apply moving calculations are also included. Use them to convert a timeseries dataset into a format better suited to application of traditional machine-learning algorithms.

Find example notebooks at
[KxSystems/mlnotebooks](https://github.com/kxsystems/mlnotebooks).


## Loading

The timeseries extension can be loaded independently of the ML Toolkit:

```q
\l ml/ml.q
.ml.loadfile`:timeseries/init.q
```
