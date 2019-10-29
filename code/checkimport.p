p)def< checkimport(name):
  try:
   import tensorflow
   import tensorflow_text
   return 0
  except ModuleNotFoundError as e:
   traceback.print_exc()
   print("\nTensorflow not found, tensorflow.q script will not be loaded")

