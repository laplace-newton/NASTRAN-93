      SUBROUTINE SHSTNS (NUMPX,ELID,IGRID,Z12,EPSLNI,BENDNG,IDR)        
C        
C     TO CALCULATE SHELL ELEMENT STRAINS FOR A 2-D FORMULATION BASE.    
C     COMPOSITE LAYER STRAINS ARE NOT CALCULATED IN THIS ROUTINE.       
C        
C        
C     INPUT :        
C           NUMPX  - NUMBER OF EVALUATION POINTS        
C           ELID   - ELEMENT ID        
C           IGRID  - ARRAY IF EXTERNAL GRID IDS        
C           Z12    - EVALUATION POINT FIBER DISTANCES        
C           EPSLNI - CORRECTED STRAINS AT EVALUATION POINTS        
C           BENDNG - INDICATES THE PRESENCE OF BENDING BEHAVIOR        
C           IDR    - REORDERING ARRAY BASED ON EXTERNAL GRID POINT ID'S 
C          /OUTREQ/- OUTPUT REQUEST LOGICAL FLAGS        
C        
C     OUTPUT:        
C           STRAINS ARE PLACED AT THE PROPER LOCATION IN /SDR2X7/.      
C        
C        
C     THE STRAIN OUTPUT DATA BLOCK, UAI CODE        
C        
C     ADDRESS    DESCRIPTIONS        
C        
C        1       ELID        
C     --------------------------------------------------------------    
C        2       GRID POINT NUMBER OR 'CNTR'        
C      3 - 10    STRAINS FOR LOWER POINTS OR MEMBRANE STRAINS        
C     11 - 18    STRAINS FOR UPPER POINTS OR BENDING CURVATURES        
C     ---------- ABOVE DATA REPEATED 3 TIMES        
C                FOR GRID POINTS        
C        
C        
C     THE STRAIN OUTPUT DATA BLOCK, AT ELEMENT CENTER ONLY, COSMIC      
C        
C     ADDRESS    DESCRIPTIONS        
C        
C        1       ELID        
C     --------------------------------------------------------------    
C        2       LOWER FIBER DISTANCE        
C      3 -  9    STRAINS FOR LOWER POINTS OR MEMBRANE STRAINS        
C       10       UPPER FIBER DISTANCE        
C     11 - 17    STRAINS FOR UPPER POINTS OR BENDING CURVATURES        
C     ---------- ABOVE DATA REPEATED 3 TIMES        
C                FOR GRID POINTS        
C        
C        
      LOGICAL         BENDNG,STSREQ,STNREQ,FORREQ,STRCUR,        
     1                GRIDS,VONMS,LAYER,GRIDSS,VONMSS,LAYERS,COSMIC     
      INTEGER         IGRID(1),NSTRIN(1),IDR(1),ELID        
      REAL            Z12(2,1),EPSLNI(6,1),EPSIL(3),EPSS,FIBER,EPSILP(4)
      COMMON /SDR2X7/ DUM71(100),STRES(100),FORSUL(200),STRIN(100)      
      COMMON /OUTREQ/ STSREQ,STNREQ,FORREQ,STRCUR,GRIDS,VONMS,LAYER     
     1,               GRIDSS,VONMSS,LAYERS        
      EQUIVALENCE     (NSTRIN(1),STRIN(1))        
      DATA    COSMIC, EPSS / .TRUE., 1.0E-17 /        
C        
C        
C     ELEMENT ENTER COMPUATION ONLY FOR COSMIC        
C     I.E. CALLER SHOULD PASS 1 IN NUMPX FOR COSMIC, 4 FOR UAI        
C        
      NUMP = NUMPX        
      IF (COSMIC) NUMP = 1        
C        
      NSTRIN(1) = ELID        
C        
C     START THE LOOP ON EVALUATION POINTS        
C        
      NUMP1 = NUMP - 1        
      DO 250 INPLAN = 1,NUMP        
C        
      ISTRIN = 1        
      IF (COSMIC) GO TO 140        
C        
      ISTRIN = (INPLAN-1)*17 + 2        
      NSTRIN(ISTRIN) = INPLAN - 1        
      IF (.NOT.GRIDSS .OR. INPLAN.LE.1) GO TO 130        
      DO 100 INPTMP = 1,NUMP1        
      IF (IDR(INPTMP) .EQ. IGRID(INPLAN)) GO TO 120        
  100 CONTINUE        
      CALL ERRTRC ('SHSTNS  ',100)        
  120 ISTRIN = INPTMP*17 + 2        
      NSTRIN(ISTRIN) = IGRID(INPLAN)        
  130 IF (INPLAN .EQ. 1) NSTRIN(ISTRIN) = IGRID(INPLAN)        
C        
C     START THE LOOP ON FIBERS        
C        
  140 DO 240 IZ = 1,2        
      IF (.NOT.STRCUR) GO TO 190        
C        
C     IF STRAIN/CURVATURE IS REQUESTED, SIMPLY OUTPUT THE AVAILABLE     
C     STRAINS.        
C        
      STRIN(ISTRIN+1) = 0.0        
      DO 150 I = 1,3        
      EPSIL(I) = 0.0        
  150 CONTINUE        
      IF (IZ .NE. 1) GO TO 170        
      DO 160 I = 1,3        
      EPSIL(I) = EPSLNI(I,INPLAN)        
  160 CONTINUE        
  170 IF (.NOT.BENDNG .OR. IZ.NE.2) GO TO 190        
      DO 180 I = 1,3        
      EPSIL(I) = EPSLNI(I+3,INPLAN)        
  180 CONTINUE        
      GO TO 220        
C        
C     IF FIBER STRAINS ARE REQUESTED, EVALUATE STRAINS AT THIS FIBER    
C     DISTANCE        
C        
  190 FIBER = Z12(IZ,INPLAN)        
      STRIN(ISTRIN+1) = FIBER        
      DO 200 I = 1,3        
      EPSIL(I) = EPSLNI(I,INPLAN) - EPSLNI(I+3,INPLAN)*FIBER        
  200 CONTINUE        
C        
C     CLEANUP AND SHIP CALCULATED STRAINS        
C        
  220 DO 230 ITS = 1,3        
      IF (ABS(EPSIL(ITS)) .LE. EPSS) EPSIL(ITS) = 0.0        
      STRIN(ISTRIN+1+ITS) = EPSIL(ITS)        
  230 CONTINUE        
C        
C     CALCULATE PRINCIPAL STRAINS        
C        
      CALL SHPSTS (EPSIL(1),VONMSS,EPSILP)        
      STRIN(ISTRIN+5) = EPSILP(1)        
      STRIN(ISTRIN+6) = EPSILP(2)        
      STRIN(ISTRIN+7) = EPSILP(3)        
      STRIN(ISTRIN+8) = EPSILP(4)        
C        
      ISTRIN = ISTRIN + 8        
  240 CONTINUE        
  250 CONTINUE        
C        
      RETURN        
      END        
