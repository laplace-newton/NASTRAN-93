      SUBROUTINE GETDEF (DFRM,PH,MAG,CONV,PLTTYP,BUF,GPT,D)        
C        
      INTEGER         DFRM,BUF(1),GPT(1),SILN,REW,SP,GP,GPX,SIL1,SIL2,  
     1                TRL(7),TYPE,PLTTYP        
      REAL            D(3,1),MAXDEF        
      COMMON /BLANK / NGP,LSIL,SKP11(3),NGPSET,SKP12(4),SKP2(6),MSIL    
      COMMON /XXPARM/ PBUFSZ,PLOTER(5),PENPAP(30),SCALE(4),MAXDEF       
      COMMON /ZNTPKX/ DEFC(4),SILN,LAST        
      EQUIVALENCE     (DEFVAL,DEFC(1))        
      DATA    INPREW, REW / 0,1 /        
C        
      LAST = 0        
      K    = 3*NGPSET        
      DO 10 I = 1,K        
   10 D(I,1) = 0.0        
      TRL(1) = DFRM        
      CALL RDTRL (TRL(1))        
      IF (TRL(5) .LE. 0) RETURN        
      SP = TRL(5)        
      ASSIGN 140 TO TYPE        
C        
C     NOTE TRANSIENT RESPONSE HAS SP = 1        
C        
      IF (SP .LT. 3) GO TO 30        
      ASSIGN 130 TO TYPE        
      IF (MAG .NE. 0) GO TO 30        
      ASSIGN 120 TO TYPE        
      SN = SIN(PH)*CONV        
      CN = COS(PH)*CONV        
      IF (PLTTYP .EQ. 2) GO TO 20        
C        
C     DISPLACEMENT OR ACCELERATION        
C        
      I1 = 1        
      I2 = SP - 1        
      IF (PLTTYP.EQ.3 .OR. PLTTYP.EQ.4) CN = -CN        
      GO TO 30        
C        
C     VELOCITY        
C        
   20 I1 = SP - 1        
      I2 = 1        
   30 CONTINUE        
      MAXDEF = 0.        
      CALL INTPK (*170,DFRM,0,SP,0)        
      GP   = 0        
      SILN = 0        
      CALL GOPEN (MSIL,BUF(1),INPREW)        
      CALL FREAD (MSIL,SIL2,1,0)        
C        
C     -GP- = PREVIOUS EXISTENT GRID POINT IN THIS SET. FIND NEXT ONE.   
C        
   40 K = GP + 1        
      DO 50 GPX = K,NGP        
      IF (GPT(GPX) .NE. 0) GO TO 60        
   50 CONTINUE        
      SIL1 = LSIL + 1        
      GO TO 100        
   60 IF (GPX .NE. GP+1) GO TO 70        
      SIL1 = SIL2        
      GO TO 80        
   70 GP = GP + 1        
      CALL FREAD (MSIL,SIL2,1,0)        
      GO TO 60        
C        
C     -SIL1- = SIL NUMBER OF NEXT EXISTENT GRID POINT. READ SIL NUMBER  
C              OF NEXT GRID POINT.        
C        
   80 GP = GPX        
      GPX = IABS(GPT(GP))        
      IF (GP .EQ. NGP) SIL2 = LSIL + 1        
      IF (GP .NE. NGP) CALL FREAD (MSIL,SIL2,1,0)        
C        
C     READ NEXT DEFORMATION VALUE AT THIS EXISTING GRID POINT.        
C        
   90 IF (SILN.LE.LSIL .AND. SILN.GE.SIL1) GO TO 150        
  100 IF (LAST .NE. 0) GO TO 160        
  110 CALL ZNTPKI        
      GO TO TYPE, (120,130,140)        
  120 DEFVAL = DEFC(I1)*CN - DEFC(I2)*SN        
      GO TO 140        
  130 DEFVAL = CONV*SQRT(DEFC(1)**2 + DEFC(SP-1)**2)        
  140 IF (ABS(DEFVAL) .GT. MAXDEF) MAXDEF = ABS(DEFVAL)        
      GO TO 90        
  150 IF (SILN.GT.SIL1+2 .OR. SILN.GE.SIL2) GO TO 40        
      K = SILN - SIL1 + 1        
      D(K,GPX) = DEFVAL        
      IF (LAST) 160,110,160        
C        
  160 CALL CLOSE (MSIL,REW)        
  170 RETURN        
      END        
