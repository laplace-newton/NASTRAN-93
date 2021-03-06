      SUBROUTINE NORMAL        
C        
C     THIS IS THE DRIVER FOR THE NORM MODULE.        
C        
C     NORM        INMAT/OUTMAT/S,N,NCOL/S,N,NROW/S,N,XNORM/V,Y,IOPT $   
C        
C     DEPENDING ON THE VALUE OF IOPT, THIS MODULE PERFORMS THE        
C     FOLLOWING FUNCTIONS --        
C        
C     IOPT = 'MAX'        
C                 NORM GENERATES A MATRIX.  EACH COLUMN OF THIS OUTPUT  
C                 MATRIX REPRESENTS A COLUMN OF THE INPUT MATRIX        
C                 NORMALIZED BY ITS LARGEST ROW ELEMENT. (DEFAULT)      
C        
C     IOPT = 'SRSS'        
C                 NORM GENERATES A COLUMN VECTOR.  EACH ELEMENT OF THIS 
C                 VECTOR REPRESENTS THE SQUARE ROOT OF THE SUM OF THE   
C                 SQUARES (SRSS) OF THE CORRESPONDING ROW OF THE INPUT  
C                 MATRIX.        
C        
C        
C        
C     INPUT DATA BLOCK --        
C        
C     INMAT     - ANY MATRIX        
C        
C     OUTPUT DATA BLOCK --        
C        
C     OUTMAT    - OUTPUT MATRIX GENERATED AS DESCRIBED BELOW        
C        
C     PARAMETERS --        
C        
C     NCOL      - NO. OF COLUMNS OF THE INPUT MATRIX (OUTPUT/INTEGER)   
C        
C     NROW      - NO. OF ROWS OF THE INPUT MATRIX (OUTPUT/INTEGER)      
C        
C     XNORM     - MAX. NORMALIZING OR SRSS VALUE, DEPENDING UPON THE    
C                 IOPT VALUE SPECIFIED (OUTPUT/REAL)        
C     IOPT      - OPTION INDICATING WHETHER EACH COLUMN OF THE INPUT    
C                 MATRIX IS TO BE NORMALIZED BY THE MAXIMUM ROW ELEMENT 
C                 IN THAT COLUMN OR WHETHER THE SRSS VALUE FOR EACH ROW 
C                 OF THE INPUT MATRIX IS TO BE COMPUTED (INPUT/BCD)     
C        
C     THIS MODULE DEVELOPED BY P. R. PAMIDI OF RPK CORPORATION,        
C     MARCH 1988        
C        
      DIMENSION        MCB(7), Z(1)   , ISUBNM(2)        
      DOUBLE PRECISION DXMAX , ZD(1)  , DZERO        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /BLANK /  NCOL   , NROW   , XXMAX , IOPT(2)        
      COMMON /PACKX /  IPKOT1 , IPKOT2 , IP1   , IP2   , INCRP        
      COMMON /SYSTEM/  ISYSBF , NOUT        
      COMMON /TYPE  /  IPRC(2), NWDS(4), IRC(4)        
      COMMON /UNPAKX/  IUNOUT , IU1    , IU2   , INCRU        
CZZ   COMMON /ZZNRML/  IZ(1)        
      COMMON /ZZZZZZ/  IZ(1)        
      EQUIVALENCE      (IZ(1),Z(1),ZD(1)), (IOPT1,IOPT(1))        
      DATA    MATIN ,  MATOUT / 101, 201/        
      DATA    ISUBNM,           MAX     , ISRSS , IBLNK  , DZERO  /     
     1        4HNORM,  4HAL   , 4HMAX   , 4HSRSS, 4H     , 0.0D+0 /     
C        
      IF (IOPT(2).EQ.IBLNK .AND. (IOPT1.EQ.MAX .OR. IOPT1.EQ.ISRSS))    
     1    GO TO 20        
      WRITE  (NOUT,10) UFM,IOPT        
   10 FORMAT (A23,', ILLEGAL BCD VALUE (', 2A4,') FOR THE 4TH PARAMATER'
     1,      ' IN MODULE NORM')        
      CALL MESAGE (-61,0,0)        
   20 INCRU  = 1        
      INCRP  = 1        
      ICORE  = KORSZ(IZ)        
      IBUF1  = ICORE - ISYSBF + 1        
      IBUF2  = IBUF1 - ISYSBF        
      ICORE  = IBUF2 - 1        
      CALL GOPEN (MATIN ,IZ(IBUF1),0)        
      CALL GOPEN (MATOUT,IZ(IBUF2),1)        
      MCB(1) = MATIN        
      CALL RDTRL (MCB)        
      NCOL   = MCB(2)        
      NROW   = MCB(3)        
      NROW2  = 2*NROW        
      ITYPE  = MCB(5)        
      IPREC  = ITYPE        
      IF (IPREC .GT. 2) IPREC = IPREC - 2        
      IUNOUT = ITYPE        
      IPKOT1 = ITYPE        
      IPKOT2 = ITYPE        
      NROWP  = IPREC*NROW        
      NWORDS = NWDS(ITYPE)        
      MWORDS = NROW*NWORDS        
      KWORDS = MWORDS        
      IF (IOPT1 .NE. MAX) KWORDS = KWORDS + NROWP        
      ICRREQ = KWORDS - ICORE        
      IF (ICRREQ .GT. 0) CALL MESAGE (-8,ICRREQ,ISUBNM)        
      IVEC   = MWORDS        
      IVEC1  = IVEC + 1        
      IVEC2  = IVEC + NROWP        
      IF (IOPT1 .EQ. MAX) GO TO 40        
      MCB(5) = IPREC        
      IPKOT1 = IPREC        
      IPKOT2 = IPREC        
      DO 30 I= IVEC1,IVEC2        
   30 Z(I)   = 0.0        
   40 MCB(1) = MATOUT        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      IU1    = 1        
      IU2    = NROW        
C        
      XXMAX  = 0.0        
      DO 700 I = 1,NCOL        
      XX   = 0.0        
      CALL UNPACK (*50,MATIN,Z)        
      IP1  = IU1        
      IP2  = IU2        
      XMAX =-1.0        
      GO TO 70        
   50 IP1  = 1        
      IP2  = 1        
      XMAX = 0.0        
      DO 60 J = 1,NWORDS        
      Z(J) = 0.0        
   60 CONTINUE        
C        
   70 IF (IOPT1 .EQ. ISRSS) GO TO 600        
      IF (XMAX  .EQ.   0.0) GO TO 510        
C        
C     OPTION IS MAX        
C        
      GO TO (100,200,300,400), ITYPE        
C        
  100 XMAX = 0.0        
      DO 110 J = 1,NROW        
      X = ABS(Z(J))        
      IF (X .GT. XMAX) XMAX = X        
  110 CONTINUE        
      IF (XMAX .EQ. 0.0) GO TO 510        
      XX = XMAX        
      DO 120 J = 1,NROW        
      Z(J) = Z(J)/XMAX        
  120 CONTINUE        
      GO TO 500        
C        
  200 DXMAX = DZERO        
      DO 210 J = 1,NROW        
      DX = DABS(ZD(J))        
      IF (DX .GT. DXMAX) DXMAX = DX        
  210 CONTINUE        
      IF (DXMAX .EQ. DZERO) GO TO 510        
      XX = DXMAX        
      DO 220 J = 1,NROW        
      ZD(J) = ZD(J)/DXMAX        
  220 CONTINUE        
      GO TO 500        
C        
  300 XMAX = 0.0        
      DO 310 J = 1,NROW2,2        
      X = SQRT(Z(J)*Z(J) + Z(J+1)**2)        
      IF (X .GT. XMAX) XMAX = X        
  310 CONTINUE        
      IF (XMAX .EQ. 0.0) GO TO 510        
      XX = XMAX        
      DO 320 J = 1,NROW2,2        
      Z(J  ) = Z(J  )/XMAX        
      Z(J+1) = Z(J+1)/XMAX        
  320 CONTINUE        
      GO TO 500        
C        
  400 DXMAX = DZERO        
      DO 410 J = 1,NROW2,2        
      DX = DSQRT(ZD(J)*ZD(J) + ZD(J+1)**2)        
      IF (DX .GT. DXMAX) DXMAX = DX        
  410 CONTINUE        
      IF (DXMAX .EQ. DZERO) GO TO 510        
      XX = DXMAX        
      DO 420 J = 1,NROW2,2        
      ZD(J  ) = ZD(J  )/DXMAX        
      ZD(J+1) = ZD(J+1)/DXMAX        
  420 CONTINUE        
C        
  500 IF (XX .GT. XXMAX) XXMAX = XX        
  510 CALL PACK (Z,MATOUT,MCB)        
      GO TO 700        
C        
C     OPTION IS SRSS        
C        
  600 IF (XMAX .EQ. 0.0) GO TO 700        
      GO TO (610,630,650,670), ITYPE        
C        
  610 DO 620 J = 1,NROW        
      K = IVEC + J        
      Z(K) = Z(K) + Z(J)*Z(J)        
  620 CONTINUE        
      GO TO 700        
C        
  630 DO 640 J = 1,NROW        
      K = IVEC + J        
      ZD(K) = ZD(K) + ZD(J)*ZD(J)        
  640 CONTINUE        
      GO TO 700        
C        
  650 K = IVEC        
      DO 660 J = 1,NROW2,2        
      K = K + 1        
      Z(K) = Z(K) + Z(J)*Z(J) + Z(J+1)**2        
  660 CONTINUE        
      GO TO 700        
C        
  670 K = IVEC        
      DO 680 J = 1,NROW2,2        
      K = K + 1        
      ZD(K) = ZD(K) + ZD(J)*ZD(J) + ZD(J+1)**2        
  680 CONTINUE        
C        
  700 CONTINUE        
      CALL CLOSE (MATIN, 1)        
      IF (IOPT1 .EQ. MAX) GO TO 760        
C        
      IP1 = IU1        
      IP2 = IU2        
      GO TO (710,730), IPREC        
C        
  710 DO 720 I = IVEC1,IVEC2        
      Z(I) = SQRT(Z(I))        
      IF (Z(I) .GT. XXMAX) XXMAX = Z(I)        
  720 CONTINUE        
      GO TO 750        
C        
  730 DO 740 I = IVEC1,IVEC2        
      ZD(I) = DSQRT(ZD(I))        
      IF (ZD(I) .GT. XXMAX) XXMAX = ZD(I)        
  740 CONTINUE        
C        
  750 CALL PACK (Z(IVEC1),MATOUT,MCB)        
C        
  760 CALL CLOSE (MATOUT,1)        
      CALL WRTTRL (MCB)        
      RETURN        
      END        
