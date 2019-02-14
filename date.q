\d .nlp

// Pad day string to 2 digits
tm.parseDay:{-2#"0",x where x in .Q.n}

// Convert month string and pad to 2 digits
tm.months:`jan`feb`mar`apr`may`jun`jul`aug`sep`oct`nov`dec!`$string 1+til 12
tm.parseMonth:{-2#"0",string x^tm.months x:lower`$3 sublist x}

// Pad year string to 4 digits (>35 deemed 1900s)
tm.parseYear:{-4#$[35<"I"$-2#x;"19";"20"],x}

// Convert year string to date range
tm.convY:{"D"$x,/:(".01.01";".12.31")}

// Convert yearmonth string to date range
tm.convYM:{
  matches:ungroup([fmt:"ym"]txt:regex.matchAll[;x]each regex.objects`year`month);
  matches:value select fmt,last txt by s from matches,'flip`txt`s`e!flip matches`txt;
  fmt:{@[x;where not xx;except[;raze x where xx:1=count each x]]}/[matches`fmt];
  fmt:raze@[fmt;i where 1<count each i:group fmt;:;" "];
  0 -1+"d"$0 1+"M"$"."sv tm[`parseYear`parseMonth]@'matches[`txt]idesc fmt}

// Convert yearmonthday string to date range
tm.convYMD:{
  matches:ungroup([fmt:"ymd"]txt:regex.matchAll[;x]each regex.objects`year`month`day);
  matches:value select fmt,last txt by s from matches,'flip`txt`s`e!flip matches`txt;
  fmt:{@[x;i unq;:;"ymd" unq:where 1=count each i:where each "ymd" in/:\:x]}/[matches`fmt];
  fmt:tm.resolveFormat raze@[fmt;where 1<count each fmt;:;" "];  
  2#"D"$"."sv tm[`parseYear`parseMonth`parseDay]@'matches[`txt]idesc fmt}

// Fill in blanks in date format string
tm.resolveFormat:{$[0=n:sum" "=x;;1=n;ssr[;" ";first"ymd"except x];2=n;tm.dateFormats;{"dmy"}]x}

tm.dateFormats:(!). flip( / fmt given single known position
  ("d  ";"dmy"); // 2nd 12 12
  ("m  ";"mdy"); // Jan 12 12
  ("y  ";"ymd"); // 1999 12 12
  (" d ";"mdy"); // 12 2nd 12
  (" m ";"dmy"); // 12 Jan 12
  (" y ";"dym"); // 12 1999 12 This is never conventionally used
  ("  d";"ymd"); // 12 12 2nd
  ("  m";"ydm"); // 12 12 Jan This is never conventionally used
  ("  y";"dmy")) // 12 12 1999 //mdy is the american option

// Find all dates : list of 5-tuples (startDate; endDate; dateText; startIndex; 1+endIndex)
tm.findDates:{[text]
  rmInv:{x where not null x[;0]};
  ym:regex.matchAll[regex.objects.yearmonth;text];
  ymd:regex.matchAll[regex.objects.yearmonthday;text];
  dts:rmInv(tm.convYMD each ymd[;0]),'ymd;
  if[count dts;ym@:where not any ym[;1] within/: dts[; 3 4]];
  dts,:rmInv(tm.convYM each ym[;0]),'ym;
  dts iasc dts[;3]}

