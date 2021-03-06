      SUBROUTINE SMA3        
C        
C     THIS ROUTINE, FOR EACH GENERAL ELEMENT, READS THE GENERAL ELEMENT 
C     INPUT FILE, GEI, CALLS SMA3A OR SMA3B, DEPENDING UPON WHETHER OR  
C     NOT THE ORDERS OF THE K OR Z AND S MATRICES WILL ALLOW THE IN CORE
C     MATRIX ROUTINES (CALLED BY SMA3A) TO BE USED, AND THEN CALLS THE  
C     MATRIX ADD ROUTINE TO ADD THE KGGX MATRIX TO THE GENERAL ELEMENT  
C     MATRIX.        
C        
      LOGICAL          EVEN,ONLYGE        
      INTEGER          IQ(1),EOR,OUTRW,CLSRW,CLSNRW        
      DOUBLE PRECISION DQ(1)        
      DIMENSION        IBUFF3(3),NAME(2),MCBID(7),BLOCK(11),IBLOCK(11)  
      COMMON /BLANK /  LUSET,NGENEL,NOECPT        
      COMMON /SYSTEM/  KSYSTM(65)        
CZZ   COMMON /ZZSMA3/  Q(1)        
      COMMON /ZZZZZZ/  Q(1)        
      COMMON /GENELY/  IFGEI,IFKGGX,IFOUT,IFA,IFB,IFC,IFD,IFE,IFF,INRW, 
     1                 OUTRW,CLSRW,CLSNRW,EOR,NEOR,MCBA(7),MCBB(7),     
     2                 MCBC(7),MCBD(7),MCBE(7),MCBF(7),MCBKGG(7),       
     3                 IUI,IUD,IZI,IS,IZIS,ISTZIS,IBUFF3,LEFT        
      EQUIVALENCE      (KSYSTM(1),ISYS),(KSYSTM(55),IPREC),        
     1                 (IQ(1),DQ(1),Q(1)),(IBUFF3(2),M),(IBUFF3(3),N),  
     2                 (MCBID(1),MCBC(1)),(BLOCK(1),IBLOCK(1))        
      DATA    NAME  /  4HSMA3,4H    /        
C        
C     GENERAL INITIALIZATION        
C        
      IFGEI  = 101        
      IFKGGX = 102        
      IF201  = 201        
      IF301  = 301        
      IF302  = 302        
      IF303  = 303        
      IF304  = 304        
      IF305  = 305        
      IF306  = 306        
      IFOUT  = IF201        
      IFA    = IF301        
      IFB    = IF302        
      IFC    = IF303        
      IFD    = IF304        
      IFE    = IF305        
      IFF    = IF306        
      IFG    = 307        
      INRW   = 0        
      OUTRW  = 1        
      CLSRW  = 1        
      CLSNRW = 2        
      EOR    = 1        
      NEOR  = 0        
C        
C     DETERMINE THE SIZE OF VARIABLE CORE AVAILABLE AND SET IUI TO THE  
C     ZEROTH LOCATION OF VARIABLE CORE.        
C        
      IQMAX = KORSZ (Q)        
      IUI   = 0        
C        
C     OPEN THE GENERAL ELEMENT INPUT FILE AND SKIP OVER THE HEADER      
C     RECORD.        
C        
      IGGEI = IQMAX - ISYS + 1        
      CALL GOPEN (IFGEI,Q(IGGEI),0)        
      IGA   = IGGEI - ISYS        
C        
C     DETERMINE IF THE NUMBER OF GENERAL ELEMENTS IS EVEN OR ODD.       
C        
      EVEN = .TRUE.        
      IF ((NGENEL/2)*2 .NE. NGENEL) EVEN = .FALSE.        
      IPASS = 0        
C        
C     COMPUTE LENGTH OF OPEN CORE        
C        
      LEFT = IGA - 1        
      NZ   = LEFT        
C        
C     READ THE TRAILER FOR KGGX TO SEE IF IT EXISTS.        
C        
      ONLYGE = .FALSE.        
      MCBKGG(1) = IFKGGX        
      CALL RDTRL (MCBKGG(1))        
      IF (MCBKGG(1) .LT. 0) GO TO 12        
      IFB = MCBKGG(1)        
      DO 10 I = 1,7        
      MCBB(I) = MCBKGG(I)        
   10 MCBKGG(I) = 0        
      GO TO 14        
   12 ONLYGE = .TRUE.        
C        
C     INITIALIZATION PRIOR TO LOOP        
C        
   14 IF (ONLYGE) GO TO 21        
      IFOUT = IF201        
      IF (EVEN) IFOUT = IF302        
      GO TO 30        
   21 IFA = IFOUT        
      IF (EVEN) IFA = IF302        
C        
C     BEGIN MAIN LOOP OF THE PROGRAM        
C        
   30 IPASS = IPASS + 1        
C        
C     READ THE ELEMENT ID, THE LENGTH OF THE UI SET, M, AND THE LENGTH  
C     OF THE UD SET, N        
C        
      CALL READ (*200,*210,IFGEI,IBUFF3(1),3,NEOR,IDUMMY)        
      NEEDED = 2*(M+N+M**2 + N**2 + 2*M*N)        
      ITEMP1 = 2*(M+N+ M**2) + 3*M        
      IF (ITEMP1 .GT. NEEDED) NEEDED = ITEMP1        
C        
C     DETERMINE IF THERE IS ENOUGH CORE STORAGE AVAILABLE TO USE THE IN 
C     CORE MATRIX ROUTINES.        
C        
      IF (NEEDED .GT. LEFT) GO TO 140        
C        
C        
C     **********  IN CORE VERSION  ****************        
C        
C     USE THE IN CORE MATRIX ROUTINES.  CALL SMA3A.        
C        
      CALL MAKMCB (MCBA,IFA,0,6,IPREC)        
C        
C     OPEN THE FILE ON WHICH THE CURRENT GENERAL ELEMENT WILL BE OUTPUT.
C        
      CALL GOPEN (IFA,Q(IGA),1)        
      CALL SMA3A (MCBA)        
C        
C     STORE THE CORRECT NUMBER OF ROWS IN THE 3RD WORD OF THE MATRIX    
C     CONTROL BLOCK AND CLOSE THE FILE WITH REWIND.        
C        
      MCBA(3) = MCBA(2)        
      CALL WRTTRL (MCBA)        
      CALL CLOSE (IFA,CLSRW)        
C        
C     SUMATION        
C        
C     JUMP TO 100 ONLY IF THIS IS THE FIRST PASS AND KGGX DOES NOT EXIST
C        
   60 IF (IPASS.EQ.1 .AND. ONLYGE) GO TO 100        
      CALL MAKMCB (MCBKGG,IFOUT,0,6,IPREC)        
      IBLOCK(1) = 1        
      BLOCK (2) = 1.0        
      BLOCK (3) = 0.0        
      BLOCK (4) = 0.0        
      BLOCK (5) = 0.0        
      BLOCK (6) = 0.0        
      IBLOCK(7) = 1        
      BLOCK (8) = 1.0        
      BLOCK (9) = 0.0        
      BLOCK(10) = 0.0        
      BLOCK(11) = 0.0        
C        
C     CLOSE GEI WITH NO REWIND SO SUBROUTINE ADD CAN HAVE THE BUFFER    
C        
      CALL CLOSE (IFGEI,2)        
C        
C     CALL SSG2C TO PERFORM SUMMATION - OUTPUT ON IFOUT        
C        
      CALL SSG2C (IFA,IFB,IFOUT,0,BLOCK)        
      IF (IPASS .EQ. NGENEL) GO TO 160        
      CALL RDTRL (MCBKGG)        
C        
C     RESTORE GEI AFTER SUMATION        
C        
      CALL GOPEN (IFGEI,Q(IGGEI),2)        
      IF (IPASS  .GT. 1) GO TO 130        
  100 IF (NGENEL .EQ. 1) GO TO 160        
      IFA   = IF301        
      IFB   = IF302        
      IFOUT = IF201        
      IF (.NOT.EVEN) GO TO 130        
      IFB   = IF201        
      IFOUT = IF302        
C        
C     SWITCH FILES IFB AND IFOUT FOR NEXT GENEL PROCESSING        
C        
  130 DO 135 I = 1,7        
      II = MCBKGG(I)        
      MCBKGG(I) = MCBB(I)        
  135 MCBB(I) = II        
      II = IFOUT        
      IFOUT = IFB        
      IFB = II        
C        
C     RETURN TO BEGIN LOOP        
C        
      GO TO 30        
C        
C     ***********  OUT OF CORE VERSION  *************        
C        
C     IFOUT MUST CONTAIN THE RESULTS OF THE LAST GENEL PROCESSED        
C     SWITCH FILES IFB AND IFOUT FOR OUT OF CORE VERSION        
C        
  140 IF (IPASS.EQ.1 .AND. ONLYGE .AND. .NOT.EVEN) GO TO 142        
      DO 141 I = 1,7        
      II = MCBKGG(I)        
      MCBKGG(I) = MCBB(I)        
  141 MCBB(I) = II        
      II = IFOUT        
      IFOUT = IFB        
      IFB = II        
C        
C     THE IN CORE MATRIX ROUTINES CANNOT BE USED.SUBROUTINE SMA3B BUILDS
C     THE ZE IF Z IS INPUT OR THE ZINYS IF K IS INPUT AND IF PRESENT THE
C     SE MATRICES. IF THE SE MATRIX IS PRESENT ISE IS POSITIVE.        
C     NOTE - SE(T) IS ON THE SE FILE.        
C        
  142 CALL SMA3B (ISE,IZK)        
      IF (IZK .EQ. 2) GO TO 145        
C        
C     FACTOR DECOMPOSES THE ZE MATRIX INTO ITS UPPER AND LOWER        
C     TRIANGULAR FACTORS.  TWO SCRATCH FILES ARE NEEDED.        
C        
      CALL FACTOR (IFA,IFE,IFF,IFD,IFC,IFG)        
C        
C     CONVERT IFB INTO THE IDENTITY MATRIX.  (MCBID HAS BEEN SET UP BY  
C     SMA3B)        
C        
      CALL WRTTRL (MCBID)        
C        
C     COMPUTE Z INVERSE        
C        
      CALL SSG3A (IFA,IFE,IFC,IFD,0,0,-1,0)        
  145 CONTINUE        
C        
C     GO TO 150 IF NO SE MATRIX IS PRESENT.        
C        
      IF (ISE .LT. 0) GO TO 150        
C        
C               T        T  -1        
C     COMPUTE -S XK OR -S XZ  AND STORE ON IFF        
C               E  E     E  E        
C        
      CALL SSG2B (IFB,IFD,0,IFF,0,IPREC,1,IFC)        
C        
C     TRANSPOSE THE SE FILE ONTO IFA.  HENCE IFA CONTAINS THE -SE MATRIX
C        
      CALL TRANP1 (IFB,IFA,1,IFC,0,0,0,0,0,0,0)        
C        
C                       -1        
C     COMPUTE K X-S OR Z  X-S AND STORE ON IFE        
C              E   E    E    E        
C        
      CALL SSG2B (IFD,IFA,0,IFE,0,IPREC,1,IFC)        
C        
C              T          T  -1        
C     COMPUTE S XK XS OR S XZ  XS AND STORE ON IFC        
C              E  E  E    E  E   E        
C        
      CALL SSG2B (IFB,IFE,0,IFC,0,IPREC,1,IFA)        
C        
C     SMA3C BUILDS THE FINAL MATRIX OF G (LUSET) SIZE.        
C        
      MCBA(1) = IFA        
  150 CALL SMA3C (ISE,MCBA)        
C        
C     RETURN FILES IFB AND IFOUT TO ORIGIONAL FILES AFTER OUT OF CORE   
C        
      IF (IPASS.EQ.1 .AND. ONLYGE .AND. .NOT.EVEN) GO TO 60        
      DO 155 I = 1,7        
      II = MCBKGG(I)        
      MCBKGG(I) = MCBB(I)        
  155 MCBB(I) = II        
      II = IFOUT        
      IFOUT = IFB        
      IFB = II        
C        
C     RETURN TO SUMATION        
C        
      GO TO 60        
C        
C     WRAP-UP        
C        
  160 CALL CLOSE (IFGEI, CLSRW)        
      IF (IFOUT .NE. IF201) CALL MESAGE (-30,28,5)        
      RETURN        
C        
C     FATAL ERROR MESSAGES        
C        
  200 CALL MESAGE (-2,IFGEI,NAME)        
  210 CALL MESAGE (-3,IFGEI,NAME)        
      RETURN        
      END        
