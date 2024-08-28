// code/regex.q - Nlp regex utilities
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities for regular expresions

\d .nlp

// @private
// @kind function
// @category nlpRegexUtility
// @desc Import the regex module from python
regex.i.re:.p.import`re

// @private
// @kind function
// @category nlpRegexUtility
// @desc Check if a pattern occurs in the text
// @params patterns {<} A regex pattern as an embedPy object
// @params text {string} A piece of text
// @returns {boolean} Indicate whether or not the pattern is present in the
//   text 
regex.i.check:{[patterns;text]
  i.bool[patterns[`:search] pydstr text]`
  }

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of special characters
// @type string
regex.i.patterns.specialChars:"[-[\\]{}()*+?.,\\\\^$|#\\s]"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of special characters
// @type string
regex.i.patterns.money:"[$¥€£¤฿]?\\s*((?<![.0-9])([0-9][0-9, ]*(\\.",
  "([0-9]{0,2})?)?|\\.[0-9]{1,2})(?![.0-9]))\\s*((hundred|thousand|million",
  "|billion|trillion|[KMB])?\\s*([$¥€£¤฿]|dollars?|yen|pounds?|cad|usd|",
  "gbp|eur))|[$¥€£¤฿]\\s*((?<![.0-9])([0-9][0-9, ]*(\\.([0-9]{0,2})?)?|",
  "\\.[0-9]{1,2})(?![.0-9]))\\s*((hundred|thousand|million|billion|",
  "trillion|[KMB])\\s*([$¥€£¤฿]|dollars?|yen|pounds?|cad|usd|gbp|eur)?)?"


// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of phone number characters
// @type string
regex.i.patterns.phoneNumber:"\\b((\\+?\\s*\\(?[0-9]+\\)?[-. /]?)?\\(?[0-9]+",
  "\\)?[-. /]?)?[0-9]{3}[-. ][0-9]{4}(\\s*(x|ext\\s*.?|extension)[ .-]*[0-9]",
  "+)?\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of email address characters
// @type string
regex.i.patterns.emailAddress:"\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of url characters
// @type string
regex.i.patterns.url:"((https?|ftps?)://(www\\d{0,3}\\.)?|www\\d{0,3}\\.)",
  "[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/))"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of zipcode characters
// @type string
regex.i.patterns.zipCode:"\\b\\d{5}\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of postal code characters
// @type string
regex.i.patterns.postalCode:"\\b[a-z]\\d[a-z] ?\\d[a-z]\\d\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of postal or zip code characters
// @type string
regex.i.patterns.postalOrZipCode:"\\b(\\d{5}|[a-z]\\d[a-z] ?\\d[a-z]\\d)\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of date separator characters
// @type string
regex.i.patterns.dateSeparate:"[\\b(of |in )\\b\\t .,-/\\\\]+"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of date characters
// @type string
regex.i.patterns.day:"\\b[0-3]?[0-9](st|nd|rd|th)?\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of monthly characters
// @type string
regex.i.patterns.month:"\\b([01]?[0-9]|jan(uary)?|feb(ruary)?|mar(ch)?|",
  "apr(il)?|may|jun(e)?|jul(y)?|aug(ust)?|sep(tember)?|oct(ober)?|nov(ember)?",
  "|dec(ember)?)\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of yearly characters
// @type string
regex.i.patterns.year:"\\b([12][0-9])?[0-9]{2}\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of year characters in full
// @type string
regex.i.patterns.yearFull:"\\b[12][0-9]{3}\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of am characters
// @type string
regex.i.patterns.am:"(a[.\\s]?m\\.?)"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of pm characters
// @type string
regex.i.patterns.pm:"(p[.\\s]?m\\.?)"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of time (12hr) characters
// @type string
regex.i.patterns.time12:"\\b[012]?[0-9]:[0-5][0-9](h|(:[0-5][0-9])([.:][0-9]",
  "{1,9})?)?\\s*(",sv["|";regex.i.patterns`am`pm],")?\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of time (24hr) characters
// @type string
regex.i.patterns.time24:"\\b[012][0-9][0-5][0-9]h\\b"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of all time characters
// @type string
regex.i.patterns.time:"(",sv["|";regex.i.patterns`time12`time24],")"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of year/month characters as a list
// @type string
regex.i.patterns.yearMonthList:"(",sv["|";regex.i.patterns`year`month],")"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of year/month/date characters
// @type string
regex.i.patterns.yearMonthDayList:"(",sv["|";
  regex.i.patterns`year`month`day],")"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of year/month characters along with date separators
// @type string
regex.i.patterns.yearMonth:"(",sv[regex.i.patterns.dateSeparate;
  2#enlist regex.i.patterns.yearMonthList],")"

// @private
// @kind data
// @category nlpRegexUtilityPattern
// @desc A string of year/month/date characters along with date
//   separators
// @type string
regex.i.patterns.yearMonthDay:"(",sv[regex.i.patterns.dateSeparate;
  3#enlist regex.i.patterns.yearMonthDayList],")"

// @kind function
// @category nlpRegex
// @desc Compile a regular expression pattern into a regular 
//   expression embedPy object which can be used for matching
// @params patterns {string} A regex pattern
// @params ignoreCase {boolean} Whether the case of the string is to be ignored
// @return {<} The compiled regex object
regex.compile:{[patterns;ignoreCase]
  case:$[ignoreCase;regex.i.re`:IGNORECASE;0];
  regex.i.re[`:compile][pydstr patterns;case]
  }

// @kind function
// @category nlpRegex
// @desc Finds all the matches in a string of text
// @params patterns {<} A regex pattern as an embedPy object
// @params text {string} A piece of text
// @returns {::|string[]} If the pattern is not present in the text a null
//   is returned. Otherwise, the pattern along with the index where the 
//   pattern begins and ends is returned
regex.i.matchAll:.p.eval["lambda p,t:[[x.group(),x.start(),x.end()]",
  "for x in p.finditer(t)]";<]
regex.matchAll:{cstring regex.i.matchAll[x;pydstr cstring y]}

// @kind function
// @category nlpRegex
// @desc Compile all patterns into regular expression objects
// @return {<} The compiled regex object
regex.objects:regex.compile[;1b]each 1_regex.i.patterns
