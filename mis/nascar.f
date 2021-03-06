      SUBROUTINE NASCAR        
C        
C     NASCAR READS THE NASTRAN CARD (IF PRESENT) AND CALLS TTLPGE.      
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ORF,COMPLF        
      INTEGER         HDG(14),NSTRN(2),IDATE(3),BDT(7),FILES(2),        
     1                MODCOM(9),KEYWDS(2,17),BUF(75)        
      REAL            S1,RTOLEL        
      CHARACTER       UFM*23,UWM*25,S2*16        
      COMMON /XMSSG / UFM,UWM        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ SYSTEM(100)        
      COMMON /BLANK / FLAG,CARD(20)        
      COMMON /OUTPUT/ PGHDG(96)        
      COMMON /XFIST / NFIST,LFIST,FIST(2)        
      COMMON /XPFIST/ NPFIST        
      COMMON /LHPWX / LHPW(4),MXFL        
      EQUIVALENCE     (SYSTEM( 1),SYSBUF),        
     1                (SYSTEM( 2),OUTTAP),        
     2                (SYSTEM( 3),NOGO  ),        
     3                (SYSTEM( 4),INTAP ),        
     4                (SYSTEM( 7),LOGFL ),        
     5                (SYSTEM(20),PLTFLG),        
     6                (SYSTEM(29),MAXFIL),        
     7                (SYSTEM(30),MAXOPN),        
     8                (SYSTEM(34),IDRUM ),        
     9                (SYSTEM(42),IDATE(1)),        
     O                (SYSTEM(57),MODCOM(1)),        
     A                (SYSTEM(70),ITOLEL,RTOLEL),        
     B                (SYSTEM(77),BANDIT)        
C        
      DATA NSTRN  /4HNAST,  4HRAN /        
      DATA FILES  /4HFILE,  1HS   /, BLANK / 1H  /        
      DATA LKEYWD /   17 /        
      DATA KEYWDS /4HBUFF,  4HSIZE,        
     2             4HCONF,  4HIG  ,        
     3             4HMAXF,  4HILES,        
     4             4HMAXO,  4HPEN ,        
     5             4HSYST,  4HEM  ,        
     6             4HKON3,  4H60  ,        
     7             4HNLIN,  4HES  ,        
     8             4HTITL,  4HEOPT,        
     9             4HMODC,  4HOM  ,        
     O             4HHICO,  4HRE  ,        
     1             4HDRUM,  4H    ,        
     2             4HTRAC,  4HKS  ,        
     3             4HSTST,  4H    ,        
     4             4HBAND,  4HIT  ,        
     5             4HBULK,  4HDATA,        
     6             4HPLOT,  4HOPT ,        
     7             4HLOGF,  4HL   /        
      DATA HDG    /4HN A ,4HS T ,4HR A ,4HN  S,4H Y S,4H T E,4H M  ,    
     1             4HP A ,4HR A ,4HM E ,4HT E ,4HR  E,4H C H,4H O  /    
      DATA BDT    /4HTCRI,4HTMTH,4HTMPC,4HTDEP,4HTPCH,4HTRUN,4HTDIM/    
      DATA TOPT   /  -9  /        
C     DATA ADD    /4H@ASG,4H,T  ,4HLOG-,4HFILE,4H.,F ,4H .  /        
      DATA IMNTH  ,IYR1, IYR2   /4HAPR.,3H 19, 2H93  /        
      DATA S1,S2  /4HWORD, ' OF /SYSTEM/ IS '/        
C        
C        
C     SET SYSTEM RELEASE DATE        
C        
      IDATE(1) = IMNTH        
      IDATE(2) = IYR1        
      IDATE(3) = IYR2        
C        
C     CONMSG (BCD7,1,1)        
      MASK1 = COMPLF(0)        
      MASK2 = RSHIFT(MASK1,1)        
C        
C     CALL NSINFO TO OPEN NAINFO FILE AND PICK UP ANY PRESET SYSTEM     
C     PARAMETERS FROM THE SECOND SECTION OF THAT FILE        
C        
      J = 2        
      CALL NSINFO (J)        
      IF (J .NE. 2) TOPT = J        
C        
C     READ FIRST CARD IN DATA STREAM AND CALL XRCARD TO CONVERT IT.     
C     IF INPUT CARD IS BLANK, READ NEXT CARD        
C        
   10 CALL XREAD (*3500,CARD)        
      IF (CARD(1).EQ.BLANK .AND. CARD(2).EQ.BLANK .AND. CARD(3).EQ.BLANK
     1   .AND. CARD(5).EQ.BLANK .AND. CARD(7).EQ.BLANK) GO TO 10        
      CALL XRCARD (BUF,75,CARD)        
      FLAG = 1        
      IF (BUF(1)) 4000,15,20        
   15 IF (NOGO .EQ. 0) GO TO 10        
      NOGO = 0        
      GO TO 4000        
C        
C     IF CARD IS NASTRAN PARAMETER CARD, ECHO IT.        
C        
   20 IF (BUF(2).NE.NSTRN(1) .OR. BUF(3).NE.NSTRN(2)) GO TO 4000        
      DO 25 I = 1,14        
   25 PGHDG(I+2) = HDG(I)        
      IF (SYSTEM(11) .LE. 0) CALL PAGE1        
      WRITE  (OUTTAP,30) (CARD(I),I=1,20)        
   30 FORMAT (5X,20A4)        
C        
C     RETURN IF NO KEYWORD ON NASTRAN CARD        
C        
      IF (BUF(4) .EQ. MASK2) GO TO 4000        
      FLAG = 0        
C        
C     IDENTIFY KEYWORDS AND BRANCH TO APPROPRIATE CODE.        
C        
      J  = 4        
   35 JN = 2*BUF(1) + 1        
      J1 = 1        
      GO TO 50        
   40 IF (BUF(J1)) 85,45,50        
   45 CALL XREAD  (*3500,CARD)        
      CALL XRCARD (BUF,75,CARD)        
      WRITE (OUTTAP,30) CARD        
      IF (BUF(1) .EQ. 0) GO TO 45        
      J = 2        
      GO TO 35        
   50 IF (BUF(J1) .EQ. MASK2) GO TO 4000        
      DO 55 I = 1,LKEYWD        
      IF (BUF(J).EQ.KEYWDS(1,I) .AND. BUF(J+1).EQ.KEYWDS(2,I)) GO TO 110
   55 CONTINUE        
      IF (BUF(J) .EQ. KEYWDS(1,14)) GO TO 100        
      IF (BUF(J) .EQ. FILES(1)) GO TO 3000        
      IF (BUF(J) .NE. BLANK) GO TO 60        
      J = J + 2        
      IF (BUF(J+2) .EQ. MASK2) GO TO 4000        
      IF (BUF(J) .EQ. 0) GO TO 45        
      IF (J .LT. JN) GO TO 50        
      J1 = JN + 1        
      IF (BUF(J1) .EQ. MASK2) GO TO 4000        
      JN = 2*BUF(J1) + 1        
      J  = J1 + 1        
      GO TO 50        
C        
C     PRINT MESSAGE FOR UNIDENTIFIED KEYWORD.        
C        
   60 CONTINUE        
      WRITE  (OUTTAP,65) UFM,BUF(J),BUF(J+1)        
   65 FORMAT (A23,' 17, UNIDENTIFIED NASTRAN CARD KEYWORD ',2A4,        
     1        '.  ACCEPTABLE KEYWORDS FOLLOW ---', /1H0 )        
      DO 70 I = 1,LKEYWD        
      WRITE (OUTTAP,75) KEYWDS(1,I),KEYWDS(2,I)        
   70 CONTINUE        
   75 FORMAT (5X,2A4)        
      WRITE  (OUTTAP,80) (BDT(I),I=1,7)        
   80 FORMAT (7(5X,4HBAND,A4),        
     1        /5X,'FILES (MUST BE LAST IN INPUT LIST)')        
      NOGO = 1        
      GO TO 4000        
C        
C     PRINT MESSAGE FOR BAD FORMAT.        
C        
   85 WRITE  (OUTTAP,90) UFM        
   90 FORMAT (A23,' 43, INCORRECT FORMAT FOR NASTRAN CARD.')        
      NOGO = 1        
      GO TO 4000        
C        
C     . CHECK FOR LEGAL REAL NUMBER...        
C        
   95 CONTINUE        
      IF (BUF(J1-2) .NE. -2) GO TO 85        
      IF (BUF(J1-2) .EQ. -2) GO TO 120        
      IF (I .EQ. 11) GO TO 1100        
C        
C     . BANDIT KEYWORDS.        
C        
  100 I = 1400        
      K = BUF(J+1)        
C        
C     KEYWORD FOUND.        
C        
  110 CONTINUE        
      J1 = JN + 1        
      PARAM = BUF(J1+1)        
      J1 = J1 + 2        
      IF (BUF(J1) .NE. MASK2) JN = 2*BUF(J1) + J1        
      J  = J1 + 1        
      IF (BUF(J1-2) .NE. -1) GO TO 95        
  120 CONTINUE        
      IF (I .EQ. 1400) GO TO 1400        
      GO TO ( 150, 200, 300, 400, 500, 600, 700, 800, 900,1000,        
     1       1100,1200,1300,1450,1500,1600,1700),  I        
C        
C     BUFFSIZE        
C        
  150 CONTINUE        
      SYSBUF = PARAM        
      GO TO 40        
C        
C     IGNORE THE CONFIG PARAMETER        
C        
  200 CONTINUE        
      GO TO 40        
C        
C     MAXFILES UPPER LIMIT        
C        
  300 CONTINUE        
      M = MXFL        
      IF (PARAM .LE. M) GO TO 320        
      WRITE  (OUTTAP,310) M        
  310 FORMAT (' *** MAXFILES IS RESET TO THE LIMIT OF 74')        
      PARAM = M        
  320 MAXFIL = PARAM        
      GO TO 40        
C        
C     MAXOPEN        
C        
  400 CONTINUE        
      IF (PARAM .LE. MAXFIL) GO TO 420        
      IF (PARAM .GT.   MXFL) GO TO 430        
      WRITE  (OUTTAP,410) PARAM        
  410 FORMAT (' *** MAXOPEN EXCEEDS MAXFILES. MAXFILES IS AUTOMATICALLY'
     1,       ' EXPANDED TO',I4)        
      MAXFIL = PARAM        
  420 MAXOPN = PARAM        
      GO TO 40        
C        
  430 M = MXFL        
      WRITE  (OUTTAP,440) M,M        
  440 FORMAT (' *** MAXOPEN EXCEEDS MAXFILES LIMIT OF ',I3,'.  BOTH ',  
     1        'MAXOPEN AND MAXFILES ARE RESET ONLY TO ',I3,' EACH')     
      MAXFIL = M        
      MAXOPN = M        
      GO TO 40        
C        
C     SYSTEM        
C        
  500 CONTINUE        
      IF (PARAM .LE.  0) GO TO 85        
      IF (PARAM .NE. 24) GO TO 510        
      WRITE (OUTTAP,505)        
  505 FORMAT ('0*** FATAL, USER SHOULD NOT CHANGE THE 24TH WORD OF ',   
     1       '/SYSTEM/')        
      NOGO = 1        
      GO TO 40        
C        
  510 IF (BUF(J1)) 530,40,520        
  520 J1 = JN + 1        
      J  = J1 + 1        
      IF (BUF(J1) .EQ. MASK2) GO TO 85        
      JN = J1 + 2*BUF(J1)        
      GO TO 510        
  530 IF (BUF(J1).EQ.-2 .AND. PARAM.NE.70) GO TO 85        
C        
C     IGNORE THE CONFIG PARAMETER        
C        
      IF (PARAM .NE. 28) SYSTEM(PARAM) = BUF(J)        
C        
C     SYSTEM WORD ECHO        
C        
      IF (PARAM .GE. 10) GO TO 531        
      IF (PARAM .EQ.  1) WRITE (OUTTAP,541) S1,PARAM,S2        
      IF (PARAM .EQ.  2) WRITE (OUTTAP,542) S1,PARAM,S2        
      IF (PARAM .EQ.  3) WRITE (OUTTAP,543) S1,PARAM,S2        
      IF (PARAM .EQ.  4) WRITE (OUTTAP,544) S1,PARAM,S2        
      IF (PARAM .EQ.  7) WRITE (OUTTAP,547) S1,PARAM,S2        
      IF (PARAM.EQ.7 .AND. MACH.EQ.3) WRITE (OUTTAP,548)        
      IF (PARAM .EQ.  9) WRITE (OUTTAP,549) S1,PARAM,S2        
      GO TO 590        
  531 K = PARAM/10        
      IF (K .LE. 9) GO TO (532,532,533,534,534,536,536,536,536), K      
      WRITE (OUTTAP,540) S1,PARAM,S2        
      GO TO 590        
  532 IF (PARAM .EQ. 20) WRITE (OUTTAP,550) S1,PARAM,S2        
      IF (PARAM .EQ. 28) WRITE (OUTTAP,558) S1,PARAM,S2        
      IF (PARAM .EQ. 29) WRITE (OUTTAP,559) S1,PARAM,S2        
      GO TO 590        
  533 IF (PARAM .EQ. 30) WRITE (OUTTAP,560) S1,PARAM,S2        
      IF (PARAM .EQ. 31) WRITE (OUTTAP,561) S1,PARAM,S2        
      IF (PARAM.EQ.34 .AND. MACH.NE.4) WRITE (OUTTAP,564) S1,PARAM,S2   
      IF (PARAM.EQ.34 .AND. MACH.EQ.4) WRITE (OUTTAP,565) S1,PARAM,S2   
      GO TO 590        
  534 IF (PARAM .EQ. 42) WRITE (OUTTAP,572) S1,PARAM,S2        
      IF (PARAM .EQ. 45) WRITE (OUTTAP,575) S1,PARAM,S2        
      IF (PARAM .EQ. 57) WRITE (OUTTAP,577) S1,PARAM,S2        
      IF (PARAM .EQ. 58) WRITE (OUTTAP,578) S1,PARAM,S2        
      IF (PARAM .EQ. 59) WRITE (OUTTAP,579) S1,PARAM,S2        
      GO TO 590        
  536 IF (PARAM.GE.60 .AND. PARAM.LE.65) WRITE (OUTTAP,577) S1,PARAM,S2 
      IF (PARAM .EQ. 70) WRITE (OUTTAP,580) S1,PARAM,S2        
      IF (PARAM .EQ. 77) WRITE (OUTTAP,587) S1,PARAM,S2        
      GO TO 590        
  540 FORMAT (5X,A4,I3,A16,'NOT AVAILABLE. INPUT IGNORED')        
  541 FORMAT (5X,A4,I3,A16,'GINO BUFFER SIZE')        
  542 FORMAT (5X,A4,I3,A16,'OUTPUT UNIT')        
  543 FORMAT (5X,A4,I3,A16,'NOGO FLAG')        
  544 FORMAT (5X,A4,I3,A16,'INPUT UNIT')        
  547 FORMAT (5X,A4,I3,A16,'NO. OF CONSOLE LOG MESSAGES')        
  548 FORMAT (1H+,31X,'. (95 MAX.)')        
  549 FORMAT (5X,A4,I3,A16,'NO. OF LINES PER PAGE. MINIMUM 10')        
  550 FORMAT (5X,A4,I3,A16,'PLOT OPTION')        
  558 FORMAT (5X,A4,I3,A16,'MACHINE CONFIGURATION (IGNORED)')        
  559 FORMAT (5X,A4,I3,A16,'MAX FILES')        
  560 FORMAT (5X,A4,I3,A16,'MAX FILES OPEN')        
  561 FORMAT (5X,A4,I3,A16,'HI-CORE')        
  564 FORMAT (5X,A4,I3,A16,'DRUM FLAG')        
  565 FORMAT (5X,A4,I3,A16,'NOS/NOS-BE FLAG')        
  572 FORMAT (5X,A4,I3,A16,'SYSTEM RELEASE DATE')        
  575 FORMAT (5X,A4,I3,A16,'TAPE BIT')        
  577 FORMAT (5X,A4,I3,A16,'DATA EXTRACTED FROM ADUM CARDS')        
  578 FORMAT (5X,A4,I3,A16,'MPYAD METHOD SELECTION')        
  579 FORMAT (5X,A4,I3,A16,'PLOT TAPE TRACK SPEC')        
  580 FORMAT (5X,A4,I3,A16,'SMA1 SINGULAR TOLERANCE')        
  587 FORMAT (5X,A4,I3,A16,'BANDIT/BULKDATA FLAG')        
C        
C     SET BOTTOM LIMIT OF 10 TO NUMBER OF LINES PER PAGE        
C     AND FOR UNIVAC ONLY, LIMIT THE CONSOLE LOG MESSAGES TO 95 MAXIMUM 
C        
  590 IF (PARAM.EQ.9 .AND. SYSTEM(9).LT.10) SYSTEM(9) = 10        
      IF (MACH .EQ.3 .AND. PARAM.EQ.7 .AND. SYSTEM(7).GT.95)        
     1    SYSTEM(7) = 95        
      J1 = J1 + 2        
      J  = J1 + 1        
      IF (BUF(J1) .EQ. MASK2) GO TO 4000        
      JN = J1 + 2*BUF(J1)        
      GO TO 40        
C        
C     KON360/HICORE        
C        
  600 CONTINUE        
      SYSTEM(31) = PARAM        
      GO TO 40        
C        
C     NLINES - BOTTOM-LIMITED TO 10        
C        
  700 CONTINUE        
      SYSTEM(9) = PARAM        
      IF (SYSTEM(9) .LT. 10) SYSTEM(9) = 10        
      GO TO 40        
C        
C     TITLEOPT        
C        
  800 CONTINUE        
      TOPT = PARAM        
      IF (MACH.EQ.3 .AND. TOPT.LE.-2) LOGFL = 3        
      GO TO 40        
C        
C     MODCOM COMMUNICATION AREA        
C        
  900 CONTINUE        
      IF (PARAM .LE. 0) GO TO 85        
  910 IF (BUF(J1)) 930,40,920        
  920 J1 = JN + 1        
      J  = J1 + 1        
      IF (BUF(J1) .EQ. MASK2) GO TO 85        
      JN = J1 + 2*BUF(J1)        
      GO TO 910        
  930 MODCOM(PARAM) = BUF(J)        
      J1 = J1 + 2        
      J  = J1 + 1        
      IF (BUF(J1) .EQ. MASK2) GO TO 4000        
      JN = J1 + 2*BUF(J1)        
      GO TO 40        
C        
C     HICORE = LENGTH OF CORE ON UNIVAC, VAX, AND UNIX        
C        
 1000 CONTINUE        
      SYSTEM(31) = PARAM        
      GO TO 40        
C        
C     UNIVAC - DRUM ALLOCATION, 1 BY POSITIONS, 2 BY TRACKS        
C              DEFAULT IS 1,  150 POSITIONS  (GOOD FOR LARGE JOB)       
C              IF DRUM IS 2, 1280 TRKS. IS ASSIGNED (SUITABLE FOR       
C                 SMALLER JOB)        
C        
C     CDC - IDRUM (34TH WORD OF /SYSTEM/) IS LENGTH OF FET + DUMMY INDEX
C        
 1100 IDRUM = PARAM        
      GO TO 40        
C        
C     PLOT TAPE TRACK SIZE    TRACK=7 IMPLIES 7 TRACK        
C                             TRACK=9 IMPLIES 9 TRACK        
C        
 1200 IF (PARAM.NE.7 .AND. PARAM.NE.9) GO TO 1250        
      IF (PARAM .EQ. 7) SYSTEM(59) = 1        
      IF (PARAM .EQ. 9) SYSTEM(59) = 2        
      GO TO 40        
 1250 WRITE (OUTTAP,1480) UWM,PARAM,KEYWDS(1,12),KEYWDS(2,12)        
      NOGO = 1        
      GO TO 40        
C        
C     . ELEMENT SINGULARITY TOLERANCE (A REAL S.P. NUMBER)...        
C        
 1300 ITOLEL = PARAM        
      IF (BUF(J1-2).EQ.-1) RTOLEL = ITOLEL        
      GO TO 40        
C        
C     BANDIT (77TH WORD OF SYSTEM)        
C     BANDIT KEYWORDS (DEFAULT VALUES IN BRACKETS, SET BY BGRID ROUTINE)
C        BANDTCRI = (1),2,3,4     CRITERION        
C        BANDTMTH = 1,2,(3)       METHOD        
C        BANDTMPC = (0),1,2       MPC EQUS. AND RIGID ELEMENTS        
C        BANDTDEP = (0),1         DEPENDANT GRID        
C        BANDTPCH = (0),1         PUNCH SEQGP CARDS        
C        BANDTRUN = (0),1         RUN/SEQGP        
C        BANDTDIM = (0),1,2,...,9 SCRATCH ARRAY DIMENSION        
C        BANDIT   = -1,(0)        BANDIT SKIP FLAG        
C     WHERE,        
C        CRITERION = 1, USE RMS WAVEFRONT TO DETERMINE BEST RESULT,     
C                  = 2, BANDWIDTH,  =3, PROFILE, OR  =4, MAX WAVEFRONT  
C        METHOD    = 1, CM METHOD IS USED,   3, GPS, OR     2, BOTH     
C        MPC       = 0, MPC'S AND RIGID ELEM ARE NOT CONSIDERED        
C                  = 1, MPC'S AND RIGID ELEM ARE USED IN RESEQUENCING   
C                  = 2, ONLY RIGID ELEMENTS ARE USED IN RESEQUENCING    
C        DEPEND    = 0, DEPENDANT GRID IS OMITTED IN RESEQUENCING       
C                       IF MPC IS NON-ZERO        
C                  = 1, DEPENDANT GRIDS ARE INCLUDED        
C        PUNCH     = 0, NO SEQGP CARDS PUNCHED        
C                  = 1, PUNCH OUT BANDIT GENERATED SEQGP CARDS AND      
C                       TERMINATE NASTRAN JOB        
C        RUN/SEQGP = 0, BANDIT WOULD QUIT IF THERE IS ONE OR MORE SEQGP 
C                       CARD IN THE INPUT DECK        
C                  = 1, TO FORCE BANDIT TO BE EXECUTED EVEN IF SEQGP    
C                       CARDS ARE PRESENT        
C        DIM       = 1,2,...,N, TO SET THE SCRATCH AREA, USED ONLY IN   
C                       GPS METHOD, TO N*100. (N IS 9 OR LESS)        
C                  = 0, DIMENSION IS SET TO 150        
C        BANDIT    =-1, BANDIT COMPUTATION IS SKIPPED UNCONDITIONALLY   
C                  = 0, BANDIT WOULD BE EXECUTED IF BULK DATA CONTAINS  
C                       NO INPUT ERROR        
C        
 1400 CONTINUE        
      IF (BANDIT .LT. 0) GO TO 40        
      IF (K.EQ.BDT(7) .AND. PARAM.GE.100) PARAM = PARAM/100        
      IF (PARAM.LT.0 .OR. PARAM.GT.9) GO TO 1470        
      DO 1420 I = 1,7        
      IF (K .NE. BDT(I)) GO TO 1420        
      K = PARAM*10**(I-1)        
      GO TO 1430        
 1420 CONTINUE        
      GO TO 60        
 1430 BANDIT = BANDIT + K        
      GO TO 40        
 1450 IF (PARAM .LT. 0) BANDIT = -1        
      IF (PARAM .LE. 0) GO TO 40        
      K = KEYWDS(2,14)        
 1470 WRITE  (OUTTAP,1480) UWM,PARAM,KEYWDS(1,14),K        
 1480 FORMAT (A25,' 65, ILLEGAL VALUE OF ',I7,' IN NASTRAN ',2A4,       
     1       ' CARD')        
      GO TO 40        
C        
C     BULK DATA CHECK ONLY        
C     TO TERMINATE JOB AFTER BULK DATA CHECK, AND SKIP OVER BANDIT      
C     (OPTION TO PRINTOUT TIME CONSTANTS IN /NTIME/, IF BULKDATA=-3)    
C        
 1500 CONTINUE        
      IF (PARAM  .NE.  0) BANDIT = -2        
      IF (BANDIT .EQ. -2) MAXFIL = 23        
      IF (PARAM  .EQ. -3) BANDIT = -3        
      GO TO 40        
C        
C     PLOT OPTIONS -        
C        
C     PLTFLG   BULKDATA    PLOT COMMANDS       ACTION TAKEN        
C     -----  ------- --   -------------  -------------------------------
C      0      NO ERROR    NO ERROR       EXECUTES ALL LINKS, NO PLOTS   
C             NO ERROR       ERROR       STOPS AFTER LNK1 DATA CHECK    
C                ERROR  ERR OR NO ERR    STOPS AFTER LINK1 CHECK        
C      1      NO ERROR    NO ERROR       GO, ALL LINKS AND PLOTS        
C             NO ERROR       ERROR       STOP AFTER LINK1 DATA CHECK    
C                ERROR    NO ERROR       STOP AFTER LINK1 DATA CHECK    
C                ERROR       ERROR       STOP AFTER LINK1 DATA CHECK    
C      2      NO ERROR    NO ERROR       STOP AFTER UNDEFORM PLOT/LINK2 
C             NO ERROR       ERROR       STOP AFTER LINK1 DATA CHECK    
C                ERROR    NO ERROR       STOP AFTER UNDEFORM PLOT/LINK2 
C                ERROR       ERROR       STOP AFTER LINK1 DATA CHECK    
C      3      (ERROR OR   (ERROR OR      (ATTEMPT TO PLOT UNDEFORM MODEL
C             NO ERROR)   NO ERROR)      THEN STOP/LINK2)        
C      4      NO ERROR    NO ERROR       GO, ALL LINKS AND PLOTS        
C             NO ERROR       ERROR       STOP AFTER UNDEFORM PLOT/LINK2 
C                ERROR    NO ERROR       STOP AFTER UNDEFORM PLOT/LINK2 
C                ERROR       ERROR       STOP AFTER LINK1 DATA CHECK    
C      5      NO ERROR    NO ERROR       GO, ALL LINKS AND PLOTS        
C             NO ERROR       ERROR       GO, ALL LINKS BUT NO PLOTS     
C                ERROR    NO ERROR       STOP AFTER UNDEFORM PLOT/LINK2 
C                ERROR       ERROR       STOP AFTER LINK1 DATA CHECK    
C     PLTFLG 0 OR 1 IS SET BY THE PRESENCE OF THE PLOT TAPE.        
C     PLTFLG WILL BE RESET TO POSITIVE IN IFP1        
C     CUT MAXFIL TO HALF AND SKIP BANDIT IF PLOT OPTION IS 2 OR 3       
C        
 1600 CONTINUE        
      IF (PARAM.LT.2 .OR. PARAM.GT.5) GO TO 1650        
      IF (PARAM .GE. 2) PLTFLG = -PARAM        
      IF (PLTFLG.NE.-2 .AND. PLTFLG.NE.-3) GO TO 40        
      MAXFIL = 24        
      BANDIT = -1        
      GO TO 40        
 1650 WRITE (OUTTAP,1480) UWM,PARAM,KEYWDS(1,16),KEYWDS(2,16)        
      GO TO 40        
C        
C     LOGFL = LOGFILE MESSAGE CONTROL ON UNIVAC 1100        
C        
 1700 CONTINUE        
      LOGFL = PARAM        
      GO TO 40        
C        
C     FILES        
C        
 3000 IF (BUF(J+2) .NE. MASK1) GO TO 85        
      IF (J+4 .GE. JN) GO TO 85        
      IF (BUF(J+4).EQ.BLANK .AND. BUF(J+6).EQ.MASK1) GO TO 3010        
      J = J + 4        
      KHR = 0        
      GO TO 3020        
 3010 J = J + 8        
      KHR = 7        
 3020 IF (BUF(J).EQ.MASK1 .OR. KHR.EQ.1) GO TO 3090        
      DO 3030 II = 1,NPFIST        
      IF (BUF(J) .EQ. FIST(2*II-1)) GO TO 3060        
 3030 CONTINUE        
      DO 3040 I = 1,LKEYWD        
      IF (BUF(J).EQ.KEYWDS(1,I) .AND. BUF(J+1).EQ.KEYWDS(2,I)) GO TO 110
 3040 CONTINUE        
      IF (BUF(J) .NE. BLANK) WRITE (OUTTAP,3050) UWM,BUF(J)        
 3050 FORMAT (A25,' 64, ',A4,' IS NOT DEFINED AS A NASTRAN FILE AND ',  
     1       'WILL BE IGNORED.')        
      GO TO 3070        
 3060 IXX = 2**(II-1)        
      SYSTEM(45) = ORF(SYSTEM(45),IXX)        
 3070 J = J + 2        
      KHR = KHR + 1        
      IF (J .LT. JN) GO TO 3020        
      J1 = JN + 1        
      IF (BUF(J1) .EQ. MASK2) GO TO 4000        
      IF (BUF(J1) .NE. 0) GO TO 85        
 3080 CALL XREAD  (*3500,CARD)        
      CALL XRCARD (BUF,75,CARD)        
      WRITE (OUTTAP,30) (CARD(I),I=1,20)        
      IF (BUF(1) .EQ. 0) GO TO 3080        
      J  = 2        
      J1 = 1        
      JN = 2*BUF(1) + 1        
      GO TO 3020        
 3090 J = J + 2        
      GO TO 40        
C        
C        
C     END-OF-FILE ENCOUNTERED ON INPUT FILE        
C        
 3500 WRITE  (OUTTAP,3600) UFM,INTAP        
 3600 FORMAT (A23,' 74, EOF ENCOUNTERED ON UNIT ',I4,        
     1        ' WHILE READING THE INPUT DATA IN SUBROUTINE NASCAR')     
      CALL MESAGE (-61,0,0)        
C        
C        
C     GENERATE TITLE PAGE        
C        
 4000 DO 4100 I = 1,14        
 4100 PGHDG(I+2) = BLANK        
      CALL TTLPGE (TOPT)        
C        
      RETURN        
      END        
