      SUBROUTINE FRRD
C
C     FREQUENCY AND RANDOM RESPONSE MODULE
C
C     INPUTS CASECC,USETD,DLT,FRL,GMD,GOD,KDD,BDD,MDD,PHIDH,DIT
C
C     OUTPUTS UDV,PS,PD,PP
C
C     8 SCRATCHES
C
      INTEGER         SINGLE,OMIT,CASECC,USETD,DLT,FRL,GMD,GOD,BDD,
     1                PHIDH,DIT,SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,SCR8,
     2                UDV,PS,PD,PP,PDD,FOL,NAME(2),MCB(7)
      COMMON /BLANK / APP(2),MODAL(2),LUSETD,MULTI,SINGLE,OMIT,
     1                NONCUP,FRQSET
      COMMON /FRRDST/ OVF(150),ICNT,IFRST,ITL(3),IDIT,IFRD,K4DD
      COMMON /CDCMPX/ DUM32(32),IB,IBBAR
      DATA    CASECC, USETD,DLT,FRL,GMD,GOD,KDD,BDD,MDD,PHIDH,DIT /
     1        101   , 102,  103,104,105,106,107,108,109,110,  111 /
      DATA    UDV   , PS, PD, PP ,PDD,FOL /
     1        201   , 202,203,204,203,205 /
      DATA    SCR1  , SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,SCR8 /
     1        301   , 302, 303, 304, 305, 306, 307, 308  /
      DATA    MODA  / 4HMODA /,      NAME /4HFRRD,4H     /
C
      PDD  = 203
      SCR6 = 306
      IB   = 0
C
C     BUILD LOADS ON P SET ORDER IS ALL FREQ. FOR LOAD TOGETHER
C     FRRD1A IS AN ENTRY POINT IN FRLGA
C
      CALL FRRD1A (DLT,FRL,CASECC,DIT,PP,LUSETD,NFREQ,NLOAD,FRQSET,FOL,
     1             NOTRD)
      IF (MULTI.LT.0 .AND. SINGLE.LT.0 .AND. OMIT.LT.0 .AND.
     1    MODAL(1).NE. MODA) GO TO 60
C
C     REDUCE LOADS TO D OR H SET
C     FRRD1B IS AN ENTRY POINT IN FRLGB
C
      CALL FRRD1B (PP,USETD,GMD,GOD,MULTI,SINGLE,OMIT,MODAL(1),PHIDH,PD,
     1             PS,SCR5,SCR1,SCR2,SCR3,SCR4)
C
C     SCR5 HAS PH IF MODAL FORMULATION
C
      IF (MODAL(1) .EQ.MODA) PDD = SCR5
C
C     SOLVE PROBLEM FOR EACH FREQUENCY
C
      IF (NONCUP.LT.0 .AND. MODAL(1).EQ.MODA) GO TO 50
   10 IF (NFREQ.EQ.1  .OR.  NLOAD.EQ.1) SCR6 = UDV
      DO 20 I = 1,NFREQ
      CALL KLOCK (ITIME1)
C
C     FORM AND DECOMPOSE MATRICES
C     IF MATRIX IS SINGULAR, IGOOD IS SET TO 1 IN FRRD1C. ZERO OTHERWISE
C
      CALL FRRD1C (FRL,FRQSET,MDD,BDD,KDD,I,SCR1,SCR2,SCR3,SCR4,SCR8,
     1             SCR7,IGOOD)
C
C     ULL IS ON SCR1 -- LLL IS IN SCR2
C
C     SOLVE FOR PD LOADS STACK ON SCR6
C
      CALL FRRD1D (PDD,SCR1,SCR2,SCR3,SCR4,SCR6,I,NLOAD,IGOOD,NFREQ)
      CALL KLOCK  (ITIME2)
      CALL TMTOGO (ITLEFT)
      IF (2*(ITIME2-ITIME1) .GT. ITLEFT .AND. I.NE.NFREQ) GO TO 70
   20 CONTINUE
C
      I = NFREQ
   30 IF (NFREQ.EQ.1 .OR. NLOAD.EQ.1) GO TO 40
C
C     RESORT SOLUTION VECTORS INTO SAME ORDER AS LOADS
C     FRRD1E IS AN ENTRY POINT IN FRRD1D
C
      CALL FRRD1E (SCR6,UDV,NLOAD,I)
   40 RETURN
C
C     UNCOUPLED MODAL
C
   50 CALL FRRD1F (MDD,BDD,KDD,FRL,FRQSET,NLOAD,NFREQ,PDD,UDV)
      GO TO 40
   60 PDD = PP
      GO TO 10
C
C     INSUFFICIENT TIME TO COMPLETE ANOTHER LOOP
C
   70 CALL MESAGE (45,NFREQ-I,NAME)
      MCB(1) = SCR6
      CALL RDTRL (MCB(1))
      NDONE  = MCB(2)
      MCB(1) = PP
      CALL RDTRL (MCB(1))
      MCB(2) = NDONE
      CALL WRTTRL (MCB(1))
      IF (SINGLE .LT. 0) GO TO 80
      MCB(1) = PS
      CALL RDTRL (MCB(1))
      MCB(2) = NDONE
      CALL WRTTRL (MCB(1))
   80 MCB(1) = PD
      CALL RDTRL( MCB(1))
      MCB(2) = NDONE
      CALL WRTTRL (MCB(1))
      GO TO 30
      END
