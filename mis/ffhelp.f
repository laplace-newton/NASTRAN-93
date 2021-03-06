      SUBROUTINE FFHELP (*,*,J)        
      CHARACTER*1     QMARK        
      CHARACTER*4     STOP,     YES,      HELP,     XX        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ DUMMY(3), IN        
      COMMON /XREADX/ NOUT        
      COMMON /XECHOX/ SKIP(2),  IECHOS        
      COMMON /QMARKQ/ QMARK        
      DATA    STOP,   YES,      HELP  /   'STOP',   'Y   ',   'HELP' /  
C        
C     THIS ROUTINE IS CALLED ONLY BY FF        
C        
      GO TO (10,50,100,120,140), J        
 10   WRITE (NOUT,20)        
 20   FORMAT (///1X,        
     1  'GENERATED OUTPUT CARDS ARE SAVED ONLY IF FILE NAME IS GIVEN.', 
     2  //,' YOU MAY ENTER NASTRAN EXECUTIVE CONTROL AND CASE CONTROL', 
     2  ' CARDS FIRST',/,' (NO INPUT ECHO ON SCREEN)', //,        
     3  ' ADDITIONAL INPUT INFORMATION WILL BE GIVEN WHEN YOU ENTER ',  
     3  12H'BEGIN BULK', //,        
     4  ' YOU MAY QUIT FREE-FIELD PROGRAM AT ANY TIME BY ENTERING ',    
     4  6H'STOP', /,' NORMALLY, JOB TERMINATES BY ',9H'ENDDATA', //,    
     5  ' YOU MAY USE ',10H'READFILE',' COMMAND TO READ ANY FILE WHICH',
     5  14H WAS 'STOPPED', /,        
     5  ' BEFORE, AND CONTINUE FROM WHERE THE PREVIOUS JOB ENDED', //,  
     6  ' FREE-FIELD INPUT IS AVAILABLE ONLY IN BULK DATA SECTION', /,  
     6  ' AND IS ACTIVATED BY A COMMA OR EQUAL SIGN IN COLS. 1 THRU 10',
     7  //,' BOTH UPPER-CASE AND LOWER-CASE LETTERS ARE ACCEPTABLE',//, 
     8  ' REFERENCE - G.CHAN: ',1H','COSMIC/NASTRAN FREE-FIELD INPUT',  
     8  2H',, /13X,'12TH NASTRAN USERS',1H',' COLLOQUIUM, MAY 1984')    
      WRITE (NOUT,30) QMARK        
 30   FORMAT (/,' MORE',A1,' (Y,N) - ')        
      READ (IN,40,END=80) XX        
 40   FORMAT (A4)        
      CALL UPCASE (XX,4)        
      IF (XX .NE. YES) GO TO 80        
C        
 50   WRITE (NOUT,60)        
 60   FORMAT (///,' THE FOLLOWING SYMBOLS ARE USED FOR FREE-FIELD INPUT'
     1, //10X,'SYMBOL', 12X,'FUNCTION',/,9X,2('----'),5X,10('----'),    
     2   /10X,', OR BLANK  FIELD SEPERATORS',        
     3   /10X,'  =         DUPLICATES ONE CORRESPONDING FIELD',        
     4   /10X,'  ==        DUPLICATES THE REMAINING FIELDS',        
     5   /10X,'  *(N)      INCREMENT BY N',        
     6   /10X,'  %(E)      ENDING VALUE BY E',        
     7   /10X,'  /         THIS INPUT FIELD IS SAME AS PREVIOUS FIELD', 
     8   /10X,'  J)        FIELD INDEX, J-TH FIELD (MUST FOLLOWED BY A V
     9ALUE)',        
     O   /10X,')+ OR 10)   INDEX FOR CONTINUATION FIELD',        
     A   /10X,'  )         (IN COL. 1 ONLY) DUPLICATES THE CONTINUATION 
     BID',/22X,'OF PREVIOUS CARD INTO FIELD 1 OF CURRENT CARD',        
     C   /10X,'  ,         COL.1 ONLY, AUTO-CONTINUATION ID GENERATION',
     D   /10X,'  =(N)      1ST FIELD ONLY, DUPLICATES N CARDS WITH PROPE
     ER',/22X,' INCREMENTS',        
     F   /12X,'+A-I',6X,'CONTINUATION ID CAN BE DUPLICATED AUTOMATICALLY
     G', /22X,'ONLY IF IT IS IN PLUS-ALPHA-MINUS-INTEGER FORM',        
     H  //1X,'EXAMPLES:',  /1X,'GRID, 101,,  0.  0. ,  7. 8)2  )+ABC-2',
     I   /1X,'=(11),*(1)  ,,  *(1.), /  %(23.45),==')        
      IF (J.EQ.1 .OR. IECHOS.NE.-2) GO TO 170        
      WRITE (NOUT,30) QMARK        
      READ (IN,40,END=80) XX        
      CALL UPCASE (XX,4)        
      IF (XX .EQ. YES) GO TO 140        
 80   IF (XX .EQ. STOP) RETURN 2        
      IF (MACH.EQ.4 .AND. IN.EQ.5) REWIND IN        
      GO TO 190        
C        
 100  WRITE (NOUT,110)        
 110  FORMAT (//,24H ENTER 'N' FOR NO PUNCH,, /7X,        
     1       38H'Y' FOR PUNCH IN FREE-FIELD FORMAT, OR, /7X,        
     2       43H'X' FOR PUNCH IN NASTRAN FIXED-FIELD FORMAT,/)        
      GO TO 190        
C        
 120  WRITE (NOUT,130)        
 130  FORMAT (/,' MIFYLE - IS A RESERVED WORD.  TRY ANY OTHER NAME')    
      GO TO 190        
C        
 140  WRITE (NOUT,150)        
 150  FORMAT (//,' *** FREE-FIELD INPUT IS OPTIONAL.',//5X,'FOUR (4)',  
     1 ' CONTROL OPTIONS ARE AVAILABLE - CAN BE ENTERED AT ANY TIME',   
     2 /7X,'1.  PROMPT=ON, PROMPT=OFF, OR PROMPT=YES(DEFAULT)',        
     3 /7X,'2.  SCALE/10,  OR SCALE/8',        
     4 /7X,'3.  CANCEL=N,  (TO CANCEL N PREVIOUSLY GENERATED CARDS)',   
     5 /7X,'4.  LIST  =N,  (TO   LIST N PREVIOUSLY GENERATED CARDS)',   
     6//7X,'ENTER ''HELP'' IF YOU NEED ADDITIONAL INSTRUCTIONS',        
     7//7X,'INTEGER INPUT SHOULD BE LIMITED TO 8 DIGITS',        
     8 /7X,'UP TO 12 DIGITS ARE ALLOWED FOR FLOATING PT. NUMBER INPUT', 
     9 /7X,'HOWEVER, ONLY UP TO 8 DIGIT ACCURACY IS KEPT',        
     O /7X,'             INPUT           RESULT ',        
     1 /7X,'         ------------       --------',        
     2 /7X,'E.G.     123.456789         123.4567',        
     3 /7X,'         123.456789+6       .12345+9',        
     4 /7X,'         -123.4567D+5       -.1234+8',        
     5 /7X,'         123.45678E+4       1234567.',        
     6 /7X,'         0.00123456-3       .12345-5',        
     7 /7X,'         0.0123456789       .0123456',        
     8 /7X,'         .00000123456       .12345-5')        
      IF (IECHOS .NE. -2) WRITE (NOUT,160)        
 160  FORMAT (/7X,'(3 AND 4 ARE AVAILABLE ONLY IN THE FREE-FIELD STAND',
     1     '-ALONE VERSION)')        
 170  WRITE (NOUT,180)        
 180  FORMAT (/4X,'UP TO 94 CHARATERS ALLOWABLE ON AN INPUT LINE. ',    
     1       ' C/R TO CONTINUE')        
      READ (IN,40,END=80) XX        
      CALL UPCASE (XX,4)        
      IF (XX .EQ. HELP) GO TO 50        
      IF (J .NE. 1) GO TO 80        
 190  RETURN 1        
      END        
