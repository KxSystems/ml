// code/email.q - Nlp email utilities
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities for handling emails

\d .nlp

// @private
// @kind function
// @category nlpEmailUtility
// @desc Rich Text Format (RTF) parsing function imported from python
email.i.striprtf:.p.get[`striprtf;<]

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract information from various message text types
// @params textTyp {string} The format of the message text 
// @param msg {string|dictionary} An email message, or email subtree
// @returns {boolean} Whether or not msg fits the text type criteria 
email.i.findMime:{[textTyp;msg]
  msgDict:99=type each msg`payload;
  contentTyp:textTyp~/:msg`contentType;
  attachment:0b~'msg[`payload]@'`attachment;
  all(msgDict;contentTyp;attachment)
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Use beautiful soup to extract text from a html file
// @param msg {string} The message payload
// @returns {string} The text from the html
email.i.html2text:{[msg]
  email.i.bs[msg;"html.parser"][`:get_text;"\\n"]`
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Given an email, extract the text of the email
// @param msg {string|dictionary} An email message, or email subtree
// @returns {string} The text of the email, or email subtree
email.i.extractText:{[msg]
  // String is actual text, bytes attachment or non text mime type like inline 
  // image, dict look at content element
  msgType:type msg;
  if[10=msgType;:msg];
  if[4=msgType;:""];
  if[99=msgType;:.z.s msg`content];
  findMime:email.i.findMime[;msg];
  text:$[count i:where findMime["text/plain"];
      {x[y][`payload]`content}[msg]each i;
    count i:where findMime["text/html"];
      {email.i.html2text x[y][`payload]`content}[msg]each i;
    count i:where findMime["application/rtf"];
      // Use python script to extract text from rtf
      {email.i.striprtf x[y][`payload]`content}[msg]each i;
    .z.s each msg`payload
    ];
  "\n\n"sv text
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Get all the to/from pairs from an email
// @param msg {dictionary} An email message, or subtree thereof
// @returns {any[]} To/from pairings of an email
email.i.getToFrom:{[msg]
  payload:msg`payload;
  payload:$[98=type payload;raze .z.s each payload;()];
  edges:(msg[`sender;0;1];)each msg[`to;;1];
  edges,payload
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract the sender information from an email
// @param emails {<} The email as an embedPy object
// @returns {string[]} Sender name and email
email.i.getSender:{[emails]
  fromInfo:raze emails[`:get_all;<]each("from";"resent-from");
  email.i.getAddr fromInfo where not(::)~'fromInfo
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract the receiver information from an email
// @param emails {<} The email as an embedPy object
// @returns {string[]} Reciever name and email
email.i.getTo:{[emails]
  toInfo:raze emails[`:get_all;<]each("to";"cc";"resent-to";"resent-cc");
  email.i.getAddr toInfo where not any(::;"")~/:\:toInfo
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract the date information from an email
// @param emails {<} The email as an embedPy object
// @returns {timestamp} Date email was sent
email.i.getDate:{[emails]
  dates:string 6#email.i.parseDate emails[@;`date];
  "P"$"D"sv".:"sv'3 cut{$[1=count x;"0";""],x}each dates
  }
 
// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract the subject information from an email
// @param emails {<} The email as an embedPy object
// @returns {string} Subject of the email
email.i.getSubject:{[emails]
  subject:emails[@;`subject];
  $[(::)~subject`;
    "";
    email.i.makeHdr[email.i.decodeHdr subject][`:__str__][]`
    ]
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract the content type of an email
// @param emails {<} The email as an embedPy object
// @returns {string} Content type of an email 
email.i.getContentType:{[emails]
  emails[`:get_content_type][]`
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract the payload information from an email
// @param emails {<} The email as an embedPy object
// @returns {dictionary|table} Dictionary of `attachment`content or a table 
//   of payloads
//   Content is byte[] for binary data, char[] for text
email.i.getPayload:{[emails]
  if[emails[`:is_multipart][]`;
    :email.i.parseMbox1 each emails[`:get_payload][]`
    ];
  // Raw bytes decoded from base64 encoding, wrapped embedPy
  raw:emails[`:get_payload;`decode pykw 1]; 
  rtf:"application/rtf"~email.i.getContentType emails;
  attachment:"attachment"~emails[`:get_content_disposition][]`;
  payload:`attachment`content!(0b;raw`);
  if[all(rtf;attachment);:payload];
  if[attachment;
    payload,`attachment`filename!(1b;email[`:get_filename][]`);
    ];
  content:email.i.getContentType emails;
  if[not any content~/:("text/html";"text/plain";"message/rfc822");:payload];
  charset:emails[`:get_content_charset][]`;
  content:i.str[raw;$[(::)~charset;"us-ascii";charset];"ignore"]`;
  `attachment`content!(0b;content)
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract meta information from an email 
// @params filepath {string} The path to the mbox
// @returns {dictionary} Meta information from the email
email.i.parseMbox:{[filepath]
  mbox:email.i.mbox filepath;
  email.i.parseMbox1 each .p.list[<] mbox
  }

// @private
// @kind function
// @category nlpEmailUtility
// @desc Extract meta information from an email 
// @params mbox {<} Emails in mbox format
// @returns {dictionary} Meta information from the email
email.i.parseMbox1:{[mbox]
  columns:`sender`to`date`subject`contentType`payload;
  msgInfo:`getSender`getTo`getDate`getSubject`getContentType`getPayload;
  columns!email.i[msgInfo]@\:.p.wrap mbox
  }

// Python imports
email.i.bs:.p.import[`bs4]`:BeautifulSoup
email.i.getAddr:.p.import[`email.utils;`:getaddresses;<]
email.i.parseDate:.p.import[`email.utils;`:parsedate;<]
email.i.decodeHdr:.p.import[`email.header;`:decode_header]
email.i.makeHdr:.p.import[`email.header;`:make_header]
email.i.msgFromString:.p.import[`email]`:message_from_string
email.i.mbox:.p.import[`mailbox]`:mbox


// @kind function
// @category nlpEmail
// @desc Convert an mbox file to a table of parsed metadata
// @param filepath {string} The path to the mbox file
// @returns {table} Parsed metadata and content of the mbox file
email.loadEmails:{[filepath]
  parseMbox:email.i.parseMbox filepath;
  update text:.nlp.email.i.extractText each payload from parseMbox
  }

// @kind function
// @category nlpEmail
// @desc Get the graph of who emailed who, including the number of
//   times they emailed
// @param emails {table} The result of .nlp.loadEmails
// @returns {table} Defines to-from pairings of emails
email.getGraph:{[emails]
  getToFrom:flip`$raze email.i.getToFrom each emails;
  getToFromTab:flip`sender`to!getToFrom;
  0!`volume xdesc select volume:count i by sender,to from getToFromTab
  }

// @kind function
// @category nlpEmailUtility
// @desc Extract meta information from an email
// @params filepath {string} The path to where the email is stored
// @returns {dictionary} Meta information from the email
email.parseMail:{[filepath]
  email.i.parseMbox1 email.i.msgFromString[filepath]`.
  }
