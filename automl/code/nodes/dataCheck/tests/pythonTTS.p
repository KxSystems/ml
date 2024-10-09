from sklearn.model_selection import train_test_split
import pandas as pd

def python_train_test_split(X, y, test_size):
  X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size)
  split_data = {"xtrain" : X_train, "xtest"  : X_test, "ytrain" : y_train, "ytest"  : y_test}
  return(split_data)