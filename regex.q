\d .nlp

re:.p.import`re
regex.compile:{re[`:compile;x;$[y;re`:IGNORECASE;0]]}
regex.matchAll:.p.eval["lambda p,t:[[x.group(),x.start(),x.end()]for x in p.finditer(t)]";<]
regex.check:{i.bool[x[`:search]y]`}

regex.patterns.specialChars:    "[-[\\]{}()*+?.,\\\\^$|#\\s]"
regex.patterns.money:           "[$¥€£¤฿]?\\s*((?<![.0-9])([0-9][0-9, ]*(\\.([0-9]{0,2})?)?|\\.[0-9]{1,2})(?![.0-9]))\\s*((hundred|thousand|million|billion|trillion|[KMB])?\\s*([$¥€£¤฿]|dollars?|yen|pounds?|cad|usd|gbp|eur))|[$¥€£¤฿]\\s*((?<![.0-9])([0-9][0-9, ]*(\\.([0-9]{0,2})?)?|\\.[0-9]{1,2})(?![.0-9]))\\s*((hundred|thousand|million|billion|trillion|[KMB])\\s*([$¥€£¤฿]|dollars?|yen|pounds?|cad|usd|gbp|eur)?)?"
regex.patterns.phoneNumber:     "\\b((\\+?\\s*\\(?[0-9]+\\)?[-. /]?)?\\(?[0-9]+\\)?[-. /]?)?[0-9]{3}[-. ][0-9]{4}(\\s*(x|ext\\s*.?|extension)[ .-]*[0-9]+)?\\b"
regex.patterns.emailAddress:    "\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}\\b"
regex.patterns.url:             "((https?|ftps?)://(www\\d{0,3}\\.)?|www\\d{0,3}\\.)[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/))"
regex.patterns.zipCode:         "\\b\\d{5}\\b"
regex.patterns.postalCode:      "\\b[a-z]\\d[a-z] ?\\d[a-z]\\d\\b"
regex.patterns.postalOrZipCode: "\\b(\\d{5}|[a-z]\\d[a-z] ?\\d[a-z]\\d)\\b"
regex.patterns.dtsep:           "[\\t .,-/\\\\]+"
regex.patterns.day:             "\\b[0-3]?[0-9](st|nd|rd|th)?\\b"
regex.patterns.month:           "\\b([01]?[0-9]|jan(uary)?|feb(ruary)?|mar(ch)?|apr(il)?|may|jun(e)?|jul(y)?|aug(ust)?|sep(tember)?|oct(ober)?|nov(ember)?|dec(ember)?)\\b"
regex.patterns.year:            "\\b([12][0-9])?[0-9]{2}\\b"
regex.patterns.yearfull:        "\\b[12][0-9]{3}\\b"
regex.patterns.am:              "(a[.\\s]?m\\.?)"
regex.patterns.pm:              "(p[.\\s]?m\\.?)"
regex.patterns.time12:          "\\b[012]?[0-9]:[0-5][0-9](h|(:[0-5][0-9])([.:][0-9]{1,9})?)?\\s*(",sv["|";regex.patterns`am`pm],")?\\b"
regex.patterns.time24:          "\\b[012][0-9][0-5][0-9]h\\b"
regex.patterns.time:            "(",sv["|";regex.patterns`time12`time24],")"
regex.patterns.yearmonthList:   "(",sv["|";regex.patterns`year`month    ],")"
regex.patterns.yearmonthdayList:"(",sv["|";regex.patterns`year`month`day],")"
regex.patterns.yearmonth:       "(",sv[regex.patterns.dtsep;2#enlist regex.patterns.yearmonthList   ],")"
regex.patterns.yearmonthday:    "(",sv[regex.patterns.dtsep;3#enlist regex.patterns.yearmonthdayList],")"

regex.objects:regex.compile[;1b]each 1_regex.patterns
