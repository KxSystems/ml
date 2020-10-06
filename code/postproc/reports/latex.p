import pylatex as pl
from pylatex import Document, Section, Subsection, Command, Figure, NewPage, Center
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
  with doc.create(Figure(position='h!')) as images:
     images.add_image(img,width = NoEscape(r'0.75\textwidth'))
     images.add_caption(caption)


# Main report generation function
## dict    = extensive dictionary containing required information
## dt      = dictionary containing the date and time at which the framework began this run
## paths   = dictionary containing the paths to images and where the report is to be generated
## ptype   = problem type 'class'/'reg'
## dscrb   = pandas dataframe describing the 'main' table
## score   = pandas dataframe containing the scores achieved in cross validation
## grid    = pandas dataframe containing 'where required' the hyperparameters
## exclude = list of methods (NN/deterministic) on which a hyperparameter search is not applied 

def python_latex(dict,dt,paths,ptype,dscrb,score,grid,exclude):
  geometry_options = {"margin": "2.5cm"}
  filepath = paths['fpath']
  doc = Document(filepath, geometry_options=geometry_options)
  doc.preamble.append(Command('title', 'kdb+/q Automated Machine Learning - Generated Report'))
  doc.preamble.append(Command('author', 'KxSystems'))
  doc.preamble.append(Command('date', 'Date: ' + dt['stdate']))
  doc.append(NoEscape(r'\maketitle'))

  with doc.create(Section('Introduction')):
    doc.append('This report outlines the results achieved through the running ') 
    doc.append('of the kdb+/q automated machine learning framework.\n')
    doc.append('This run started on ' + dt['stdate'] + ' at ' + dt['sttime'])

  with doc.create(Section('Description of input data')):
    doc.append('The following is a breakdown of information for a number of the relevant columns in the dataset\n\n')
    createTable(doc,dscrb,'cccccccc')

  with doc.create(Section('Pre-processing Breakdown')):
    doc.append(dict['typ'] + ' feature extraction was performed with a total of ' + dict['cnt_feats'] + ' features produced\n')
    doc.append('Feature extraction took a total time of ' + dict['feat_time'] + '.\n')

  with doc.create(Section('Initial Scores')):
    # Check how cross validation was completed and tailor output appropriately
    if(dict['xv'][0] in ['.ml.xv.mcsplit','.ml.xv.pcsplit']):
      doc.append('Cross validation was completed using ' + dict['xv'][0] + ' with a split of ' + dict['xv'][1] + ' of training data used for validation.\n')
    else:
      doc.append(dict['xv'][1] + '-fold cross validation was performed on the training set using ' + dict['xv'][0] + '.\n')
    createImage(doc,paths['path'] + '/code/postproc/images/train_test_validate.png','This image shows a general representation of how the data is split into training, testing and validation sets')
    doc.append('The total time that was required to complete selection of the best model based on the training set was ' + dict['xval_time'])
    doc.append('\n\nThe metric that is being used for scoring and optimizing the models was ' + dict['metric'] + '\n\n')
    doc.append('The following table outlines the scores achieved for each of the models tested \n')
    createTable(doc,score,'cc')
    createImage(doc,''.join(dict['impact_plot']),'This is the feature impact for a number of the most significant features as determined on the training set')
  
  with doc.create(Section('Model selection summary')):
    doc.append('Best scoring model = ' + dict['best_scoring_name'] + '\n\n')
    doc.append('The score on the validation set for this model was = ' + dict['holdout'] + '\n\n')
    doc.append('The total time to complete the running of this model on the validation set was: ' + dict['val_time'])

  # Check for hyperparameter search type
  typ_upper = ''
  typ_lower = ''
  typ_key = ''
  if dict['hp']=='sobol':
      typ_upper = 'Sobol'
      typ_key = 'rs'
  elif dict['hp']=='random':
      typ_upper = 'Random'
      typ_key = 'rs'
  else:
      typ_upper = 'Grid'
      typ_key = 'gs'
    
  # If appropriate return the output from a completed hyperparameter search
  if(not dict['best_scoring_name'] in exclude):
    with doc.create(Section(typ_upper + ' search for a ' + dict['best_scoring_name'] + ' model.')):
      if(dict[typ_key][0] in ['.ml.gs.mcsplit','.ml.gs.pcsplit']):
        doc.append('The ' + dict['hp'] + ' search was completed using ' + dict[typ_key][0] + ' with a split of ' + dict[typ_key][1] + ' of training data used for validation.\n')
      else:
        doc.append('A ' + dict[typ_key][1] + '-fold ' + dict['hp'] + ' search was performed on the training set to find the best model using ' + dict[typ_key][0] + '.\n')
      doc.append('The following are the hyper parameters which have been deemed optimal for the model.\n')
      createTable(doc,grid,'cc')
      doc.append('The score for the best model fit on the entire training set and scored on the testing set was = ' + dict['test_score'])
  
  # If the problem is classification then display the appropriate confusion matrix
  if(ptype=="class"):
    with doc.create(Section('Classification summary')):
      doc.append('The following displays the performance of the classification model on the testing set\n\n')
      createImage(doc,''.join(dict['conf_plot']),'This is a confusion matrix produced for predictions made on the testing set')

  # Generate the pdf using the pdflatex compiler (this compiler flag may change depending on final choice of install instructions)
  doc.generate_pdf(clean_tex=False, compiler='pdflatex')
