# Ensure that a user that is attempting to use the framework
# has the required dependencies for neural network models
p)def< checkimport(x):
  if(x==0):
    try:
      import keras;return(0)
    except:
      return(1)
  elif(x==1):
    try:
      import torch;return(0)
    except:
      return(1)
  elif(x==2):
    try:
      import pylatex;return(0)
    except:
      return(1)
  elif(x==3):
    try:
      import gensim.models;import spacy;import builtins;return(0);
    except:
      return(1)
  elif(x==4):
    try:
      import tensorflow;return(0)
    except:
      return(1)
  elif(x==5):
    try:
      import theano;return(0);
    except:
      return(1)
  else:
    return(0)
