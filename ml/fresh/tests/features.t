/
The following code is used to test the outputs from the functions written in q based on the functions
that are present in the tsfresh documentation. It should be noted that for large lists of values some of the functions which include exponentials suffer from overflow namely skewness,kurtosis and absenergy   
\

\l ml.q
\l fresh/init.q
\l fresh/tests/test.p

xj:10000?10000;
xi:1000?1000i;
xf:10000?50000f;
xh:10000?5000h;
xb:10000#0101101011b;
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
xs:enlist 1f

autocorrkeys:`mean`var`median`std
changequantkeys:`max`min`mean`var`median`std

np:.p.import[`numpy] 

.ml.fresh.feat.hasDup[xj] ~ .p.get[`hasduplicate;<]xj
.ml.fresh.feat.hasDup[xf] ~ .p.get[`hasduplicate;<]xf
.ml.fresh.feat.hasDup[xb] ~ .p.get[`hasduplicate;<]xb
.ml.fresh.feat.hasDup[xi] ~ .p.get[`hasduplicate;<]xi
.ml.fresh.feat.hasDup[x0] ~ .p.get[`hasduplicate;<]x0
.ml.fresh.feat.hasDup[x1] ~ .p.get[`hasduplicate;<]x1
.ml.fresh.feat.hasDup[x2] ~ .p.get[`hasduplicate;<]x2
.ml.fresh.feat.hasDupMin[xj] ~ .p.get[`hasduplicatemin;<]xj
.ml.fresh.feat.hasDupMin[xf] ~ .p.get[`hasduplicatemin;<]xf
.ml.fresh.feat.hasDupMin[xi] ~ .p.get[`hasduplicatemin;<]xi
.ml.fresh.feat.hasDupMin[xb] ~ .p.get[`hasduplicatemin;<]xb
.ml.fresh.feat.hasDupMin[x0] ~ 0b
.ml.fresh.feat.hasDupMin[x1] ~ .p.get[`hasduplicatemin;<]x1
.ml.fresh.feat.hasDupMin[x2] ~ .p.get[`hasduplicatemin;<]x2
.ml.fresh.feat.hasDupMax[xj] ~ .p.get[`hasduplicatemax;<]xj
.ml.fresh.feat.hasDupMax[xf] ~ .p.get[`hasduplicatemax;<]xf
.ml.fresh.feat.hasDupMax[xi] ~ .p.get[`hasduplicatemax;<]xi
.ml.fresh.feat.hasDupMax[xb] ~ .p.get[`hasduplicatemax;<]xb
.ml.fresh.feat.hasDupMax[x0] ~ 0b
.ml.fresh.feat.hasDupMax[x1] ~ .p.get[`hasduplicatemax;<]x1
.ml.fresh.feat.hasDupMax[x2] ~ .p.get[`hasduplicatemax;<]x2
.ml.fresh.feat.hasDup[xmixf] ~ 1b
.ml.fresh.feat.hasDupMin[xmixf] ~ .p.get[`hasduplicatemin;<]xmixf
.ml.fresh.feat.hasDupMax[xmixf] ~ .p.get[`hasduplicatemax;<]xmixf
.ml.fresh.feat.hasDup[xnull] ~ 1b
.ml.fresh.feat.hasDupMin[xnull] ~ 0b
.ml.fresh.feat.hasDupMax[xnull] ~ 0b

.ml.fresh.feat.absEnergy[xj] ~ "f"$.p.get[`abs_energy;<][xj]
.ml.fresh.feat.absEnergy[xf] ~ .p.get[`abs_energy;<][xf]
.ml.fresh.feat.absEnergy[xb] ~ "f"$.p.get[`abs_energy;<][xb]
.ml.fresh.feat.absEnergy[xi] = "f"$.p.get[`abs_energy;<][xi]
.ml.fresh.feat.absEnergy[x0] ~ "f"$.p.get[`abs_energy;<][x0]
.ml.fresh.feat.absEnergy[x1] ~ "f"$.p.get[`abs_energy;<][x1]
.ml.fresh.feat.absEnergy[x2] ~ "f"$.p.get[`abs_energy;<][x2]
.ml.fresh.feat.absEnergy[xmixf] ~ sum l*l:xmixf
.ml.fresh.feat.absEnergy[xnull] ~ 0f

.ml.fresh.feat.meanChange[xj] ~ .p.get[`mean_change;<][xj]
.ml.fresh.feat.meanChange[xf] ~ .p.get[`mean_change;<][xf]
.ml.fresh.feat.meanChange[xi] ~ .p.get[`mean_change;<][xi]
.ml.fresh.feat.meanChange[x0] ~ .p.get[`mean_change;<][x0]
.ml.fresh.feat.meanChange[x1] ~ .p.get[`mean_change;<][x1]
.ml.fresh.feat.meanChange[x2] ~ .p.get[`mean_change;<][x2]
/.ml.fresh.feat.meanChange[xb] ~ .p.get[`mean_change;<][xb]

.ml.fresh.feat.absSumChange[xj] ~ .p.get[`absolute_sum_of_changes;<][xj]
.ml.fresh.feat.absSumChange[xf] ~ .p.get[`absolute_sum_of_changes;<][xf]
.ml.fresh.feat.absSumChange[xi] ~ "i"$.p.get[`absolute_sum_of_changes;<][xi]
.ml.fresh.feat.absSumChange[xb] ~ "i"$.p.get[`absolute_sum_of_changes;<][xb]
.ml.fresh.feat.absSumChange[x0] ~ 0f 
.ml.fresh.feat.absSumChange[x1] ~ .p.get[`absolute_sum_of_changes;<][x1]
.ml.fresh.feat.absSumChange[x2] ~ .p.get[`absolute_sum_of_changes;<][x2]
.ml.fresh.feat.absSumChange[xnull] ~ 0f

.ml.fresh.feat.meanAbsChange[xj] ~ .p.get[`mean_abs_change][xj]`
.ml.fresh.feat.meanAbsChange[xf] ~ .p.get[`mean_abs_change][xf]`
.ml.fresh.feat.meanAbsChange[xb] ~ .p.get[`mean_abs_change][xb]`
.ml.fresh.feat.meanAbsChange[xi] ~ .p.get[`mean_abs_change][xi]`
.ml.fresh.feat.meanAbsChange[x0] ~ 0n
.ml.fresh.feat.meanAbsChange[x1] ~ .p.get[`mean_abs_change][x1]`
.ml.fresh.feat.meanAbsChange[x2] ~ .p.get[`mean_abs_change][x2]`
.ml.fresh.feat.meanAbsChange[xnull] ~ 0n

.ml.fresh.feat.countAboveMean[xj] ~ "i"$.p.get[`count_above_mean][xj]`
.ml.fresh.feat.countAboveMean[xf] ~ "i"$.p.get[`count_above_mean][xf]`
.ml.fresh.feat.countAboveMean[xb] ~ "i"$.p.get[`count_above_mean][xb]`
.ml.fresh.feat.countAboveMean[xi] ~ "i"$.p.get[`count_above_mean][xi]`
.ml.fresh.feat.countAboveMean[x0] ~ "i"$.p.get[`count_above_mean][x0]`
.ml.fresh.feat.countAboveMean[x1] ~ "i"$.p.get[`count_above_mean][x1]`
.ml.fresh.feat.countAboveMean[x2] ~ "i"$.p.get[`count_above_mean][x2]`
.ml.fresh.feat.countAboveMean[xnull] ~ "i"$.p.get[`count_above_mean][xnull]`

.ml.fresh.feat.countBelowMean[xj] ~ "i"$.p.get[`count_below_mean][xj]`
.ml.fresh.feat.countBelowMean[xf] ~ "i"$.p.get[`count_below_mean][xf]`
.ml.fresh.feat.countBelowMean[xb] ~ "i"$.p.get[`count_below_mean][xb]`
.ml.fresh.feat.countBelowMean[xi] ~ "i"$.p.get[`count_below_mean][xi]`
.ml.fresh.feat.countBelowMean[x0] ~ "i"$.p.get[`count_below_mean][x0]`
.ml.fresh.feat.countBelowMean[x1] ~ "i"$.p.get[`count_below_mean][x1]`
.ml.fresh.feat.countBelowMean[x2] ~ "i"$.p.get[`count_below_mean][x2]`
.ml.fresh.feat.countBelowMean[xnull] ~ "i"$.p.get[`count_below_mean][xnull]`

.ml.fresh.feat.firstMax[xj] ~ .p.get[`first_location_of_maximum][xj]`
.ml.fresh.feat.firstMax[xf] ~ .p.get[`first_location_of_maximum][xf]`
.ml.fresh.feat.firstMax[xb] ~ .p.get[`first_location_of_maximum][xb]`
.ml.fresh.feat.firstMax[xi] ~ .p.get[`first_location_of_maximum][xi]`
.ml.fresh.feat.firstMax[x0] ~ 0n
.ml.fresh.feat.firstMax[x1] ~ .p.get[`first_location_of_maximum][x1]`
.ml.fresh.feat.firstMax[x2] ~ .p.get[`first_location_of_maximum][x2]`
.ml.fresh.feat.firstMax[xnull] ~ 1f

.ml.fresh.feat.firstMin[xj] ~ .p.get[`first_location_of_minimum][xj]`
.ml.fresh.feat.firstMin[xf] ~ .p.get[`first_location_of_minimum][xf]`
.ml.fresh.feat.firstMin[xb] ~ .p.get[`first_location_of_minimum][xb]`
.ml.fresh.feat.firstMin[xi] ~ .p.get[`first_location_of_minimum][xi]`
.ml.fresh.feat.firstMin[x0] ~ 0n
.ml.fresh.feat.firstMin[x1] ~ .p.get[`first_location_of_minimum][x1]`
.ml.fresh.feat.firstMin[x2] ~ .p.get[`first_location_of_minimum][x2]`
.ml.fresh.feat.firstMin[xnull] ~ 1f

.ml.fresh.feat.ratioValNumToSeriesLength[xj] ~ .p.get[`ratio_val_num_to_t_series][xj]`
.ml.fresh.feat.ratioValNumToSeriesLength[xf] ~ .p.get[`ratio_val_num_to_t_series][xf]`
.ml.fresh.feat.ratioValNumToSeriesLength[xb] ~ .p.get[`ratio_val_num_to_t_series][xb]`
.ml.fresh.feat.ratioValNumToSeriesLength[xi] ~ .p.get[`ratio_val_num_to_t_series][xi]`
.ml.fresh.feat.ratioValNumToSeriesLength[x0] ~ 0n
.ml.fresh.feat.ratioValNumToSeriesLength[x1] ~ .p.get[`ratio_val_num_to_t_series][x1]`
.ml.fresh.feat.ratioValNumToSeriesLength[x2] ~ .p.get[`ratio_val_num_to_t_series][x2]`
.ml.fresh.feat.ratioValNumToSeriesLength[xnull] ~ 0.0001

.ml.fresh.feat.ratioBeyondRSigma[xj;0.2] ~ .p.get[`ratio_beyond_r_sigma][xj;0.2]`
.ml.fresh.feat.ratioBeyondRSigma[xj;2.0] ~ .p.get[`ratio_beyond_r_sigma][xj;2.0]`
.ml.fresh.feat.ratioBeyondRSigma[xj;10] ~ .p.get[`ratio_beyond_r_sigma][xj;10]`
.ml.fresh.feat.ratioBeyondRSigma[xf;0.2] ~ .p.get[`ratio_beyond_r_sigma][xf;0.2]`
.ml.fresh.feat.ratioBeyondRSigma[xf;2.0] ~ .p.get[`ratio_beyond_r_sigma][xf;2.0]`
.ml.fresh.feat.ratioBeyondRSigma[xf;10] ~ .p.get[`ratio_beyond_r_sigma][xf;10]`
.ml.fresh.feat.ratioBeyondRSigma[xi;0.2] ~ .p.get[`ratio_beyond_r_sigma][xi;0.2]`
.ml.fresh.feat.ratioBeyondRSigma[xi;2.0] ~ .p.get[`ratio_beyond_r_sigma][xi;2.0]`
.ml.fresh.feat.ratioBeyondRSigma[xi;10] ~ .p.get[`ratio_beyond_r_sigma][xi;10]`
.ml.fresh.feat.ratioBeyondRSigma[xb;0.2] ~ .p.get[`ratio_beyond_r_sigma][xb;0.2]`
.ml.fresh.feat.ratioBeyondRSigma[xb;2.0] ~ .p.get[`ratio_beyond_r_sigma][xb;2.0]`
.ml.fresh.feat.ratioBeyondRSigma[xb;10] ~ .p.get[`ratio_beyond_r_sigma][xb;10]`
.ml.fresh.feat.ratioBeyondRSigma[x0;0.2] ~ 0n
.ml.fresh.feat.ratioBeyondRSigma[x0;2.0] ~ 0n
.ml.fresh.feat.ratioBeyondRSigma[x0;10] ~ 0n
.ml.fresh.feat.ratioBeyondRSigma[x1;0.2] ~ .p.get[`ratio_beyond_r_sigma][x1;0.2]`
.ml.fresh.feat.ratioBeyondRSigma[x1;2.0] ~ .p.get[`ratio_beyond_r_sigma][x1;2.0]`
.ml.fresh.feat.ratioBeyondRSigma[x1;10] ~ .p.get[`ratio_beyond_r_sigma][x1;10]`
.ml.fresh.feat.ratioBeyondRSigma[x2;0.2] ~ .p.get[`ratio_beyond_r_sigma][x2;0.2]`
.ml.fresh.feat.ratioBeyondRSigma[x2;2.0] ~ .p.get[`ratio_beyond_r_sigma][x2;2.0]`
.ml.fresh.feat.ratioBeyondRSigma[x2;10] ~ .p.get[`ratio_beyond_r_sigma][x2;10]`
.ml.fresh.feat.ratioBeyondRSigma[xnull;0.2] ~ 0f
.ml.fresh.feat.ratioBeyondRSigma[xnull;2.0] ~ 0f
.ml.fresh.feat.ratioBeyondRSigma[xnull;10] ~ 0f

.ml.fresh.feat.perRecurToAllData[xj] ~ .p.get[`percentage_recurring_all_data][xj]`
.ml.fresh.feat.perRecurToAllData[xf] ~ .p.get[`percentage_recurring_all_data][xf]`
.ml.fresh.feat.perRecurToAllData[xb] ~ .p.get[`percentage_recurring_all_data][xb]`
.ml.fresh.feat.perRecurToAllData[xi] ~ .p.get[`percentage_recurring_all_data][xi]`
.ml.fresh.feat.perRecurToAllData[x1] ~ .p.get[`percentage_recurring_all_data][x1]`
.ml.fresh.feat.perRecurToAllData[x2] ~ .p.get[`percentage_recurring_all_data][x2]`
.ml.fresh.feat.perRecurToAllData[xnull] ~ 1f

.ml.fresh.feat.perRecurToAllVal[xj] ~ .p.get[`percentage_recurring_all_val][xj]`
.ml.fresh.feat.perRecurToAllVal[xf] ~ .p.get[`percentage_recurring_all_val][xf]`
.ml.fresh.feat.perRecurToAllVal[xb] ~ .p.get[`percentage_recurring_all_val][xb]`
.ml.fresh.feat.perRecurToAllVal[xi] ~ .p.get[`percentage_recurring_all_val][xi]`
.ml.fresh.feat.perRecurToAllVal[x1] ~ .p.get[`percentage_recurring_all_val][x1]`
.ml.fresh.feat.perRecurToAllVal[x2] ~ .p.get[`percentage_recurring_all_val][x2]`
.ml.fresh.feat.perRecurToAllVal[xnull] ~ 1f

.ml.fresh.feat.largestDev[xj;0.5] ~ .p.get[`large_standard_deviation][xj;0.5]`
.ml.fresh.feat.largestDev[xj;5.0] ~ .p.get[`large_standard_deviation][xj;5.0]`
.ml.fresh.feat.largestDev[xj;1] ~ .p.get[`large_standard_deviation][xj;1]`
.ml.fresh.feat.largestDev[xf;0.5] ~ .p.get[`large_standard_deviation][xf;0.5]`
.ml.fresh.feat.largestDev[xf;5.0] ~ .p.get[`large_standard_deviation][xf;5.0]`
.ml.fresh.feat.largestDev[xf;1] ~ .p.get[`large_standard_deviation][xf;1]`
.ml.fresh.feat.largestDev[xi;0.5] ~ .p.get[`large_standard_deviation][xi;0.5]`
.ml.fresh.feat.largestDev[xi;5.0] ~ .p.get[`large_standard_deviation][xi;5.0]`
.ml.fresh.feat.largestDev[xi;1] ~ .p.get[`large_standard_deviation][xi;1]`
.ml.fresh.feat.largestDev[x0;0.5] ~ 0b
.ml.fresh.feat.largestDev[x0;5.0] ~ 0b
.ml.fresh.feat.largestDev[x0;1] ~ 0b
.ml.fresh.feat.largestDev[x1;0.5] ~ 0b
.ml.fresh.feat.largestDev[x1;5.0] ~ 0b
.ml.fresh.feat.largestDev[x1;1] ~ 0b
.ml.fresh.feat.largestDev[x2;0.5] ~ 0b
.ml.fresh.feat.largestDev[x2;5.0] ~ 0b
.ml.fresh.feat.largestDev[x2;1] ~ 0b
.ml.fresh.feat.largestDev[xb;0.5] ~ 0b
.ml.fresh.feat.largestDev[xb;5.0] ~ 0b
.ml.fresh.feat.largestDev[xb;1] ~ 0b
.ml.fresh.feat.largestDev[xnull;0.5] ~ .p.get[`large_standard_deviation][xnull;0.5]`
.ml.fresh.feat.largestDev[xnull;5.0] ~ .p.get[`large_standard_deviation][xnull;5.0]`
.ml.fresh.feat.largestDev[xnull;1] ~ .p.get[`large_standard_deviation][xnull;1]`

.ml.fresh.feat.valCount[xj;yint] ~ "i"$.p.get[`value_count][xj;yint]`
.ml.fresh.feat.valCount[xf;yfloat] ~ "i"$.p.get[`value_count][xf;yfloat]`
.ml.fresh.feat.valCount[xb;yint] ~ "i"$.p.get[`value_count][xb;yint]`
.ml.fresh.feat.valCount[xb;yfloat] ~ "i"$.p.get[`value_count][xb;yfloat]`
.ml.fresh.feat.valCount[xi;yint] ~ "i"$.p.get[`value_count][xi;yint]`
.ml.fresh.feat.valCount[xi;yfloat] ~ "i"$.p.get[`value_count][xi;yfloat]`
.ml.fresh.feat.valCount[x0;yint] ~ "i"$.p.get[`value_count][x0;yint]`
.ml.fresh.feat.valCount[x0;yfloat] ~ "i"$.p.get[`value_count][x0;yfloat]`
.ml.fresh.feat.valCount[x1;yint] ~ "i"$.p.get[`value_count][x1;yint]`
.ml.fresh.feat.valCount[x1;yfloat] ~ "i"$.p.get[`value_count][x1;yfloat]`
.ml.fresh.feat.valCount[x2;yint] ~ "i"$.p.get[`value_count][x2;yint]`
.ml.fresh.feat.valCount[x2;yfloat] ~ "i"$.p.get[`value_count][x2;yfloat]`
.ml.fresh.feat.valCount[xnull;yint] ~ "i"$.p.get[`value_count][xnull;yint]`
.ml.fresh.feat.valCount[xnull;yfloat] ~ "i"$.p.get[`value_count][xnull;yfloat]`

.ml.fresh.feat.cidCe[xj;0b] ~ .p.get[`cid_ce][xj;0b]`
.ml.fresh.feat.cidCe[xf;0b] ~ .p.get[`cid_ce][xf;0b]`
.ml.fresh.feat.cidCe[xb;0b] ~ .p.get[`cid_ce][xb;0b]`
.ml.fresh.feat.cidCe[xi;0b] ~ .p.get[`cid_ce][xi;0b]`
.ml.fresh.feat.cidCe[x0;0b] ~ .p.get[`cid_ce][x0;0b]`
.ml.fresh.feat.cidCe[x1;0b] ~ .p.get[`cid_ce][x1;0b]`
.ml.fresh.feat.cidCe[x2;0b] ~ .p.get[`cid_ce][x2;0b]`
.ml.fresh.feat.cidCe[xnull;0b] ~ 0n
.ml.fresh.feat.cidCe[xj;1b] ~ .p.get[`cid_ce][xj;1b]`
.ml.fresh.feat.cidCe[xf;1b] ~ .p.get[`cid_ce][xf;1b]`
.ml.fresh.feat.cidCe[xb;1b] ~ .p.get[`cid_ce][xb;1b]`
.ml.fresh.feat.cidCe[xi;1b] ~ .p.get[`cid_ce][xi;1b]`
.ml.fresh.feat.cidCe[x0;1b] ~ .p.get[`cid_ce][x0;1b]`
.ml.fresh.feat.cidCe[x1;0b] ~ .p.get[`cid_ce][x1;0b]`
.ml.fresh.feat.cidCe[x2;0b] ~ .p.get[`cid_ce][x2;0b]`
.ml.fresh.feat.cidCe[xnull;1b] ~ 0n

.ml.fresh.feat.mean2DerCentral[xj] ~ .p.get[`mean_second_derivative_central][xj]`
.ml.fresh.feat.mean2DerCentral[xf] ~ .p.get[`mean_second_derivative_central][xf]`
.ml.fresh.feat.mean2DerCentral[xi] ~ .p.get[`mean_second_derivative_central][xi]`
.ml.fresh.feat.mean2DerCentral[xb] ~ 0f
.ml.fresh.feat.mean2DerCentral[x0] ~ 0n
.ml.fresh.feat.mean2DerCentral[x1] ~ 0n
.ml.fresh.feat.mean2DerCentral[x2] ~ 0n
.ml.fresh.feat.mean2DerCentral[xnull] ~ 0n

.ml.fresh.feat.skewness[xj] ~ .p.get[`skewness_py;<][xj]
(.ml.fresh.feat.skewness[xf] - .p.get[`skewness_py;<][xf])<1e-13
.ml.fresh.feat.skewness[xb] ~ .p.get[`skewness_py;<][xb]
.ml.fresh.feat.skewness[xi] ~ .p.get[`skewness_py;<][xi]
.ml.fresh.feat.skewness[x0] ~ 0n
.ml.fresh.feat.skewness[x1] ~ 0n
.ml.fresh.feat.skewness[x2] ~ 0n
.ml.fresh.feat.skewness[xnull] ~ 0n

.ml.fresh.feat.kurtosis[xj] ~ .p.get[`kurtosis_py][xj]`
.ml.fresh.feat.kurtosis[xf] ~ .p.get[`kurtosis_py][xf]`
.ml.fresh.feat.kurtosis[xb] ~ .p.get[`kurtosis_py][xb]`
.ml.fresh.feat.kurtosis[xi] ~ .p.get[`kurtosis_py][xi]`
.ml.fresh.feat.kurtosis[x0] ~ 0n
.ml.fresh.feat.kurtosis[x1] ~ 0n
.ml.fresh.feat.kurtosis[x2] ~ 0n
.ml.fresh.feat.kurtosis[xnull] ~ 0n

.ml.fresh.feat.longStrikeBelowMean[xj] ~ .p.get[`longest_strike_below_mean;<][xj]
.ml.fresh.feat.longStrikeBelowMean[xf] ~ .p.get[`longest_strike_below_mean;<][xf]
.ml.fresh.feat.longStrikeBelowMean[xb] ~ .p.get[`longest_strike_below_mean;<][xb]
.ml.fresh.feat.longStrikeBelowMean[xi] ~ .p.get[`longest_strike_below_mean;<][xi]
.ml.fresh.feat.longStrikeBelowMean[x0] ~ .p.get[`longest_strike_below_mean;<][x0]
("f"$.ml.fresh.feat.longStrikeBelowMean[x1]) ~ 0f
.ml.fresh.feat.longStrikeBelowMean[x2] ~ .p.get[`longest_strike_below_mean;<][x2]
.ml.fresh.feat.longStrikeBelowMean[xnull] ~ .p.get[`longest_strike_below_mean;<][xnull]

.ml.fresh.feat.longStrikeAboveMean[xj] ~ .p.get[`longest_strike_above_mean;<][xj]
.ml.fresh.feat.longStrikeAboveMean[xf] ~ .p.get[`longest_strike_above_mean;<][xf]
.ml.fresh.feat.longStrikeAboveMean[xb] ~ .p.get[`longest_strike_above_mean;<][xb]
.ml.fresh.feat.longStrikeAboveMean[xi] ~ .p.get[`longest_strike_above_mean;<][xi]
.ml.fresh.feat.longStrikeAboveMean[x0] ~ .p.get[`longest_strike_above_mean;<][x0]
("f"$.ml.fresh.feat.longStrikeAboveMean[x1]) ~ 0f
.ml.fresh.feat.longStrikeAboveMean[x2] ~ .p.get[`longest_strike_above_mean;<][x2]
.ml.fresh.feat.longStrikeAboveMean[xnull] ~ .p.get[`longest_strike_above_mean;<][xnull]

.ml.fresh.feat.sumRecurringVal[xj] ~ .p.get[`sum_recurring_values;<][xj]
.ml.fresh.feat.sumRecurringVal[xf] ~ .p.get[`sum_recurring_values;<][xf]
.ml.fresh.feat.sumRecurringVal[xi] ~ "i"$.p.get[`sum_recurring_values;<][xi]
.ml.fresh.feat.sumRecurringVal[xb] ~ "i"$.p.get[`sum_recurring_values;<][xb]
.ml.fresh.feat.sumRecurringVal[x1] ~ .p.get[`sum_recurring_values;<][x1]
.ml.fresh.feat.sumRecurringVal[x2] ~ .p.get[`sum_recurring_values;<][x2]
.ml.fresh.feat.sumRecurringVal[x0] ~ 0f
.ml.fresh.feat.sumRecurringVal[xnull] ~ 0f

.ml.fresh.feat.sumRecurringDataPoint[xj] ~ .p.get[`sum_recurring_data_points;<][xj]
.ml.fresh.feat.sumRecurringDataPoint[xf] ~ .p.get[`sum_recurring_data_points;<][xf]
.ml.fresh.feat.sumRecurringDataPoint[xb] ~ .p.get[`sum_recurring_data_points;<][xb]
.ml.fresh.feat.sumRecurringDataPoint[xi] ~ .p.get[`sum_recurring_data_points;<][xi]
.ml.fresh.feat.sumRecurringDataPoint[x1] ~ .p.get[`sum_recurring_data_points;<][x1]
.ml.fresh.feat.sumRecurringDataPoint[x2] ~ .p.get[`sum_recurring_data_points;<][x2]
.ml.fresh.feat.sumRecurringDataPoint[xnull] ~ 0f

.ml.fresh.feat.c3[xj;2] ~ .p.get[`c3_py;<][xj;2]
.ml.fresh.feat.c3[xf;4] ~ .p.get[`c3_py;<][xf;4]
.ml.fresh.feat.c3[xi;4] ~ .p.get[`c3_py;<][xi;4]
("i"$100*.ml.fresh.feat.c3[xb;4]) ~ "i"$100*.p.get[`c3_py;<][xb;4]
.ml.fresh.feat.c3[x0;4] ~ 0n
.ml.fresh.feat.c3[x1;4] ~ 0n
.ml.fresh.feat.c3[x2;4] ~ 0n
.ml.fresh.feat.c3[xnull;4] ~ 0n

.ml.fresh.feat.varAboveStdDev[xj] ~ .p.get[`variance_larger_than_standard_deviation;<][xj]
.ml.fresh.feat.varAboveStdDev[xf] ~ .p.get[`variance_larger_than_standard_deviation;<][xf] 
.ml.fresh.feat.varAboveStdDev[xb] ~ .p.get[`variance_larger_than_standard_deviation;<][xb]
.ml.fresh.feat.varAboveStdDev[xi] ~ .p.get[`variance_larger_than_standard_deviation;<][xi]
.ml.fresh.feat.varAboveStdDev[x0] ~ 0b
.ml.fresh.feat.varAboveStdDev[x1] ~ .p.get[`variance_larger_than_standard_deviation;<][x1]
.ml.fresh.feat.varAboveStdDev[x2] ~ .p.get[`variance_larger_than_standard_deviation;<][x2]
.ml.fresh.feat.varAboveStdDev[xnull] ~ 0b

.ml.fresh.feat.numCwtPeaks[xj;3] ~ .p.get[`number_cwt_peaks;<][xj;3]
.ml.fresh.feat.numCwtPeaks[xf;3] ~ .p.get[`number_cwt_peaks;<][xf;3]
.ml.fresh.feat.numCwtPeaks[xb;3] ~ .p.get[`number_cwt_peaks;<][xb;3]
.ml.fresh.feat.numCwtPeaks[xi;3] ~ .p.get[`number_cwt_peaks;<][xi;3]
.ml.fresh.feat.numCwtPeaks[x1;3] ~ .p.get[`number_cwt_peaks;<][x1;3]
.ml.fresh.feat.numCwtPeaks[x2;3] ~ .p.get[`number_cwt_peaks;<][x2;3]
.ml.fresh.feat.numCwtPeaks[xnull;3] ~ .p.get[`number_cwt_peaks;<][xnull;3]

/For the testing of quantiles the 'y' argument must be in the range [0;1] by definition
.ml.fresh.feat.quantile[xj;0.5] ~ .p.get[`quantile_py;<][xj;0.5]
.ml.fresh.feat.quantile[xf;0.5] ~ .p.get[`quantile_py;<][xf;0.5]
.ml.fresh.feat.quantile[xb;0.5] ~ .p.get[`quantile_py;<]["f"$xb;0.5]
.ml.fresh.feat.quantile[xi;0.5] ~ .p.get[`quantile_py;<][xi;0.5]
.ml.fresh.feat.quantile[x0;0.5] ~ 0f
.ml.fresh.feat.quantile[x1;0.5] ~ .p.get[`quantile_py;<][x1;0.5]
.ml.fresh.feat.quantile[x2;0.5] ~ .p.get[`quantile_py;<][x2;0.5]
.ml.fresh.feat.quantile[xnull;0.5] ~ 0f

.ml.fresh.feat.numCrossing[xj;350] ~ "i"$.p.get[`number_crossing_m;<][xj;350]
.ml.fresh.feat.numCrossing[xf;350] ~ "i"$.p.get[`number_crossing_m;<][xf;350]
.ml.fresh.feat.numCrossing[xb;350] ~ "i"$.p.get[`number_crossing_m;<][xb;350]
.ml.fresh.feat.numCrossing[xi;350] ~ "i"$.p.get[`number_crossing_m;<][xi;350]
.ml.fresh.feat.numCrossing[x0;350] ~ "i"$.p.get[`number_crossing_m;<][x0;350]
.ml.fresh.feat.numCrossing[x1;350] ~ "i"$.p.get[`number_crossing_m;<][x1;350]
.ml.fresh.feat.numCrossing[x2;350] ~ "i"$.p.get[`number_crossing_m;<][x2;350]
.ml.fresh.feat.numCrossing[xnull;350] ~ "i"$.p.get[`number_crossing_m;<][xnull;350]

.ml.fresh.feat.binnedEntropy[xj;50] ~ .p.get[`binned_entropy;<][xj;50]
.ml.fresh.feat.binnedEntropy[xf;50] ~ .p.get[`binned_entropy;<][xf;50]
.ml.fresh.feat.binnedEntropy[xi;50] ~ .p.get[`binned_entropy;<][xi;50]
.ml.fresh.feat.binnedEntropy[x1;50] ~ .p.get[`binned_entropy;<][x1;50]
.ml.fresh.feat.binnedEntropy[x2;50] ~ .p.get[`binned_entropy;<][x2;50]
abs[.ml.fresh.feat.binnedEntropy[xnull;50]] ~ 0f

.ml.fresh.feat.autoCorr[xf;50] ~ .p.get[`autocorrelation][xf;50]`
.ml.fresh.feat.autoCorr[xj;50] ~ .p.get[`autocorrelation][xj;50]`
.ml.fresh.feat.autoCorr[xi;50] ~ .p.get[`autocorrelation][xi;50]`
.ml.fresh.feat.autoCorr[x0;50] ~ 0n
.ml.fresh.feat.autoCorr[x1;50] ~ 0n
.ml.fresh.feat.autoCorr[x2;50] ~ 0n
.ml.fresh.feat.autoCorr[xnull;50] ~ 0n

.ml.fresh.feat.numPeaks[xj;1] ~ "i"$.p.get[`number_peaks;<][xj;1]
.ml.fresh.feat.numPeaks[xj;4] ~ "i"$.p.get[`number_peaks;<][xj;4]
.ml.fresh.feat.numPeaks[xf;1] ~ "i"$.p.get[`number_peaks;<][xf;1]
.ml.fresh.feat.numPeaks[xf;4] ~ "i"$.p.get[`number_peaks;<][xf;4]
.ml.fresh.feat.numPeaks[xb;1] ~ "i"$.p.get[`number_peaks;<][xb;1]
.ml.fresh.feat.numPeaks[xb;4] ~ "i"$.p.get[`number_peaks;<][xb;4]
.ml.fresh.feat.numPeaks[xi;1] ~ "i"$.p.get[`number_peaks;<][xi;1]
.ml.fresh.feat.numPeaks[xi;4] ~ "i"$.p.get[`number_peaks;<][xi;4]
.ml.fresh.feat.numPeaks[x0;1] ~ "i"$.p.get[`number_peaks;<][x0;1]
.ml.fresh.feat.numPeaks[x0;4] ~ "i"$.p.get[`number_peaks;<][x0;4]
.ml.fresh.feat.numPeaks[x1;1] ~ "i"$.p.get[`number_peaks;<][x1;1]
.ml.fresh.feat.numPeaks[x1;4] ~ "i"$.p.get[`number_peaks;<][x1;4]
.ml.fresh.feat.numPeaks[x2;1] ~ "i"$.p.get[`number_peaks;<][x2;1]
.ml.fresh.feat.numPeaks[x2;4] ~ "i"$.p.get[`number_peaks;<][x2;4]
.ml.fresh.feat.numPeaks[xnull;1] ~ "i"$.p.get[`number_peaks;<][xnull;1]
.ml.fresh.feat.numPeaks[xnull;4] ~ "i"$.p.get[`number_peaks;<][xnull;4]

.ml.fresh.feat.rangeCount[xj;20;100] ~ "i"$.p.get[`range_count;<][xj;20;100]
.ml.fresh.feat.rangeCount[xf;20.1;100.0] ~ "i"$.p.get[`range_count;<][xf;20.1;100.0]
.ml.fresh.feat.rangeCount[xi;20;100] ~ "i"$.p.get[`range_count;<][xi;20;100]
.ml.fresh.feat.rangeCount[xb;20;100] ~ "i"$.p.get[`range_count;<][xb;20;100]
.ml.fresh.feat.rangeCount[x0;20;100] ~ "i"$.p.get[`range_count;<][x0;20;100]
.ml.fresh.feat.rangeCount[x1;20;100] ~ "i"$.p.get[`range_count;<][x1;20;100]
.ml.fresh.feat.rangeCount[x2;20;100] ~ "i"$.p.get[`range_count;<][x2;20;100]
.ml.fresh.feat.rangeCount[xnull;20;100] ~ "i"$.p.get[`range_count;<][xnull;20;100]

.ml.fresh.feat.treverseAsymStat[xj;2] ~ .p.get[`time_reversal_asymmetry_statistic;<][xj;2]
.ml.fresh.feat.treverseAsymStat[xf;2] ~ .p.get[`time_reversal_asymmetry_statistic;<][xf;2]
.ml.fresh.feat.treverseAsymStat[xi;2] ~ .p.get[`time_reversal_asymmetry_statistic;<][xi;2]
.ml.fresh.feat.treverseAsymStat[xb;2] ~ 0.0001
.ml.fresh.feat.treverseAsymStat[x0;2] ~ 0f
.ml.fresh.feat.treverseAsymStat[x1;2] ~ "f"$.p.get[`time_reversal_asymmetry_statistic;<][x1;2]
.ml.fresh.feat.treverseAsymStat[x2;2] ~ "f"$.p.get[`time_reversal_asymmetry_statistic;<][x2;2]
.ml.fresh.feat.treverseAsymStat[xnull;2] ~ 0f

.ml.fresh.feat.indexMassQuantile[xi;.6] ~ .p.get[`index_mass_quantile;<][xi;.6]
.ml.fresh.feat.indexMassQuantile[xj;1.] ~ .p.get[`index_mass_quantile;<][xj;1.]
.ml.fresh.feat.indexMassQuantile[xh;0.] ~ .p.get[`index_mass_quantile;<][xh;0.]
.ml.fresh.feat.indexMassQuantile[xi;x0] ~ x0

.ml.fresh.feat.lastMax[xi] ~ .p.get[`last_location_of_maximum;<][xi]
.ml.fresh.feat.lastMax[xj] ~ .p.get[`last_location_of_maximum;<][xj]
.ml.fresh.feat.lastMax[xf] ~ .p.get[`last_location_of_maximum;<][xf]
.ml.fresh.feat.lastMax[x0] ~ 0n
.ml.fresh.feat.lastMax[xs] ~ 0f

.ml.fresh.feat.lastMin[xi] ~ .p.get[`last_location_of_minimum;<][xi]
.ml.fresh.feat.lastMin[xj] ~ .p.get[`last_location_of_minimum;<][xj]
.ml.fresh.feat.lastMin[xf] ~ .p.get[`last_location_of_minimum;<][xf]
.ml.fresh.feat.lastMin[x0] ~ 0n
.ml.fresh.feat.lastMin[xs] ~ 0f

(value .ml.fresh.feat.changeQuant[xf;0.2;0.8;1b]) ~ .p.get[`change_quantiles;<][xf;0.2;0.8;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.25;0.7;1b]) ~ .p.get[`change_quantiles;<][xf;0.25;0.7;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.2;0.65;1b]) ~ .p.get[`change_quantiles;<][xf;0.2;0.65;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.2;0.775;1b]) ~ .p.get[`change_quantiles;<][xf;0.2;0.775;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.2;0.8;0b]) ~ .p.get[`change_quantiles;<][xf;0.2;0.8;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.25;0.7;0b]) ~ .p.get[`change_quantiles;<][xf;0.25;0.7;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.2;0.65;0b]) ~ .p.get[`change_quantiles;<][xf;0.2;0.65;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xf;0.2;0.775;0b]) ~ .p.get[`change_quantiles;<][xf;0.2;0.775;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.2;0.8;1b]) ~ .p.get[`change_quantiles;<][xj;0.2;0.8;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.25;0.7;1b]) ~ .p.get[`change_quantiles;<][xj;0.25;0.7;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.2;0.65;1b]) ~ .p.get[`change_quantiles;<][xj;0.2;0.65;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.2;0.775;1b]) ~ .p.get[`change_quantiles;<][xj;0.2;0.775;1b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.2;0.8;0b]) ~ .p.get[`change_quantiles;<][xj;0.2;0.8;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.25;0.7;0b]) ~ .p.get[`change_quantiles;<][xj;0.25;0.7;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.2;0.65;0b]) ~ .p.get[`change_quantiles;<][xj;0.2;0.65;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[xj;0.2;0.775;0b]) ~ .p.get[`change_quantiles;<][xj;0.2;0.775;0b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.2;0.8;1b]) = .p.get[`change_quantiles;<][xi;0.2;0.8;1b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.25;0.7;1b]) = .p.get[`change_quantiles;<][xi;0.25;0.7;1b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.2;0.65;1b]) = .p.get[`change_quantiles;<][xi;0.2;0.65;1b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.2;0.775;1b]) = .p.get[`change_quantiles;<][xi;0.2;0.775;1b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.2;0.8;0b]) = .p.get[`change_quantiles;<][xi;0.2;0.8;0b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.25;0.7;0b]) = .p.get[`change_quantiles;<][xi;0.25;0.7;0b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.2;0.65;0b]) = .p.get[`change_quantiles;<][xi;0.2;0.65;0b;]each changequantkeys
all (value .ml.fresh.feat.changeQuant[xi;0.2;0.775;0b]) = .p.get[`change_quantiles;<][xi;0.2;0.775;0b;]each changequantkeys
(value .ml.fresh.feat.changeQuant[x0;0.2;0.775;1b]) ~ (-0w 0w,4#0n)
(value .ml.fresh.feat.changeQuant[x1;0.2;0.775;1b]) ~ (-0w 0w,4#0n)
(value .ml.fresh.feat.changeQuant[x2;0.2;0.775;1b]) ~ (-0w 0w,4#0n)
(value .ml.fresh.feat.changeQuant[xnull;0.2;0.775;1b]) ~ (-0w 0w,4#0n)

(.ml.fresh.feat.linTrend[xj]`slope) ~ .p.get[`linear_trend][xj][`:slope]`
(.ml.fresh.feat.linTrend[xj]`intercept) ~ .p.get[`linear_trend][xj][`:intercept]`
(.ml.fresh.feat.linTrend[xj]`rval) ~ .p.get[`linear_trend][xj][`:rvalue]`
(.ml.fresh.feat.linTrend[xf]`slope) ~ .p.get[`linear_trend][xf][`:slope]`
(.ml.fresh.feat.linTrend[xf]`intercept) ~ .p.get[`linear_trend][xf][`:intercept]`
(.ml.fresh.feat.linTrend[xf]`rval) ~ .p.get[`linear_trend][xf][`:rvalue]`
(.ml.fresh.feat.linTrend[xb]`slope) ~ .p.get[`linear_trend][xb][`:slope]`
(.ml.fresh.feat.linTrend[xb]`intercept) ~ .p.get[`linear_trend][xb][`:intercept]`
(.ml.fresh.feat.linTrend[xb]`rval) ~ .p.get[`linear_trend][xb][`:rvalue]`
(.ml.fresh.feat.linTrend[xi]`slope) ~ .p.get[`linear_trend][xi][`:slope]`
(.ml.fresh.feat.linTrend[xi]`intercept) ~ .p.get[`linear_trend][xi][`:intercept]`
(.ml.fresh.feat.linTrend[xi]`rval) ~ .p.get[`linear_trend][xi][`:rvalue]`
(.ml.fresh.feat.linTrend[x0]`slope) ~ 0f
(.ml.fresh.feat.linTrend[x0]`intercept) ~ 0f
(.ml.fresh.feat.linTrend[x0]`rval) ~ 0f
(.ml.fresh.feat.linTrend[x1]`slope) ~ 0f
(.ml.fresh.feat.linTrend[x1]`intercept) ~ 0f
(.ml.fresh.feat.linTrend[x1]`rval) ~ 0f
(.ml.fresh.feat.linTrend[x2]`slope) ~ .p.get[`linear_trend][x2][`:slope]`
(.ml.fresh.feat.linTrend[x2]`intercept) ~ .p.get[`linear_trend][x2][`:intercept]`
(.ml.fresh.feat.linTrend[x2]`rval) ~ .p.get[`linear_trend][x2][`:rvalue]`
(.ml.fresh.feat.linTrend[xnull]`slope) ~ 0f
(.ml.fresh.feat.linTrend[xnull]`intercept) ~ 0f
(.ml.fresh.feat.linTrend[xnull]`rval) ~ 0f

(value .ml.fresh.feat.aggAutoCorr[xj]) ~ .p.get[`agg_autocorrelation;<][xj;]each autocorrkeys
(value .ml.fresh.feat.aggAutoCorr[xf]) ~ .p.get[`agg_autocorrelation;<][xf;]each autocorrkeys
(1_value .ml.fresh.feat.aggAutoCorr[xb]) ~ 1_.p.get[`agg_autocorrelation;<][xb;]each autocorrkeys
(value .ml.fresh.feat.aggAutoCorr[xi]) ~ .p.get[`agg_autocorrelation;<][xi;]each autocorrkeys
(value .ml.fresh.feat.aggAutoCorr[x0]) ~ 4#0f
(value .ml.fresh.feat.aggAutoCorr[x1]) ~ 4#0f
(value .ml.fresh.feat.aggAutoCorr[x2]) ~ .p.get[`agg_autocorrelation;<][x2;]each autocorrkeys
(value .ml.fresh.feat.aggAutoCorr[xnull]) ~ 4#0f

(.ml.fresh.feat.fftAggreg[xj]`centroid) ~ .p.get[`fft_aggregated;<][xj][0]
(.ml.fresh.feat.fftAggreg[xj]`variance) ~ .p.get[`fft_aggregated;<][xj][1]
(.ml.fresh.feat.fftAggreg[xi]`centroid) ~ .p.get[`fft_aggregated;<][xi][0]
(.ml.fresh.feat.fftAggreg[xi]`variance) ~ .p.get[`fft_aggregated;<][xi][1]
(.ml.fresh.feat.fftAggreg[xf]`centroid) ~ .p.get[`fft_aggregated;<][xf][0]
(.ml.fresh.feat.fftAggreg[xf]`variance) ~ .p.get[`fft_aggregated;<][xf][1]
(.ml.fresh.feat.fftAggreg[xb]`centroid) ~ .p.get[`fft_aggregated;<][xb][0]
(.ml.fresh.feat.fftAggreg[xb]`variance) ~ .p.get[`fft_aggregated;<][xb][1]
(.ml.fresh.feat.fftAggreg[x1]`centroid) ~ .p.get[`fft_aggregated;<][x1][0]
(.ml.fresh.feat.fftAggreg[x1]`variance) ~ .p.get[`fft_aggregated;<][x1][1]
(.ml.fresh.feat.fftAggreg[x2]`centroid) ~ .p.get[`fft_aggregated;<][x2][0]
(.ml.fresh.feat.fftAggreg[x2]`variance) ~ .p.get[`fft_aggregated;<][x2][1]
(.ml.fresh.feat.fftAggreg[xnull]`centroid) ~ 0n
(.ml.fresh.feat.fftAggreg[xnull]`variance) ~ 0n

(value .ml.fresh.feat.augFuller[xj]) ~ "f"$.p.get[`augmented_dickey_fuller;<][xj][0 1 2]
(value .ml.fresh.feat.augFuller[xf]) ~ "f"$.p.get[`augmented_dickey_fuller;<][xf][0 1 2]
(value .ml.fresh.feat.augFuller[xi]) ~ "f"$.p.get[`augmented_dickey_fuller;<][xi][0 1 2]
(value .ml.fresh.feat.augFuller[xb]) ~ "f"$.p.get[`augmented_dickey_fuller;<][xb][0 1 2]
(value .ml.fresh.feat.augFuller[x0]) ~ 3#0n
(value .ml.fresh.feat.augFuller[x1]) ~ 3#0n
(value .ml.fresh.feat.augFuller[x2]) ~ 3#0n
(value .ml.fresh.feat.augFuller[xnull]) ~ 3#0n

(.ml.fresh.feat.spktWelch[xj;til 100]) ~ .p.get[`spkt_welch_density;<][xj;til 100]
(.ml.fresh.feat.spktWelch[xf;til 100]) ~ .p.get[`spkt_welch_density;<][xf;til 100]
(.ml.fresh.feat.spktWelch[xi;til 100]) ~ .p.get[`spkt_welch_density;<][xi;til 100]
(.ml.fresh.feat.spktWelch[xb;til 100]) ~ .p.get[`spkt_welch_density;<][xb;til 100]
(.ml.fresh.feat.spktWelch[xnull;til 100]) ~ 100#0n

(.ml.fresh.feat.spktWelch[xj;k]) ~ .p.get[`spkt_welch_density;<][xj;k]
(.ml.fresh.feat.spktWelch[xf;k]) ~ .p.get[`spkt_welch_density;<][xf;k]
(.ml.fresh.feat.spktWelch[xi;k]) ~ .p.get[`spkt_welch_density;<][xi;k]
(.ml.fresh.feat.spktWelch[xb;k]) ~ .p.get[`spkt_welch_density;<][xb;k]
(.ml.fresh.feat.spktWelch[xnull;k]) ~ 100#0n

.p.get[`fft_coefficient;<][xj;`abs;0]~.ml.fresh.feat.fftCoeff[xj;1]`coeff_0_abs
.p.get[`fft_coefficient;<][xj;`abs;49]~.ml.fresh.feat.fftCoeff[xj;50]`coeff_49_abs
.p.get[`fft_coefficient;<][xj;`real;0]~.ml.fresh.feat.fftCoeff[xj;1]`coeff_0_real
.p.get[`fft_coefficient;<][xj;`real;49]~.ml.fresh.feat.fftCoeff[xj;50]`coeff_49_real
.p.get[`fft_coefficient;<][xj;`angle;0]~.ml.fresh.feat.fftCoeff[xj;1]`coeff_0_angle
.p.get[`fft_coefficient;<][xj;`angle;49]~.ml.fresh.feat.fftCoeff[xj;50]`coeff_49_angle
.p.get[`fft_coefficient;<][xj;`imag;0]~.ml.fresh.feat.fftCoeff[xj;1]`coeff_0_imag
.p.get[`fft_coefficient;<][xj;`imag;49]~.ml.fresh.feat.fftCoeff[xj;50]`coeff_49_imag
.p.get[`fft_coefficient;<][xf;`abs;0]~.ml.fresh.feat.fftCoeff[xf;1]`coeff_0_abs
.p.get[`fft_coefficient;<][xf;`abs;49]~.ml.fresh.feat.fftCoeff[xf;50]`coeff_49_abs
.p.get[`fft_coefficient;<][xf;`real;0]~.ml.fresh.feat.fftCoeff[xf;1]`coeff_0_real
.p.get[`fft_coefficient;<][xf;`real;49]~.ml.fresh.feat.fftCoeff[xf;50]`coeff_49_real
.p.get[`fft_coefficient;<][xf;`angle;0]~.ml.fresh.feat.fftCoeff[xf;1]`coeff_0_angle
.p.get[`fft_coefficient;<][xf;`angle;49]~.ml.fresh.feat.fftCoeff[xf;50]`coeff_49_angle
.p.get[`fft_coefficient;<][xf;`imag;0]~.ml.fresh.feat.fftCoeff[xf;1]`coeff_0_imag
.p.get[`fft_coefficient;<][xf;`imag;49]~.ml.fresh.feat.fftCoeff[xf;50]`coeff_49_imag
.p.get[`fft_coefficient;<][xi;`abs;0]~.ml.fresh.feat.fftCoeff[xi;1]`coeff_0_abs
.p.get[`fft_coefficient;<][xi;`abs;49]~.ml.fresh.feat.fftCoeff[xi;50]`coeff_49_abs
.p.get[`fft_coefficient;<][xi;`real;0]~.ml.fresh.feat.fftCoeff[xi;1]`coeff_0_real
.p.get[`fft_coefficient;<][xi;`real;49]~.ml.fresh.feat.fftCoeff[xi;50]`coeff_49_real
.p.get[`fft_coefficient;<][xi;`angle;0]~.ml.fresh.feat.fftCoeff[xi;1]`coeff_0_angle
.p.get[`fft_coefficient;<][xi;`angle;49]~.ml.fresh.feat.fftCoeff[xi;50]`coeff_49_angle
.p.get[`fft_coefficient;<][xi;`imag;0]~.ml.fresh.feat.fftCoeff[xi;1]`coeff_0_imag
.p.get[`fft_coefficient;<][xi;`imag;49]~.ml.fresh.feat.fftCoeff[xi;50]`coeff_49_imag
.p.get[`fft_coefficient;<][xb;`abs;0]~.ml.fresh.feat.fftCoeff[xb;1]`coeff_0_abs
.p.get[`fft_coefficient;<][xb;`abs;49]~.ml.fresh.feat.fftCoeff[xb;50]`coeff_49_abs
.p.get[`fft_coefficient;<][xb;`real;0]~.ml.fresh.feat.fftCoeff[xb;1]`coeff_0_real
.p.get[`fft_coefficient;<][xb;`real;49]~.ml.fresh.feat.fftCoeff[xb;50]`coeff_49_real
.p.get[`fft_coefficient;<][xb;`angle;0]~.ml.fresh.feat.fftCoeff[xb;1]`coeff_0_angle
.p.get[`fft_coefficient;<][xb;`angle;49]~.ml.fresh.feat.fftCoeff[xb;50]`coeff_49_angle
.p.get[`fft_coefficient;<][xb;`imag;0]~.ml.fresh.feat.fftCoeff[xb;1]`coeff_0_imag
.p.get[`fft_coefficient;<][xb;`imag;49]~.ml.fresh.feat.fftCoeff[xb;50]`coeff_49_imag

(.ml.fresh.feat.fftCoeff[xnull;50]`coeff_49_abs) ~ 0n
(.ml.fresh.feat.fftCoeff[xnull;50]`coeff_49_real) ~ 0n
(.ml.fresh.feat.fftCoeff[xnull;50]`coeff_49_angle) ~ 0n
(.ml.fresh.feat.fftCoeff[xnull;50]`coeff_49_imag) ~ 0n 

/
(value[.ml.fresh.feat.fftAggreg[xb]]0 1 2) ~ .p.get[`fft_aggregated;<][xb] 0 1 2
fftAggreg[xj][3] ~ .p.get[`fft_aggregated;<][xj][3]
fftAggreg[xf][2] ~ .p.get[`fft_aggregated;<][xf][2]
fftAggreg[xf][3] ~ .p.get[`fft_aggregated;<][xf][3]
\
