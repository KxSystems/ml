\d .nlp

// Turns string matching time regex into a q time
tm.parseTime:{
  tm:"T"$x where vs[" ";x][0]in"1234567890:.";
  ampm:regex.check[;x]each regex.objects`am`pm;
  tm+$[ampm[0]&12=`hh$tm;-1;ampm[1]&12>`hh$tm;1;0]*12:00}

// Find all times : list of 4-tuples (time; timeText; startIndex; 1+endIndex)
tm.findTimes:{time:(tm.parseTime each tmtxt[;0]),'tmtxt:regex.matchAll[regex.objects.time;x]; time where time[;0]<24:01}
