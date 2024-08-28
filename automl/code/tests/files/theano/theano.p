import theano
from theano import tensor as T
import numpy as np


def init_weights(shape):
    """ Weight initialization """
    weights = np.asarray(np.random.randn(*shape) * 0.01, dtype=theano.config.floatX)
    return theano.shared(weights)

def backprop(cost, params, lr=0.01):
    """ Back-propagation """
    grads   = T.grad(cost=cost, wrt=params)
    updates = []
    for p, g in zip(params, grads):
        updates.append([p, p - g * lr])
    return updates

def forwardprop(X, w_1, w_2):
    """ Forward-propagation """
    h    = T.nnet.sigmoid(T.dot(X, w_1))  # The \sigma function
    yhat = T.nnet.softmax(T.dot(h, w_2))  # The \varphi function
    return yhat


def buildModel(train_X,train_y,seed):
  
   np.random.seed(seed)  
 
  # Symbols
   X = T.fmatrix()
   Y = T.fmatrix()

   # Layers sizes
   x_size = train_X.shape[1]             # Number of input nodes: 4 features and 1 bias
   h_size = 256                          # Number of hidden nodes
   y_size = train_y.shape[1]             # Number of outcomes (3 iris flowers)
   w_1 = init_weights((x_size, h_size))  # Weight initializations
   w_2 = init_weights((h_size, y_size))

   # Forward propagation
   yhat   = forwardprop(X, w_1, w_2)

   # Backward propagation
   cost    = T.mean(T.nnet.categorical_crossentropy(yhat, Y))
   params  = [w_1, w_2]
   updates = backprop(cost, params)

   # Train and predict
   train   = theano.function(inputs=[X, Y], outputs=cost, updates=updates, allow_input_downcast=True)
   pred_y  = T.argmax(yhat, axis=1)
   predict = theano.function(inputs=[X], outputs=pred_y, allow_input_downcast=True)
 
   return(train,predict)


def fitModel(train_X,train_y,model):
    for iter in range(5):
        for i in range(len(train_X)):
            model(train_X[i: i + 1], train_y[i: i + 1]) 


def predictModel(test_X,model):
  return model(test_X)




