\l nlp.q
\l init.q
\d .nlp
lines: read0 `:tests/data/test.mbox;
emails:email.parseMail each "\n" sv/:  (where lines like "From *") cut lines;
to: 9#enlist enlist("";"john.doe@domain.com");
to[0;0;0]:"John Doe";
emails[`to]~to
emails[`date]~2018.05.16D10:58:23.000000000 2018.05.11D13:11:26.000000000 2018.05.12D20:01:07.000000000 2017.12.22D12:00:54.000000000 2018.05.11D18:23:59.000000000 2018.04.02D16:32:17.000000000 2015.08.06D09:08:35.000000000 2018.05.03D04:53:48.000000000 2018.05.14D03:01:14.000000000
emails[`sender]~enlist each(("John Doe";"john.doe@domain.com");("Duolingo";"no-reply@duolingo.com");("Dan from Kaggle";"dan.becker@kaggle.intercom-mail.com");("Lowe's Canada";"reply@e.lowes.ca");("=?UTF-8?Q?Hydro=20One?=";"customercommunications@hydroone.com");("Fred";"fredrodriguezes@gmail.com");("Magellan GPS";"emailupdates@magellangps.com");("=?UTF-8?Q?Hydro=20One?="; "customercommunications@hydroone.com");("PRESTO Customer Service";"prestomailer@prestocard.ca"))
emails[`subject]~("test email";"The new Duolingo experience is here!";"Our New Hands-On Data Science Courses";"\360\237\216\211 You’re Invited to our Gloucester Grand Opening!";"Thank you for your patience during the wind storm";"App/Web Development";"Up to 60% OFF | Magellan Sports Watch New Back-to-School Essential";"Deal Days ends this Sunday - Don’t miss out!";"PRESTO – Account Lockout / PRESTO – Compte verrouillé")
emails[`payload][0]~([] sender:(();());to:(();());date:(2#("p"$()));subject:(""; "");contentType:("text/plain"; "text/html");payload:(`attachment`content!(0b;"This is a test\n");`attachment`content!(0b;"<div dir=\"ltr\">This is a test</div>\n")))
text:ssr[email.i.html2text emails[`payload][6][`content];"\\n";"\n"]
whitespace:regex.compile["\\s+"; 1b]
regex.replaceAll:{x[`:sub;<][y;z]}
regex.replaceAll[whitespace; " "; text] ~" FREE SHIPPING to US Address on Any Order Over $99.99 Switch Series and Accessories Designed for multi-sport athletes who run,"," bike or swim and want GPS tracking on their watch. 60% OFF Echo Series For the athlete using phone apps when participating in a sport."," Wether you golf, run, hike, etc. you can display and control compatible apps and music playlists conveniently from your wrist."," 20% OFF Follow Magellan 2015 MiTAC International Corporation."," All rights reserved 471 El Camino Real, Santa Clara, CA, 95050, USA Click Here to Opt Out. . "
\d .
