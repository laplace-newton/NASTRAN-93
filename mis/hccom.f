      SUBROUTINE HCCOM(ITYPE,LCORE,ICORE,NEXTZ,KCOUNT)        
C        
C COMBINES HC CENTROID INFO ON SCR6 TO HCCENS        
C        
      INTEGER SCR6,HCCENS,IZ(1),ID(2),NAM(2),MCBH(7)        
      LOGICAL INCORE,BLDP,EOR        
      DIMENSION HC(63)        
      COMMON/SYSTEM/IDUM,IOUT        
CZZ   COMMON/ZZSSA1/Z(1)        
      COMMON/ZZZZZZ/Z(1)        
      COMMON/PACKX/ITA,ITB,II,JJ,INCR        
      COMMON/ZBLPKX/A(4),IROW        
      EQUIVALENCE (Z(1),IZ(1))        
      DATA MCBH/307,0,0,2,1,0,0/        
      DATA SCR6,HCCENS/306,307/        
      DATA NAM/4HHCCO,4HM   /        
C        
      ITA=1        
      ITB=1        
      II=1        
      INCR=1        
      ICOUNT=0        
      NSKIP=0        
      NSKIP1=0        
      IN=0        
      EOR=.FALSE.        
      BLDP=.FALSE.        
      INCORE=.TRUE.        
C        
C IF TYPE IS 24 JUST PACK ZEROS ON HCCENS        
C        
      IF(ITYPE.EQ.24)GO TO 60        
C        
      CALL GOPEN(SCR6,Z(LCORE+1),0)        
C        
C SCR6 HAS 3 ENTRIES PER ELEMENT-ID,NUMBER OF POINTS AT WHICH HC IS     
C COMPUTED=N, AND 3*N HC VALUES--THERE IS ONE RECORD PER CARD TYPE      
C ON SCR6 FOR THIS SUBCASE        
C IF  .NOT. INCORE, THEN WE ARE BACK HERE DUE TO SPILL LOGIC AND  ARE   
C TRYING TO FINISH THE FIRST RECORD. SO WE MUST SKIP THE PART OF THE    
C RECORD PREVIOUSLY READ.        
C        
    5 IF(.NOT.INCORE)CALL FREAD(SCR6,ID,-NSKIP,0)        
      INWORD=0        
   10 CALL READ (*1002,*20,SCR6,ID,2,0,NWDS)        
      NSKIP=NSKIP+2        
      INEXT=NEXTZ+INWORD        
      NWORDS=3*ID(2)        
      IF(INEXT+NWORDS.GT.ICORE)GO TO 80        
      CALL FREAD(SCR6,Z(INEXT),NWORDS,0)        
C        
C INWORD IS THE NUMBER OF WORDS READ INTO CORE ON THIS READ        
C NSKIP IS THE TOTAL NUMBER OF WORDS READ FROM SCR6 FROM THIS RECORD    
C ICOUNT IS THE TOTAL NUMBER OF WORDS SAVED IN CORE FROM THIS RECORD    
C        
      INWORD=INWORD+NWORDS        
      NSKIP=NSKIP+NWORDS        
      ICOUNT=ICOUNT+NWORDS        
      GO TO 10        
C        
   20 EOR=.TRUE.        
      IF(.NOT.INCORE)GO TO 95        
C        
C CHECK ON COUNT CONSISTENCY        
C        
      IF(ICOUNT.NE.KCOUNT)GO TO 500        
C        
C EOR ON SCR6, I.E. END OF HC FOR A GIVEN CARD TYPE IN THIS SUBCASE.    
C IF OTHER CARD TYPES EXIST IN THIS SUBCASE, THEY ARE IN SUBSEQUENT     
C RECORDS. ADD RESULTS TO PREVIOUS ONES        
C        
   30 JCOUNT=0        
   35 CALL READ (*50,*30,SCR6,ID,2,0,NWDS)        
      NWORDS=3*ID(2)        
      CALL FREAD(SCR6,HC,NWORDS,0)        
C        
C ADD TO PREVIOUS HC FOR THIS ELEMENT- ALL ELEMENTS SHOULD BE  ON SCR6  
C IN SAME ORDER IN EVERY RECORD        
C        
      NJ=NEXTZ+JCOUNT-1        
      DO 40 I=1,NWORDS        
      Z(NJ+I)=Z(NJ+I)+HC(I)        
   40 CONTINUE        
      JCOUNT=JCOUNT+NWORDS        
      IF((.NOT.INCORE).AND.JCOUNT.EQ.INWORD)GO TO 90        
      GO TO 35        
C        
C INFO WILL NOT FIT IN CORE - SPILL LOGIC        
C        
   80 INCORE=.FALSE.        
   90 CALL FWDREC (*1002,SCR6)        
C        
C SKIP APPROPRIATE NUMBER OF WORDS IN THIS RECORD TO ACCOUNT FOR        
C THE PORTION OF THIS RECORD PREVIOUSLY READ        
C        
   95 CALL READ (*50,*1003,SCR6,ID,-NSKIP1,0,NWDS)        
      GO TO 30        
C        
C        
C DONE FOR THIS SUBCASE. PACK RESULTS. CLOSE SCR6 AND REOPEN TO WRITE   
C NEXT SUBCASE (IF ALL DATA CAN FIT INTO CORE)        
C        
   50 IF(INCORE)GO TO 57        
C        
C SPILL LOGIC-PACK OUT INWORD WORDS. THEN REWIND  SCRL AND SKIP DOWN    
C AS NECESSARY        
C        
      IF(.NOT.BLDP)CALL BLDPK(1,1,SCR6,0,0)        
      BLDP=.TRUE.        
      DO 55 K=1,INWORD        
      A(1)=Z(NEXTZ+K-1)        
      IROW=IN+K        
      CALL ZBLPKI        
   55 CONTINUE        
      IF(EOR)GO TO 58        
C        
      IN=IN+INWORD        
      CALL REWIND(SCR6)        
      CALL FWDREC (*1002,SCR6)        
      NSKIP=NSKIP-2        
      NSKIP1=NSKIP        
      GO TO 5        
C        
   57 CALL CLOSE(SCR6,1)        
      JJ=ICOUNT        
      MCBH(3)=JJ        
      CALL PACK(Z(NEXTZ),HCCENS,MCBH)        
      GO TO 70        
C        
C DONE FOR THIS SUBCASE (SPILL LOGIC)        
C        
   58 CALL CLOSE(SCR6,1)        
      MCBH(3)=ICOUNT        
      CALL BLDPKN(SCR6,0,MCBH)        
      GO TO 70        
C        
C        
C PACK A COLUMN OF ZEROS CORRESPONDING TO REMFLUX        
C        
   60 MCBH(3)=KCOUNT        
      CALL BLDPK(1,1,HCCENS,0,0)        
      CALL BLDPKN(HCCENS,0,MCBH)        
C        
   70 CALL WRTTRL(MCBH)        
      IF(ITYPE.EQ.24)GO TO 75        
C        
C CHECK ON COUNT CONSISTENCY        
C        
      IF(INCORE)GO TO 75        
      IF(ICOUNT.NE.KCOUNT)GO TO 500        
C        
   75 CALL GOPEN(SCR6,Z(LCORE+1),1)        
      RETURN        
C        
  500 WRITE(IOUT,501)        
  501 FORMAT(58H0***SYSTEM FATAL ERROR,LOGIC ERROR,COUNTS ARE OFF IN HCC
     1OM)        
      CALL MESAGE(-61,0,0)        
C        
 1002 CALL MESAGE(-2,SCR6,NAM)        
 1003 CALL MESAGE(-3,SCR6,NAM)        
      RETURN        
      END        