/
The following code is used to test the outputs from the functions written in q based on the functions
that are present in the tsfresh documentation. It should be noted that for large lists of values some of the functions which include exponentials suffer from overflow namely skewness,kurtosis and absenergy   
\

\l p.q
\l ml.q
\l fresh/fresh.q
\l fresh/tests/test.p

xint:10000?10000 ;xfloat:10000?50000f;
xb:1000?0b;
xsmallf:10?1f;xsmalli:10?5;
xnull:10000#0n;
xmixf:@[10000?100f;10?1000;:;0n];
yint:42;ynull:0n;
yfloat:9f;xminint:20;xmaxint:200;
xminfloat:20;xmaxfloat:200;
k:100?100

np:.p.import[`numpy] 

.ml.fresh.feat.hasdup[xint] ~ hasduplicate[xint]
.ml.fresh.feat.hasdup[xfloat] ~ hasduplicate[xfloat]
.ml.fresh.feat.hasdup[xb] ~ hasduplicate[xb]
.ml.fresh.feat.hasdup[xmixf] ~ 1b
.ml.fresh.feat.hasdupmin[xint] ~ hasduplicatemin[xint]
.ml.fresh.feat.hasdupmin[xfloat] ~ hasduplicatemin[xfloat]
.ml.fresh.feat.hasdupmin[xmixf] ~ hasduplicatemin[xmixf]
.ml.fresh.feat.hasdupmin[xb] ~ hasduplicatemin[xb]
.ml.fresh.feat.hasdupmax[xint] ~ hasduplicatemax[xint]
.ml.fresh.feat.hasdupmax[xfloat] ~ hasduplicatemax[xfloat]
.ml.fresh.feat.hasdupmax[xmixf] ~ hasduplicatemax[xmixf]
.ml.fresh.feat.hasdupmax[xb] ~ hasduplicatemax[xb]
.ml.fresh.feat.hasdup[xnull] ~ 1b
.ml.fresh.feat.hasdupmin[xnull] ~ 0b
.ml.fresh.feat.hasdupmax[xnull] ~ 0b

.ml.fresh.feat.absenergy[xint] ~ "f"$abs_energy[xint]
.ml.fresh.feat.absenergy[xfloat] ~ abs_energy[xfloat]
.ml.fresh.feat.absenergy[xmixf] ~ sum l*l:xmixf
.ml.fresh.feat.absenergy[xb] ~ "f"$abs_energy[xb]
.ml.fresh.feat.absenergy[xnull] ~ 0f

.ml.fresh.feat.meanchange[xint] ~ mean_change[xint]
.ml.fresh.feat.meanchange[xfloat] ~ mean_change[xfloat]
/.ml.fresh.feat.meanchange[xb] ~ mean_change[xb]

.ml.fresh.feat.abssumchange[xint] ~ absolute_sum_of_changes[xint]
.ml.fresh.feat.abssumchange[xfloat] ~ absolute_sum_of_changes[xfloat]
.ml.fresh.feat.abssumchange[xb] ~ "i"$absolute_sum_of_changes[xb]
.ml.fresh.feat.abssumchange[xnull] ~ 0f

.ml.fresh.feat.meanabschange[xint] ~ mean_abs_change[xint]
.ml.fresh.feat.meanabschange[xfloat] ~ mean_abs_change[xfloat]
.ml.fresh.feat.meanabschange[xb] ~ mean_abs_change[xb]
.ml.fresh.feat.meanabschange[xnull] ~ mean_abs_change[xnull]

.ml.fresh.feat.countabovemean[xint] ~ "i"$count_above_mean[xint]
.ml.fresh.feat.countabovemean[xfloat] ~ "i"$count_above_mean[xfloat]
.ml.fresh.feat.countabovemean[xb] ~ "i"$count_above_mean[xb]
.ml.fresh.feat.countabovemean[xnull] ~ "i"$count_above_mean[xnull]

.ml.fresh.feat.countbelowmean[xint] ~ "i"$count_below_mean[xint]
.ml.fresh.feat.countbelowmean[xfloat] ~ "i"$count_below_mean[xfloat]
.ml.fresh.feat.countbelowmean[xb] ~ "i"$count_below_mean[xb]
.ml.fresh.feat.countbelowmean[xnull] ~ "i"$count_below_mean[xnull]

.ml.fresh.feat.firstmax[xint] ~ first_location_of_maximum[xint]
.ml.fresh.feat.firstmax[xfloat] ~ first_location_of_maximum[xfloat]
.ml.fresh.feat.firstmax[xb] ~ first_location_of_maximum[xb]
.ml.fresh.feat.firstmax[xnull] ~ 1f

.ml.fresh.feat.firstmin[xint] ~ first_location_of_minimum[xint]
.ml.fresh.feat.firstmin[xfloat] ~ first_location_of_minimum[xfloat]
.ml.fresh.feat.firstmin[xb] ~ first_location_of_minimum[xb]
.ml.fresh.feat.firstmin[xnull] ~ 1f

.ml.fresh.feat.ratiovalnumtserieslength[xint] ~ ratio_val_num_to_t_series[xint]
.ml.fresh.feat.ratiovalnumtserieslength[xfloat] ~ ratio_val_num_to_t_series[xfloat]
.ml.fresh.feat.ratiovalnumtserieslength[xb] ~ ratio_val_num_to_t_series[xb]
.ml.fresh.feat.ratiovalnumtserieslength[xnull] ~ 0.0001

.ml.fresh.feat.ratiobeyondrsigma[xint;0.2] ~ ratio_beyond_r_sigma[xint;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xint;2.0] ~ ratio_beyond_r_sigma[xint;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xint;10] ~ ratio_beyond_r_sigma[xint;10]
.ml.fresh.feat.ratiobeyondrsigma[xfloat;0.2] ~ ratio_beyond_r_sigma[xfloat;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xfloat;2.0] ~ ratio_beyond_r_sigma[xfloat;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xfloat;10] ~ ratio_beyond_r_sigma[xfloat;10]
.ml.fresh.feat.ratiobeyondrsigma[xb;0.2] ~ ratio_beyond_r_sigma[xb;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xb;2.0] ~ ratio_beyond_r_sigma[xb;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xb;10] ~ ratio_beyond_r_sigma[xb;10]
.ml.fresh.feat.ratiobeyondrsigma[xnull;0.2] ~ ratio_beyond_r_sigma[xnull;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xnull;2.0] ~ ratio_beyond_r_sigma[xnull;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xnull;10] ~ ratio_beyond_r_sigma[xnull;10]

.ml.fresh.feat.perrecurtoalldata[xint] ~ percentage_recurring_all_data[xint]
.ml.fresh.feat.perrecurtoalldata[xfloat] ~ percentage_recurring_all_data[xfloat]
.ml.fresh.feat.perrecurtoalldata[xb] ~ percentage_recurring_all_data[xb]
.ml.fresh.feat.perrecurtoalldata[xnull] ~ 1f
.ml.fresh.feat.perrecurtoallval[xint] ~ percentage_recurring_all_val[xint]
.ml.fresh.feat.perrecurtoallval[xfloat] ~ percentage_recurring_all_val[xfloat]
.ml.fresh.feat.perrecurtoallval[xb] ~ percentage_recurring_all_val[xb]
.ml.fresh.feat.perrecurtoallval[xnull] ~ 1f

.ml.fresh.feat.largestdev[xint;0.5] ~ large_standard_deviation[xint;0.5]
.ml.fresh.feat.largestdev[xint;5.0] ~ large_standard_deviation[xint;5.0]
.ml.fresh.feat.largestdev[xint;1] ~ large_standard_deviation[xint;1]
.ml.fresh.feat.largestdev[xfloat;0.5] ~ large_standard_deviation[xfloat;0.5]
.ml.fresh.feat.largestdev[xfloat;5.0] ~ large_standard_deviation[xfloat;5.0]
.ml.fresh.feat.largestdev[xfloat;1] ~ large_standard_deviation[xfloat;1]
.ml.fresh.feat.largestdev[xb;0.5] ~ 0b
.ml.fresh.feat.largestdev[xb;5.0] ~ 0b
.ml.fresh.feat.largestdev[xb;1] ~ 0b
.ml.fresh.feat.largestdev[xnull;0.5] ~ large_standard_deviation[xnull;0.5]
.ml.fresh.feat.largestdev[xnull;5.0] ~ large_standard_deviation[xnull;5.0]
.ml.fresh.feat.largestdev[xnull;1] ~ large_standard_deviation[xnull;1]

.ml.fresh.feat.valcount[xint;yint] ~ "i"$value_count[xint;yint]
.ml.fresh.feat.valcount[xfloat;yfloat] ~ "i"$value_count[xfloat;yfloat]
.ml.fresh.feat.valcount[xb;yint] ~ "i"$value_count[xb;yint]
.ml.fresh.feat.valcount[xb;yfloat] ~ "i"$value_count[xb;yfloat]
.ml.fresh.feat.valcount[xnull;yint] ~ "i"$value_count[xnull;yint]
.ml.fresh.feat.valcount[xnull;yfloat] ~ "i"$value_count[xnull;yfloat]

.ml.fresh.feat.cidce[xint;0b] ~ cid_ce[xint;0b]
.ml.fresh.feat.cidce[xfloat;0b] ~ cid_ce[xfloat;0b]
.ml.fresh.feat.cidce[xb;0b] ~ cid_ce[xb;0b]
.ml.fresh.feat.cidce[xnull;0b] ~ cid_ce[xnull;0b]
.ml.fresh.feat.cidce[xint;1b] ~ cid_ce[xint;1b]
.ml.fresh.feat.cidce[xfloat;1b] ~ cid_ce[xfloat;1b]
.ml.fresh.feat.cidce[xb;1b] ~ cid_ce[xb;1b]
.ml.fresh.feat.cidce[xnull;1b] ~ cid_ce[xnull;1b]

.ml.fresh.feat.mean2dercentral[xint] ~ mean_second_derivative_central[xint]
.ml.fresh.feat.mean2dercentral[xfloat] ~ mean_second_derivative_central[xfloat]
.ml.fresh.feat.mean2dercentral[xb] ~ 0.0005
.ml.fresh.feat.mean2dercentral[xnull] ~ mean_second_derivative_central[xnull]

.ml.fresh.feat.skewness[xint] ~ skewness_py[xint]
(.ml.fresh.feat.skewness[xfloat]-skewness_py[xfloat])<1e-15
.ml.fresh.feat.skewness[xb] ~ skewness_py[xb]
.ml.fresh.feat.skewness[xnull] ~ skewness_py[xnull]

.ml.fresh.feat.kurtosis[xint] ~ kurtosis_py[xint]
.ml.fresh.feat.kurtosis[xfloat] ~ kurtosis_py[xfloat]
.ml.fresh.feat.kurtosis[xb] ~ kurtosis_py[xb]
.ml.fresh.feat.kurtosis[xnull] ~ kurtosis_py[xnull]

.ml.fresh.feat.longstrikeltmean[xint] ~ longest_strike_below_mean[xint]
.ml.fresh.feat.longstrikeltmean[xfloat] ~ longest_strike_below_mean[xfloat]
.ml.fresh.feat.longstrikeltmean[xb] ~ longest_strike_below_mean[xb]
.ml.fresh.feat.longstrikeltmean[xnull] ~ longest_strike_below_mean[xnull]

.ml.fresh.feat.longstrikegtmean[xint] ~ longest_strike_above_mean[xint]
.ml.fresh.feat.longstrikegtmean[xfloat] ~ longest_strike_above_mean[xfloat]
.ml.fresh.feat.longstrikegtmean[xb] ~ longest_strike_above_mean[xb]
.ml.fresh.feat.longstrikegtmean[xnull] ~ longest_strike_above_mean[xnull]

.ml.fresh.feat.sumrecurringval[xint] ~ sum_recurring_values[xint]
.ml.fresh.feat.sumrecurringval[xfloat] ~ sum_recurring_values[xfloat]
.ml.fresh.feat.sumrecurringval[xb] ~ "i"$sum_recurring_values[xb]
.ml.fresh.feat.sumrecurringval[xnull] ~ 0f

.ml.fresh.feat.sumrecurringdatapoint[xint] ~ sum_recurring_data_points[xint]
.ml.fresh.feat.sumrecurringdatapoint[xfloat] ~ sum_recurring_data_points[xfloat]
.ml.fresh.feat.sumrecurringdatapoint[xb] ~ sum_recurring_data_points[xb]
.ml.fresh.feat.sumrecurringdatapoint[xnull] ~ 0f

.ml.fresh.feat.c3[xint;2] ~ c3_py[xint;2]
.ml.fresh.feat.c3[xfloat;4] ~ c3_py[xfloat;4]
("i"$100*.ml.fresh.feat.c3[xb;4]) ~ "i"$100*c3_py[xb;4]
.ml.fresh.feat.c3[xnull;4] ~ 0n

.ml.fresh.feat.vargtstddev[xint] ~ variance_larger_than_standard_deviation[xint]
.ml.fresh.feat.vargtstddev[xfloat] ~ variance_larger_than_standard_deviation[xfloat] 
.ml.fresh.feat.vargtstddev[xb] ~ variance_larger_than_standard_deviation[xb]
.ml.fresh.feat.vargtstddev[xnull] ~ 0b

.ml.fresh.feat.numcwtpeaks[xint;3] ~ number_cwt_peaks[xint;3]
.ml.fresh.feat.numcwtpeaks[xfloat;3] ~ number_cwt_peaks[xfloat;3]
.ml.fresh.feat.numcwtpeaks[xb;3] ~ number_cwt_peaks[xb;3]
.ml.fresh.feat.numcwtpeaks[xnull;3] ~ number_cwt_peaks[xnull;3]

/For the testing of quantiles the 'y' argument must be in the range [0;1] by definition
.ml.fresh.feat.quantile[xint;0.5] ~ quantile_py[xint;0.5]
.ml.fresh.feat.quantile[xfloat;0.5] ~ quantile_py[xfloat;0.5]
.ml.fresh.feat.quantile[xb;0.5] ~ quantile_py[xb;0.5]
.ml.fresh.feat.quantile[xnull;0.5] ~ 0f

.ml.fresh.feat.numcrossingm[xint;350] ~ "i"$number_crossing_m[xint;350]
.ml.fresh.feat.numcrossingm[xfloat;350] ~ "i"$number_crossing_m[xfloat;350]
.ml.fresh.feat.numcrossingm[xb;350] ~ "i"$number_crossing_m[xb;350]
.ml.fresh.feat.numcrossingm[xnull;350] ~ "i"$number_crossing_m[xnull;350]

.ml.fresh.feat.binnedentropy[xint;50] ~ binned_entropy[xint;50]
.ml.fresh.feat.binnedentropy[xfloat;50] ~ binned_entropy[xfloat;50]
abs[.ml.fresh.feat.binnedentropy[xnull;50]] ~ 0f

.ml.fresh.feat.autocorr[xfloat;5] ~ autocorrelation[xfloat;5]
.ml.fresh.feat.autocorr[xint;50] ~ autocorrelation[xint;50]
.ml.fresh.feat.autocorr[xnull;50] ~ autocorrelation[xnull;50]

.ml.fresh.feat.numpeaks[xint;1] ~ "i"$number_peaks[xint;1]
.ml.fresh.feat.numpeaks[xint;4] ~ "i"$number_peaks[xint;4]
.ml.fresh.feat.numpeaks[xfloat;1] ~ "i"$number_peaks[xfloat;1]
.ml.fresh.feat.numpeaks[xfloat;4] ~ "i"$number_peaks[xfloat;4]
.ml.fresh.feat.numpeaks[xb;4] ~ "i"$number_peaks[xb;4]
.ml.fresh.feat.numpeaks[xb;4] ~ "i"$number_peaks[xb;4]
.ml.fresh.feat.numpeaks[xnull;1] ~ "i"$number_peaks[xnull;1]
.ml.fresh.feat.numpeaks[xnull;4] ~ "i"$number_peaks[xnull;4]

.ml.fresh.feat.rangecount[xint;20;100] ~ "i"$range_count[xint;20;100]
.ml.fresh.feat.rangecount[xfloat;20.1;100.0] ~ "i"$range_count[xfloat;20.1;100.0]
.ml.fresh.feat.rangecount[xnull;20;100] ~ "i"$range_count[xnull;20;100]
.ml.fresh.feat.rangecount[xb;20;100] ~ "i"$range_count[xb;20;100]

.ml.fresh.feat.treverseasymstat[xint;4] ~ time_reversal_asymmetry_statistic[xint;4]
.ml.fresh.feat.treverseasymstat[xfloat;2] ~ time_reversal_asymmetry_statistic[xfloat;2]
.ml.fresh.feat.treverseasymstat[xb;2] ~ 0.001
.ml.fresh.feat.treverseasymstat[xnull;2] ~ 0f

(value .ml.fresh.feat.changequant[xfloat;0.2;0.8;1b])~(change_quantiles[xfloat;0.2;0.8;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xfloat;0.25;0.7;1b])~(change_quantiles[xfloat;0.25;0.7;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xfloat;0.2;0.65;1b])~(change_quantiles[xfloat;0.2;0.65;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xfloat;0.2;0.775;1b])~(change_quantiles[xfloat;0.2;0.775;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xnull;0.2;0.775;1b])~(-0w 0w,4#0n)

(.ml.fresh.feat.lintrend[xint]`slope) ~ linear_trend[xint][0]
(.ml.fresh.feat.lintrend[xint]`intercept) ~ linear_trend[xint][1]
(.ml.fresh.feat.lintrend[xint]`rval) ~ linear_trend[xint][2]
(.ml.fresh.feat.lintrend[xfloat]`slope) ~ linear_trend[xfloat][0]
(.ml.fresh.feat.lintrend[xfloat]`intercept) ~ linear_trend[xfloat][1]
(.ml.fresh.feat.lintrend[xfloat]`rval) ~ linear_trend[xfloat][2]
(.ml.fresh.feat.lintrend[xb]`slope) ~ linear_trend[xb][0]
(.ml.fresh.feat.lintrend[xb]`intercept) ~ linear_trend[xb][1]
(.ml.fresh.feat.lintrend[xb]`rval) ~ linear_trend[xb][2]
(.ml.fresh.feat.lintrend[xnull]`slope) ~ 0f
(.ml.fresh.feat.lintrend[xnull]`intercept) ~ 0f
(.ml.fresh.feat.lintrend[xnull]`rval) ~ 0f

(value .ml.fresh.feat.aggautocorr[xint]) ~ agg_autocorrelation[xint;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xfloat]) ~ agg_autocorrelation[xfloat;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xb]) ~ agg_autocorrelation[xb;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xnull]) ~ 4#0f

(.ml.fresh.feat.fftaggreg[xint]`centroid) ~ fft_aggregated[xint][0]
(.ml.fresh.feat.fftaggreg[xint]`variance) ~ fft_aggregated[xint][1]
(.ml.fresh.feat.fftaggreg[xfloat]`centroid) ~ fft_aggregated[xfloat][0]
(.ml.fresh.feat.fftaggreg[xfloat]`variance) ~ fft_aggregated[xfloat][1]
(.ml.fresh.feat.fftaggreg[xb]`centroid) ~ fft_aggregated[xb][0]
(.ml.fresh.feat.fftaggreg[xb]`variance) ~ fft_aggregated[xb][1]
(.ml.fresh.feat.fftaggreg[xnull]`centroid) ~ 0n
(.ml.fresh.feat.fftaggreg[xnull]`variance) ~ 0n

(value .ml.fresh.feat.augfuller[xint]) ~ augmented_dickey_fuller[xint][0 1 2]
(value .ml.fresh.feat.augfuller[xfloat]) ~ augmented_dickey_fuller[xfloat][0 1 2]
(value .ml.fresh.feat.augfuller[xb]) ~ augmented_dickey_fuller[xb][0 1 2]
(value .ml.fresh.feat.augfuller[xnull]) ~ 3#0n

(.ml.fresh.feat.spktwelch[xint;til 100]) ~ spkt_welch_density[xint;til 100]
(.ml.fresh.feat.spktwelch[xint;k]) ~ spkt_welch_density[xint;k]
(.ml.fresh.feat.spktwelch[xfloat;til 100]) ~ spkt_welch_density[xfloat;til 100]
(.ml.fresh.feat.spktwelch[xfloat;k]) ~ spkt_welch_density[xfloat;k]
(.ml.fresh.feat.spktwelch[xb;til 100]) ~ spkt_welch_density[xb;til 100]
(.ml.fresh.feat.spktwelch[xb;k]) ~ spkt_welch_density[xb;k]
(.ml.fresh.feat.spktwelch[xnull;til 100]) ~ spkt_welch_density[xnull;til 100]
(.ml.fresh.feat.spktwelch[xnull;k]) ~ spkt_welch_density[xnull;k]

fft_coefficient[xint;`abs;0]~.ml.fresh.feat.fftcoeff[xint;1]`coeff_0_abs
fft_coefficient[xint;`abs;49]~.ml.fresh.feat.fftcoeff[xint;50]`coeff_49_abs
fft_coefficient[xint;`real;0]~.ml.fresh.feat.fftcoeff[xint;1]`coeff_0_real
fft_coefficient[xint;`real;49]~.ml.fresh.feat.fftcoeff[xint;50]`coeff_49_real
fft_coefficient[xint;`angle;0]~.ml.fresh.feat.fftcoeff[xint;1]`coeff_0_angle
fft_coefficient[xint;`angle;49]~.ml.fresh.feat.fftcoeff[xint;50]`coeff_49_angle
fft_coefficient[xint;`imag;0]~.ml.fresh.feat.fftcoeff[xint;1]`coeff_0_imag
fft_coefficient[xint;`imag;49]~.ml.fresh.feat.fftcoeff[xint;50]`coeff_49_imag
fft_coefficient[xfloat;`abs;0]~.ml.fresh.feat.fftcoeff[xfloat;1]`coeff_0_abs
fft_coefficient[xfloat;`abs;49]~.ml.fresh.feat.fftcoeff[xfloat;50]`coeff_49_abs
fft_coefficient[xfloat;`real;0]~.ml.fresh.feat.fftcoeff[xfloat;1]`coeff_0_real
fft_coefficient[xfloat;`real;49]~.ml.fresh.feat.fftcoeff[xfloat;50]`coeff_49_real
fft_coefficient[xfloat;`angle;0]~.ml.fresh.feat.fftcoeff[xfloat;1]`coeff_0_angle
fft_coefficient[xfloat;`angle;49]~.ml.fresh.feat.fftcoeff[xfloat;50]`coeff_49_angle
fft_coefficient[xfloat;`imag;0]~.ml.fresh.feat.fftcoeff[xfloat;1]`coeff_0_imag
fft_coefficient[xfloat;`imag;49]~.ml.fresh.feat.fftcoeff[xfloat;50]`coeff_49_imag
fft_coefficient[xb;`abs;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_abs
fft_coefficient[xb;`abs;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_abs
fft_coefficient[xb;`real;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_real
fft_coefficient[xb;`real;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_real
fft_coefficient[xb;`angle;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_angle
fft_coefficient[xb;`angle;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_angle
fft_coefficient[xb;`imag;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_imag
fft_coefficient[xb;`imag;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_imag
fft_coefficient[xnull;`abs;0]~.ml.fresh.feat.fftcoeff[xnull;1]`coeff_0_abs
fft_coefficient[xnull;`abs;49]~.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_abs
fft_coefficient[xnull;`real;0]~.ml.fresh.feat.fftcoeff[xnull;1]`coeff_0_real
fft_coefficient[xnull;`real;49]~.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_real
fft_coefficient[xnull;`angle;0]~.ml.fresh.feat.fftcoeff[xnull;1]`coeff_0_angle
fft_coefficient[xnull;`angle;49]~.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_angle
fft_coefficient[xnull;`imag;0]~.ml.fresh.feat.fftcoeff[xnull;1]`coeff_0_imag
fft_coefficient[xnull;`imag;49]~.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_imag

/
(value[.ml.fresh.feat.fftaggreg[xb]]0 1 2) ~ fft_aggregated[xb] 0 1 2
fftaggreg[xint][3] ~ fft_aggregated[xint][3]
fftaggreg[xfloat][2] ~ fft_aggregated[xfloat][2]
fftaggreg[xfloat][3] ~ fft_aggregated[xfloat][3]
\
