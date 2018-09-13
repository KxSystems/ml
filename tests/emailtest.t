\d .nlp
lines:read0 `:./data/test.mbox;
emails:email.i.parseMail each "\n" sv/:  (where lines like "From *") cut lines;
to: 9#enlist enlist("";"john.doe@domain.com");
to[0;0;0]:"John Doe";
emails[`to]~to
emails[`date]~2018.05.16D10:58:23.000000000 2018.05.11D13:11:26.000000000 2018.05.12D20:01:07.000000000 2017.12.22D12:00:54.000000000 2018.05.11D18:23:59.000000000 2018.04.02D16:32:17.000000000 2015.08.06D09:08:35.000000000 2018.05.03D04:53:48.000000000 2018.05.14D03:01:14.000000000
emails[`sender]~enlist each(("John Doe";"john.doe@domain.com");("Duolingo";"no-reply@duolingo.com");("Dan from Kaggle";"dan.becker@kaggle.intercom-mail.com");("Lowe's Canada";"reply@e.lowes.ca");("=?UTF-8?Q?Hydro=20One?=";"customercommunications@hydroone.com");("Fred";"fredrodriguezes@gmail.com");("Magellan GPS";"emailupdates@magellangps.com");("=?UTF-8?Q?Hydro=20One?="; "customercommunications@hydroone.com");("PRESTO Customer Service";"prestomailer@prestocard.ca"))
emails[`subject]~("test email";"The new Duolingo experience is here!";"Our New Hands-On Data Science Courses";"\360\237\216\211 You’re Invited to our Gloucester Grand Opening!";"Thank you for your patience during the wind storm";"App/Web Development";"Up to 60% OFF | Magellan Sports Watch New Back-to-School Essential";"Deal Days ends this Sunday - Don’t miss out!";"PRESTO – Account Lockout / PRESTO – Compte verrouillé")
emails[`payload][0]~([] sender:(();());to:(();());date:(2#("p"$()));subject:(""; "");contentType:("text/plain"; "text/html");payload:(`attachment`content!(0b;"This is a test\n");`attachment`content!(0b;"<div dir=\"ltr\">This is a test</div>\n")))
/(47 1118 286 43 3115 127 13011)~count each exec text from .nlp.loadEmails"data/message.mbox"
((exec payload from .nlp.loadEmails"data/message.mbox")[1]`payload)[1][`attachment]=1
((exec payload from .nlp.loadEmails"data/message.mbox")[3]`payload)[1][`attachment]=0
("multipart/alternative";"multipart/mixed";"multipart/alternative";"multipart/alternative";"multipart/mixed";"multipart/related";"multipart/mixed")~exec contentType from  .nlp.loadEmails"data/message.mbox"
\d .
