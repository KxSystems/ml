# Natural Language Processing

## Introduction

Natural language processing (NLP) can be used to answer a variety of questions about unstructured text, as well as facilitating open-ended exploration. It can be applied to datasets such as emails, online articles and comments, tweets and novels. Although the source is text, transformations are applied to convert this data to vectors, dictionaries and symbols which can be handled very effectively by q. Many operations such as searching, clustering, and keyword extraction can all be done using very simple data structures, such as feature vectors.

## Features

The NLP allows users to parse dataset using the spacy model from python in which it runs tokenisation, Sentence Detection, Part of speech tagging and Lemmatization. In addition to parsing, users can cluster text documents together using different clustering algorithms like MCL, K-means and radix. You can also run sentiment analysis which indicates whether a word has a positive or negative sentiment.

For full documentation, go to [nlp](https://code.kx.com/q/ml/nlp/)
    
## Installation

Clone the NLP repo to `$QHOME` and load using
```
q)\l nlp/init.q
```

## Requirements

The following python packages are required:
  1. numpy
  2. beautifulsoup4
  3. spacy

To install these packages,run ```$pip install -r requirements.txt```

* Download the English model using ```python -m spacy download en```
  

## Status
  
The nlp library is still in development and is available here as a beta release.  
If you have any issues, questions or suggestions, please write to ai@kx.com.
