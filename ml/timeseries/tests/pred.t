\l ml.q
\l timeseries/utils.q
\l timeseries/fit.q
\l timeseries/predict.q
\l timeseries/tests/failMessage.q

-1"Warning: These tests may cause varying results for Linux vs Windows users";

\S 42
exogIntFuture   :1000 50#5000?1000
exogFloatFuture :1000 50#5000?1000f
exogMixedFuture :(1000 20#20000?1000),'(1000 20#20000?1000f),'(1000 10#10000?0b)

os:$[.z.o like "w*";"windows/";"linux/"];

// Load files
fileList:`AR1`AR2`AR3`AR4`ARCH1`ARCH2`ARMA1`ARMA2`ARMA3`ARMA4`ARIMA1`ARIMA2,
         `ARIMA3`ARIMA4`SARIMA1`SARIMA2`SARIMA3`SARIMA4
loadFunc:{load hsym`$":timeseries/tests/data/",x,y,string z}
loadFunc[os;"fit/"]each fileList;
loadFunc[os;"pred/pred"]each fileList;


// AR tests

AR1.predict[()             ;1000]~predAR1
AR2.predict[exogFloatFuture;1000]~predAR2
AR3.predict[exogIntFuture  ;1000]~predAR3
AR4.predict[exogMixedFuture;1000]~predAR4

failingTest[AR2.predict;(-1_'exogFloatFuture;1000);0b;"Test exog length does not match train exog length"]
failingTest[AR3.predict;(-1_'exogIntFuture  ;1000);0b;"Test exog length does not match train exog length"]

// ARCH tests

ARCH1.predict[1000]~predARCH1
ARCH2.predict[1000]~predARCH2

// ARMA tests

ARMA1.predict[();1000]~predARMA1
ARMA2.predict[exogFloatFuture;1000]~predARMA2
ARMA3.predict[exogIntFuture;1000]~predARMA3
ARMA4.predict[exogMixedFuture;1000]~predARMA4

failingTest[ARMA2.predict;(-1_'exogFloatFuture;1000);0b;"Test exog length does not match train exog length"]
failingTest[ARMA3.predict;(-1_'exogIntFuture  ;1000);0b;"Test exog length does not match train exog length"]


// ARIMA tests

ARIMA1.predict[()             ;1000]~predARIMA1
ARIMA2.predict[exogFloatFuture;1000]~predARIMA2
ARIMA3.predict[exogIntFuture  ;1000]~predARIMA3
ARIMA4.predict[exogMixedFuture;1000]~predARIMA4

failingTest[ARIMA2.predict;(-1_'exogFloatFuture;1000);0b;"Test exog length does not match train exog length"]
failingTest[ARIMA3.predict;(-1_'exogIntFuture  ;1000);0b;"Test exog length does not match train exog length"] 

// SARIMA tests

SARIMA1.predict[()             ;1000]~predSARIMA1
SARIMA2.predict[exogFloatFuture;1000]~predSARIMA2
SARIMA3.predict[exogIntFuture  ;1000]~predSARIMA3
SARIMA4.predict[exogMixedFuture;1000]~predSARIMA4

failingTest[SARIMA2.predict;(-1_'exogFloatFuture;1000);0b;"Test exog length does not match train exog length"]
failingTest[SARIMA3.predict;(-1_'exogIntFuture  ;1000);0b;"Test exog length does not match train exog length"]


