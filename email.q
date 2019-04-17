\d .nlp

//Loading python script to extract rtf text
system"l ",.nlp.path,"/","extract_rtf.p";
striprtf:.p.get[`striprtf;<]

// Read mbox file, convert to table, parse metadata & content
email.i.getMboxText:{[fp]update text:.nlp.email.i.extractText each payload from email.i.parseMbox fp}

email.i.findmime:{all(99=type each y`payload;x~/:y`contentType;0b~'y[`payload]@'`attachment)}
email.i.html2text:{email.i.bs[x;"html.parser"][`:get_text;"\\n"]`} / extract text from html
email.i.extractText:{
 / string is actual text, bytes attachment or non text mime type like inline image, dict look at content element
 $[10=type x;x;4=type x;"";99=type x;.z.s x`content;
   count i:where email.i.findmime["text/plain"]x;"\n\n"sv{x[y][`payload]`content}[x]each i;
   / use beautiful soup to extract text from html
   count i:where email.i.findmime["text/html"]x ;"\n\n"sv{email.i.html2text x[y][`payload]`content}[x]each i;
   / use python script to extract text from rtf
   count i:where email.i.findmime["application/rtf"]x ;"\n\n"sv{striprtf x[y][`payload]`content}[x]each i;
   "\n\n"sv .z.s each x`payload]}


// Graph of who emailed whom, inc number of mails
email.getGraph:{[msgs]
  0!`volume xdesc select volume:count i by sender,to from flip`sender`to!flip`$raze email.i.getToFrom each msgs}

// Get to/from pairs from an email
email.i.getToFrom:{[msg]
  ((msg[`sender;0;1];)each msg[`to;;1]),$[98=type p:msg`payload;raze .z.s each p;()]}

// Init python and q functions for reading mbox files
email.i.parseMail:{email.i.parseMbox1 email.i.msgFromString[x]`.}
email.i.parseMbox:{email.i.parseMbox1 each .p.list[<] .p.import[`mailbox;`:mbox]x}
email.i.parseMbox1:{k!email.get[k:`sender`to`date`subject`contentType`payload]@\:.p.wrap x}

email.i.bs:.p.import[`bs4]`:BeautifulSoup
email.i.getaddr:.p.import[`email.utils;`:getaddresses;<]
email.i.parsedate:.p.import[`email.utils;`:parsedate;<]
email.i.decodehdr:.p.import[`email.header;`:decode_header]
email.i.makehdr:.p.import[`email.header;`:make_header]
email.i.msgFromString:.p.import[`email]`:message_from_string

email.get.sender:{email.i.getaddr e where not(::)~'e:raze x[`:get_all;<]each("from";"resent-from")}
email.get.to:{email.i.getaddr e where not any(::;"")~/:\:e:raze x[`:get_all;<]each("to";"cc";"resent-to";"resent-cc")}
email.get.date:{"P"$"D"sv".:"sv'3 cut{$[1=count x;"0";""],x}each string 6#email.i.parsedate x[@;`date]}
email.get.subject:{$[(::)~(s:x[@;`subject])`;"";email.i.makehdr[email.i.decodehdr s][`:__str__][]`]}
email.get.contentType:{x[`:get_content_type][]`}
/ return a dict of `attachment`content or a table of payloads, content is byte[] for binary data, char[] for text
email.get.payload:{
 if[x[`:is_multipart][]`;:email.i.parseMbox1 each x[`:get_payload][]`];
 raw:x[`:get_payload;`decode pykw 1]; / raw bytes decoded from base64 encoding, wrapped embedPy
 if[all("application/rtf"~(x[`:get_content_type][]`);"attachment"~x[`:get_content_disposition][]`);:`attachment`content!(0b;raw`)];
 if["attachment"~x[`:get_content_disposition][]`;:`attachment`content`filename!(1b;raw`;x[`:get_filename][]`)];
 /if text is in rtf, mbox treats it as an attachment
 /if[all("application/rtf"~(x[`:get_content_type][]`);"attachment"~x[`:get_content_dispositon][]`);:`attachment`content!(0b;raw`)];
 / e.g. inline images, return raw bytes in payload
 if[not any(ct:x[`:get_content_type][]`)~/:("text/html";"text/plain";"message/rfc822");:`attachment`content!(0b;raw`)];
 :`attachment`content!(0b;i.str[raw;$[(::)~s:x[`:get_content_charset][]`;"us-ascii";s];"ignore"]`)
 }
