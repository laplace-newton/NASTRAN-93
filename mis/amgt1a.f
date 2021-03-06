      SUBROUTINE AMGT1A (INPUT,MATOUT,AJJ,TSONX,TAMACH,TREDF,NSTNS2)    
C        
C     COMPUTE AJJ MATRIX FOR SWEPT TURBOPROP BLADES.        
C        
      LOGICAL         TSONIC,DEBUG        
      INTEGER         SLN,NAME(2),TSONX(1)        
      REAL            MINMAC,MAXMAC,MACH        
      COMPLEX         AJJ(NSTNS2,1)        
      DIMENSION       TAMACH(1),TREDF(1)        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGMA,RFREQ        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISQ        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /TAMG1L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFSWP,SLN,NSTNSX,STAGER,    
     2                CHORD,DCBDZB,BSPACE,MACH,DEN,VEL,SWEEP,AMACH,     
     3                REDF,BLSPC,AMACHR,TSONIC        
      COMMON /AMGBUG/ DEBUG        
      DATA    NAME  / 4HAMGT,4H1A  /        
C        
C     LOOP ON STREAMLINES, COMPUTE AJJ FOR EACH STREAMLINE AND THEN     
C     PACK AJJ INTO AJJL MATRIX AT CORRECT POSITION        
C        
      II = 0        
      NN = 0        
      NSTNS3 = 3*NSTNS        
      DO 70 LINE = 1,NLINES        
C        
C     READ STREAMLINE DATA (SKIP COORDINATE DATA)        
C        
      CALL READ (*400,*400,INPUT,SLN,10,0,NWAR)        
C        
C     COMPUTE PARAMETERS        
C        
      AMACH = MACH        
      REDF  = RFREQ*(CHORD/REFCRD)*(REFVEL/VEL)        
      BLSPC = BSPACE/CHORD        
C        
C     COMPUTE C3 AND C4 FOR THIS STREAMLINE.        
C        
C     INPUT IS POSITIONED AT THE FIRST 10 WORDS OF THE NEXT        
C     STREAMLINE WHEN IT RETURNS FROM AMGT1T        
C        
      CALL AMGT1T (NLINES,LINE,INPUT,NSTNS,C3,C4)        
C        
      IF (DEBUG) CALL BUG1 ('TAMG1L    ',5,IREF,26)        
C        
C     COMPUTE POINTER FOR LOCATION INTO AJJ MATRIX        
C        
      IAJJC = 1        
      IF (TSONIC) IAJJC = NSTNS2*(LINE-1) + 1        
C        
C     BRANCH TO SUBSONIC, SUPERSONIC OR TRANSONIC CODE        
C        
      TAMACH(LINE) = AMACH        
      TREDF(LINE)  = REDF        
      IF (AMACH .LE. MAXMAC) GO TO 10        
      IF (AMACH .GE. MINMAC) GO TO 20        
C        
C     TRANSONIC STREAMLINE. STORE DATA FOR TRANSONIC INTERPOLATION      
C        
      TSONX(LINE) = IAJJC        
      GO TO 70        
C        
C     SUBSONIC STREAMLINE        
C        
   10 CALL AMGT1B (AJJ(1,IAJJC),NSTNS2,C3,C4)        
      GO TO 30        
C        
C     SUPERSONIC STREAMLINE        
C        
   20 CALL AMGT1C (AJJ(1,IAJJC),NSTNS2,C3,C4)        
   30 CONTINUE        
C        
C     IF THERE ARE NO TRANSONIC STREAMLINES OUTPUT THIS AJJ SUBMATRIX   
C        
      IF (TSONIC) GO TO 60        
      II = NN + 1        
      NN = NN + NSTNS2        
C        
C     OUTPUT AJJ MATRIX        
C        
      DO 50 I = 1,NSTNS2        
      IF (DEBUG) CALL BUG1 ('SS-AJJL   ',40,AJJ(1,I),NSTNS2*2)        
      CALL PACK (AJJ(1,I),MATOUT,MCB)        
   50 CONTINUE        
      GO TO 70        
   60 TSONX(LINE) = 0        
   70 CONTINUE        
C        
C     PERFORM TRANSONIC INTERPOLATION, IF NECESSARY        
C        
      IF (.NOT.TSONIC) GO TO 300        
      IF (DEBUG) CALL BUG1 ('TSONX     ', 80,TSONX,NLINES)        
      IF (DEBUG) CALL BUG1 ('TAMACH    ', 90,TAMACH,NLINES)        
      IF (DEBUG) CALL BUG1 ('TREDF     ',100,TREDF,NLINES)        
      CALL AMGT1D (AJJ,TSONX,TAMACH,TREDF,NSTNS2)        
C        
C     OUTPUT AJJ FOR EACH STREAMLINE        
C        
      DO 200 NLINE = 1,NLINES        
      II = NN + 1        
      NN = NN + NSTNS2        
      DO 120 I = II,NN        
      IF (DEBUG) CALL BUG1 ('STS-AJJL  ',110,AJJ(1,I),NSTNS2*2)        
      CALL PACK (AJJ(1,I),MATOUT,MCB)        
  120 CONTINUE        
  200 CONTINUE        
  300 RETURN        
C        
C     ERROR MESSAGES        
C        
C     INPUT NOT POSITIONED PROPERLY OR INCORRECTLY WRITTEN        
C        
  400 CALL MESAGE (-7,0,NAME)        
      RETURN        
      END        
