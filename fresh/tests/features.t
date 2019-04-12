/
The following code is used to test the outputs from the functions written in q based on the functions
that are present in the tsfresh documentation. It should be noted that for large lists of values some of the functions which include exponentials suffer from overflow namely skewness,kurtosis and absenergy   
\

\l p.q
\l ml.q
\l fresh/extract.q
\l fresh/tests/test.p

xj:10000?10000;
xi:10000?10000i;
xf:10000?50000f;
xh:10000?5000h;
xb:1000?0b;
x0:`float$();
x1:1?100f;
x2:2?100f;
xnull:10000#0n;
xmixf:@[10000?100f;10?1000;:;0n];
yint:42;ynull:0n;
yfloat:9f;
xminint:20;
xmaxj:200;
xminfloat:20;
xmaxf:200;
k:100?100

np:.p.import[`numpy] 

.ml.fresh.feat.hasdup[xj] ~ hasduplicate[xj]
.ml.fresh.feat.hasdup[xf] ~ hasduplicate[xf]
.ml.fresh.feat.hasdup[xb] ~ hasduplicate[xb]
.ml.fresh.feat.hasdup[xi] ~ hasduplicate[xi]
.ml.fresh.feat.hasdup[x0] ~ hasduplicate[x0]
.ml.fresh.feat.hasdup[x1] ~ hasduplicate[x1]
.ml.fresh.feat.hasdup[x2] ~ hasduplicate[x2]
.ml.fresh.feat.hasdupmin[xj] ~ hasduplicatemin[xj]
.ml.fresh.feat.hasdupmin[xf] ~ hasduplicatemin[xf]
.ml.fresh.feat.hasdupmin[xi] ~ hasduplicatemin[xi]
.ml.fresh.feat.hasdupmin[xb] ~ hasduplicatemin[xb]
.ml.fresh.feat.hasdupmin[x0] ~ 0b
.ml.fresh.feat.hasdupmin[x1] ~ hasduplicatemin[x1]
.ml.fresh.feat.hasdupmin[x2] ~ hasduplicatemin[x2]
.ml.fresh.feat.hasdupmax[xj] ~ hasduplicatemax[xj]
.ml.fresh.feat.hasdupmax[xf] ~ hasduplicatemax[xf]
.ml.fresh.feat.hasdupmax[xi] ~ hasduplicatemax[xi]
.ml.fresh.feat.hasdupmax[xb] ~ hasduplicatemax[xb]
.ml.fresh.feat.hasdupmax[x0] ~ 0b
.ml.fresh.feat.hasdupmax[x1] ~ hasduplicatemax[x1]
.ml.fresh.feat.hasdupmax[x2] ~ hasduplicatemax[x2]
.ml.fresh.feat.hasdup[xmixf] ~ 1b
.ml.fresh.feat.hasdupmin[xmixf] ~ hasduplicatemin[xmixf]
.ml.fresh.feat.hasdupmax[xmixf] ~ hasduplicatemax[xmixf]
.ml.fresh.feat.hasdup[xnull] ~ 1b
.ml.fresh.feat.hasdupmin[xnull] ~ 0b
.ml.fresh.feat.hasdupmax[xnull] ~ 0b

.ml.fresh.feat.absenergy[xj] ~ "f"$abs_energy[xj]
.ml.fresh.feat.absenergy[xf] ~ abs_energy[xf]
.ml.fresh.feat.absenergy[xb] ~ "f"$abs_energy[xb]
.ml.fresh.feat.absenergy[xi] ~ "f"$abs_energy[xi]
.ml.fresh.feat.absenergy[x0] ~ "f"$abs_energy[x0]
.ml.fresh.feat.absenergy[x1] ~ "f"$abs_energy[x1]
.ml.fresh.feat.absenergy[x2] ~ "f"$abs_energy[x2]
.ml.fresh.feat.absenergy[xmixf] ~ sum l*l:xmixf
.ml.fresh.feat.absenergy[xnull] ~ 0f

.ml.fresh.feat.meanchange[xj] ~ mean_change[xj]
.ml.fresh.feat.meanchange[xf] ~ mean_change[xf]
.ml.fresh.feat.meanchange[xi] ~ mean_change[xi]
.ml.fresh.feat.meanchange[x0] ~ mean_change[x0]
.ml.fresh.feat.meanchange[x1] ~ mean_change[x1]
.ml.fresh.feat.meanchange[x2] ~ mean_change[x2]
/.ml.fresh.feat.meanchange[xb] ~ mean_change[xb]

.ml.fresh.feat.abssumchange[xj] ~ absolute_sum_of_changes[xj]
.ml.fresh.feat.abssumchange[xf] ~ absolute_sum_of_changes[xf]
.ml.fresh.feat.abssumchange[xi] ~ "i"$absolute_sum_of_changes[xi]
.ml.fresh.feat.abssumchange[xb] ~ "i"$absolute_sum_of_changes[xb]
.ml.fresh.feat.abssumchange[x0] ~ 0f 
.ml.fresh.feat.abssumchange[x1] ~ absolute_sum_of_changes[x1]
.ml.fresh.feat.abssumchange[x2] ~ absolute_sum_of_changes[x2]
.ml.fresh.feat.abssumchange[xnull] ~ 0f

.ml.fresh.feat.meanabschange[xj] ~ mean_abs_change[xj]
.ml.fresh.feat.meanabschange[xf] ~ mean_abs_change[xf]
.ml.fresh.feat.meanabschange[xb] ~ mean_abs_change[xb]
.ml.fresh.feat.meanabschange[xi] ~ mean_abs_change[xi]
.ml.fresh.feat.meanabschange[x0] ~ 0n
.ml.fresh.feat.meanabschange[x1] ~ mean_abs_change[x1]
.ml.fresh.feat.meanabschange[x2] ~ mean_abs_change[x2]
.ml.fresh.feat.meanabschange[xnull] ~ 0n

.ml.fresh.feat.countabovemean[xj] ~ "i"$count_above_mean[xj]
.ml.fresh.feat.countabovemean[xf] ~ "i"$count_above_mean[xf]
.ml.fresh.feat.countabovemean[xb] ~ "i"$count_above_mean[xb]
.ml.fresh.feat.countabovemean[xi] ~ "i"$count_above_mean[xi]
.ml.fresh.feat.countabovemean[x0] ~ "i"$count_above_mean[x0]
.ml.fresh.feat.countabovemean[x1] ~ "i"$count_above_mean[x1]
.ml.fresh.feat.countabovemean[x2] ~ "i"$count_above_mean[x2]
.ml.fresh.feat.countabovemean[xnull] ~ "i"$count_above_mean[xnull]

.ml.fresh.feat.countbelowmean[xj] ~ "i"$count_below_mean[xj]
.ml.fresh.feat.countbelowmean[xf] ~ "i"$count_below_mean[xf]
.ml.fresh.feat.countbelowmean[xb] ~ "i"$count_below_mean[xb]
.ml.fresh.feat.countbelowmean[xi] ~ "i"$count_below_mean[xi]
.ml.fresh.feat.countbelowmean[x0] ~ "i"$count_below_mean[x0]
.ml.fresh.feat.countbelowmean[x1] ~ "i"$count_below_mean[x1]
.ml.fresh.feat.countbelowmean[x2] ~ "i"$count_below_mean[x2]
.ml.fresh.feat.countbelowmean[xnull] ~ "i"$count_below_mean[xnull]

.ml.fresh.feat.firstmax[xj] ~ first_location_of_maximum[xj]
.ml.fresh.feat.firstmax[xf] ~ first_location_of_maximum[xf]
.ml.fresh.feat.firstmax[xb] ~ first_location_of_maximum[xb]
.ml.fresh.feat.firstmax[xi] ~ first_location_of_maximum[xi]
.ml.fresh.feat.firstmax[x0] ~ 0n
.ml.fresh.feat.firstmax[x1] ~ first_location_of_maximum[x1]
.ml.fresh.feat.firstmax[x2] ~ first_location_of_maximum[x2]
.ml.fresh.feat.firstmax[xnull] ~ 1f

.ml.fresh.feat.firstmin[xj] ~ first_location_of_minimum[xj]
.ml.fresh.feat.firstmin[xf] ~ first_location_of_minimum[xf]
.ml.fresh.feat.firstmin[xb] ~ first_location_of_minimum[xb]
.ml.fresh.feat.firstmin[xi] ~ first_location_of_minimum[xi]
.ml.fresh.feat.firstmin[x0] ~ 0n
.ml.fresh.feat.firstmin[x1] ~ first_location_of_minimum[x1]
.ml.fresh.feat.firstmin[x2] ~ first_location_of_minimum[x2]
.ml.fresh.feat.firstmin[xnull] ~ 1f

.ml.fresh.feat.ratiovalnumtserieslength[xj] ~ ratio_val_num_to_t_series[xj]
.ml.fresh.feat.ratiovalnumtserieslength[xf] ~ ratio_val_num_to_t_series[xf]
.ml.fresh.feat.ratiovalnumtserieslength[xb] ~ ratio_val_num_to_t_series[xb]
.ml.fresh.feat.ratiovalnumtserieslength[xi] ~ ratio_val_num_to_t_series[xi]
.ml.fresh.feat.ratiovalnumtserieslength[x0] ~ 0n
.ml.fresh.feat.ratiovalnumtserieslength[x1] ~ ratio_val_num_to_t_series[x1]
.ml.fresh.feat.ratiovalnumtserieslength[x2] ~ ratio_val_num_to_t_series[x2]
.ml.fresh.feat.ratiovalnumtserieslength[xnull] ~ 0.0001

.ml.fresh.feat.ratiobeyondrsigma[xj;0.2] ~ ratio_beyond_r_sigma[xj;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xj;2.0] ~ ratio_beyond_r_sigma[xj;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xj;10] ~ ratio_beyond_r_sigma[xj;10]
.ml.fresh.feat.ratiobeyondrsigma[xf;0.2] ~ ratio_beyond_r_sigma[xf;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xf;2.0] ~ ratio_beyond_r_sigma[xf;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xf;10] ~ ratio_beyond_r_sigma[xf;10]
.ml.fresh.feat.ratiobeyondrsigma[xi;0.2] ~ ratio_beyond_r_sigma[xi;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xi;2.0] ~ ratio_beyond_r_sigma[xi;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xi;10] ~ ratio_beyond_r_sigma[xi;10]
.ml.fresh.feat.ratiobeyondrsigma[xb;0.2] ~ ratio_beyond_r_sigma[xb;0.2]
.ml.fresh.feat.ratiobeyondrsigma[xb;2.0] ~ ratio_beyond_r_sigma[xb;2.0]
.ml.fresh.feat.ratiobeyondrsigma[xb;10] ~ ratio_beyond_r_sigma[xb;10]
.ml.fresh.feat.ratiobeyondrsigma[x0;0.2] ~ 0n
.ml.fresh.feat.ratiobeyondrsigma[x0;2.0] ~ 0n
.ml.fresh.feat.ratiobeyondrsigma[x0;10] ~ 0n
.ml.fresh.feat.ratiobeyondrsigma[x1;0.2] ~ ratio_beyond_r_sigma[x1;0.2]
.ml.fresh.feat.ratiobeyondrsigma[x1;2.0] ~ ratio_beyond_r_sigma[x1;2.0]
.ml.fresh.feat.ratiobeyondrsigma[x1;10] ~ ratio_beyond_r_sigma[x1;10]
.ml.fresh.feat.ratiobeyondrsigma[x2;0.2] ~ ratio_beyond_r_sigma[x2;0.2]
.ml.fresh.feat.ratiobeyondrsigma[x2;2.0] ~ ratio_beyond_r_sigma[x2;2.0]
.ml.fresh.feat.ratiobeyondrsigma[x2;10] ~ ratio_beyond_r_sigma[x2;10]
.ml.fresh.feat.ratiobeyondrsigma[xnull;0.2] ~ 0f
.ml.fresh.feat.ratiobeyondrsigma[xnull;2.0] ~ 0f
.ml.fresh.feat.ratiobeyondrsigma[xnull;10] ~ 0f

.ml.fresh.feat.perrecurtoalldata[xj] ~ percentage_recurring_all_data[xj]
.ml.fresh.feat.perrecurtoalldata[xf] ~ percentage_recurring_all_data[xf]
.ml.fresh.feat.perrecurtoalldata[xb] ~ percentage_recurring_all_data[xb]
.ml.fresh.feat.perrecurtoalldata[xi] ~ percentage_recurring_all_data[xi]
.ml.fresh.feat.perrecurtoalldata[x1] ~ percentage_recurring_all_data[x1]
.ml.fresh.feat.perrecurtoalldata[x2] ~ percentage_recurring_all_data[x2]
.ml.fresh.feat.perrecurtoalldata[xnull] ~ 1f

.ml.fresh.feat.perrecurtoallval[xj] ~ percentage_recurring_all_val[xj]
.ml.fresh.feat.perrecurtoallval[xf] ~ percentage_recurring_all_val[xf]
.ml.fresh.feat.perrecurtoallval[xb] ~ percentage_recurring_all_val[xb]
.ml.fresh.feat.perrecurtoallval[xi] ~ percentage_recurring_all_val[xi]
.ml.fresh.feat.perrecurtoallval[x1] ~ percentage_recurring_all_val[x1]
.ml.fresh.feat.perrecurtoallval[x2] ~ percentage_recurring_all_val[x2]
.ml.fresh.feat.perrecurtoallval[xnull] ~ 1f

.ml.fresh.feat.largestdev[xj;0.5] ~ large_standard_deviation[xj;0.5]
.ml.fresh.feat.largestdev[xj;5.0] ~ large_standard_deviation[xj;5.0]
.ml.fresh.feat.largestdev[xj;1] ~ large_standard_deviation[xj;1]
.ml.fresh.feat.largestdev[xf;0.5] ~ large_standard_deviation[xf;0.5]
.ml.fresh.feat.largestdev[xf;5.0] ~ large_standard_deviation[xf;5.0]
.ml.fresh.feat.largestdev[xf;1] ~ large_standard_deviation[xf;1]
.ml.fresh.feat.largestdev[xi;0.5] ~ large_standard_deviation[xi;0.5]
.ml.fresh.feat.largestdev[xi;5.0] ~ large_standard_deviation[xi;5.0]
.ml.fresh.feat.largestdev[xi;1] ~ large_standard_deviation[xi;1]
.ml.fresh.feat.largestdev[x0;0.5] ~ 0b
.ml.fresh.feat.largestdev[x0;5.0] ~ 0b
.ml.fresh.feat.largestdev[x0;1] ~ 0b
.ml.fresh.feat.largestdev[x1;0.5] ~ 0b
.ml.fresh.feat.largestdev[x1;5.0] ~ 0b
.ml.fresh.feat.largestdev[x1;1] ~ 0b
.ml.fresh.feat.largestdev[x2;0.5] ~ 0b
.ml.fresh.feat.largestdev[x2;5.0] ~ 0b
.ml.fresh.feat.largestdev[x2;1] ~ 0b
.ml.fresh.feat.largestdev[xb;0.5] ~ 0b
.ml.fresh.feat.largestdev[xb;5.0] ~ 0b
.ml.fresh.feat.largestdev[xb;1] ~ 0b
.ml.fresh.feat.largestdev[xnull;0.5] ~ large_standard_deviation[xnull;0.5]
.ml.fresh.feat.largestdev[xnull;5.0] ~ large_standard_deviation[xnull;5.0]
.ml.fresh.feat.largestdev[xnull;1] ~ large_standard_deviation[xnull;1]

.ml.fresh.feat.valcount[xj;yint] ~ "i"$value_count[xj;yint]
.ml.fresh.feat.valcount[xf;yfloat] ~ "i"$value_count[xf;yfloat]
.ml.fresh.feat.valcount[xb;yint] ~ "i"$value_count[xb;yint]
.ml.fresh.feat.valcount[xb;yfloat] ~ "i"$value_count[xb;yfloat]
.ml.fresh.feat.valcount[xi;yint] ~ "i"$value_count[xi;yint]
.ml.fresh.feat.valcount[xi;yfloat] ~ "i"$value_count[xi;yfloat]
.ml.fresh.feat.valcount[x0;yint] ~ "i"$value_count[x0;yint]
.ml.fresh.feat.valcount[x0;yfloat] ~ "i"$value_count[x0;yfloat]
.ml.fresh.feat.valcount[x1;yint] ~ "i"$value_count[x1;yint]
.ml.fresh.feat.valcount[x1;yfloat] ~ "i"$value_count[x1;yfloat]
.ml.fresh.feat.valcount[x2;yint] ~ "i"$value_count[x2;yint]
.ml.fresh.feat.valcount[x2;yfloat] ~ "i"$value_count[x2;yfloat]
.ml.fresh.feat.valcount[xnull;yint] ~ "i"$value_count[xnull;yint]
.ml.fresh.feat.valcount[xnull;yfloat] ~ "i"$value_count[xnull;yfloat]

.ml.fresh.feat.cidce[xj;0b] ~ cid_ce[xj;0b]
.ml.fresh.feat.cidce[xf;0b] ~ cid_ce[xf;0b]
.ml.fresh.feat.cidce[xb;0b] ~ cid_ce[xb;0b]
.ml.fresh.feat.cidce[xi;0b] ~ cid_ce[xi;0b]
.ml.fresh.feat.cidce[x0;0b] ~ cid_ce[x0;0b]
.ml.fresh.feat.cidce[x1;0b] ~ cid_ce[x1;0b]
.ml.fresh.feat.cidce[x2;0b] ~ cid_ce[x2;0b]
.ml.fresh.feat.cidce[xnull;0b] ~ 0n
.ml.fresh.feat.cidce[xj;1b] ~ cid_ce[xj;1b]
.ml.fresh.feat.cidce[xf;1b] ~ cid_ce[xf;1b]
.ml.fresh.feat.cidce[xb;1b] ~ cid_ce[xb;1b]
.ml.fresh.feat.cidce[xi;1b] ~ cid_ce[xi;1b]
.ml.fresh.feat.cidce[x0;1b] ~ cid_ce[x0;1b]
.ml.fresh.feat.cidce[x1;0b] ~ cid_ce[x1;0b]
.ml.fresh.feat.cidce[x2;0b] ~ cid_ce[x2;0b]
.ml.fresh.feat.cidce[xnull;1b] ~ 0n

.ml.fresh.feat.mean2dercentral[xj] ~ mean_second_derivative_central[xj]
.ml.fresh.feat.mean2dercentral[xf] ~ mean_second_derivative_central[xf]
.ml.fresh.feat.mean2dercentral[xi] ~ mean_second_derivative_central[xi]
.ml.fresh.feat.mean2dercentral[xb] ~ 0.0005
.ml.fresh.feat.mean2dercentral[x0] ~ 0n
.ml.fresh.feat.mean2dercentral[x1] ~ 0n
.ml.fresh.feat.mean2dercentral[x2] ~ 0n
.ml.fresh.feat.mean2dercentral[xnull] ~ 0n

.ml.fresh.feat.skewness[xj] ~ skewness_py[xj]
(.ml.fresh.feat.skewness[xf] - skewness_py[xf])<1e-15
.ml.fresh.feat.skewness[xb] ~ skewness_py[xb]
.ml.fresh.feat.skewness[xi] ~ skewness_py[xi]
.ml.fresh.feat.skewness[x0] ~ 0n
.ml.fresh.feat.skewness[x1] ~ 0n
.ml.fresh.feat.skewness[x2] ~ 0n
.ml.fresh.feat.skewness[xnull] ~ 0n

.ml.fresh.feat.kurtosis[xj] ~ kurtosis_py[xj]
.ml.fresh.feat.kurtosis[xf] ~ kurtosis_py[xf]
.ml.fresh.feat.kurtosis[xb] ~ kurtosis_py[xb]
.ml.fresh.feat.kurtosis[xi] ~ kurtosis_py[xi]
.ml.fresh.feat.kurtosis[x0] ~ 0n
.ml.fresh.feat.kurtosis[x1] ~ 0n
.ml.fresh.feat.kurtosis[x2] ~ 0n
.ml.fresh.feat.kurtosis[xnull] ~ 0n

.ml.fresh.feat.longstrikeltmean[xj] ~ longest_strike_below_mean[xj]
.ml.fresh.feat.longstrikeltmean[xf] ~ longest_strike_below_mean[xf]
.ml.fresh.feat.longstrikeltmean[xb] ~ longest_strike_below_mean[xb]
.ml.fresh.feat.longstrikeltmean[xi] ~ longest_strike_below_mean[xi]
.ml.fresh.feat.longstrikeltmean[x0] ~ longest_strike_below_mean[x0]
("f"$.ml.fresh.feat.longstrikeltmean[x1]) ~ 0f
.ml.fresh.feat.longstrikeltmean[x2] ~ longest_strike_below_mean[x2]
.ml.fresh.feat.longstrikeltmean[xnull] ~ longest_strike_below_mean[xnull]

.ml.fresh.feat.longstrikegtmean[xj] ~ longest_strike_above_mean[xj]
.ml.fresh.feat.longstrikegtmean[xf] ~ longest_strike_above_mean[xf]
.ml.fresh.feat.longstrikegtmean[xb] ~ longest_strike_above_mean[xb]
.ml.fresh.feat.longstrikegtmean[xi] ~ longest_strike_above_mean[xi]
.ml.fresh.feat.longstrikegtmean[x0] ~ longest_strike_above_mean[x0]
("f"$.ml.fresh.feat.longstrikegtmean[x1]) ~ 0f
.ml.fresh.feat.longstrikegtmean[x2] ~ longest_strike_above_mean[x2]
.ml.fresh.feat.longstrikegtmean[xnull] ~ longest_strike_above_mean[xnull]

.ml.fresh.feat.sumrecurringval[xj] ~ sum_recurring_values[xj]
.ml.fresh.feat.sumrecurringval[xf] ~ sum_recurring_values[xf]
.ml.fresh.feat.sumrecurringval[xi] ~ "i"$sum_recurring_values[xi]
.ml.fresh.feat.sumrecurringval[xb] ~ "i"$sum_recurring_values[xb]
.ml.fresh.feat.sumrecurringval[x1] ~ sum_recurring_values[x1]
.ml.fresh.feat.sumrecurringval[x2] ~ sum_recurring_values[x2]
.ml.fresh.feat.sumrecurringval[x0] ~ 0f
.ml.fresh.feat.sumrecurringval[xnull] ~ 0f

.ml.fresh.feat.sumrecurringdatapoint[xj] ~ sum_recurring_data_points[xj]
.ml.fresh.feat.sumrecurringdatapoint[xf] ~ sum_recurring_data_points[xf]
.ml.fresh.feat.sumrecurringdatapoint[xb] ~ sum_recurring_data_points[xb]
.ml.fresh.feat.sumrecurringdatapoint[xi] ~ sum_recurring_data_points[xi]
.ml.fresh.feat.sumrecurringdatapoint[x1] ~ sum_recurring_data_points[x1]
.ml.fresh.feat.sumrecurringdatapoint[x2] ~ sum_recurring_data_points[x2]
.ml.fresh.feat.sumrecurringdatapoint[xnull] ~ 0f

.ml.fresh.feat.c3[xj;2] ~ c3_py[xj;2]
.ml.fresh.feat.c3[xf;4] ~ c3_py[xf;4]
.ml.fresh.feat.c3[xi;4] ~ c3_py[xi;4]
("i"$100*.ml.fresh.feat.c3[xb;4]) ~ "i"$100*c3_py[xb;4]
.ml.fresh.feat.c3[x0;4] ~ 0n
.ml.fresh.feat.c3[x1;4] ~ 0n
.ml.fresh.feat.c3[x2;4] ~ 0n
.ml.fresh.feat.c3[xnull;4] ~ 0n

.ml.fresh.feat.vargtstddev[xj] ~ variance_larger_than_standard_deviation[xj]
.ml.fresh.feat.vargtstddev[xf] ~ variance_larger_than_standard_deviation[xf] 
.ml.fresh.feat.vargtstddev[xb] ~ variance_larger_than_standard_deviation[xb]
.ml.fresh.feat.vargtstddev[xi] ~ variance_larger_than_standard_deviation[xi]
.ml.fresh.feat.vargtstddev[x0] ~ 0b
.ml.fresh.feat.vargtstddev[x1] ~ variance_larger_than_standard_deviation[x1]
.ml.fresh.feat.vargtstddev[x2] ~ variance_larger_than_standard_deviation[x2]
.ml.fresh.feat.vargtstddev[xnull] ~ 0b

.ml.fresh.feat.numcwtpeaks[xj;3] ~ number_cwt_peaks[xj;3]
.ml.fresh.feat.numcwtpeaks[xf;3] ~ number_cwt_peaks[xf;3]
.ml.fresh.feat.numcwtpeaks[xb;3] ~ number_cwt_peaks[xb;3]
.ml.fresh.feat.numcwtpeaks[xi;3] ~ number_cwt_peaks[xi;3]
.ml.fresh.feat.numcwtpeaks[x1;3] ~ number_cwt_peaks[x1;3]
.ml.fresh.feat.numcwtpeaks[x2;3] ~ number_cwt_peaks[x2;3]
.ml.fresh.feat.numcwtpeaks[xnull;3] ~ number_cwt_peaks[xnull;3]

/For the testing of quantiles the 'y' argument must be in the range [0;1] by definition
.ml.fresh.feat.quantile[xj;0.5] ~ quantile_py[xj;0.5]
.ml.fresh.feat.quantile[xf;0.5] ~ quantile_py[xf;0.5]
.ml.fresh.feat.quantile[xb;0.5] ~ quantile_py[xb;0.5]
.ml.fresh.feat.quantile[xi;0.5] ~ quantile_py[xi;0.5]
.ml.fresh.feat.quantile[x0;0.5] ~ 0f
.ml.fresh.feat.quantile[x1;0.5] ~ quantile_py[x1;0.5]
.ml.fresh.feat.quantile[x2;0.5] ~ quantile_py[x2;0.5]
.ml.fresh.feat.quantile[xnull;0.5] ~ 0f

.ml.fresh.feat.numcrossingm[xj;350] ~ "i"$number_crossing_m[xj;350]
.ml.fresh.feat.numcrossingm[xf;350] ~ "i"$number_crossing_m[xf;350]
.ml.fresh.feat.numcrossingm[xb;350] ~ "i"$number_crossing_m[xb;350]
.ml.fresh.feat.numcrossingm[xi;350] ~ "i"$number_crossing_m[xi;350]
.ml.fresh.feat.numcrossingm[x0;350] ~ "i"$number_crossing_m[x0;350]
.ml.fresh.feat.numcrossingm[x1;350] ~ "i"$number_crossing_m[x1;350]
.ml.fresh.feat.numcrossingm[x2;350] ~ "i"$number_crossing_m[x2;350]
.ml.fresh.feat.numcrossingm[xnull;350] ~ "i"$number_crossing_m[xnull;350]

.ml.fresh.feat.binnedentropy[xj;50] ~ binned_entropy[xj;50]
.ml.fresh.feat.binnedentropy[xf;50] ~ binned_entropy[xf;50]
.ml.fresh.feat.binnedentropy[xi;50] ~ binned_entropy[xi;50]
.ml.fresh.feat.binnedentropy[x1;50] ~ binned_entropy[x1;50]
.ml.fresh.feat.binnedentropy[x2;50] ~ binned_entropy[x2;50]
abs[.ml.fresh.feat.binnedentropy[xnull;50]] ~ 0f

.ml.fresh.feat.autocorr[xf;50] ~ autocorrelation[xf;50]
.ml.fresh.feat.autocorr[xj;50] ~ autocorrelation[xj;50]
.ml.fresh.feat.autocorr[xi;50] ~ autocorrelation[xi;50]
.ml.fresh.feat.autocorr[x0;50] ~ 0n
.ml.fresh.feat.autocorr[x1;50] ~ 0n
.ml.fresh.feat.autocorr[x2;50] ~ 0n
.ml.fresh.feat.autocorr[xnull;50] ~ 0n

.ml.fresh.feat.numpeaks[xj;1] ~ "i"$number_peaks[xj;1]
.ml.fresh.feat.numpeaks[xj;4] ~ "i"$number_peaks[xj;4]
.ml.fresh.feat.numpeaks[xf;1] ~ "i"$number_peaks[xf;1]
.ml.fresh.feat.numpeaks[xf;4] ~ "i"$number_peaks[xf;4]
.ml.fresh.feat.numpeaks[xb;1] ~ "i"$number_peaks[xb;1]
.ml.fresh.feat.numpeaks[xb;4] ~ "i"$number_peaks[xb;4]
.ml.fresh.feat.numpeaks[xi;1] ~ "i"$number_peaks[xi;1]
.ml.fresh.feat.numpeaks[xi;4] ~ "i"$number_peaks[xi;4]
.ml.fresh.feat.numpeaks[x0;1] ~ "i"$number_peaks[x0;1]
.ml.fresh.feat.numpeaks[x0;4] ~ "i"$number_peaks[x0;4]
.ml.fresh.feat.numpeaks[x1;1] ~ "i"$number_peaks[x1;1]
.ml.fresh.feat.numpeaks[x1;4] ~ "i"$number_peaks[x1;4]
.ml.fresh.feat.numpeaks[x2;1] ~ "i"$number_peaks[x2;1]
.ml.fresh.feat.numpeaks[x2;4] ~ "i"$number_peaks[x2;4]
.ml.fresh.feat.numpeaks[xnull;1] ~ "i"$number_peaks[xnull;1]
.ml.fresh.feat.numpeaks[xnull;4] ~ "i"$number_peaks[xnull;4]

.ml.fresh.feat.rangecount[xj;20;100] ~ "i"$range_count[xj;20;100]
.ml.fresh.feat.rangecount[xf;20.1;100.0] ~ "i"$range_count[xf;20.1;100.0]
.ml.fresh.feat.rangecount[xi;20;100] ~ "i"$range_count[xi;20;100]
.ml.fresh.feat.rangecount[xb;20;100] ~ "i"$range_count[xb;20;100]
.ml.fresh.feat.rangecount[x0;20;100] ~ "i"$range_count[x0;20;100]
.ml.fresh.feat.rangecount[x1;20;100] ~ "i"$range_count[x1;20;100]
.ml.fresh.feat.rangecount[x2;20;100] ~ "i"$range_count[x2;20;100]
.ml.fresh.feat.rangecount[xnull;20;100] ~ "i"$range_count[xnull;20;100]

.ml.fresh.feat.treverseasymstat[xj;2] ~ time_reversal_asymmetry_statistic[xj;2]
.ml.fresh.feat.treverseasymstat[xf;2] ~ time_reversal_asymmetry_statistic[xf;2]
.ml.fresh.feat.treverseasymstat[xi;2] ~ time_reversal_asymmetry_statistic[xi;2]
.ml.fresh.feat.treverseasymstat[xb;2] ~ 0.001
.ml.fresh.feat.treverseasymstat[x0;2] ~ 0f
.ml.fresh.feat.treverseasymstat[x1;2] ~ "f"$time_reversal_asymmetry_statistic[x1;2]
.ml.fresh.feat.treverseasymstat[x2;2] ~ "f"$time_reversal_asymmetry_statistic[x2;2]
.ml.fresh.feat.treverseasymstat[xnull;2] ~ 0f

(value .ml.fresh.feat.changequant[xf;0.2;0.8;1b])~(change_quantiles[xf;0.2;0.8;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.25;0.7;1b])~(change_quantiles[xf;0.25;0.7;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.2;0.65;1b])~(change_quantiles[xf;0.2;0.65;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.2;0.775;1b])~(change_quantiles[xf;0.2;0.775;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.2;0.8;0b])~(change_quantiles[xf;0.2;0.8;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.25;0.7;0b])~(change_quantiles[xf;0.25;0.7;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.2;0.65;0b])~(change_quantiles[xf;0.2;0.65;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xf;0.2;0.775;0b])~(change_quantiles[xf;0.2;0.775;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.2;0.8;1b])~(change_quantiles[xj;0.2;0.8;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.25;0.7;1b])~(change_quantiles[xj;0.25;0.7;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.2;0.65;1b])~(change_quantiles[xj;0.2;0.65;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.2;0.775;1b])~(change_quantiles[xj;0.2;0.775;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.2;0.8;0b])~(change_quantiles[xj;0.2;0.8;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.25;0.7;0b])~(change_quantiles[xj;0.25;0.7;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.2;0.65;0b])~(change_quantiles[xj;0.2;0.65;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xj;0.2;0.775;0b])~(change_quantiles[xj;0.2;0.775;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.2;0.8;1b])~(change_quantiles[xi;0.2;0.8;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.25;0.7;1b])~(change_quantiles[xi;0.25;0.7;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.2;0.65;1b])~(change_quantiles[xi;0.2;0.65;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.2;0.775;1b])~(change_quantiles[xi;0.2;0.775;1b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.2;0.8;0b])~(change_quantiles[xi;0.2;0.8;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.25;0.7;0b])~(change_quantiles[xi;0.25;0.7;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.2;0.65;0b])~(change_quantiles[xi;0.2;0.65;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[xi;0.2;0.775;0b])~(change_quantiles[xi;0.2;0.775;0b;]each `max`min`mean`var`median`std)
(value .ml.fresh.feat.changequant[x0;0.2;0.775;1b])~(-0w 0w,4#0n)
(value .ml.fresh.feat.changequant[x1;0.2;0.775;1b])~(-0w 0w,4#0n)
(value .ml.fresh.feat.changequant[x2;0.2;0.775;1b])~(-0w 0w,4#0n)
(value .ml.fresh.feat.changequant[xnull;0.2;0.775;1b])~(-0w 0w,4#0n)

(.ml.fresh.feat.lintrend[xj]`slope) ~ linear_trend[xj][0]
(.ml.fresh.feat.lintrend[xj]`intercept) ~ linear_trend[xj][1]
(.ml.fresh.feat.lintrend[xj]`rval) ~ linear_trend[xj][2]
(.ml.fresh.feat.lintrend[xf]`slope) ~ linear_trend[xf][0]
(.ml.fresh.feat.lintrend[xf]`intercept) ~ linear_trend[xf][1]
(.ml.fresh.feat.lintrend[xf]`rval) ~ linear_trend[xf][2]
(.ml.fresh.feat.lintrend[xb]`slope) ~ linear_trend[xb][0]
(.ml.fresh.feat.lintrend[xb]`intercept) ~ linear_trend[xb][1]
(.ml.fresh.feat.lintrend[xb]`rval) ~ linear_trend[xb][2]
(.ml.fresh.feat.lintrend[xi]`slope) ~ linear_trend[xi][0]
(.ml.fresh.feat.lintrend[xi]`intercept) ~ linear_trend[xi][1]
(.ml.fresh.feat.lintrend[xi]`rval) ~ linear_trend[xi][2]
(.ml.fresh.feat.lintrend[x0]`slope) ~ 0f
(.ml.fresh.feat.lintrend[x0]`intercept) ~ 0f
(.ml.fresh.feat.lintrend[x0]`rval) ~ 0f
(.ml.fresh.feat.lintrend[x1]`slope) ~ 0f
(.ml.fresh.feat.lintrend[x1]`intercept) ~ 0f
(.ml.fresh.feat.lintrend[x1]`rval) ~ 0f
(.ml.fresh.feat.lintrend[x2]`slope) ~ linear_trend[x2][0] 
(.ml.fresh.feat.lintrend[x2]`intercept) ~ linear_trend[x2][1]
(.ml.fresh.feat.lintrend[x2]`rval) ~ linear_trend[x2][2]
(.ml.fresh.feat.lintrend[xnull]`slope) ~ 0f
(.ml.fresh.feat.lintrend[xnull]`intercept) ~ 0f
(.ml.fresh.feat.lintrend[xnull]`rval) ~ 0f

(value .ml.fresh.feat.aggautocorr[xj]) ~ agg_autocorrelation[xj;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xf]) ~ agg_autocorrelation[xf;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xb]) ~ agg_autocorrelation[xb;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xi]) ~ agg_autocorrelation[xi;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[x0]) ~ 4#0f
(value .ml.fresh.feat.aggautocorr[x1]) ~ 4#0f
(value .ml.fresh.feat.aggautocorr[x2]) ~ agg_autocorrelation[x2;]each `mean`var`median`std
(value .ml.fresh.feat.aggautocorr[xnull]) ~ 4#0f

(.ml.fresh.feat.fftaggreg[xj]`centroid) ~ fft_aggregated[xj][0]
(.ml.fresh.feat.fftaggreg[xj]`variance) ~ fft_aggregated[xj][1]
(.ml.fresh.feat.fftaggreg[xi]`centroid) ~ fft_aggregated[xi][0]
(.ml.fresh.feat.fftaggreg[xi]`variance) ~ fft_aggregated[xi][1]
(.ml.fresh.feat.fftaggreg[xf]`centroid) ~ fft_aggregated[xf][0]
(.ml.fresh.feat.fftaggreg[xf]`variance) ~ fft_aggregated[xf][1]
(.ml.fresh.feat.fftaggreg[xb]`centroid) ~ fft_aggregated[xb][0]
(.ml.fresh.feat.fftaggreg[xb]`variance) ~ fft_aggregated[xb][1]
(.ml.fresh.feat.fftaggreg[x1]`centroid) ~ fft_aggregated[x1][0]
(.ml.fresh.feat.fftaggreg[x1]`variance) ~ fft_aggregated[x1][1]
(.ml.fresh.feat.fftaggreg[x2]`centroid) ~ fft_aggregated[x2][0]
(.ml.fresh.feat.fftaggreg[x2]`variance) ~ fft_aggregated[x2][1]
(.ml.fresh.feat.fftaggreg[xnull]`centroid) ~ 0n
(.ml.fresh.feat.fftaggreg[xnull]`variance) ~ 0n

(value .ml.fresh.feat.augfuller[xj]) ~ "f"$augmented_dickey_fuller[xj][0 1 2]
(value .ml.fresh.feat.augfuller[xf]) ~ "f"$augmented_dickey_fuller[xf][0 1 2]
(value .ml.fresh.feat.augfuller[xi]) ~ "f"$augmented_dickey_fuller[xi][0 1 2]
(value .ml.fresh.feat.augfuller[xb]) ~ "f"$augmented_dickey_fuller[xb][0 1 2]
(value .ml.fresh.feat.augfuller[x0]) ~ 3#0n
(value .ml.fresh.feat.augfuller[x1]) ~ 3#0n
(value .ml.fresh.feat.augfuller[x2]) ~ 3#0n
(value .ml.fresh.feat.augfuller[xnull]) ~ 3#0n

(.ml.fresh.feat.spktwelch[xj;til 100]) ~ spkt_welch_density[xj;til 100]
(.ml.fresh.feat.spktwelch[xf;til 100]) ~ spkt_welch_density[xf;til 100]
(.ml.fresh.feat.spktwelch[xi;til 100]) ~ spkt_welch_density[xi;til 100]
(.ml.fresh.feat.spktwelch[xb;til 100]) ~ spkt_welch_density[xb;til 100]
(.ml.fresh.feat.spktwelch[xnull;til 100]) ~ 100#0n

(.ml.fresh.feat.spktwelch[xj;k]) ~ spkt_welch_density[xj;k]
(.ml.fresh.feat.spktwelch[xf;k]) ~ spkt_welch_density[xf;k]
(.ml.fresh.feat.spktwelch[xi;k]) ~ spkt_welch_density[xi;k]
(.ml.fresh.feat.spktwelch[xb;k]) ~ spkt_welch_density[xb;k]
(.ml.fresh.feat.spktwelch[xnull;k]) ~ 100#0n

fft_coefficient[xj;`abs;0]~.ml.fresh.feat.fftcoeff[xj;1]`coeff_0_abs
fft_coefficient[xj;`abs;49]~.ml.fresh.feat.fftcoeff[xj;50]`coeff_49_abs
fft_coefficient[xj;`real;0]~.ml.fresh.feat.fftcoeff[xj;1]`coeff_0_real
fft_coefficient[xj;`real;49]~.ml.fresh.feat.fftcoeff[xj;50]`coeff_49_real
fft_coefficient[xj;`angle;0]~.ml.fresh.feat.fftcoeff[xj;1]`coeff_0_angle
fft_coefficient[xj;`angle;49]~.ml.fresh.feat.fftcoeff[xj;50]`coeff_49_angle
fft_coefficient[xj;`imag;0]~.ml.fresh.feat.fftcoeff[xj;1]`coeff_0_imag
fft_coefficient[xj;`imag;49]~.ml.fresh.feat.fftcoeff[xj;50]`coeff_49_imag
fft_coefficient[xf;`abs;0]~.ml.fresh.feat.fftcoeff[xf;1]`coeff_0_abs
fft_coefficient[xf;`abs;49]~.ml.fresh.feat.fftcoeff[xf;50]`coeff_49_abs
fft_coefficient[xf;`real;0]~.ml.fresh.feat.fftcoeff[xf;1]`coeff_0_real
fft_coefficient[xf;`real;49]~.ml.fresh.feat.fftcoeff[xf;50]`coeff_49_real
fft_coefficient[xf;`angle;0]~.ml.fresh.feat.fftcoeff[xf;1]`coeff_0_angle
fft_coefficient[xf;`angle;49]~.ml.fresh.feat.fftcoeff[xf;50]`coeff_49_angle
fft_coefficient[xf;`imag;0]~.ml.fresh.feat.fftcoeff[xf;1]`coeff_0_imag
fft_coefficient[xf;`imag;49]~.ml.fresh.feat.fftcoeff[xf;50]`coeff_49_imag
fft_coefficient[xi;`abs;0]~.ml.fresh.feat.fftcoeff[xi;1]`coeff_0_abs
fft_coefficient[xi;`abs;49]~.ml.fresh.feat.fftcoeff[xi;50]`coeff_49_abs
fft_coefficient[xi;`real;0]~.ml.fresh.feat.fftcoeff[xi;1]`coeff_0_real
fft_coefficient[xi;`real;49]~.ml.fresh.feat.fftcoeff[xi;50]`coeff_49_real
fft_coefficient[xi;`angle;0]~.ml.fresh.feat.fftcoeff[xi;1]`coeff_0_angle
fft_coefficient[xi;`angle;49]~.ml.fresh.feat.fftcoeff[xi;50]`coeff_49_angle
fft_coefficient[xi;`imag;0]~.ml.fresh.feat.fftcoeff[xi;1]`coeff_0_imag
fft_coefficient[xi;`imag;49]~.ml.fresh.feat.fftcoeff[xi;50]`coeff_49_imag
fft_coefficient[xb;`abs;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_abs
fft_coefficient[xb;`abs;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_abs
fft_coefficient[xb;`real;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_real
fft_coefficient[xb;`real;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_real
fft_coefficient[xb;`angle;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_angle
fft_coefficient[xb;`angle;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_angle
fft_coefficient[xb;`imag;0]~.ml.fresh.feat.fftcoeff[xb;1]`coeff_0_imag
fft_coefficient[xb;`imag;49]~.ml.fresh.feat.fftcoeff[xb;50]`coeff_49_imag

(.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_abs) ~ 0n
(.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_real) ~ 0n
(.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_angle) ~ 0n
(.ml.fresh.feat.fftcoeff[xnull;50]`coeff_49_imag) ~ 0n 

/
(value[.ml.fresh.feat.fftaggreg[xb]]0 1 2) ~ fft_aggregated[xb] 0 1 2
fftaggreg[xj][3] ~ fft_aggregated[xj][3]
fftaggreg[xf][2] ~ fft_aggregated[xf][2]
fftaggreg[xf][3] ~ fft_aggregated[xf][3]
\
