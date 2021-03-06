      SUBROUTINE SFETCH (NAME,ITEM,IRW,ITEST)        
C        
C     POSITIONS THE SOF TO READ OR WRITE DATA ASSOCIATED WITH ITEM OF   
C     SUBSTRUCTURE NAME.        
C        
      EXTERNAL        ANDF        
      LOGICAL         MDIUP        
      INTEGER         ANDF,BUF,MDI,MDIPBN,MDILBN,MDIBL,BLKSIZ,DIRSIZ    
      DIMENSION       NAME(2),NMSBR(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DITDUM(6),IO,IOPBN,IOLBN,IOMODE,IOPTR,IOSIND,     
     1                IOITCD,IOBLK,MDI,MDIPBN,MDILBN,MDIBL,NXTDUM(15),  
     2                DITUP,MDIUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      COMMON /SYSTEM/ NBUFF,NOUT        
      DATA    IDLE  , IRD,IWRT /0,1,2/, NMSBR /4HSFET,4HCH  /        
C        
      CALL CHKOPN (NMSBR(1))        
      CALL FDSUB  (NAME(1),IOSIND)        
      IF (IOSIND .EQ. -1) GO TO 500        
      IOITCD = ITCODE(ITEM)        
      IF (IOITCD .EQ. -1) GO TO 510        
C        
C     CHECK IF ITEM IS A TABLE ITEM UNLESS SPECIAL CALL FROM MTRXO OR   
C     MTRXI        
C        
      IF (IRW .LT. 0) GO TO 10        
      ITM = ITTYPE(ITEM)        
      IF (ITM .NE. 0) GO TO 530        
   10 CALL FMDI (IOSIND,IMDI)        
      IOLBN = 1        
      IOPTR = IO + 1        
      IBL   = ANDF(BUF(IMDI+IOITCD),65535)        
      IRDWRT= IABS(IRW)        
      GO TO (30,80,30), IRDWRT        
C        
C     READ OPERATION.        
C        
   30 IF (IBL .EQ.     0) GO TO 50        
      IF (IBL .NE. 65535) GO TO 60        
C        
C     ITEM WAS PSEUDO-WRITTEN.        
C        
      ITEST = 2        
      GO TO 520        
C        
C     ITEM HAS NOT BEEN WRITTEN.        
C        
   50 ITEST = 3        
      GO TO 520        
C        
C     UPDATE THE COMMON BLOCK SOF, AND BRING INTO CORE THE DESIRED BLOCK
C        
   60 ITEST = 1        
      IF (IRDWRT .EQ. 3) GO TO 520        
      IOPBN  = IBL        
      IOMODE = IRD        
      CALL SOFIO (IRD,IOPBN,BUF(IO-2))        
      RETURN        
C        
C     WRITE OPERATION.        
C        
   80 IF (IBL.EQ.0 .OR. IBL.EQ.65535) GO TO 90        
C        
C     ITEM HAS ALREADY BEEN WRITTEN.        
C        
      ITEST = 1        
      GO TO 520        
   90 ITEST1 = ITEST - 1        
      GO TO (100,110), ITEST1        
C        
C     ITEM IS TO BE PSEUDO-WRITTEN.        
C        
  100 BUF(IMDI+IOITCD) = 65535        
      MDIUP = .TRUE.        
      RETURN        
C        
C     ITEM IS TO BE WRITTEN.  GET A FREE BLOCK AND UPDATE THE COMMON    
C     BLOCK SOF.        
C        
  110 CALL GETBLK (0,IOBLK)        
      IF (IOBLK .EQ. -1) GO TO 1000        
      IOPBN  = IOBLK        
      IOMODE = IWRT        
      RETURN        
C        
C     NAME DOES NOT EXIST.        
C        
  500 ITEST = 4        
      GO TO 520        
C        
C     ITEM IS AN ILLEGAL ITEM NAME.        
C        
  510 ITEST  = 5        
  520 IOMODE = IDLE        
      RETURN        
C        
C     ATTEMPT TO OPERATE ON A MATRIX ITEM        
C        
  530 WRITE  (NOUT,540) SFM,ITEM,NAME        
  540 FORMAT (A25,' 6227, AN ATTEMPT HAS BEEN MADE TO OPERATE ON THE ', 
     1       'MATRIX ITEM ',A4,' OF SUBSTRUCTURE ',2A4,' USING SFETCH.')
      GO TO 1010        
C        
C     NO MORE BLOCKS ON SOF        
C        
 1000 WRITE  (NOUT,1001) UFM        
 1001 FORMAT (A23,' 6223, SUBROUTINE SFETCH - THERE ARE NO MORE FREE ', 
     1       'BLOCKS AVAILABLE ON THE SOF.')        
 1010 CALL SOFCLS        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
