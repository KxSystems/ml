\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Any configuration information required to run the function
nonFreshConfig:`featureExtractionType`logFunc!(`normal;{})
freshConfig   :`featureExtractionType`aggregationColumns`logFunc!(`fresh;`freshIdx;{})

-1"\nTesting appropriate sym encoding data preprocessing";

// One hot encode and frequency input data
oheList :`a`b`c`b`c`a`a`b`b`c
freqList:`ab`ac`bc`ab`bc`bc`ac`cb`ca`ba

// One hot encode and frequency return dictionaries
oheListReturn      :`oheList_a`oheList_b`oheList_c!"f"$(1 0 0 0 0 1 1 0 0 0;0 1 0 1 0 0 0 1 1 0;0 0 1 0 1 0 0 0 0 1)
freqListReturn     :enlist[`freqList_freq]!enlist 0.2 0.2 0.3 0.2 0.3 0.3 0.2 0.1 0.1 0.1
freshFreqListReturn:enlist[`freqList_freq]!enlist 0.4 0.2 0.4 0.4 0.4 0.2 0.2 0.2 0.2 0.2

// id for FRESH table
freshIdx:(5#`id1),5#`id2

// Tables for the testing of covering all encoding combinations
noEncodeTab          :([]10?1f;10?1f;10?5)
oheEncodeTab         :([]10?1f;oheList;10?1f)
freqEncodeTab        :([]freqList;10?1f;10?1f)
oheFreqEncodeTab     :([]10?1f;freqList;oheList;10?1f)
freshNoEncodeTab     :([freshIdx]10?1f;10?1f;10?1f)
freshOheEncodeTab    :([freshIdx]10?1f;oheList;10?1f)
freshFreqEncodeTab   :([freshIdx]freqList;10?1f;10?1f)
freshOheFreqEncodeTab:([freshIdx]10?1f;freqList;oheList;10?1f)


// Sym encodings dictionaries
noEncodeReturn     :`freq`ohe!2#`$()
oheEncodeReturn    :`freq`ohe!(`$();enlist `oheList)
freqEncodeReturn   :`freq`ohe!(enlist `freqList;`$())
oheFreqEncodeReturn:`freq`ohe!(enlist `freqList;enlist`oheList)

// Expected return tables
oheEncodeReturnTab         :![oheEncodeTab           ;();0b;enlist`oheList   ],'flip oheListReturn
freqReturnEncodeTab        :![freqEncodeTab          ;();0b;enlist`freqList  ],'flip freqListReturn
oheFreqReturnEncodeTab     :![oheFreqEncodeTab       ;();0b;`freqList`oheList],'flip freqListReturn,oheListReturn
freshOheEncodeReturnTab    :![0!freshOheEncodeTab    ;();0b;enlist`oheList   ],'flip oheListReturn
freshFreqReturnEncodeTab   :![0!freshFreqEncodeTab   ;();0b;enlist`freqList  ],'flip freshFreqListReturn
freshOheFreqReturnEncodeTab:![0!freshOheFreqEncodeTab;();0b;`freqList`oheList],'flip freshFreqListReturn,oheListReturn

// Testing appropriate input types for sym encoding
passingTest[.automl.dataPreprocessing.symEncoding;(noEncodeTab  ;nonFreshConfig;noEncodeReturn  );0b;noEncodeTab]
passingTest[.automl.dataPreprocessing.symEncoding;(oheEncodeTab ;nonFreshConfig;oheEncodeReturn );0b;oheEncodeReturnTab]
passingTest[.automl.dataPreprocessing.symEncoding;(freqEncodeTab;nonFreshConfig;freqEncodeReturn);0b;freqReturnEncodeTab]
passingTest[.automl.dataPreprocessing.symEncoding;(oheFreqEncodeTab;nonFreshConfig;oheFreqEncodeReturn);0b;oheFreqReturnEncodeTab]

passingTest[.automl.dataPreprocessing.symEncoding;(freshNoEncodeTab     ;freshConfig;noEncodeReturn     );0b;freshNoEncodeTab]
passingTest[.automl.dataPreprocessing.symEncoding;(freshOheEncodeTab    ;freshConfig;oheEncodeReturn    );0b;freshOheEncodeReturnTab]
passingTest[.automl.dataPreprocessing.symEncoding;(freshFreqEncodeTab   ;freshConfig;freqEncodeReturn   );0b;freshFreqReturnEncodeTab]
passingTest[.automl.dataPreprocessing.symEncoding;(freshOheFreqEncodeTab;freshConfig;oheFreqEncodeReturn);0b;freshOheFreqReturnEncodeTab]


-1"\nTesting appropriate feature preprocessing";

// Nlp configuration
nlpConfig:`featureExtractionType`logFunc!(`nlp;{})

// Constant, null and infinity input data
infList:2 1 2 0w 0w 0w 1 2 0 0
nullList:1 0n 4 3 2 2 0n 4 1 0n

// Constant, null and infinity return lists and dictionaries
nullListReturn:1 1.5 4 3 2 2 1.5 4 1 1.5
nullPlacement:0 1 0 0 0 0 1 0 0 1j
nullReturnDict:`nullList`nullList_null!(nullListReturn;nullPlacement)
infListReturn:2 1 2 2 2 2 1 2 0 0f


// Tables for testing feature preprocessing
constantTab   :([]10?10f;10?1f;10#`a)
nullTab       :([]10?10f;10?1f;nullList)
infTab        :([]10?10f;10?1f;infList)
constNullTab  :([]10?10f;10?1f;y:(5#1f),(5#0n))
nlpConstantTab:([]string each 10?`3;10?10f;10?1f;10#`a)
nlpNullTab    :([]string each 10?`3;10?10f;10?1f;nullList)
nlpInfTab     :([]string each 10?`3;10?10f;10?1f;infList)

// Expected return tables
constantReturnTab   :delete x2 from constantTab
nullReturnTab       :nullTab,'flip nullReturnDict
infReturnTab        :update infList:infListReturn from infTab
constNullReturnTab  :update y_null:"j"$0000011111b from delete y from constNullTab
nlpConstantReturnTab:delete x3 from nlpConstantTab
nlpNullReturnTab    :nlpNullTab,'flip nullReturnDict
nlpInfReturnTab     :update infList:infListReturn from nlpInfTab

// Testing appropriate input types for feature preprocessing
passingTest[.automl.dataPreprocessing.featPreprocess;(constantTab;nonFreshConfig);0b;constantReturnTab]
passingTest[.automl.dataPreprocessing.featPreprocess;(nullTab    ;nonFreshConfig);0b;nullReturnTab]
passingTest[.automl.dataPreprocessing.featPreprocess;(infTab     ;nonFreshConfig);0b;infReturnTab]
passingTest[.automl.dataPreprocessing.featPreprocess;(constNullTab;nonFreshConfig);0b;constNullReturnTab]

passingTest[.automl.dataPreprocessing.featPreprocess;(nlpConstantTab;nlpConfig);0b;nlpConstantReturnTab]
passingTest[.automl.dataPreprocessing.featPreprocess;(nlpNullTab    ;nlpConfig);0b;nlpNullReturnTab]
passingTest[.automl.dataPreprocessing.featPreprocess;(nlpInfTab     ;nlpConfig);0b;nlpInfReturnTab]
