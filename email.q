\d .nlp

// Read mbox file, convert to table, parse metadata & content
email.i.getMboxText:{[fp]update text:.nlp.email.i.extractText each payload from email.i.parseMbox fp}

email.i.extractText:{
  $[10=type x;x;
    count i:where"text/plain"~/:ct:x`contentType;.z.s x[i 0]`payload;
    count i:where"text/html"~/:ct;.z.s x[i 0]`payload;
    "\n\n"sv .z.s each x`payload]}

// Graph of who emailed whom, inc number of mails
email.getGraph:{[msgs]
  0!`volume xdesc select volume:count i by sender,to from flip`sender`to!flip`$raze email.i.getToFrom each msgs}

// Get to/from pairs from an email
email.i.getToFrom:{[msg]
  ((msg[`sender;0;1];)each msg[`to;;1]),$[99=type p:msg`payload;raze .z.s each p;()]}

// Init python and q functions for reading mbox files
email.i.parseMail:{email.i.parseMbox1 email.i.msgFromString[x]`.}
email.i.parseMbox:{email.i.parseMbox1 each .p.list[<] .p.import[`mailbox;`:mbox]x}
email.i.parseMbox1:{k!email.get[k:`sender`to`date`subject`contentType`payload]@\:.p.wrap x}

email.i.bs:.p.import[`bs4]`:BeautifulSoup
email.i.getaddr:.p.import[`email;`:utils.getaddresses;<]
email.i.parsedate:.p.import[`email;`:utils.parsedate;<]
email.i.decodehdr:.p.import[`email.header;`:decode_header]
email.i.makehdr:.p.import[`email.header;`:make_header]
email.i.msgFromString:.p.import[`email]`:message_from_string

email.get.sender:{email.i.getaddr e where not(::)~'e:raze x[`:get_all;<]each("from";"resent-from")}
email.get.to:{email.i.getaddr e where not any(::;"")~/:\:e:raze x[`:get_all;<]each("to";"cc";"resent-to";"resent-cc")}
email.get.date:{"P"$"D"sv".:"sv'3 cut{$[1=count x;"0";""],x}each string 6#email.i.parsedate x[@;`date]}
email.get.subject:{$[(::)~(s:x[@;`subject])`;"";email.i.makehdr[email.i.decodehdr s][`:__str__][]`]}
email.get.contentType:{x[`:get_content_type][]`}
email.get.payload:{
  if[x[`:is_multipart][]`;:email.i.parseMbox1 each x[`:get_payload][]`];
  if["attachment"~x[`:get_content_disposition][]`;:""];
  if[not any(ct:x[`:get_content_type][]`)~/:("text/html";"text/plain";"message/rfc822");:""];
  p:i.str[x[`:get_payload;`decode pykw 1b];$[(::)~s:x[`:get_content_charset][]`;"us-ascii";s];"ignore"]`;
  if[ct~"text/html";:email.i.bs[p;"html.parser"][`:get_text;"\\n"]`];
  p}
