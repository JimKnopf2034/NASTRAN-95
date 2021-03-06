      SUBROUTINE DDRMM1 (*,*,*,*)
C
C     PERFORMS SORT1 TYPE PROCESSING FOR MODULE DDRMM.
C
      LOGICAL         SORT2    ,COL1     ,FRSTID   ,IDOUT    ,TRNSNT  ,
     1                ANYXY    ,LMINOR
      INTEGER         BUF1     ,BUF2     ,BUF3     ,BUF4     ,BUF5    ,
     1                BUF6     ,BUFF     ,EOR      ,RD       ,RDREW   ,
     2                WRT      ,WRTREW   ,CLS      ,CLSREW   ,ELEM    ,
     3                IA(4)    ,SETS     ,ENTRYS   ,SYSBUF   ,OUTPT   ,
     4                PASSES   ,OUTFIL   ,FILE     ,DHSIZE   ,FILNAM  ,
     5                SETID    ,FORM     ,DEVICE   ,PHASE    ,SCRT    ,
     6                SCRT1    ,SCRT2    ,SCRT3    ,SCRT4    ,SCRT5   ,
     7                SCRT6    ,SCRT7    ,DVAMID(3),BUF(150) ,Z(1)    ,
     8                UVSOL    ,SUBCAS   ,SAVDAT   ,SAVPOS   ,BUFSAV
      REAL            RIDREC(6),LAMBDA
      CHARACTER       UFM*23   ,UWM*25   ,UIM*29   ,SFM*25   ,SWM*27
      COMMON /XMSSG / UFM      ,UWM      ,UIM      ,SFM      ,SWM
      COMMON /STDATA/ LMINOR   ,NSTXTR   ,NPOS     ,SAVDAT(75)        ,
     1                SAVPOS(25)         ,BUFSAV(10)
      COMMON /SYSTEM/ SYSBUF   ,OUTPT
      COMMON /NAMES / RD       ,RDREW    ,WRT      ,WRTREW   ,CLSREW  ,
     1                CLS
      COMMON /ZBLPKX/ A(4)     ,IROW
      COMMON /ZNTPKX/ AOUT(4)  ,IROWO    ,IEOL     , IEOR
      COMMON /GPTA1 / NELEM    ,LAST     ,INCR     ,ELEM(1)
      COMMON /ZZZZZZ/ RZ(1)
      COMMON /MPYADX/ MCBA(7)  ,MCBB(7)  ,MCBC(7)  ,MCBD(7)  ,LZ      ,
     1                ITFLAG   ,ISINAB   ,ISINC    ,IPREC    ,ISCRT
      COMMON /DDRMC1/ IDREC(146),BUFF(6) ,PASSES   ,OUTFIL   ,JFILE   ,
     1                MCB(7)   ,ENTRYS   ,SETS(5,3),INFILE   ,LAMBDA  ,
     2                FILE     ,SORT2    ,COL1     ,FRSTID   ,NCORE   ,
     3                NSOLS    ,DHSIZE   ,FILNAM(2),RBUF(150),IDOUT   ,
     4                ICC      ,NCC      ,ILIST    ,NLIST    ,NWDS    ,
     5                SETID    ,TRNSNT   ,I1       ,I2       ,PHASE   ,
     6                ITYPE1   ,ITYPE2   ,NPTSF    ,LSF      ,NWDSF   ,
     7                SCRT(7)  ,IERROR   ,ITEMP    ,DEVICE   ,FORM    ,
     8                ISTLST   ,LSTLST   ,UVSOL    ,NLAMBS   ,NWORDS  ,
     9                OMEGA    ,IPASS    ,SUBCAS
      COMMON /CONDAS/ PI       ,TWOPI
      EQUIVALENCE     (SCRT1,SCRT(1)), (SCRT2,SCRT(2)), (SCRT3,SCRT(3)),
     1                (SCRT4,SCRT(4)), (SCRT5,SCRT(5)), (SCRT6,SCRT(6)),
     2                (SCRT7,SCRT(7)), (BUF1 ,BUFF(1)), (BUF2 ,BUFF(2)),
     3                (BUF3 ,BUFF(3)), (BUF4 ,BUFF(4)), (BUF5 ,BUFF(5)),
     4                (BUF6 ,BUFF(6)), (A(1) ,  IA(1)), (Z(1) ,  RZ(1)),
     5                (IDREC(1),RIDREC(1)), (BUF(1),RBUF(1))
      DATA    EOR   , NOEOR / 1, 0 /, DVAMID / 1, 10, 11 /
C
C     FORMATION OF DATA-MATRIX AND SUBSEQUENT MULTIPLY BY SOLUTION-
C     MATRIX AND ULTIMATE OUTPUT OF TRANSIENT OR FREQUENCY SOLUTIONS.
C
      IPASS  = 1
   20 COL1   = .TRUE.
      FRSTID = .TRUE.
      SETID  = SETS(1,IPASS)
      DEVICE = SETS(2,IPASS)
      FORM   = SETS(3,IPASS)
      ISTLST = SETS(4,IPASS)
      LSTLST = SETS(5,IPASS)
C
C     GET LIST OF XYPLOT REQUESTED IDS FOR CURRENT SUBCASE AND
C     OUTFIL TYPE.
C
      GO TO (22,23,24,25), JFILE
C
C     DISPLACEMENT, VELOCITY, ACCELERATION
C
   22 IXYTYP = IPASS
      GO TO 26
C
C     SPCF
C
   23 IXYTYP = 4
      GO TO 26
C
C     STRESS
C
   24 IXYTYP = 6
      GO TO 26
C
C     FORCE
C
   25 IXYTYP = 7
      GO TO 26
C
   26 IXY = NLIST + 1
      CALL DDRMMP (*380,Z(IXY),BUF3-IXY,LXY,IXYTYP,SUBCAS,Z(BUF3),ANYXY)
      IF (.NOT.ANYXY .AND. SETID.EQ.0) GO TO 280
      NXY = IXY + LXY - 1
C
C     INITIALIZE DATA MATRIX FILE(SCRT5), AND MAPPING TABLE FILE(SCRT4).
C
      IERROR = 22
      FILE = SCRT4
      CALL OPEN (*350,SCRT4,Z(BUF3),WRTREW)
      FILE = SCRT5
      CALL OPEN (*350,SCRT5,Z(BUF2),WRTREW)
      CALL FNAME (SCRT5,FILNAM)
      CALL WRITE (SCRT5,FILNAM,2,EOR)
C
C     GENERAL LOGIC TO BUILD SORT1 FORMAT DATA MATRIX.
C
C     EACH COLUMN WRITTEN HERE REPRESENTS ONE EIGENVALUE.
C
C          COMPONENTS FOR FIRST ID   *
C              .                      *
C              .                       *
C              .                        *
C          COMPONENTS FOR NEXT ID        * ONE COLUMN
C              .                        *  OF DATA FOR EACH EIGENVALUE.
C              .                       *
C              .                      *
C             ETC                    *
C     --------------------------------------------- EOR
C
C          IDENTICAL COMPONENTS ARE REPRESENTED IN EACH COLUMN.
C
C
C     READ AN OFP-ID-RECORD AND SET PARAMETERS.
C     (ON ENTRY TO THIS PROCESSOR THE FIRST ID RECORD IS AT HAND)
C
      FILE   = INFILE
      MCB(1) = SCRT5
      MCB(2) = 0
      MCB(3) = 0
      MCB(4) = 2
      MCB(5) = 1
      MCB(6) = 0
      MCB(7) = 0
      IF (IPASS.EQ.1 .AND. FRSTID) GO TO 50
   40 CALL READ (*130,*130,INFILE,IDREC,146,EOR,NWDS)
      MAJID = MOD(IDREC(2),1000)
      IF (MAJID .NE. ITYPE1) GO TO 310
C
C     IF FIRST COLUMN, OFP-ID RECORD IS WRITTEN AS IS TO MAP FILE.
C
   50 IF (.NOT. COL1) GO TO 60
      IF (.NOT.FRSTID .AND. RIDREC(6).NE.LAMBDA) GO TO 60
      CALL WRITE (SCRT4,IDREC,146,EOR)
   60 LENTRY = IDREC(10)
      I1 = NWORDS + 1
      I2 = LENTRY
      MINOR = IDREC(3)
C
C     IF SAME EIGENVALUE AS THAT OF LAST OFP-ID RECORD THEN CONTINUE.
C
      IF (FRSTID) GO TO 70
      IF (RIDREC(6) .EQ. LAMBDA) GO TO 80
C
C     NEW EIGENVALUE. COMPLETE CURRENT DATA MATRIX COLUMN AND START
C     NEW COLUMN. PASS ONE IS NOW COMPLETE.
C
      CALL BLDPKN (SCRT5,0,MCB)
      IF (COL1) IROW1 = IROW
      IF (IROW .NE. IROW1) GO TO 290
      COL1 = .FALSE.
C
C     START NEW COLUMN.
C
   70 CALL BLDPK (1,1,SCRT5,0,0)
      IROW   = 0
      FRSTID = .FALSE.
      LAMBDA = RIDREC(6)
C
C     READ A POINT OR ELEMENT ENTRY.
C
   80 CALL READ (*360,*120,INFILE,BUF,LENTRY,NOEOR,NWDS)
      ID = BUF(1)/10
C
C     CHECK FOR ID IN OUTPUT REQUEST LIST
C
      IDVICE = DEVICE
      IF (SETID) 100,95,90
C
C//// NEXT MAY NOT NEED TO BE INITIALIZED EVERY TIME.
C
   90 NEXT = 1
      CALL SETFND (*95,Z(ISTLST),LSTLST,ID,NEXT)
      GO TO 100
   95 IF (.NOT. ANYXY) GO TO 80
      CALL BISLOC (*80,ID,Z(IXY),1,LXY,JP)
      IDVICE = 0
C
C     THIS ID IS TO BE OUTPUT.
C
  100 IF (.NOT. COL1) GO TO 105
      BUF(1) = 10*ID + IDVICE
      CALL WRITE (SCRT4,BUF(1),NWORDS,NOEOR)
      NSTXTR = 0
      IF (ITYPE1.NE.5 .OR. SAVDAT(MINOR).EQ.0) GO TO 104
      NPOS   = SAVDAT(MINOR)/100
      NSTXTR = SAVDAT(MINOR) - NPOS*100
      DO 101 I = 1,NSTXTR
      J = SAVPOS(NPOS+I-1)
  101 BUFSAV(I) = BUF(J)
      CALL WRITE (SCRT4,BUFSAV(1),NSTXTR,NOEOR)
  104 CONTINUE
C
C     OUTPUT TO DATA MATRIX THE COMPONENTS OF THIS ENTRY.
C
  105 DO 110 I = I1,I2
      IROW = IROW + 1
      A(1) = RBUF(I)
C
C     GET RID OF INTEGERS.
C
C     OLD LOGIC -
C     IF (MACH.NE.5 .AND.  IABS(IA(1)) .LT.   100000000) A(1) = 0.0
C     IF (MACH.EQ.5 .AND. (IA(1).LE.127.AND.IA(1).GE.1)) A(1) = 0.0
C     OLD LOGIC SHOULD INCLUDE ALPHA MACHINE (MACH=21)
C
C     NEW LOGIC BY G.CHAN/UNISYS, 8/91 -
      IF (NUMTYP(IA(1)) .LE. 1) A(1) = 0.0
C
      CALL ZBLPKI
  110 CONTINUE
      GO TO 80
C
C     END OF CURRENT OFP-DATA RECORD ENCOUNTERED.
C     IF NEXT OFP-ID-RECORD INDICATES ANOTHER OFP-DATA RECORD FOR
C     THIS SAME EIGENVALUE (I.E. A CHANGE IN ELEMENT TYPE) THEN
C     FURTHER CONSTRUCTION OF THE DATA MATRIX COLUMN TAKES PLACE.
C
  120 IF (COL1) CALL WRITE (SCRT4,0,0,EOR)
      GO TO 40
C
C     END OF FILE ENCOUNTERED ON INFILE.
C     DATA MATRIX AND MAPING FILE ARE COMPLETE.
C
  130 CALL CLOSE (INFILE,CLSREW)
      CALL CLOSE (SCRT4 ,CLSREW)
C
C     COMPLETE LAST COLUMN OF DATA MATRIX WRITTEN.
C
      IF (COL1) IROW1 = IROW
      IF (IROW .NE. IROW1) GO TO 310
      CALL BLDPKN (SCRT5,0,MCB)
      MCB(3) = IROW
      CALL WRTTRL (MCB)
      CALL CLOSE (SCRT5,CLSREW)
C
C     TO GET SOLUTION MATRIX BASED ON SORT-1 INFILE.
C
C     SOLVE,
C              (DATA MATRIX)     X    (MODAL SOLUTION MATRIX)
C             NCOMPS X NLAMBS           NLAMBS X NSOLUTIONS
C             ===============         =======================
C
C     RESULTANT MATRIX IS NCOMPS BY NSOLUTIONS IN SIZE.
C
C
C     MATRIX MULTIPLY SETUP AND CALL.
C
      MCBA(1) = SCRT5
      CALL RDTRL (MCBA)
      MCBB(1) = UVSOL
      IF (TRNSNT) MCBB(1) = SCRT(IPASS)
      CALL RDTRL (MCBB)
      MCBC(1) = 0
      MCBD(1) = SCRT6
      MCBD(2) = 0
      MCBD(3) = IROW
      MCBD(4) = 2
      MCBD(5) = 1
      MCBD(6) = 0
      MCBD(7) = 0
      IF (.NOT.TRNSNT) MCBD(5) = 3
      NXY1    = NXY + 1
      IF (MOD(NXY1,2) .EQ. 0) NXY1 = NXY1 + 1
      LZ      = KORSZ(Z(NXY1))
      ITFLAG  = 0
      ISINAB  = 1
      ISINC   = 1
      IPREC   = 1
      ISCRT   = SCRT7
      CALL MPYAD (Z(NXY1),Z(NXY1),Z(NXY1))
      MCBD(1) = SCRT6
      CALL WRTTRL (MCBD)
C
C     PRODUCT MATRIX IS NOW OUTPUT, USING THE MAP ON SCRT4 FOR EACH
C     COLUMN.  (SORT-1)  PRODUCT MATRIX IS ON SCRATCH DATA BLOCK 6.
C
      IERROR = 10
      FILE = OUTFIL
      CALL OPEN (*350,OUTFIL,Z(BUF1),WRT)
      FILE = SCRT4
      CALL OPEN (*350,SCRT4,Z(BUF2),RDREW)
      FILE = SCRT6
      CALL OPEN (*350,SCRT6,Z(BUF3),RDREW)
      CALL FWDREC (*360,SCRT6)
      JLIST = ILIST
C
C     LOOP ON COLUMNS OF SCRT6.
C
  140 CALL DDRMMA (.TRUE.)
C
C     READ AN OFP-ID-RECORD FROM THE MAP.
C
      FILE = SCRT4
  150 CALL READ (*270,*370,SCRT4,IDREC,146,EOR,NWDS)
C
C     SET THE FREQUENCY OR TIME AND CLOBBER THE EIGENVALUE.
C
      RIDREC(5) = RZ(JLIST)
      RIDREC(6) = 0.0
      IDOUT = .FALSE.
      MINOR = IDREC(3)
C
C     SET NUMBER OF STRESS OR FORCE WORDS AND COMPLEX POINTERS IF
C     NECESSARY
C
      ITYPE2 = IDREC(3)
      IF (ITYPE1.EQ.3 .OR. ITYPE1.EQ.7) GO TO 200
      IELEM = (ITYPE2-1)*INCR
      IF (ITYPE1 .EQ. 4) GO TO 180
      IF (ITYPE1 .EQ. 5) GO TO 190
      WRITE  (OUTPT,170) SWM,ITYPE1,ITYPE2,INFILE
  170 FORMAT (A27,' 2334.  (DDRMM-3) ILLEGAL MAJOR OR MINOR OFP-ID ',
     1       'IDENTIFICATIONS =',2I10, /5X,'DETECTED IN DATA BLOCK',I5,
     2       '. PROCESSING OF SAID DATA BLOCK DISCONTINUED.')
      GO TO 340
C
C     FORCES ASSUMED.
C
  180 LSF   = ELEM(IELEM+19)
      NPTSF = ELEM(IELEM+21)
      NWDSF = LSF
      GO TO 220
C
C     STRESSES ASSUMED.
C
  190 LSF   = ELEM(IELEM+18)
      NPTSF = ELEM(IELEM+20)
      NWDSF = LSF
      GO TO 220
C
C     SPCF OR DISPLACEMENTS ASSUMED
C
  200 IF (.NOT.TRNSNT) GO TO 210
      NWDSF = 8
      GO TO 220
  210 NWDSF = 14
C
C     SET OMEGA IF THIS IS THE VELOCITY OR ACCELERATION PASS
C
      GO TO (220,211,212), IPASS
C
C     OMEGA FOR VELOCITY PASS
C
  211 OMEGA = TWOPI*RZ(JLIST)
      GO TO 220
C
C     OMEGA FOR ACCELERATION PASS
C
  212 OMEGA = -((TWOPI*RZ(JLIST))**2)
C
  220 LENTRY = IDREC(10)
      I1 = NWORDS + 1
      I2 = LENTRY
C
C
C     SET DISPLACEMENT, VELOCITY, OR ACCELERATION OFP MAJOR ID IF INFILE
C     IS MODAL DISPLACEMENTS.
C
      IF (ITYPE1 .NE. 7) GO TO 230
      IDREC(2) = DVAMID(IPASS)
  230 IF (.NOT.TRNSNT) IDREC(2) = IDREC(2) + 1000
C
C     RESET APPROACH CODE FROM EIGENVALUE TO TRANSIENT OR FREQUENCY
C
      IAPP = 5
      IF (TRNSNT) IAPP = 6
      IDREC(1) = 10*IAPP + DEVICE
C
C     FILL TITLE, SUBTITLE, AND LABEL FROM CASECC FOR THIS SUBCASE.
C
      DO 238 I = 1,96
      IDREC(I+50) = Z(ICC+I+37)
  238 CONTINUE
      IDREC(4) = SUBCAS
C
C     READ FIRST WORDS OF OUTPUT ENTRY FROM MAP.
C
  240 CALL READ (*360,*260,SCRT4,BUF,NWORDS,NOEOR,NWDS)
      LMINOR = .TRUE.
      IF (ITYPE1.NE.5 .OR. SAVDAT(MINOR).EQ.0) GO TO 241
      NPOS   = SAVDAT(MINOR)/100
      NSTXTR = SAVDAT(MINOR) - NPOS*100
      CALL READ (*360,*370,SCRT4,BUFSAV(1),NSTXTR,NOEOR,NWDS)
      LMINOR = .FALSE.
  241 CONTINUE
C
C     GET BALANCE USING UTILITY WHICH WILL COLLECT AND MAP TOGETHER
C     AS REQUIRED REAL OR COMPLEX, AND GENERATE MAGNITUDE/PHASE IF
C     REQUIRED.  (THIS ROUTINE WILL BUFFER DATA IN FROM SCRT6 AS IT
C     NEEDS IT.)
C
      CALL DDRMMA (.FALSE.)
C
C     CALL DDRMMS TO RECOMPUTE SOME ELEMENT STRESS QUANTITIES
C     IN TRANSIENT PROBLEMS ONLY.
C
      IF (TRNSNT .AND. ITYPE1.EQ.5) CALL DDRMMS (BUF,ITYPE2,BUF4,BUF5)
      IF (IDOUT) GO TO 250
      IDREC( 9) = FORM
      IDREC(10) = NWDSF
      CALL WRITE (OUTFIL,IDREC,146,EOR)
      IDOUT = .TRUE.
C
C     OUTPUT THE COMPLETED ENTRY TO OFP OUTFIL.
C
  250 CALL WRITE (OUTFIL,BUF,NWDSF,NOEOR)
      GO TO 240
C
C     END OF ENTRIES FOR ONE ID-REC HIT.  IF NO EOF ON MAP WITH
C     NEXT READ, THEN CONTINUE OUTPUT OF THIS SOLUTION COLUMN.
C
  260 CALL WRITE (OUTFIL,0,0,EOR)
      GO TO 150
C
C     END OF FILE ON MAP.  THUS START NEXT COLUMN IF REQUIRED.
C
  270 JLIST = JLIST + 1
      IF (JLIST .GT. NLIST) GO TO 280
      CALL REWIND (SCRT4)
      GO TO 140
C
C     ALL DATA OF SOLUTION PRODUCT MATRIX HAS NOW BEEN OUTPUT.
C
  280 CALL CLOSE (OUTFIL,CLS)
      CALL CLOSE (INFILE,CLSREW)
      CALL CLOSE (SCRT4,CLSREW)
      CALL CLOSE (SCRT6,CLSREW)
      IPASS = IPASS + 1
      IF (IPASS .GT. PASSES) GO TO 340
C
C     PREPARE FOR ANOTHER PASS
C
      FILE = INFILE
      CALL OPEN (*350,INFILE,Z(BUF1),RDREW)
      CALL FWDREC (*360,INFILE)
      GO TO 20
C
C     DATA INCONSISTENCY ON -INFILE-.
C
  290 WRITE  (OUTPT,300) SWM,INFILE
  300 FORMAT (A27,' 2335.  (DDRMM1-1) THE AMOUNT OF DATA IS NOT ',
     1       'CONSISTENT FOR EACH EIGENVALUE IN DATA BLOCK',I5, /5X,
     2       'PROCESSING OF THIS DATA BLOCK TERMINATED.')
      GO TO 330
C
C     CHANGE IN MAJOR OFP-ID DETECTED ON -INFILE-.
C
  310 WRITE  (OUTPT,320) SWM,INFILE
  320 FORMAT (A27,' 2336.  (DDRMM1-2) A CHANGE IN WORD 2 OF THE OFP-ID',
     1       ' RECORDS OF DATA BLOCK',I5, /5X,'HAS BEEN DETECTED. ',
     2       ' POOCESSING OF THIS DATA BLOCK HAS BEEN TERMINATED.')
  330 IPASS = 3
      GO TO 280
C
C     COMPLETION OF PASS FOR INPUT MODAL SOLUTION -FILE-.
C
  340 RETURN
C
C     UNDEFINED FILE.
C
  350 RETURN 1
C
C     END OF FILE HIT.
C
  360 RETURN 2
C
C     END OF RECORD HIT.
C
  370 RETURN 3
C
C     INSUFFICIENT CORE.
C
  380 RETURN 4
      END
