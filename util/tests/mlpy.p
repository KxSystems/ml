p)import numpy as np
p)from sklearn.metrics import fbeta_score

p)def mean_absolute_percentage_error(y_true, y_pred): 
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    return np.mean(np.abs((y_true - y_pred) / y_true)) * 100

p)def smape(A, F):
    return 100 * np.mean(np.abs(F - A) / (np.abs(A) + np.abs(F)))
