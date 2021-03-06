      SUBROUTINE PIKLVL (*,LVLS1,LVLS2,CCSTOR,IDFLT,ISDIR,XC,NHIGH,        
     1                   NLOW,NACUM,SIZE,STPT)        
C        
      INTEGER          CCSTOR(1), SIZE(1), STPT(1),  XC,  END, TEMP        
      DIMENSION        NHIGH(1),  NLOW(1), NACUM(1), LVLS1(1), LVLS2(1)        
      COMMON /BANDG /  IDUM,      IDPTH        
C        
C     THIS ROUTINE IS USED ONLY BY GIBSTK OF BANDIT MODULE        
C        
C     PIKLVL CHOOSES THE LEVEL STRUCTURE  USED IN NUMBERING GRAPH        
C        
C     LVLS1-    ON INPUT CONTAINS FORWARD LEVELING INFO        
C     LVLS2-    ON INPUT CONTAINS REVERSE LEVELING INFO        
C               ON OUTPUT THE FINAL LEVEL STRUCTURE CHOSEN        
C     CCSTOR-   ON INPUT CONTAINS CONNECTED COMPONENT INFO        
C     IDFLT-    ON INPUT =1 IF WDTH LVLS1'WDTH LVLS2, =2 OTHERWISE        
C     NHIGH     KEEPS TRACK OF LEVEL WIDTHS FOR HIGH NUMBERING        
C               DIMENSION OF NHIGH IS MAXIMUM ALLOWABLE NUMBER OF LEVELS        
C     NLOW-     KEEPS TRACK OF LEVEL WIDTHS FOR LOW NUMBERING        
C     NACUM-    KEEPS TRACK OF LEVEL WIDTHS FOR CHOSEN LEVEL STRUCTURE        
C     XC-       NUMBER OF MAXIMUM ALLOWABLE CONNECTED COMPONENTS        
C               (IS THE DIMENSION FOR SIZE AND STPT)        
C     SIZE(I)-  SIZE OF ITH CONNECTED COMPONENT        
C     STPT(I)-  INDEX INTO CCSTORE OF 1ST NODE IN ITH CON COMPT        
C     ISDIR-    FLAG WHICH INDICATES WHICH WAY THE LARGEST CONNECTED        
C               COMPONENT FELL.  =+1 IF LOW AND -1 IF HIGH        
C        
C        
C     PART 1 -        
C     ========        
C     SORTS SIZE AND STPT HERE, IN DECENDING ORDER        
C     (PREVIOUS SORT2 ROUTINE IS NOW MOVED INTO HERE.        
C     THE ORIGINAL BUBBLE SORT HAS BEEN REPLACED BY THE MODIFIED SHELL        
C     SORT WHICH IS MUCH FASTER   /G.CHAN,  MAY 1988)        
C        
      IF (XC .EQ. 0) RETURN 1        
      M=XC        
   10 M=M/2        
      IF (M .EQ. 0) GO TO 70        
      J=1        
      K=XC-M        
   20 I=J        
   30 N=I+M        
      IF (SIZE(N)-SIZE(I)) 60,60,50        
   50 TEMP   =SIZE(I)        
      SIZE(I)=SIZE(N)        
      SIZE(N)=TEMP        
      TEMP   =STPT(I)        
      STPT(I)=STPT(N)        
      STPT(N)=TEMP        
      I=I-M        
      IF (I .GE. 1) GO TO 30        
   60 J=J+1        
      IF (J-K) 20,20,10        
   70 CONTINUE        
C        
C        
C     PART 2 -        
C     ========        
C     CHOOSES THE LEVEL STRUCTURE USED IN NUMBERING GRAPH        
C        
C        
C     FOR EACH CONNECTED COMPONENT DO        
C        
      DO 270 I=1,XC        
      J  =STPT(I)        
      END=SIZE(I)+J-1        
C        
C     SET NHIGH AND NLOW EQUAL TO NACUM        
C        
      DO 200 K=1,IDPTH        
      NHIGH(K)=NACUM(K)        
      NLOW(K) =NACUM(K)        
  200 CONTINUE        
C        
C     UPDATE NHIGH AND NLOW FOR EACH NODE IN CONNECTED COMPONENT        
C        
      DO 210 K=J,END        
      INODE=CCSTOR(K)        
      LVLNH=LVLS1(INODE)        
      NHIGH(LVLNH)=NHIGH(LVLNH)+1        
      LVLNL=LVLS2(INODE)        
      NLOW(LVLNL)=NLOW(LVLNL)+1        
  210 CONTINUE        
      MAX1=0        
      MAX2=0        
C        
C     SET MAX1=LARGEST NEW NUMBER IN NHIGH        
C     SET MAX2=LARGEST NEW NUMBER IN NLOW        
C        
      DO 220 K=1,IDPTH        
      IF (2*NACUM(K).EQ.NLOW(K)+NHIGH(K)) GO TO 220        
      IF (NHIGH(K).GT.MAX1) MAX1=NHIGH(K)        
      IF (NLOW(K) .GT.MAX2) MAX2=NLOW(K)        
  220 CONTINUE        
C        
C     SET IT= NUMBER OF LEVEL STRUCTURE TO BE USED        
C        
      IT=1        
      IF (MAX1.GT.MAX2) IT=2        
      IF (MAX1.EQ.MAX2) IT=IDFLT        
      IF (IT.EQ.2) GO TO 250        
      IF (I .EQ.1) ISDIR=-1        
C        
C     COPY LVLS1 INTO LVLS2 FOR EACH NODE IN CONNECTED COMPONENT        
C        
      DO 230 K=J,END        
      INODE=CCSTOR(K)        
      LVLS2(INODE)=LVLS1(INODE)        
  230 CONTINUE        
C        
C     UPDATE NACUM TO BE THE SAME AS NHIGH        
C        
      DO 240 K=1,IDPTH        
      NACUM(K)=NHIGH(K)        
  240 CONTINUE        
      GO TO 270        
C        
C     UPDATE NACUM TO BE THE SAME AS NLOW        
C        
  250 DO 260 K=1,IDPTH        
      NACUM(K)=NLOW(K)        
  260 CONTINUE        
  270 CONTINUE        
      RETURN        
      END        
