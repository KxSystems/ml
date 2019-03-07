/
The following code is used to test the outputs from the functions written in q based on the functions
that are present in the tsfresh documentation. It should be noted that for large lists of values some of the functions which include exponentials suffer from overflow namely skewness,kurtosis and absenergy   
\

\l p.q
\l fresh/fresh.q
\l fresh/tests/test.p

xint:10000?10000 ;xfloat:10000?50000f;
yint:42;ynull:0n;
yfloat:9f;xminint:20;xmaxint:200;
xminfloat:20;xmaxfloat:200;
k:100?100

np:.p.import[`numpy] 

.ml.fresh.feat.hasdup[xint] ~ 2*hasduplicate[xint]
.ml.fresh.feat.hasdup[xfloat] ~ hasduplicate[xfloat]
.ml.fresh.feat.hasdupmin[xint] ~ hasduplicatemin[xint]
.ml.fresh.feat.hasdupmax[xint] ~ hasduplicatemax[xint]
.ml.fresh.feat.hasdup[xfloat] ~ hasduplicate[xfloat]
.ml.fresh.feat.hasdupmin[xfloat] ~ hasduplicatemin[xfloat]
.ml.fresh.feat.hasdupmax[xfloat] ~ hasduplicatemax[xfloat]

.ml.fresh.feat.absenergy[xint] ~ "f"$abs_energy[xint]
.ml.fresh.feat.absenergy[xfloat] ~ abs_energy[xfloat]

.ml.fresh.feat.meanchange[xint] ~ mean_change[xint]
.ml.fresh.feat.meanchange[xfloat] ~ mean_change[xfloat]

.ml.fresh.feat.abssumchange[xint] ~ absolute_sum_of_changes[xint]
.ml.fresh.feat.abssumchange[xfloat] ~ absolute_sum_of_changes[xfloat]

.ml.fresh.feat.meanabschange[xint] ~ mean_abs_change[xint]
.ml.fresh.feat.meanabschange[xfloat] ~ mean_abs_change[xfloat]

.ml.fresh.feat.countabovemean[xint] ~ "i"$count_above_mean[xint]
.ml.fresh.feat.countabovemean[xfloat] ~ "i"$count_above_mean[xfloat]

.ml.fresh.feat.countbelowmean[xint] ~ "i"$count_below_mean[xint]
.ml.fresh.feat.countbelowmean[xfloat] ~ "i"$count_below_mean[xfloat]

.ml.fresh.feat.firstmax[xint] ~ first_location_of_maximum[xint]
.ml.fresh.feat.firstmax[xfloat] ~ first_location_of_maximum[xfloat]

.ml.fresh.feat.firstmin[xint] ~ first_location_of_minimum[xint]
.ml.fresh.feat.firstmin[xfloat] ~ first_location_of_minimum[xfloat]

.ml.fresh.feat.ratiovalnumtserieslength[xint] ~ ratio_val_num_to_t_series[xint]
.ml.fresh.feat.ratiovalnumtserieslength[xfloat] ~ ratio_val_num_to_t_series[xfloat]

.ml.fresh.feat.ratiobeyondrsigma[xint;0.2] ~ ratio_beyond_r_sigma[xint;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xint;2.0] ~ ratio_beyond_r_sigma[xint;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xint;10] ~ ratio_beyond_r_sigma[xint;10]
.ml.fresh.feat.ratiobeyondrsigma[xfloat;0.2] ~ ratio_beyond_r_sigma[xfloat;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xfloat;2.0] ~ ratio_beyond_r_sigma[xfloat;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xfloat;10] ~ ratio_beyond_r_sigma[xfloat;10]

.ml.fresh.feat.perrecurtoalldata[xint] ~ percentage_recurring_all_data[xint]
.ml.fresh.feat.perrecurtoalldata[xfloat] ~ percentage_recurring_all_data[xfloat]
.ml.fresh.feat.perrecurtoallval[xint] ~  percentage_recurring_all_val[xint]
.ml.fresh.feat.perrecurtoallval[xfloat] ~  percentage_recurring_all_val[xfloat]

.ml.fresh.feat.largestdev[xint;0.5] ~ large_standard_deviation[xint;0.5]
.ml.fresh.feat.largestdev[xint;5.0] ~ large_standard_deviation[xint;5.0]
.ml.fresh.feat.largestdev[xint;1] ~ large_standard_deviation[xint;1]
.ml.fresh.feat.largestdev[xfloat;0.5] ~ large_standard_deviation[xfloat;0.5]
.ml.fresh.feat.largestdev[xfloat;5.0] ~ large_standard_deviation[xfloat;5.0]
.ml.fresh.feat.largestdev[xfloat;1] ~ large_standard_deviation[xfloat;1]

.ml.fresh.feat.valcount[xint;yint] ~ "i"$value_count[xint;yint]
.ml.fresh.feat.valcount[xfloat;yfloat] ~ "i"$value_count[xfloat;yfloat]

.ml.fresh.feat.cidce[xint;0b] ~ cid_ce[xint;0b]
.ml.fresh.feat.cidce[xfloat;0b] ~ cid_ce[xfloat;0b]
.ml.fresh.feat.cidce[xint;1b] ~ cid_ce[xint;1b]
.ml.fresh.feat.cidce[xfloat;1b] ~ cid_ce[xfloat;1b]

.ml.fresh.feat.mean2dercentral[xint] ~ mean_second_derivative_central[xint]
.ml.fresh.feat.mean2dercentral[xfloat] ~ mean_second_derivative_central[xfloat]

.ml.fresh.feat.skewness[xint] ~ skewness_py[xint]
/.fresh.feat.skewness[xfloat] ~ skewness_py[xfloat]

.ml.fresh.feat.kurtosis[xint] ~ kurtosis_py[xint]
.ml.fresh.feat.kurtosis[xfloat] ~ kurtosis_py[xfloat]

.ml.fresh.feat.longstrikeltmean[xint] ~ longest_strike_below_mean[xint]
.ml.fresh.feat.longstrikeltmean[xfloat] ~ longest_strike_below_mean[xfloat]

.ml.fresh.feat.longstrikegtmean[xint] ~ longest_strike_above_mean[xint]
.ml.fresh.feat.longstrikegtmean[xfloat] ~ longest_strike_above_mean[xfloat]

.ml.fresh.feat.sumrecurringval[xint] ~ sum_recurring_values[xint]
.ml.fresh.feat.sumrecurringval[xfloat] ~ sum_recurring_values[xfloat]

.ml.fresh.feat.sumrecurringdatapoint[xint] ~ sum_recurring_data_points[xint]
.ml.fresh.feat.sumrecurringdatapoint[xfloat] ~ sum_recurring_data_points[xfloat]

.ml.fresh.feat.c3[xint;2] ~ c3_py[xint;2]
.ml.fresh.feat.c3[xfloat;4] ~ c3_py[xfloat;4]

.ml.fresh.feat.vargtstddev[xint] ~ variance_larger_than_standard_deviation[xint]
.ml.fresh.feat.vargtstddev[xfloat] ~ variance_larger_than_standard_deviation[xfloat] 

.ml.fresh.feat.numcwtpeaks[xint;4] ~ number_cwt_peaks[xint;4]
.ml.fresh.feat.numcwtpeaks[xfloat;3] ~ number_cwt_peaks[xfloat;3]

/For the testing of quantiles the 'y' argument must be in the range [0;1] by definition
.ml.fresh.feat.quantile[xint;0.5] ~ quantile_py[xint;0.5]
.ml.fresh.feat.quantile[xfloat;1] ~ quantile_py[xfloat;1]

.ml.fresh.feat.numcrossingm[xint;350] ~ "i"$number_crossing_m[xint;350]
.ml.fresh.feat.numcrossingm[xint;350.] ~ "i"$number_crossing_m[xint;350.]
.ml.fresh.feat.numcrossingm[xfloat;350] ~ "i"$number_crossing_m[xfloat;350]
.ml.fresh.feat.numcrossingm[xfloat;350.] ~ "i"$number_crossing_m[xfloat;350.]

.ml.fresh.feat.binnedentropy[xint;50] ~ binned_entropy[xint;50]
.ml.fresh.feat.binnedentropy[xfloat;50] ~ binned_entropy[xfloat;50]

.ml.fresh.feat.autocorr[xfloat;5] ~ autocorrelation[xfloat;5]
.ml.fresh.feat.autocorr[xint;50] ~ autocorrelation[xint;50]

.ml.fresh.feat.numpeaks[xint;4] ~ "i"$number_peaks[xint;4]
.ml.fresh.feat.numpeaks[xint;1] ~ "i"$number_peaks[xint;1]
.ml.fresh.feat.numpeaks[xfloat;4] ~ "i"$number_peaks[xfloat;4]
.ml.fresh.feat.numpeaks[xfloat;1] ~ "i"$number_peaks[xfloat;1]

.ml.fresh.feat.rangecount[xint;20;100] ~ "i"$range_count[xint;20;100]
.ml.fresh.feat.rangecount[xfloat;20.1;100.0] ~ "i"$range_count[xfloat;20.1;100.0]

.ml.fresh.feat.treverseasymstat[xint;4] ~ time_reversal_asymmetry_statistic[xint;4]
.ml.fresh.feat.treverseasymstat[xfloat;2] ~ time_reversal_asymmetry_statistic[xfloat;2]

(value .ml.fresh.feat.changequant[xfloat;0.2;0.8;1b])~(change_quantiles[xfloat;0.2;0.8;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xfloat;0.25;0.7;1b])~(change_quantiles[xfloat;0.25;0.7;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xfloat;0.2;0.65;1b])~(change_quantiles[xfloat;0.2;0.65;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xfloat;0.2;0.775;1b])~(change_quantiles[xfloat;0.2;0.775;1b;]each `max`min`mean`var`median`std)

(.ml.fresh.feat.lintrend[xint]`slope) ~ linear_trend[xint][0]
(.ml.fresh.feat.lintrend[xint]`intercept) ~ linear_trend[xint][1]
(.ml.fresh.feat.lintrend[xint]`rval) ~ linear_trend[xint][2]
(.ml.fresh.feat.lintrend[xint]`p) ~ linear_trend[xint][3]
(.ml.fresh.feat.lintrend[xint]`stderr) ~ linear_trend[xint][4]
(.ml.fresh.feat.lintrend[xfloat]`slope) ~ linear_trend[xfloat][0]
(.ml.fresh.feat.lintrend[xfloat]`intercept) ~ linear_trend[xfloat][1]
(.ml.fresh.feat.lintrend[xfloat]`rval) ~ linear_trend[xfloat][2]
(.ml.fresh.feat.lintrend[xfloat]`p) ~ linear_trend[xfloat][3]
(.ml.fresh.feat.lintrend[xfloat]`stderr) ~ linear_trend[xfloat][4]

(value .ml.fresh.aggautocorr[xint]) ~ agg_autocorrelation[xint;]each `mean`var`median`std
(value .ml.fresh.aggautocorr[xfloat]) ~ agg_autocorrelation[xfloat;]each `mean`var`median`std

(.ml.fresh.fftaggreg[xint]`centroid) ~ fft_aggregated[xint][0]
(.ml.fresh.fftaggreg[xint]`variance) ~ fft_aggregated[xint][1]
(.ml.fresh.fftaggreg[xfloat]`centroid) ~ fft_aggregated[xfloat][0]
(.ml.fresh.fftaggreg[xfloat]`variance) ~ fft_aggregated[xfloat][1]

(value .ml.fresh.augfuller[xint]) ~ augmented_dickey_fuller[xint][0 1 2]
(value .ml.fresh.augfuller[xfloat]) ~ augmented_dickey_fuller[xfloat][0 1 2]

(value .ml.fresh.feat.spktwelch[xint;til 100]) ~ spkt_welch_density[xint;til 100]
(value .ml.fresh.feat.spktwelch[xint;k]) ~ spkt_welch_density[xint;k]
(value .ml.fresh.feat.spktwelch[xfloat;til 100]) ~ spkt_welch_density[xfloat;til 100]
(value .ml.fresh.feat.spktwelch[xfloat;k]) ~ spkt_welch_density[xfloat;k]

((.ml.fresh.feat.fftcoeff[xint;]each til 30)`real)~fft_coefficient[xint;`real;til 30]
((.ml.fresh.feat.fftcoeff[xint;]each til 30)`imag)~fft_coefficient[xint;`imag;til 30]
((.ml.fresh.feat.fftcoeff[xint;]each til 30)`angle)~fft_coefficient[xint;`angle;til 30]
((.ml.fresh.feat.fftcoeff[xint;]each til 30)`abs)~fft_coefficient[xint;`abs;til 30]
((.ml.fresh.feat.fftcoeff[xfloat;]each til 30)`real)~fft_coefficient[xfloat;`real;til 30]
((.ml.fresh.feat.fftcoeff[xfloat;]each til 30)`imag)~fft_coefficient[xfloat;`imag;til 30]
((.ml.fresh.feat.fftcoeff[xfloat;]each til 30)`angle)~fft_coefficient[xfloat;`angle;til 30]
((.ml.fresh.feat.fftcoeff[xfloat;]each til 30)`abs)~fft_coefficient[xfloat;`abs;til 30]


/

The following functions have been tested but do not work 'correctly' under the outlined conditions...
* Change Quantiles has issues with deciding where to split the data if passed integer values.
* Linear Trend appears to work reasonably well but looks like there is some floating point error
  exact matches in all cases are not found in particular (lintrend - linear_trend) for the 
  intercept has quiet a large error. 
* The aggregated Fourier Transform also has issues which appear to be related to the floating point
  accuracy. In this case the calculation of centroid and variance appear ok but the calculations
  of skewness and kurtosis are not found to be true this is likely related to overflow... 
  this is an issue with the normal implementations of these functions.

changequant[xint;0.25;0.7;1b;min] ~ change_quantiles[xint;0.2;0.7;1b;`min]
changequant[xint;0.2;0.65;1b;var] ~ change_quantiles[xint;0.2;0.65;1b;`var]
changequant[xint;0.2;0.775;1b;dev] ~ change_quantiles[xint;0.2;0.775;1b;`std]
changequant[xint;0.2;0.7;1b;avg] ~ change_quantiles[xint;0.2;0.7;1b;`mean]

fftaggreg[xint][2] ~ fft_aggregated[xint][2]
fftaggreg[xint][3] ~ fft_aggregated[xint][3]
fftaggreg[xfloat][2] ~ fft_aggregated[xfloat][2]
fftaggreg[xfloat][3] ~ fft_aggregated[xfloat][3]
\
