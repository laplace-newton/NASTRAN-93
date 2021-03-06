      SUBROUTINE DIAGON        
C        
C     DMAP FUNCTIONAL MODULE        
C        
C     DIAGONAL  A / B / V,Y,OPT=COLUMN / V,Y,POWER $        
C        
C     INPUT  - A IS ANY MATRIX, EXCEPT RECTANGULAR AND ROW VECTOR       
C            - OPT IS OUTPUT MATRIX TYPE V,Y FLAG        
C            - POWER IS A VALUE TO WHICH THE REAL PART OF EACH ELEMENT  
C              ON THE DIAGONAL OF A IS RAISED. (DEFAULT OF POWER IS 1.0)
C     OUTPUT - B IS A REAL SYMMETRIC MATRIX (OPT='SQUARE'), OR A COLUMN 
C              VECTOR CONTAINING THE DIAGONAL OF A (OPT='COLUMN'), OR   
C              A DIAGONAL MATRIX (OPT='DIAGONAL'        
C        
C     WRITTEN BY R. MITCHELL, CODE 324, GSFC, DECEMBER 7,1972        
C        
C     LAST MODIFIED BY G.CHAN/UNISYS   11/1991        
C     TO MAKE SUERE  0.0**0 = 1.0, NOT 0.0        
C        
      INTEGER          SYSBUF,COL,SQ,IA(7),IB(7),NAME(2),OPT(2)        
      DOUBLE PRECISION D(2),DVAL(2),DCORE(1)        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM,SWM        
      COMMON /UNPAKX/  ITYPEU,IU,JU,INCRU        
      COMMON /ZNTPKX/  A(4),II,LAST        
      COMMON /ZBLPKX/  VAL(4),JROW        
CZZ   COMMON /ZZDIAG/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
      COMMON /SYSTEM/  KSYSTM(60)        
      COMMON /BLANK /  PARAM(3)        
      EQUIVALENCE      (KSYSTM(1),SYSBUF), (KSYSTM(2),NOUT),        
     1                 (IA(2),INCOL), (IA(3),INROW), (IA(4),IFORM),     
     2                 (IA(5),ITYPE), (A(1),D(1)), (VAL(1),DVAL(1)),    
     3                 (PARAM(1),OPT(1)), (PARAM(3),POWER),        
     4                 (CORE(1), DCORE(1))        
      DATA    COL,SQ/  4HCOLU,4HSQUA  /,  IN1,IOUT / 101,201 /        
      DATA    NAME  /  4HDIAG,4HONAL  /        
C        
C        
C     CHECK FOR VALID PARAMETER.        
C        
      IF (OPT(1).EQ.SQ .OR. OPT(1).EQ.COL .OR. OPT(1).EQ.NAME(1))       
     1    GO TO 10        
      WRITE  (NOUT,5) SWM,OPT        
    5 FORMAT (A27,' 3300, INVALID PARAMETER ',2A4,        
     1       ' SUPPLIED TO MODULE DIAGONAL, COLUMN SUBSTITUTED')        
      OPT(1) = COL        
C        
C     GET INFO ON INPUT MATRIX        
C        
   10 IA(1) = IN1        
      CALL RDTRL (IA)        
C        
C     CHECK FOR PURGED INPUT.        
C        
      IF (IA(1) .LT. 0) GO TO 210        
C        
C     CHECK FOR PROPER FORM OF MATRIX        
C        
      GO TO (20,220,20,20,20,20,220,200), IFORM        
C        
C     SET OUTPUT CONTROL BLOCK TO MATCH INPUT AND REQUESTS.        
C        
   20 IB4 = 6        
      IF (OPT(1) .EQ. COL) IB4 = 2        
      IF (OPT(1) .NE. NAME(1)) GO TO 25        
      IB4 = 3        
      OPT(1) = COL        
   25 IB5 = 1        
      IF (ITYPE.EQ.2 .OR. ITYPE.EQ.4) IB5 = 2        
      CALL MAKMCB (IB,IOUT,INROW,IB4,IB5)        
C        
C     CHECK FOR SPECIAL CASES OF POWER PARAMETER.        
C        
C     CHECK FOR 1.0 = NO ARITHMETIC REQUIRED.        
C        
      IF (ABS(POWER-1.0)-1.0E-6) 30,30,40        
   30 IPOW = 1        
      GO TO 100        
C        
C     CHECK FOR 0.5 = SQUARE ROOT        
C        
   40 IF (ABS(POWER-0.5)-1.0E-6) 45,45,50        
   45 IPOW = 2        
      GO TO 100        
C        
C     CHECK FOR 2.0 = SQUARE        
C        
   50 IF (ABS(POWER-2.0)-1.0E-6) 55,55,60        
   55 IPOW = 3        
      GO TO 100        
C        
C     CHECK FOR 0.0 = IDENTITY MATRIX        
C        
   60 IF (POWER) 70,65,70        
   65 IPOW = 4        
      GO TO 100        
C        
C     GENERAL CASE        
C        
   70 IPOW = 5        
C        
C     DO OPEN CORE BOOKKEEPING        
C        
C     OBTAIN LENGTH OF OPEN CORE        
C        
  100 LCORE = KORSZ(CORE)        
C        
C     NEED ROOM FOR 2 GINO BUFFERS        
C        
      IF (LCORE .LT. 2*SYSBUF) GO TO 230        
C        
C     IF INPUT MATRIX IS A DIAGONAL MATRIX, NEED ADDITIONAL        
C     ROOM FOR A FULL COLUMN        
C        
      IF (IFORM.EQ.3 .AND.        
     1    LCORE.LT.(2*SYSBUF + IB(5)*INROW + 1)) GO TO 230        
      IBUF = LCORE - SYSBUF + 1        
C        
C     OPEN INPUT FILE AND SKIP HEADER        
C        
      CALL GOPEN (IA,CORE(IBUF),0)        
C        
C     OPEN OUTPUT FILE AND WRITE HEADER        
C        
      NPREC = IB(5)        
      IBUF  = IBUF - SYSBUF        
      CALL GOPEN (IB,CORE(IBUF),1)        
C        
C     PRIME PACK ROUTINE IF COLUMN OUTPUT        
C        
      IF (OPT(1) .EQ. COL) CALL BLDPK (NPREC,NPREC,IOUT,0,0)        
C        
C     READ INPUT MATRIX AND SEARCH COLUMNS FOR DIAGONAL ELEMENTS.       
C        
      DO 180 NOWCOL = 1,INCOL        
C        
C     CHECK IF THE INPUT MATRIX IS A DIAGONAL MATRIX (IFORM = 3)        
C        
      IF (IFORM .NE. 3) GO TO 118        
C        
C     UNPACK THE FULL COLUMN OF THE INPUT DIAGONAL MATRIX        
C        
      ITYPEU = NPREC        
      IU = 1        
      JU = INROW        
      INCRU = 1        
      CALL UNPACK (*105,IA,CORE)        
      GO TO 110        
  105 JJU = NPREC*JU        
      DO 108 I = 1,JJU        
      CORE(I) = 0.0        
  108 CONTINUE        
      IF (IPOW .NE. 4) GO TO 110        
      IF (NPREC .EQ.  1) CORE (NOWCOL) = 1.0        
      IF (NPREC .EQ.  2) DCORE(NOWCOL) = 1.0D0        
  110 II = 0        
  115 II = II + 1        
      A(1) = CORE(II)        
      IF (NPREC .EQ. 2) D(1) = DCORE(II)        
      IF (OPT(1) .EQ. SQ) CALL BLDPK (NPREC,NPREC,IOUT,0,0)        
      GO TO 140        
C        
C     START A NEW COLUMN IF SYMMETRIC OUTPUT MATRIX.        
C        
  118 IF (OPT(1) .EQ. SQ) CALL BLDPK (NPREC,NPREC,IOUT,0,0)        
C        
C     START READING A COLUMN        
C        
C     NOTE THAT NULL INPUT COLUMN RESULTS IN NULL OUTPUT ELEMENT ONLY   
C     IF POWER IS NOT ZERO.        
C        
      CALL INTPK (*120,IA,0,ITYPE,0)        
      GO TO 130        
  120 IF (IPOW .NE. 4) GO TO 175        
      VAL(2)  = 0.0        
      DVAL(2) = 0.0D0        
      IF (NPREC .EQ. 1)  VAL(1) = 1.0        
      IF (NPREC .EQ. 2) DVAL(1) = 1.0D0        
      II = NOWCOL        
      GO TO 170        
C        
C     GET AN ELEMENT        
C        
  130 CALL ZNTPKI        
C        
C     CHECK FOR DESIRED ELEMENT (ROW = COLUMN)        
C        
      IF (II-NOWCOL) 132,140,135        
C        
C     CHECK FOR LAST NON-ZERO ELEMENT IN COLUMN.        
C        
  132 IF (LAST) 130,130,135        
C        
C     SET ELEMENT VALUE TO 0. IF NOT IN COLUMN        
C        
  135 VAL(1)  = 0.        
      DVAL(1) = 0.0D0        
      GO TO 170        
C        
C     PROCESS RETURNED VALUE.        
C        
C     CHECK FOR PRECISION REQUIRED        
C        
  140 GO TO (150,160), NPREC        
C        
C     SINGLE PRECISION PROCESSING OF REAL PART OF DIAGONAL ELEMENT      
C        
C     PERFORM REQUESTED OPERATION        
C        
  150 GO TO (152,154,156,158,159), IPOW        
  152 VAL(1) = A(1)        
      GO TO 170        
  154 VAL(1) = SQRT(A(1))        
      GO TO 170        
  156 VAL(1) = A(1)*A(1)        
      GO TO 170        
  158 VAL(1) = 1.0        
      GO TO 170        
  159 VAL(1) = A(1)**POWER        
      GO TO 170        
C        
C     DOUBLE PRECISION PROCESSING OF REAL PART OF DIAGONAL ELEMENT      
C        
C     PERFORM REQUESTED OPERATION        
C        
  160 GO TO (162,164,166,168,169), IPOW        
  162 DVAL(1) = D(1)        
      GO TO 170        
  164 DVAL(1) = DSQRT(D(1))        
      GO TO 170        
  166 DVAL(1) = D(1)*D(1)        
      GO TO 170        
  168 DVAL(1) = 1.0D0        
      GO TO 170        
  169 DVAL(1) = D(1)**POWER        
C        
C     PACK COMPUTED VALUE INTO OUTPUT MATRIX        
C        
  170 JROW = NOWCOL        
      IF (IFORM .EQ. 3) JROW = II        
      CALL ZBLPKI        
C        
C     TEST FOR SPECIAL CASE OF DIAGONAL INPUT MATRIX (1 COLUMN).        
C        
      IF (IFORM .EQ. 3) GO TO 175        
C        
C     SKIP REST OF INPUT COLUMN IF NOT ON LAST ELEMENT.        
C        
      IF (LAST .EQ. 0) CALL SKPREC (IN1,1)        
C        
C     TEST FOR SQUARE MATRIX CASE        
C     FINISHED WITH COLUMN IF SQUARE MATRIX        
C        
  175 IF (OPT(1) .EQ. SQ) CALL BLDPKN (IOUT,0,IB)        
C        
C     FINISHED WITH ONE OUTPUT ELEMENT.        
C        
      IF (IFORM.EQ.3 .AND. II.LT.INROW) GO TO 115        
  180 CONTINUE        
C        
C     FINISH PACKING VECTOR IF COLUMN OUTPUT OPTION.        
C        
      IF (OPT(1) .EQ. COL) CALL BLDPKN (IOUT,0,IB)        
C        
C     WRITE TRAILER IN FIAT.        
C        
      CALL WRTTRL (IB)        
C        
C     FINISHED WITH ALL OF MATRIX, CLOSE UNITS        
C        
      CALL CLOSE(IN1,1)        
      CALL CLOSE(IB ,1)        
  200 RETURN        
C        
C     ERROR MESSAGES        
C        
  210 RETURN        
C        
C     WRONG TYPE OF INPUT MATRIX = MSG.3016        
C        
  220 NUMM = -16        
      GO TO 300        
C        
C     NOT ENOUGH CORE (MESSAGE 3008)        
C        
  230 NUMM = -8        
      GO TO 300        
C        
  300 CALL MESAGE (NUMM,NUM,NAME)        
      RETURN        
C        
      END        
