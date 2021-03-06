      SUBROUTINE PLTTRA        
C        
C     PLTTRA MODIFIES THE SIL AND BGPDT TABLES FOR THE PURPOSE OF       
C     PLOTTING SPECIAL SCALAR GRID POINTS        
C        
C     INPUT  SIL  BGPDT  LUSET        
C     OUTPUT SIP  BGPDP  LUSEP        
C        
C     SPECIAL SCALAR GRID POINTS        
C     BGPDT(I,1)= 1  SIL(I+1)-SIL(I)=1        
C     BGPDP(I,1)=-2  SIP(I+1)-SIP(I)=6        
C        
C     LUSET IS THE VALUE OF SIL(LAST+1) IF IT EXISTED        
C     LUSEP IS THE VALUE OF SIP(LAST+1) IF IT EXISTED        
C        
      LOGICAL         LEOF        
      INTEGER         SYSBUF,BUF1,BUF2,BUF3,BUF4,FILE,SIL,BGPDT,SIP,    
     1                BGPDP,NAME(2),Z,PLT(2),FLAG,A,B,S1,S2,DELTA       
      DIMENSION       A(4),B(2),MCB(7)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / LUSET,LUSEP        
      COMMON /SYSTEM/ SYSBUF,NOT        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,CLS        
CZZ   COMMON /ZZPLTR/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (A(3),B(1)),(FILE,MCB(1))        
      DATA    BGPDT , SIL,BGPDP,SIP/ 101,102,201,202 /        
      DATA    PLT   / 4HPLTT,4HRA  /,   MCB / 7*0    /        
      DATA    LEOF  / .FALSE./        
C        
      NADD = 0        
      NS   = 0        
C        
C     LOCATE STORAGE AREA FOR FILE BUFFERS        
C        
      NZ   = KORSZ(Z)        
      BUF1 = NZ   - SYSBUF + 1        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      IF (BUF4 .LE. 0) CALL MESAGE (-8,NZ,PLT)        
C        
C     READ TRAILER RECORDS OF INPUT FILES AND CHECK COMPATABILITY       
C     OPEN AND FOREWARD SPACE LABEL RECORD OF INPUT FILES        
C     OPEN AND WRITE LABEL RECORD OF OUTPUT FILES        
C        
      FILE = BGPDT        
      CALL RDTRL (MCB)        
      CALL FNAME (FILE,NAME)        
      IF (FILE .LE. 0) GO TO 900        
      CALL OPEN (*900, BGPDT, Z(BUF2), RDREW)        
      CALL FWDREC (*1010,BGPDT)        
C        
      FILE = SIL        
      CALL RDTRL (MCB)        
      CALL FNAME (FILE,NAME)        
      IF (FILE .LE. 0) GO TO 900        
      IF (MCB(3) .NE. LUSET) GO TO 1130        
      CALL OPEN (*900,SIL,Z(BUF1),RDREW)        
      CALL FWDREC (*1010,SIL)        
C        
      FILE = SIP        
      CALL FNAME (SIP,A)        
      CALL OPEN  (*1000,SIP,Z(BUF3),WRTREW)        
      CALL WRITE (SIP,A,2,1)        
C        
      FILE = BGPDP        
      CALL OPEN  (*1000,BGPDP,Z(BUF4),WRTREW)        
      CALL FNAME (BGPDP,B)        
      CALL WRITE (BGPDP,B,2,1)        
C        
C     READ SIL(I)        
C        
      FILE = SIL        
      CALL READ (*1010,*1020,SIL,S1,1,0,FLAG)        
C        
C     READ SIL(I+1)        
C        
   10 FILE = SIL        
      CALL READ (*1010,*30,SIL,S2,1,0,FLAG)        
C        
C     READ BGPDT(I,J)        
C        
   15 FILE = BGPDT        
      CALL READ (*1010,*1020,BGPDT,A,4,0,FLAG)        
      DELTA = 0        
      NS = NS + 1        
C        
C     CHECK IF SPECIAL SCALAR GRID POINT        
C        
      IF (A(1).LT.0 .OR. S2-S1.EQ.6) GO TO 20        
      IF (S2-S1 .NE. 1) GO TO 1110        
C        
C     SPECIAL SCALAR GRID POINT        
C        
      DELTA = 5        
      A(1)  =-2        
   20 S1 = S1 + NADD        
C        
C     WRITE SIP AND BGPDP TABLE ENTRIES        
C        
      CALL WRITE (SIP,S1,1,0)        
      CALL WRITE (BGPDP,A,4,0)        
      NADD = NADD + DELTA        
      IF (LEOF) GO TO 40        
      S1 = S2        
      GO TO 10        
C        
C     SIL(I) IS SIL(LAST)        
C        
   30 LEOF = .TRUE.        
      S2   = LUSET + 1        
      GO TO 15        
   40 LUSEP = LUSET + NADD        
C        
C     CLOSE OUTPUT FILES AND WRITE TRAILER RECORDS        
C        
      CALL CLOSE (SIL  ,CLSREW)        
      CALL CLOSE (BGPDT,CLSREW)        
      CALL CLOSE (SIP  ,CLSREW)        
      CALL CLOSE (BGPDP,CLSREW)        
      MCB(1) = BGPDP        
      MCB(3) = 0        
      CALL WRTTRL (MCB)        
      MCB(1) = SIP        
      MCB(3) = LUSEP        
      CALL WRTTRL (MCB)        
      RETURN        
C        
  900 LUSEP = LUSET        
      RETURN        
C        
C     ERROR DIAGNOSTICS        
C        
 1000 NDX = -1        
      GO TO 1100        
 1010 NDX = -2        
      GO TO 1100        
 1020 NDX = -3        
 1100 CALL MESAGE (NDX,FILE,PLT)        
      GO TO 1150        
 1130 WRITE  (NOT,2001) UFM,LUSET,MCB(3)        
 2001 FORMAT (A23,' 5011, FIRST PARAMETER',I6,' NE TRAILER RECORD ',    
     1       'PARAMETER',I6)        
      GO TO 1150        
 1110 WRITE  (NOT,2002) UFM,NS        
 2002 FORMAT (A23,' 5012, ENTRY',I6,' OF SIL TABLE INCOMPATIBLE WITH ', 
     1       'NEXT ENTRY')        
 1150 CALL MESAGE (-61,0,0)        
      RETURN        
      END        
