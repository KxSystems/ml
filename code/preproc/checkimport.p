# Ensure that a user that is attempting to use the framework
# has the required dependencies for neural network models
p)def< checkimport():
  try:
    import tensorflow
    import keras
    return(0)
  except:
    return(1)
