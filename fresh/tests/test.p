p)import numpy as np
p)import pandas as pd
p)from scipy.signal import welch, cwt, ricker, find_peaks_cwt
p)from scipy.stats import linregress
p)from statsmodels.tsa.stattools import acf, adfuller, pacf
p)from numpy.linalg import LinAlgError

p)def< _get_length_sequences_where(x):
        if len(x) == 0:
                return [0]
        else:
                res = [len(list(group)) for value, group in itertools.groupby(x) if value == 1]
                return res if len(res) > 0 else [0]
p)def< aggregate_on_chunks(x, f_agg, chunk_len):return [getattr(x[i * chunk_len: (i + 1) * chunk_len], f_agg)() for i in range(int(np.ceil(len(x) / chunk_len)))]

p)def< hasduplicate(x):return len(x) != len(set(x))
p)def< hasduplicatemin(x):return sum(np.asarray(x) == min(x)) >= 2
p)def< hasduplicatemax(x):return sum(np.asarray(x) == max(x)) >= 2
p)def< abs_energy(x):x = np.asarray(x); return sum(x * x)
p)def< mean_change(x):return np.mean(np.diff(x))
p)def< mean_abs_change(x):return np.mean(np.abs(np.diff(x)))
p)def< count_above_mean(x): x = np.asarray(x); m = np.mean(x); return np.where(x > m)[0].shape[0]
p)def< count_below_mean(x): x = np.asarray(x); m = np.mean(x); return np.where(x < m)[0].shape[0]
p)def< first_location_of_maximum(x): x = np.asarray(x); return np.argmax(x) / len(x) if len(x) > 0 else np.NaN
p)def< first_location_of_minimum(x): x = np.asarray(x); return np.argmin(x) / len(x) if len(x) > 0 else np.NaN
p)def< last_location_of_minimum(x): x = np.asarray(x); return 1.0 - (1+np.argmin(x[::-1]))/ len(x) if len(x) > 0 else np.NaN
p)def< last_location_of_maximum(x): x = np.asarray(x); return 1.0 - (1+np.argmax(x[::-1]))/ len(x) if len(x) > 0 else np.NaN
p)def< ratio_val_num_to_t_series(x):return len(set(x))/len(x)
p)def< ratio_beyond_r_sigma(x,r):return sum(abs(x - np.mean(x)) > r * np.std(x))/len(x)
p)def< large_standard_deviation(x,r):x = np.asarray(x);return np.std(x) > (r * (max(x) - min(x)))
p)def< absolute_sum_of_changes(x):return np.sum(abs(np.diff(x)))
p)def< longest_strike_below_mean(x):return max(_get_length_sequences_where(x <= np.mean(x))) if len(x) > 0 else 0
p)def< longest_strike_above_mean(x):return max(_get_length_sequences_where(x >= np.mean(x))) if len(x) > 0 else 0
p)def< skewness_py(x):x = pd.Series(x);return pd.Series.skew(x)
p)def< kurtosis_py(x):x = pd.Series(x);return pd.Series.kurtosis(x)
p)def< range_count(x,min,max):return np.sum((x >= min) & (x < max))
p)def< variance_larger_than_standard_deviation(x):return np.var(x) > np.std(x)
p)def< number_cwt_peaks(x,n):return len(find_peaks_cwt(vector=x, widths=np.array(list(range(1, n + 1))), wavelet=ricker)) 
p)def< quantile_py(x, q):x = pd.Series(x);return pd.Series.quantile(x, q)
p)def< value_count(x, value):
        if np.isnan(value):
                return np.isnan(x)
        else:
                return x[x == value].shape[0]

p)def< percentage_recurring_all_data(x):
        unique, counts = np.unique(x, return_counts=True)
        return np.sum(counts > 1) / float(counts.shape[0])

p)def< percentage_recurring_all_val(x):
        x = pd.Series(x)
        if len(x) == 0:
                return np.nan
        x = x.copy()
        value_counts = x.value_counts()
        return value_counts[value_counts > 1].sum() / len(x)

p)def< number_peaks(x, n):
        x = np.asarray(x)
        x_reduced = x[n:-n]
        res = None
        for i in range(1, n + 1):
                result_first = (x_reduced > np.roll(x, i)[n:-n])
                if res is None:
                        res = result_first
                else:
                        res &= result_first
                res &= (x_reduced > np.roll(x, -i)[n:-n])
        return sum(res)

p)def< cid_ce(x, normalize):
        x = np.asarray(x)
        if normalize:
                s = np.std(x)
                if s!=0:
                        x = (x - np.mean(x))/s
                else:
                        return 0.0
        x = np.diff(x)
        return np.sqrt(np.sum((x * x)))

p)def< mean_second_derivative_central(x):
        diff = (np.roll(x, 1) - 2 * np.array(x) + np.roll(x, -1)) / 2.0
        return np.mean(diff[1:-1])

p)def< sum_recurring_values(x):
        unique, counts = np.unique(x, return_counts=True)
        counts[counts < 2] = 0
        counts[counts > 1] = 1
        return np.sum(counts * unique)

p)def< sum_recurring_data_points(x):
        unique, counts = np.unique(x, return_counts=True)
        counts[counts < 2] = 0
        return np.sum(counts * unique)

p)def< c3_py(x, lag):
        n = len(x)
        x = np.asarray(x)
        if 2 * lag >= n:
                return 0
        else:
                return np.mean((np.roll(x, 2 * -lag) * np.roll(x, -lag) * x)[0:(n - 2 * lag)])

p)def< number_crossing_m(x, m):
        if not isinstance(x, (np.ndarray, pd.Series)):
                x = np.asarray(x)
        positive = x > m
        return np.where(np.bitwise_xor(positive[1:], positive[:-1]))[0].size

p)def< binned_entropy(x, max_bins):
        if not isinstance(x, (np.ndarray, pd.Series)):
                x = np.asarray(x)
        hist, bin_edges = np.histogram(x, bins=max_bins)
        probs = hist / x.size
        return - np.sum(p * np.math.log(p) for p in probs if p != 0)

p)def< autocorrelation(x, lag):
        if type(x) is pd.Series:
                x = x.values
        if len(x) < lag:
                return np.nan
        y1 = x[:(len(x)-lag)]
        y2 = x[lag:]
        x_mean = np.mean(x)
        sum_product = np.sum((y1-x_mean)*(y2-x_mean))
        return sum_product / ((len(x) - lag) * np.var(x))

p)def< energy_ratio_by_chunks(x,y,z):
        full_series_energy = np.sum(x ** 2)
        num_segments = y
        segment_focus = z
        assert segment_focus < num_segments
        segment_length = len(x)//num_segments
        start = segment_focus*segment_length
        end = min((segment_focus+1)*segment_length, len(x))
        res_data=(np.sum(x[start:end]**2.0)/full_series_energy)
        return res_data 

p)def< change_quantiles(x, ql, qh, isabs, f_agg):
        if ql >= qh:
                ValueError("ql={} should be lower than qh={}".format(ql, qh))
        div = np.diff(x)
        if isabs:
                div = np.abs(div)
        try:
                bin_cat = pd.qcut(x, [ql, qh], labels=False)
                bin_cat_0 = bin_cat == 0
        except ValueError: 
                return 0
        ind = (bin_cat_0 * np.roll(bin_cat_0, 1))[1:]
        if sum(ind) == 0:
                return 0
        else:
                ind_inside_corridor = np.where(ind == 1)
                aggregator = getattr(np, f_agg)
                return aggregator(div[ind_inside_corridor])

p)def< time_reversal_asymmetry_statistic(x, lag):
    n = len(x)
    x = np.asarray(x)
    if 2 * lag >= n:
        return 0
    else:
        return np.mean((np.roll(x, 2 * -lag) * np.roll(x, 2 * -lag) * np.roll(x, -lag) -
                        np.roll(x, -lag) * x * x)[0:(n - 2 * lag)])

p)def< index_mass_quantile(x, q):

    x = np.asarray(x)
    abs_x = np.abs(x)
    s = sum(abs_x)

    if s == 0:
        return np.NaN
    else:
        mass_centralized = np.cumsum(abs_x) / s
        return (np.argmax(mass_centralized >= q)+1)/len(x)

p)def< linear_trend(x):
    linReg = linregress(range(len(x)), x)
    return linReg

p)def< get_moment(y, moment):return y.dot(np.arange(len(y))**moment) / y.sum()
p)def< get_centroid(y):return get_moment(y, 1)
p)def< get_variance(y):return get_moment(y, 2) - get_centroid(y) ** 2

p)def get_skew(y):
    variance = get_variance(y)
    if variance < 0.5:
        return np.nan
    else:
        return (
            get_moment(y, 3) - 3*get_centroid(y)*variance - get_centroid(y)**3
        ) / get_variance(y)**(1.5)
p)def< get_kurtosis(y):
    variance = get_variance(y)
    if variance < 0.5:
        return np.nan
    else:
        return (
            get_moment(y, 4) - 4*get_centroid(y)*get_moment(y, 3)
            + 6*get_moment(y, 2)*get_centroid(y)**2 - 3*get_centroid(y)
        ) / get_variance(y)**2

p)def< fft_aggregated(x):
    fft_abs = abs(np.fft.rfft(x))
    return get_centroid(fft_abs),get_variance(fft_abs),get_skew(fft_abs),get_kurtosis(fft_abs)

p)def< index_mass_quantile(x, q):

    x = np.asarray(x)
    abs_x = np.abs(x)
    s = sum(abs_x)

    if s == 0:
        return np.NaN
    else:
        mass_centralized = np.cumsum(abs_x) / s
        return (np.argmax(mass_centralized >= q)+1)/len(x)

p)def< agg_autocorrelation(x,y):
    var = np.var(x)
    n = len(x)
    if np.abs(var) < 10**-10 or n == 1:
        a = 0
    else:
        a = acf(x, unbiased=True, fft=n > 1250)[1:]
    return getattr(np, y)(a)

p)def< augmented_dickey_fuller(x):
    res = None
    try:
        res = adfuller(x)
    except LinAlgError:
        res = np.NaN, np.NaN, np.NaN
    except ValueError: 
        res = np.NaN, np.NaN, np.NaN
    except MissingDataError:
        res = np.NaN, np.NaN, np.NaN

    return res 

p)def< spkt_welch_density(x, y):
    freq, pxx = welch(x)
    return pxx[y]

p)def< fft_coefficient(x,y,z):

    fft = np.fft.rfft(x)

    def complex_agg(x, agg):
        if agg == "real":
            return np.real(x)
        elif agg == "imag":
            return np.imag(x)
        elif agg == "abs":
            return np.abs(x)
        elif agg == "angle":
            return np.angle(x, deg=True)

    res = complex_agg(fft[z],y)

    return res

p)def< partial_autocorrelation(x, param):
    max_demanded_lag = max(param)
    n = len(x)
    if n <= 1:
        pacf_coeffs = [np.nan] * (max_demanded_lag + 1)
    else:
        if (n <= max_demanded_lag):
            max_lag = n - 1
        else:
            max_lag = max_demanded_lag
        pacf_coeffs = list(pacf(x, method="ld", nlags=max_lag))
        pacf_coeffs = pacf_coeffs + [np.nan] * max(0, (max_demanded_lag - max_lag))

    return pacf_coeffs[param]

