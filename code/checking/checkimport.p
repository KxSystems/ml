# Ensure that a user that is attempting to use the framework
# has the required dependencies for relevant sections of the framework
# this will modify what is possible wrt NLP/network models/Latex/Sobol
p)def< checkimport(x):
  if(x==0):
    try:
      import tensorflow;import keras;return(0)
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
      import gensim.models;return(0);
    except:
      return(1)
  elif(x==4):
    try:
      import sobol_seq;return(0)
    except:
      return(1)
  else:
    return(0)
