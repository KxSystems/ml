## Python spell check function
p)def spell(doc,model):
  lst=[]
  for s in doc:
    if s._.hunspell_spell==False:
      sug=s._.hunspell_suggest
      if len(sug)>0:
        ([lst.append(n)for n in model((sug)[0])]) 
      else:
        lst.append(s)
    else:
        lst.append(s)
  return lst

## Python function for running spacy
p)def get_doc_info(parser,tokenAttrs,opts,text):
  doc=doc1=parser(text)
  if('spell' in opts):
    doc1=spell(doc,parser)
  res=[[getattr(w,a)for w in doc1]for a in tokenAttrs]
  if('sentChars' in opts): # indices of first+last char per sentence
    res.append([(s.start_char,s.end_char)for s in doc.sents])
  if('sentIndices' in opts): # index of first token per sentence
    res.append([s.start for s in doc.sents])
  res.append([w.is_punct or w.is_bracket or w.is_space for w in doc])
  return res

## Python functions to detect sentence borders
p)def x_sbd(doc):
  if len(doc):
    doc[0].is_sent_start=True
    for i,token in enumerate(doc[:-1]):
      doc[i+1].is_sent_start=token.text in ['。','？','！']
  return doc

## Python functionality for the generation of a url parser
p)from urllib.parse import urlparse
p)import re
p)seReg=re.compile('([a-z0-9]+:)?//')

