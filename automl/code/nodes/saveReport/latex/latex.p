import pylatex as pl
from pylatex import Document, Section, Subsection, Command, Figure, NewPage, Center, Package
from pylatex.utils import italic, NoEscape

#  Add a table to the document
## doc   = document to which the table is to be added
## tab   = Pandas dataframe
## ncols = list of c's indicating number of columns in the table i.e 'cccc' is 4 columns

def createTable(doc,tab,ncols):
  with doc.create(Center()) as centered:
    with centered.create(pl.Tabular(ncols)) as table:
      table.add_hline()
      table.add_row(list(tab.columns))
      table.add_hline()
      for row in tab.index:
        table.add_row(list(tab.loc[row,:]))
      table.add_hline()

#  Add an image to the document
## doc     = document to which the image is to be added
## img     = location of the image being added
## caption = caption to be displayed under to image

def createImage(doc,img,caption):
  with doc.create(Figure(position='H')) as images:
     images.add_image(img,width = NoEscape(r'0.75\textwidth'))
     images.add_caption(caption)

# Main report generation function
## dict    = extensive configDictonary containing required information
## paths   = configDictonary containing the paths to images and where the report is to be generated
## dscrb   = pandas dataframe describing the 'main' table
## score   = pandas dataframe containing the scores achieved in cross validation
## grid    = pandas dataframe containing 'where required' the hyperparameters
## exclude = list of methods (NN/deterministic) on which a hyperparameter search is not applied 

def python_latex(dict,paths,dscrb,score,grid,exclude):
  configDict = dict['config']
  metaDict =dict['modelMetaData']
  ptype = configDict['problemType']
  filepath = paths['fpath']

  if ptype=="class":
        ptype="classification"
  else:
        ptype="regression"

  geometry_options = {"margin": "2.5cm"}
  doc = Document(filepath, geometry_options=geometry_options)
  doc.packages.append(Package('float'))
  doc.preamble.append(Command('title', 'kdb+/q Automated Machine Learning - Generated Report'))
  doc.preamble.append(Command('author', 'KxSystems'))
  doc.preamble.append(Command('date', 'Date: ' + configDict['startDate']))
  doc.append(NoEscape(r'\maketitle'))
  with doc.create(Section('Introduction')):
    doc.append('This report outlines the results for a ' + ptype + ' problem ') 
    doc.append('achieved through running kdb+/q AutoML.\n')
    doc.append('This run started on ' + configDict['startDate'] + ' at ' + configDict['startTime'])
  
  with doc.create(Section('Description of input data')):
    doc.append('The following is a breakdown of information for each of the relevant columns in the dataset:\n\n')
    createTable(doc,dscrb,'cccccccc')

    createImage(doc,''.join(paths['target']),'Distribution of input target data.')
  
  with doc.create(Section('Pre-processing Breakdown')):
    doc.append(configDict['featureExtractionType'].capitalize() + ' feature extraction was performed with a total of ' + str(len(dict['sigFeats'])) + ' features produced\n')
    doc.append('Feature extraction took a total time of ' +dict['creationTime'] + '.\n')
 
  with doc.create(Section('Initial Scores')):
    # Check how cross validation was completed and tailor output appropriately
    if(configDict['crossValidationFunction'] in ['.ml.xv.mcSplit','.ml.xv.pcSplit']):
      doc.append('Percentage based cross validation, '+ configDict['crossValidationFunction'] + ', was performed with a testing set created from ' + str(100*int(configDict['crossValidationArgument'])))
      doc.append('% of the training data.\n')
    else:
      doc.append(configDict['crossValidationArgument'] + '-fold cross validation was performed on the training set using ' + configDict['crossValidationFunction'] + '.\n')
    createImage(doc,''.join(paths['data']),'The data split used within this run of AutoML, with data split into training, holdout and testing sets')
    doc.append('The total time taken to carry out cross validation for each model on the training set was ' + metaDict['xValTime'])
    doc.append('\nwhere models were scored and optimized using ' + metaDict['metric'] + '.\n\n')
    doc.append('The following table outlines the scores achieved for each of the models tested \n')
    createTable(doc,score,'cc')
    createImage(doc,''.join(paths['impact']),'Feature impact of each significant feature as determined by the training set')
  
  with doc.create(Section('Model selection summary')):
    doc.append('Best scoring model = ' + dict['modelName'] + '\n\n')
    doc.append('The score on the holdout set for this model was = ' + configDict['holdoutSize'] + '\n\n')
    doc.append('The total time to complete the running of this model on the holdout set was: ' + metaDict['xValTime'])
  
  # Check for hyperparameter search type
  typ_upper = ''
  typ_lower = ''
  typ_key = ''
  hyperParamType = configDict['hyperparameterSearchType']
  if hyperParamType=='sobol':
      typ_upper = 'Sobol'
      typ_lower = 'sobol'
      typ_key = 'rs'
      typ_key_long = 'random'
  elif hyperParamType=='random':
      typ_upper = 'Random'
      typ_lower = 'random'
      typ_key = 'rs'
      typ_key_long = 'random'
  else:
      typ_upper = 'Grid'
      typ_lower = 'grid'
      typ_key = 'gs'
      typ_key_long = 'grid'
    
  # If appropriate return the output from a completed hyperparameter search
  if(not dict['modelName'] in exclude):
    with doc.create(Section(typ_upper + ' search for a ' + dict['modelName'] + ' model.')):
      if(configDict[typ_key_long+'SearchFunction'] in ['.ml.gs.mcSplit','.ml.gs.pcSplit']):
        doc.append('The hyperparameter search was completed using '+ configDict[typ_key_long+'SearchFunction'] + ' with a percentage of '+ configDict[typ_key_long+'SearchArgument'] + '% of training data used for validation\n')
      else:
        doc.append('A ' + configDict[typ_key_long+'SearchArgument'] + '-fold ' + configDict['hyperparameterSearchType'] + ' search was performed on the training set to find the best model using ' + configDict[typ_key_long+'SearchFunction'] + '.\n')
      doc.append('The following are the hyper parameters which have been deemed optimal for the model.\n')
      createTable(doc,grid,'cc')
      doc.append('The score for the best model fit on the entire training set and scored on the testing set was = ' + dict['testScore'])
  
  # If the problem is classification then display the appropriate confusion matrix
  if(ptype=="classification"):
    with doc.create(Section('Classification summary')):
      doc.append('The following displays the performance of the classification model on the testing set\n\n')
      createImage(doc,''.join(paths['conf']),'This is the confusion matrix produced for predictions made on the testing set')
  else:
    with doc.create(Section('Regression summary')):
      doc.append('The following displays the performance of the regression model on the testing set\n\n')
      createImage(doc,''.join(paths['reg']),'Regression analysis plot produced for predictions made on the testing set')

  # Generate the pdf using the pdflatex compiler (this compiler flag may change depending on final choice of install instructions)
  doc.generate_pdf(clean_tex=False, compiler='pdflatex')
