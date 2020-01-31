p)import numpy as np
p)from scipy import stats

p)def< binary_feature_binary_test(x, y):
    x0, x1 = np.unique(x)
    y0, y1 = np.unique(y)

    n_y1_x0 = sum(y[x == x0] == y1)
    n_y0_x0 = len(y[x == x0]) - n_y1_x0
    n_y1_x1 = sum(y[x == x1] == y1)
    n_y0_x1 = len(y[x == x1]) - n_y1_x1

    table = np.array([[n_y1_x1, n_y1_x0],
                      [n_y0_x1, n_y0_x0]])

    oddsratio, p_value = stats.fisher_exact(table, alternative="two-sided")

    return p_value

p)def< target_binary_feature_real_test(y, x):
    y0, y1 = np.unique(y)

    x_y1 = x[y == y1]
    x_y0 = x[y == y0]

    KS, p_ks = stats.ks_2samp(x_y1, x_y0,mode='asymp')
    return p_ks

p)def< target_real_feature_real_test(x, y):
    tau, p_value = stats.kendalltau(x, y)
    return p_value

p)def< benjamini_hochberg_test(df_pvalues, hypotheses_independent, fdr_level):
    df_pvalues = df_pvalues.sort_values(by="p_value")
    m = len(df_pvalues)
    K = np.arange(1, m + 1)
    if hypotheses_independent:
        C = np.ones(m)
    else:
        C = np.cumsum(1.0 / K)
    T = (fdr_level * K) / (m * C)
    try:
        k_max = list(df_pvalues.p_value <= T).index(False)
    except ValueError:
        k_max = m
    df_pvalues["relevant"] = [True] * k_max + [False] * (m - k_max)
    return df_pvalues

# The code presented here has been used in a modified form from:
# Copyright 2016-2018, Maximilian Christ et al./ Blue Yonder GmbH Revision 2b6f57b3
# The code is used to test q vs python implementations of these functions.
