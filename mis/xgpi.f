      SUBROUTINE XGPI
C
C     THE PURPOSE OF XGPI IS TO INITIALIZE AND CALL THE FOLLOWING
C     SUBROUTINES - XOSGEN AND XFLORD.
C
      IMPLICIT INTEGER (A-Z)
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF
      LOGICAL         LNOGO
      INTEGER         CNM(1),FNM(1),PTDIC(1)
      DIMENSION       ICPDPL(1),ISOL(1),ICF(1),ICCNAM(1),IBUFR(1),
     1                IBF(8),IOSHDR(2),ITYPE(6),ITRL(7),DMPCRD(1),
     2                MED(1),NXGPI(2),NXPTDC(2),OSCAR(1),OS(5)
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25
      COMMON /XMSSG / UFM,UWM,UIM,SFM
      COMMON /XOLDPT/ PTDTOP,PTDBOT,LPTDIC,NRLFL,SEQNO
      COMMON /STAPID/ TAPID(6),OTAPID(6)
      COMMON /XGPI5 / ISOL,START,ALTER(2),SOL,SUBSET,IFLAG,IESTIM,
     1                ICFTOP,ICFPNT,LCTLFL,ICTLFL(1)
      COMMON /MODDMP/ IFLG(6)
      COMMON /XGPI6 / MEDTP,FNMTP,CNMTP,MEDPNT,LMED,IPLUS,DIAG14,
     1                DIAG17,DIAG4,DIAG25,IFIRST,IBUFF(20)
      COMMON /XGPI8 / ICPTOP,ICPBOT,LCPDPL
      COMMON /IFPX0 / LBD,LCC,MJMSK(1)
      COMMON /IFPX1 / NCDS,MJCD(1)
      COMMON /TWO   / TWO(32)
      COMMON /XMDMSK/ NMSKCD,NMSKFL,NMSKRF,MEDMSK(7)
      COMMON /SYSTEM/ IBUFSZ,OPTAPE,NOGO,SYS4,MPC,SPC,SYS7,LOAD,SYS9(2),
     1                PAGECT,SYS12(7),IECHO,SYS20,APPRCH,SYS22(2),
     2                ICFIAT,SYS25,CPPGCT,SYS27(42),SSCELL,SYS70(7),
     3                BANDIT,SYS78(4),ICPFLG
      COMMON /L15 L8/ L15,L8
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,
     2                MODIDX,LICF,ISAVDW,DMAP(1)
C
C                  ** CONTROL CARD NAMES **
C                  ** DMAP    CARD NAMES **
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,
     1                NMED,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT,
     3                NCHKPT,NPURGE,NEQUIV,NCPW,NBPC,NWPC,
     4                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)
      COMMON /ZZZZZZ/ CORE(1)
      COMMON /XGPI2 / LIBF,MPLPNT,MPL(1)
CWKBR COMMON /XGPI3 / PVT(6)
      COMMON /XGPI3 / PVT(200)
      COMMON /XDPL  / DPL(3)
      COMMON /XVPS  / VPS(4)
      COMMON /XFIST / IFIST(1)
      COMMON /XFIAT / IFIAT(3)
CWKBR COMMON /XCEITB/ CEITBL(2)
      COMMON /XCEITB/ CEITBL(42)
      COMMON /XGPID / ICST,IUNST,IMST,IHAPP,IDSAPP,IDMAPP,
     1                ISAVE,ITAPE,MODFLG,INTGR,LOSGN,
     2                NOFLGS,SETEOR,EOTFLG,IEQFLG,
     3                CPNTRY(7),JMP(7)
      COMMON /XGPIE / NSCR
      EQUIVALENCE     (LOSCAR,OS(1),CORE(1)), (OSPRC,OS(2)),
     1                (OSBOT ,OS(3)), (OSPNT,OS(4)), (OSCAR(1),OS(5)),
     2                (OSCAR(1),MED(1),FNM(1),CNM(1),ICPDPL(1)),
     3                (OSCAR(1),IBUFR(1),DMPCRD(1),PTDIC(1))
      EQUIVALENCE     (DMAP(1),ICF(1)), (NMED,ICCNAM(1)),
     1                (MPL(1),IBF(1)), (DPL(1),NDPFIL),
     2                (DPL(2),MAXDPL), (DPL(3),LSTDPL), (NOGO,LNOGO)
C
C           ** DEFINITION OF PROGRAM VARIABLES **
C     LICF   = NUMBER OF WORDS IN ICF ARRAY
C     WRNGRL = COUNTER FOR NUMBER OF TIMES WRONG REEL WAS MOUNTED.
C     FILCON = FLAG INDICATING FILE IS CONTINUED ON NEXT REEL.
C     IDPFCT = DATA POOL FILE NUMBER OF OSCAR FILE
C     IOSHDR = ARRAY CONTAINING HEADER RECORD FOR XOSCAR FILE IN IDP.
C     PTFCT  = PROBLEM TAPE FILE POSITION
C     EORFLG = END OF RECORD FLAG
C     ICST   = COLD START FLAG
C     IUNST  = UNMODIFIED RESTART
C     IMST   = MODIFIED   RESTART
C
C           ** VARIABLES USED IN GINO CALLS **
C     NPTBUF = NEW PROBLEM TAPE BUFFER AREA
C     IOPBUF = OLD PROBLEM TAPE BUFFER AREA
C     IDPBUF = DATA POOL FILE BUFFER AREA
C     NPTWRD = NUMBER OF WORDS READ FROM NEW PROBLEM TAPE
C     IOPWRD = NUMBER OF WORDS READ FROM OLD PROBLEM TAPE
C     IDPWRD = NUMBER OF WORDS READ FROM DATA POOL FILE
C
C           ** SYMBOLS EQUATED TO CONSTANTS **
C     NPT    = NEW PROBLEM TAPE GINO I.D. NAME (NPTP)
C     IOP    = OLD PROBLEM TAPE GINO I.D. NAME (OPTP)
C     IDP    = DATA POOL FILE GINO I.D. NAME   (POOL)
C     NSCR   = SCRATCH FILE USED FOR RIGID FORMAT. DATA IN NSCR WAS
C              PASSED OVER BY XCSA. IT MUST BE THE LAST SCRATCH FILE
C              IN LINK1, AND NOT TO BE OVER WRITTEN BY XSORT2
C              (CURRENTLY, NSCR = 315)
C
      DATA    JCARD ,JFILE  /  4HCARD,4HFILE /, IDP   /4HPOOL /
      DATA    NPVT  /4HPVT  /, IXTIM /4HXTIM /, NPT   /4HNPTP /,
     1        IOP   /4HOPTP /, IDPWRD/0      /, IOPWRD/0      /,
     2        NDPL  /4HDPL  /, IOSHDR/4HXOSC  , 4HAR          /,
     3        NPTWRD/0      /, FILCON/0      /, NXVPS /4HXVPS /
      DATA    ITYPE /1,1,2,2 , 2,4           /
      DATA    NXCSA /4HXCSA /, NXALTR/4HXALT /, NPARAM/216    /
      DATA    NXPTDC/4HXPTD  , 4HIC  /,NXGPI /  4HXGPI,4H     /
C
C
C     LOAD COMMON AREAS AND PERFORM INITIAL CALCULATIONS
C
      CALL XGPIDD
      CALL XMPLDD
      CALL XLNKDD
C
C     INITIALIZE
C
      NSCR  = 315
      CALL SSWTCH ( 4,DIAG4 )
      CALL SSWTCH (14,DIAG14)
      CALL SSWTCH (17,DIAG17)
      CALL SSWTCH (25,DIAG25)
      IF (DIAG14 .EQ. 1) IFLG(3) = 1
      IF (DIAG17 .EQ. 1) IFLG(4) = 1
      IF (DIAG4  .EQ. 1) IFLG(6) = 1
      IF (DIAG4  .NE. 0) IFLG(5) = ORF(IFLG(5),LSHIFT(1,16))
      IF (DIAG25 .EQ. 1) IFLG(5) = 1
C
C     SET DMAP COMPILER DEFAULT OPTION TO LIST FOR
C     APPROACH DMAP RUNS, RESTART RUNS AND SUBSTRUCTURE RUNS
C     RESET TO NO LIST IF ECHO=NONO (IECHO=-2)
C
      IF (IECHO.NE.-2 .AND. (APPRCH.LT.2 .OR. SSCELL.NE.0)) IFLG(3) = 1
      IF (DIAG14.EQ.0 .AND. IFLG(3).EQ.1) DIAG14 = 2
      IF (IECHO .EQ. -2) DIAG14 = 0
      CALL XGPIMW (1,0,0,0)
C
      CALL XGPIBS
      IF (NOGO .GT. 1) GO TO 2210
C
C     SET UP GINO BUFFER AREAS FOR OLD PROBLEM TAPE,NEW PROBLEM TAPE
C     AND DATA POOL TAPE.
C
      LOSCAR = KORSZ(IBUFR)
      NPTBUF = LOSCAR - IBUFSZ
C
C     OLD PROBLEM TAPE AND NEW PROBLEM TAPE SHARE BUFFER
C
      IOPBUF = NPTBUF
      IDPBUF = NPTBUF - IBUFSZ
      LOSCAR = IDPBUF - 1
C
C     ALLOW MINIMAL SIZE FOR MED ARRAY RESIDING IN OPEN CORE.
C     WE WILL EXPAND MED IF NECESSARY.
C
      MEDTP = LOSCAR
      LMED  = 1
      IF (LOSCAR .LT. 1) GO TO 2080
C
C     OPEN NEW PROBLEM TAPE AS INPUT FILE
C
      CALL OPEN (*1900,NPT,IBUFR(NPTBUF),0)
C
C     NUMBER OF FILE ON NPT + 1
C
      NRLFL = LSHIFT(TAPID(6),16) + 5
C
C     FILE POSITION OF IOP AT ENTRY TO XGPI
C
      PTFCT = LSHIFT(OTAPID(6),16) + 4
C
C     FIND XCSA FILE ON NEW PROBLEM TAPE
C
      NAM1 = NXCSA
      NAM2 = NBLANK
C
C     SKIP HEADER FILE
C
   10 CALL SKPFIL (NPT,1)
      CALL READ (*1950,*1950,NPT,ICF,1,1,NPTWRD)
C
C     CHECK FOR ALTER FILE
C     SET DIAG14 TO 10 IF ALTER CARDS ARE PRESENT. DIAG14 WOULD BE
C     CHANGED TO 11 IF DMAP CONTAINS POTENTIAL FATAL ERROR. IN SUCH
C     CASE, DMAP LISTING WILL BE PRINTED.
C
      IF (ICF(1) .NE. NXALTR) GO TO 15
      NRLFL = NRLFL + 1
      IF (DIAG14 .EQ. 0)                 DIAG14 = 10
C
C     CHECK FOR CHECKPOINT DICTIONARY FILE
C
   15 IF (ICF(1) .EQ. NXPTDC(1)) NRLFL = NRLFL + 1
C
C     CHECK FOR CONTROL FILE
C
      IF (ICF(1) .NE. NXCSA) GO TO 10
C
C     PROBLEM TAPE IS POSITIONED AT EXECUTIVE CONTROL FILE.
C
      ICFPNT = ICFTOP
C
C     READ THE SIX-WORD DATA RECORD
C
      CALL READ (*1950,*20,NPT,ISOL,7,1,NPTWRD)
      GO TO 1950
   20 CALL CLOSE (NPT,1)
      IF (IABS(APPRCH) .EQ. 1) GO TO 620
C
C     FILL MED ARRAY
C
      MEDTP = 1
C
C     SET VALUE FOR NUMBER OF WORDS PER MED ENTRY
C
      MED(MEDTP+1) = 1
      IF (START .NE. ICST) MED(MEDTP+1) = NMSKCD + NMSKFL + NMSKRF
C
      CALL GOPEN (NSCR,IBUFR(NPTBUF),0)
      LLOSCR = LOSCAR - 2
C
C     READ THE MED TABLE
C
      CALL READ (*1960,*30,NSCR,MED(MEDTP+2),LLOSCR,1,LMED)
      GO TO 2090
C
C     SET VALUE FOR NUMBER OF DMAP INSTRUCTIONS
C
   30 MED(MEDTP) = LMED/MED(MEDTP+1)
C
C     CHECK FOR ILLEGAL NUMBER OF WORDS IN MED TABLE RECORD
C
      IF (START.NE.ICST .AND. LMED.NE.MED(MEDTP)*MED(MEDTP+1))
     1    GO TO 1980
C
C     SET THE POINTERS TO THE FILE NAME AND CARD NAME TABLES
C
      FNMTP = MEDTP + LMED + 2
      CNMTP = FNMTP
      IF (START .EQ. ICST) GO TO 600
      LLOSCR = LLOSCR - LMED
C
C     READ THE FILE NAME TABLE
C
      CALL SKPREC (NSCR,1)
      JTYPE = JFILE
      CALL READ (*1970,*40,NSCR,MED(FNMTP+1),LLOSCR,1,LMED)
      GO TO 2090
C
C     SET THE VALUE FOR THE NUMBER OF ENTRIES IN THE FILE NAME TABLE
C
   40 MED(FNMTP) = LMED/3
C
C     CHECK FOR ILLEGAL NUMBER OF WORDS IN FILE NAME TABLE RECORD
C
      IF (LMED .NE. 3*MED(FNMTP)) GO TO 1990
C
C     CHECK FOR ILLEGAL BIT NUMBERS IN FILE NAME TABLE
C
      ISTRBT = 31*NMSKCD + 1
      IENDBT = 31*(NMSKCD+NMSKFL)
      DO 50 J = 3,LMED,3
      IF (MED(FNMTP+J).LT.ISTRBT .OR. MED(FNMTP+J).GT.IENDBT) GO TO 2000
   50 CONTINUE
C
C     RESET THE POINTER FOR THE CARD NAME TABLE
C
      CNMTP  = FNMTP + 3*FNM(FNMTP) + 1
      LLOSCR = LLOSCR - LMED
C
C     READ THE CARD NAME TABLE
C
      CALL SKPREC (NSCR,-2)
      JTYPE = JCARD
      CALL READ (*1970,*60,NSCR,MED(CNMTP+1),LLOSCR,1,LMED)
      GO TO 2090
C
C     SET THE VALUE FOR THE NUMBER OF ENTRIES IN THE CARD NAME TABLE
C
   60 MED(CNMTP) = LMED/3
C
C     CHECK FOR ILLEGAL NUMBER OF WORDS IN CARD NAME TABLE RECORD
C
      IF (LMED .NE. 3*MED(CNMTP)) GO TO 1990
C
C     CHECK FOR ILLEGAL BIT NUMBERS IN CARD NAME TABLE
C
      ISTRBT = 1
      IENDBT = 31*NMSKCD
      DO 70 J = 3,LMED,3
      IF (MED(CNMTP+J).LT.ISTRBT .OR. MED(CNMTP+J).GT.IENDBT) GO TO 2000
   70 CONTINUE
C
C     RESTART - CHECK MEDMSK TABLE
C     IF MEDMSK WORD(S), CORRESPONDING TO RIGID FORMAT SWITCH, IS(ARE)
C     NON-ZERO, SOLUTION HAS BEEN CHANGED.
C     RESET ENTRY SEQUENCE NO. TO INFINITE IF SOLUTION IS CHANGED.
C
      NMASK = MED(MEDTP+1)
      IBEGN = NMSKCD + NMSKFL + 1
      DO 80 I = IBEGN,NMASK
      IF (MEDMSK(I) .EQ. 0) GO TO 80
      SEQNO = MASKLO
      START = IMST
   80 CONTINUE
C
C     SEE IF ANY BULK DATA OR CASE CONTROL CARDS HAVE BEEN MODIFIED.
C
      BGNMSK = 1
      ENDMSK = LBD + LCC
C
C     TURN OFF BIT IN MJMSK ARRAY IF THE CORRESPONDING CARD NAME
C     IS NOT IN THE CARD NAME RESTART TABLE
C
      I1 = CNMTP + 1
      I2 = I1 + 3*CNM(CNMTP) - 3
      DO 110 LX = BGNMSK,ENDMSK
      IF (MJMSK(LX) .EQ. 0) GO TO 110
      L = LX - BGNMSK + 1
      DO 100 L1 = 2,32
      IF (ANDF(MJMSK(LX),TWO(L1)) .EQ. 0) GO TO 100
C
C     IGNORE BIT IF IT CORRESPONDS TO QOUT$ OR BOUT$
C
      IF (LX.EQ.LBD+2 .AND. (L1.EQ.3 .OR. L1.EQ.4)) GO TO 100
      I = 62*(L-1) + 2*(L1-2) + 1
      DO 90 II = I1,I2,3
      IF (MJCD(I).EQ.CNM(II) .AND. MJCD(I+1).EQ.CNM(II+1)) GO TO 100
   90 CONTINUE
      II = COMPLF(TWO(L1))
      MJMSK(LX) = ANDF(MJMSK(LX),II)
  100 CONTINUE
  110 CONTINUE
      IF (START .EQ. IMST) GO TO 130
C
C     DETERMINE TYPE OF RESTART
C
      INDEX = 0
      IEND  = LBD
      DO 120 L = BGNMSK,IEND
      IF (MJMSK(L) .EQ. 0) GO TO 120
      INDEX = 1
      GO TO 130
  120 CONTINUE
  130 L = LBD + 1
      IF (START .EQ. IMST) GO TO 160
      IF (INDEX .EQ.    1) GO TO 150
      IF (MJMSK(L) .EQ. 0) GO TO 140
C
C     CHECK FOR NOLOOP$ AND LOOP$
C                                          2**21
      IF (MJMSK(L).NE.1 .AND. MJMSK(L).NE.TWO(11)) GO TO 150
C
C     CHECK FOR GUST$
C                         2**30
  140 IF (MJMSK(L+1) .LT. TWO(2)) GO TO 170
  150 START = IMST
C
C     TURN ON POUT$ IF QOUT$ IS ON
C                         2**29                                  2**14
  160 IF (ANDF(MJMSK(L+1),TWO(3)) .NE. 0) MJMSK(L)=ORF(MJMSK(L),TWO(18))
C
C     TURN ON AOUT$ IF BOUT$ IS ON
C                         2**28                                  2**22
      IF (ANDF(MJMSK(L+1),TWO(4)) .NE. 0) MJMSK(L)=ORF(MJMSK(L),TWO(10))
C
C     TURN OFF BOUT$ AND QOUT$
C                 2**28    2**29
      II = COMPLF(TWO(4) + TWO(3))
      MJMSK(L+1) = ANDF(MJMSK(L+1),II)
C
C     TURN OFF NOLOOP$ FOR UNMODIFIED RESTARTS
C
  170 IF (START.EQ.IUNST .AND. MJMSK(LBD+1).EQ.1) MJMSK(LBD+1) = 0
  180 CALL PAGE1
      IF (START .NE. IUNST) GO TO 200
      WRITE  (OPTAPE,190) UIM
  190 FORMAT (A29,' 4143, THIS IS AN UNMODIFIED RESTART.')
      BANDIT = -1
      IF (APPRCH .EQ. -1) GO TO 700
      GO TO 600
  200 CALL PAGE2 (-2)
      IF (SEQNO .NE. MASKLO) WRITE (OPTAPE,210) UIM
      IF (SEQNO .EQ. MASKLO) WRITE (OPTAPE,220) UIM
  210 FORMAT (A29,' 4144, THIS IS A MODIFIED RESTART.')
  220 FORMAT (A29,' 4145, THIS IS A MODIFIED RESTART INVOLVING RIGID ',
     1       'FORMAT SWITCH.')
      IBULK = 0
      ICASE = 0
      DO 230 L = 1,LBD
      IF (MJMSK(L) .EQ. 0) GO TO 230
      IBULK = 1
      GO TO 240
  230 CONTINUE
  240 LBD1 = LBD + 1
      LBDLCC = LBD + LCC
      DO 250 L = LBD1,LBDLCC
      IF (MJMSK(L) .EQ. 0) GO TO 250
      ICASE = 1
      GO TO 260
  250 CONTINUE
  260 IF (IBULK.NE.0 .OR. ICASE.NE.0) GO TO 290
      IF (SEQNO .EQ. MASKLO) GO TO 270
      WRITE (OPTAPE,460)
      CALL MESAGE (-61,0,0)
  270 WRITE  (OPTAPE,280) UIM
  280 FORMAT (A29,'. THERE ARE NO CASE CONTROL OR BULK DATA DECK ',
     1       'CHANGES AFFECTING THIS RESTART.')
      GO TO 600
  290 CALL PAGE2 (-4)
      WRITE  (OPTAPE,300) UIM
  300 FORMAT (A29,'. CASE CONTROL AND BULK DATA DECK CHANGES AFFECTING',
     1       ' THIS RESTART ARE INDICATED BELOW.',/)
      DO 500 LLX = 1,2
      IF (LLX .EQ. 1) GO TO 360
      CALL PAGE2 (-3)
      WRITE  (OPTAPE,310) UIM
  310 FORMAT (A29,'. EFFECTIVE BULK DATA DECK CHANGES', /1X,32(1H-))
      IF (IBULK .NE. 0) GO TO 330
      CALL PAGE2 (-3)
      WRITE  (OPTAPE,320)
  320 FORMAT (//,' NONE',/)
      GO TO 500
  330 CALL PAGE2 (-3)
      IF (APPRCH .NE. -1) WRITE (OPTAPE,340)
      IF (APPRCH .EQ. -1) WRITE (OPTAPE,350)
  340 FORMAT (//,' MASK WORD - BIT POSITION - CARD/PARAM NAME - PACKED',
     1       ' BIT POSITION',/)
  350 FORMAT (//,' MASK WORD - BIT POSITION - CARD/PARAM NAME',/)
      LIM1 = 1
      LIM2 = LBD
      GO TO 410
  360 CALL PAGE2 (-3)
      WRITE  (OPTAPE,370) UIM
  370 FORMAT (A29,'. EFFECTIVE CASE CONTROL DECK CHANGES', /1X,35(1H-))
      IF (ICASE .NE. 0) GO TO 380
      CALL PAGE2 (-3)
      WRITE (OPTAPE,320)
      GO TO 500
  380 CALL PAGE2 (-3)
      IF (APPRCH .NE. -1) WRITE (OPTAPE,390)
      IF (APPRCH .EQ. -1) WRITE (OPTAPE,400)
  390 FORMAT (//,' MASK WORD - BIT POSITION ---- FLAG NAME ---- PACKED',
     1       ' BIT POSITION',/)
  400 FORMAT (//,' MASK WORD - BIT POSITION ---- FLAG NAME',/)
      LIM1 = LBD1
      LIM2 = LBDLCC
  410 DO 490 L = LIM1,LIM2
      IF (MJMSK(L) .EQ. 0) GO TO 490
      CALL PAGE2 (-1)
      WRITE  (OPTAPE,420) L
  420 FORMAT (1X,I5)
      DO 480 K = 2,32
      IF (ANDF(MJMSK(L),TWO(K)) .EQ. 0) GO TO 480
C
C     GET CORRESPONDING CARD NAME FROM MAIN CARD TABLE
C
      I  = 62*(L-1) + 2*(K-2) + 1
      KZ = K - 1
      CALL PAGE2 (-1)
      IF (APPRCH .NE. -1) GO TO 430
      WRITE (OPTAPE,440) KZ,MJCD(I),MJCD(I+1)
      GO TO 480
C
C     SEARCH RIGID FORMAT CARD NAME RESTART TABLE FOR A MATCH
C
  430 DO 450 II = I1,I2,3
      IF (MJCD(I).NE.CNM(II) .OR. MJCD(I+1).NE.CNM(II+1)) GO TO 450
C
C     CARD NAME FOUND - SET BIT IN MEDMSK
C
      WRITE  (OPTAPE,440) KZ,MJCD(I),MJCD(I+1),CNM(II+2)
  440 FORMAT (17X,I3,11X,2A4,14X,I3)
      L1 = (CNM(II+2)-1)/31
      LL = L1 + 1
      KK = CNM(II+2) - 31*L1 + 1
      MEDMSK(LL) = ORF(MEDMSK(LL),TWO(KK))
      GO TO 480
  450 CONTINUE
      WRITE  (OPTAPE,460) SFM
  460 FORMAT (A25,' 4146, LOGIC ERROR IN SUBROUTINE XGPI WHILE ',
     1       'PROCESSING DATA CHANGES FOR MODIFIED RESTART.')
      WRITE  (OPTAPE,470) MJCD(I),MJCD(I+1),(CNM(LL),CNM(LL+1),
     1       LL=I1,I2,3)
  470 FORMAT (/10X,2A4, //,10(4X,2A4))
      CALL MESAGE (-61,0,0)
  480 CONTINUE
  490 CONTINUE
  500 CONTINUE
      IF (APPRCH .EQ. -1) GO TO 700
C
C     MOVE MED AND FILE NAME TABLES TO BOTTOM OF OPEN CORE.
C
  600 CALL CLOSE (NSCR,1)
      LMED = CNMTP - MEDTP
      DO 610 I = 1,LMED
      LL = MEDTP + LMED - I
      M  = LOSCAR - I + 1
  610 MED(M) = MED(LL)
      MEDTP  = LOSCAR - LMED + 1
      FNMTP  = MEDTP + MED(MEDTP)*MED(MEDTP+1) + 2
      LOSCAR = MEDTP - 1
C
C     DETERMINE TYPE OF RESTART IF IT IS A RESTART OF A DMAP RUN
C
  620 IF (APPRCH .NE.  -1) GO TO 700
      IF (MJMSK(LBD+1) .EQ. 0) GO TO 630
C
C     CHECK FOR NOLOOP$ AND LOOP$
C                                                  2**21
      IF (MJMSK(LBD+1).NE.1 .AND. MJMSK(LBD+1).NE.TWO(11)) GO TO 650
      MJMSK(LBD+1) = 0
C
C     CHECK FOR GUST$
C                           2**30
  630 IF (MJMSK(LBD+2) .GE. TWO(2)) GO TO 650
      DO 640 L = 1,LBD
      IF (MJMSK(L) .NE. 0) GO TO 650
  640 CONTINUE
      GO TO 180
  650 START = IMST
      SEQNO = LSHIFT(1,16)
      GO TO 180
C
C     CONTROL FILE LOADED, LOAD PVT TABLE
C     BUMP NUMBER OF FILES IF OLD PROBLEM TAPE HAD ALTERS
C
  700 PTFCT = PTFCT + ALTER(2)
      ITRL(1) = NPARAM
      CALL RDTRL (ITRL(1))
      IF (ITRL(2) .LE. 0) GO TO 760
      CALL OPEN (*1900,NPARAM,IBUFR(NPTBUF),0)
      CALL READ (*760,*710,NPARAM,PVT(6),2,1,NPTWRD)
  710 IF (PVT(6) .NE. NPVT) GO TO 1950
      I = 3
C
C      LOAD PVT VALUES INTO PVT TABLES
C
  720 CALL READ (*740,*730,NPARAM,PVT(I),PVT(1)-I+1,0,NPTWRD)
      GO TO 2020
  730 I = I + NPTWRD
      GO TO 720
  740 PVT(2) = I - 1
      CALL CLOSE (NPARAM,1)
C
C     ELIMINATE TRAILER SO FILE WILL BE DELETED
C
      DO 750 I = 2,7
  750 ITRL(I) = 0
      CALL WRTTRL (ITRL(1))
  760 CONTINUE
      IF (START .EQ. ICST) GO TO 1000
      IF (APPRCH.EQ.-1 .AND. START.EQ.IMST) GO TO 1000
C
C     INITIALIZE VPS TABLE FOR RESTART
C     GET FIRST ENTRY IN CHECKPOINT DICTIONARY
C
      PTDTOP = 1
      ASSIGN 770 TO IRTURN
      GO TO 1090
  770 I = PTDTOP
      IF (PTDIC(PTDTOP) .NE. NXVPS) GO TO 1000
C
C     FIRST ENTRY IN CHECKPOINT DICTIONARY IS XVPS - GET FILE OFF OF OLD
C     PROBLEM TAPE, OPTP
C
      CALL OPEN (*1910,IOP,IBUFR(IOPBUF),2)
C
C     CHECK TO SEE IF OLD RESTART TAPE HAS PVT  J = 0 WITHOUT PVT
C
      J = ANDF(MASKHI,PTDIC(PTDTOP+2)) - (ANDF(MASKHI,PTFCT)+1)
      PTFCT = PTFCT + J
      CALL SKPFIL (IOP,J)
      CALL READ (*2060,*780,IOP,VPS(3),2,1,IOPWRD)
  780 IF (VPS(3).NE.NXVPS .OR. VPS(4).NE.NBLANK) GO TO 2060
      J = VPS(1)
      CALL READ (*2060,*790,IOP,VPS,J,1,IOPWRD)
  790 CALL SKPFIL (IOP,1)
      CALL CLOSE  (IOP,2)
      PTFCT  = PTFCT + 1
      VPS(1) = J
C
C     FOR RESTART COMPARE PVT VALUES WITH VPS VALUES. IF NOT EQUAL SET
C     MODFLG INVPS ENTRY.
C
      IF (PVT(2) .LE. 2) GO TO 850
      I = 3
  800 J = 3
  810 IF (PVT(2) .LT. J) GO TO 840
      IF (PVT(J).EQ.VPS(I) .AND. PVT(J+1).EQ.VPS(I+1)) GO TO 820
      JJ = ANDF(PVT(J+2),NOSGN)
      J  = J + ITYPE(JJ) + 3
      GO TO 810
C
C     FOUND VARIABLE IN PVT TABLE
C
  820 L = ANDF(VPS(I+2),MASKHI)
      PVT(J+2) = ORF(PVT(J+2),ISGNON)
      DO 830 LL = 1,L
      II = I + LL + 2
      JJ = J + LL + 2
      VPS(I+2) = ORF(VPS(I+2),MODFLG)
      VPS(II ) = PVT(JJ)
  830 CONTINUE
  840 I = I + ANDF(VPS(I+2),MASKHI) + 3
      IF (I .LT. VPS(2)) GO TO 800
  850 I = LBD + LCC + 1
      IPARPT = MJMSK(I)
      IPARW1 = (IPARPT-1)/31 + 1
      IPARW2 = LBD
      IPARBT = MOD(IPARPT-1,31) + 2
      IDELET = 0
      DO 860 J1 = IPARW1,IPARW2
      IF (MJMSK(J1) .NE. 0) GO TO 870
  860 CONTINUE
      IDELET = 1
      GO TO 1000
  870 DO 920 J1 = IPARW1,IPARW2
      IF (MJMSK(J1) .EQ. 0) GO TO 910
      DO 900 I1 = IPARBT,32
      IF (ANDF(MJMSK(J1),TWO(I1)) .EQ. 0) GO TO 900
      NAMPT = 2*(31*(J1-1)+I1-1) - 1
      I2 = 3
  880 IF (MJCD(NAMPT).NE.VPS(I2) .OR. MJCD(NAMPT+1).NE.VPS(I2+1))
     1    GO TO 890
      IF (ANDF(VPS(I2+2),TWO(2)) .NE. 0) GO TO 900
      VPS(I2  ) = NBLANK
      VPS(I2+1) = NBLANK
      GO TO 900
  890 I2 = I2 + ANDF(VPS(I2+2),MASKHI) + 3
      IF (I2 .LT. VPS(2)) GO TO 880
  900 CONTINUE
  910 IPARBT = 2
  920 CONTINUE
C
C     DMAP SEQUENCE COMPILATION - PHASE 1
C     ***********************************
C
C     GENERATE OSCAR
C     POSITION NEW PROBLEM TAPE AT ALTER FILE IF IT EXISTS
C
 1000 IF (ALTER(1) .EQ. 0) GO TO 1030
      NAM1 = NXALTR
      NAM2 = NBLANK
      CALL OPEN (*1900,NPT,IBUFR(NPTBUF),0)
 1010 CALL SKPFIL (NPT,1)
      CALL READ (*1950,*1020,NPT,ICF,2,1,NPTWRD)
 1020 IF (ICF(1) .NE. NXALTR) GO TO 1010
C
C     ALTER FILE FOUND - INITIALIZE ALTER CELLS
C
      CALL READ (*1950,*1950,NPT,ALTER,2,1,NPTWRD)
 1030 CALL OPEN (*2010,NSCR,IBUFR(IDPBUF),0)
      CALL XGPIMW (1,1,0,0)
      CALL XOSGEN
      IF (START .EQ. ICST) GO TO 1050
      DO 1040 I = 1,NMASK
      MEDMSK(I) = 0
 1040 CONTINUE
 1050 IF (ALTER(1) .EQ. 0) GO TO 1060
      CALL CLOSE (NPT,2)
 1060 CONTINUE
      IF (PVT(2) .LE. 2) GO TO 1080
      J = 5
 1070 IF (PVT(2) .LT. J) GO TO 1080
      IF (PVT(J) .GE. 0) CALL XGPIDG (-54,0,PVT(J-2),PVT(J-1))
      JJ = ANDF(PVT(J),NOSGN)
      J  = J + ITYPE(JJ) + 3
      GO TO 1070
 1080 IF (NOGO .EQ. 2) GO TO 2210
      CALL CLOSE (NSCR,1)
      IF (START .NE. ICST) CALL XGPIMW (2,0,0,0)
      CALL XGPIMW (1,0,0,0)
C
C     ALLOW MINIMAL SIZE FOR PTDIC ARRAY IN OPEN CORE.
C     WE WILL EXPAND IF THIS IS RESTART.
C
      PTDTOP = OSCAR(OSBOT) + OSBOT
      PTDBOT = PTDTOP
      LPTDIC = 3
      ASSIGN 1130 TO IRTURN
C
 1090 IF (START .EQ. ICST) GO TO 1130
C
C     RESTART - LOAD OLD PROBLEM TAPE DICTIONARY INTO OPEN CORE.
C
      CALL OPEN (*1900,NPT,IBUFR(NPTBUF),0)
C
C     FIND XPTDIC ON NEW PROBLEM TAPE
C
      NAM1 = NXPTDC(1)
      NAM2 = NXPTDC(2)
 1100 CALL SKPFIL (NPT,1)
      CALL READ (*1950,*1110,NPT,PTDIC(PTDTOP),2,1,NPTWRD)
 1110 IF (PTDIC(PTDTOP) .EQ.     NXCSA) GO TO 1950
      IF (PTDIC(PTDTOP) .NE. NXPTDC(1)) GO TO 1100
C
C     FOUND XPTDIC
C
      LPTDIC = LOSCAR - PTDTOP
      CALL READ (*1950,*1120,NPT,PTDIC(PTDTOP),LPTDIC,1,NPTWRD)
      GO TO 2030
 1120 PTDBOT = PTDTOP + NPTWRD - 3
      CALL CLOSE (NPT,1)
      GO TO IRTURN, (770,1130)
C
C     IF BOTH DIAGS 14 AND 20 ARE ON, TERMINATE JOB
C
 1130 IF (DIAG14 .NE. 1) GO TO 1200
      CALL SSWTCH (20,I)
      IF (I .EQ. 0) GO TO 1200
      WRITE  (OPTAPE,1140)
 1140 FORMAT (//' *** JOB TERMINATED BY DIAG 20',//)
      CALL PEXIT
C
C     DMAP SEQUENCE COMPILATION - PHASE 2
C     ***********************************
C
C     COMPUTE NTU AND LTU FOR DATA SETS IN OSCAR
C
 1200 IF (NOGO.NE.0 .AND. START.NE.ICST .AND. PTDTOP.EQ.PTDBOT)
     1    GO TO 2210
      CALL XFLORD
      IF (DIAG14 .EQ. 11) GO TO 2120
      IF (NOGO.NE.0 .OR. LNOGO) GO TO 2210
      IF (DIAG4 .NE. 0) CALL DUMPER
C
C     PURGE ALL FILES IN FIAT TABLE THAT HAVE NOT BEEN GENERATED BY
C     IFP SUBROUTINE
C
      I = IFIAT(1)*ICFIAT - 2
      DO 1230 K = 4,I,ICFIAT
      IF (IFIAT(K+1) .EQ. 0) GO TO 1210
      IF (IFIAT(K+3).NE.0 .OR. IFIAT(K+4).NE.0 .OR. IFIAT(K+5).NE.0)
     1    GO TO 1230
      IF (ICFIAT.EQ.11  .AND. (IFIAT(K+8).NE.0 .OR. IFIAT(K+9).NE.0 .OR.
     1    IFIAT(K+10).NE.0)) GO TO 1230
C
C     FILE NOT GENERATED - PURGE IT.
C
      K1 = IFIAT(3)*ICFIAT + 4
      IFIAT(3)  = IFIAT(3) + 1
      IFIAT(K1) = ORF( ANDF(IFIAT(K),MASKLO),MASKHI)
      IFIAT(K ) = ANDF(IFIAT(K),ORF(MASKHI,LOSGN))
      IFIAT(K1+1) = IFIAT(K+1)
      IFIAT(K1+2) = IFIAT(K+2)
C
C     MAKE SURE NO RESIDUE LEFT IN FIAT TABLE
C
 1210 J1 = K + 1
      J2 = K + ICFIAT - 1
      DO 1220 J = J1,J2
 1220 IFIAT(J) = 0
C
 1230 CONTINUE
C
C     WRITE OSCAR ON DATA POOL FILE.
C
C     PUT OSCAR NAME IN DPL AND ASSIGN FILE NO.
C
      LSTDPL = LSTDPL + 1
      I = LSTDPL*3 + 1
      DPL(I  ) = IOSHDR(1)
      DPL(I+1) = IOSHDR(2)
      DPL(I+2) = NDPFIL
      NDPFIL   = 1 + NDPFIL
C
C     WRITE OSCAR HEADER RECORD
C     POSITION FILE
C
      IF (NDPFIL .EQ. 2) GO TO 1240
      CALL OPEN (*1940,IDP,IBUFR(IDPBUF),0)
      CALL SKPFIL (IDP,NDPFIL-2)
      CALL CLOSE  (IDP,2)
 1240 IDPFCT = NDPFIL - 1
      CALL OPEN (*1940,IDP,IBUFR(IDPBUF),3)
      CALL WRITE (IDP,IOSHDR,2,1)
C
C     IF CHECKPOINT AND RESTART FLAGS ARE ON INSERT CHECKPOINT ENTRY IN
C     OSCAR TO SAVE FILES LISTED IN ICPDPL TABLE
C
      IF (START .EQ. ICST) GO TO 1290
      IF (ICPBOT.GE.ICPTOP .AND. ICPFLG.NE.0) GO TO 1250
      CPNTRY(6) = 1
      CALL WRITE (IDP,CPNTRY,6,1)
      GO TO 1270
C
C     CHECKPOINT ALL FILES LISTED IN ICPDPL
C
 1250 CPNTRY(7) = (ICPBOT - ICPTOP + 3)/3
      CPNTRY(1) = 7 + CPNTRY(7)*2
C
C     FOR UNMODIFIED RESTART - DMAP SEQUENCE NO. OF THIS INITIAL
C     CHECKPOINT MUST = REENTRY POINT - 1
C
      IF (START .EQ. IUNST)
     1    CPNTRY(6) = ORF(ISGNON,RSHIFT(ANDF(SEQNO,MASKLO),16)-1)
      CALL WRITE (IDP,CPNTRY,7,0)
      DO 1260 I = ICPTOP,ICPBOT,3
 1260 CALL WRITE (IDP,ICPDPL(I),2,0)
      CALL WRITE (IDP,0,0,1)
C
C     FOR RESTART - INSERT JUMP IN OSCAR TO POSITION OSCAR AT CORRECT
C     REENTRY POINT
C     FOR MODIFIED RESTART - START AT FIRST EXECUTABLE MODULE
C
 1270 IF (START .EQ. IMST) JMP(6) = 1
C
C     SEE IF RE-ENTRY POINT IS WITHIN BOUNDS UNLESS SOLUTION CHANGED.
C
      IF (ANDF(SEQNO,MASKLO) .EQ. MASKLO) GO TO 1280
      I = ANDF(SEQNO,MASKHI)
      IF (I.GT.OSCAR(OSBOT+1) .OR. I.EQ.0) GO TO 2110
      JMP(7) = LSHIFT(I,16)
 1280 CALL WRITE (IDP,JMP,7,1)
 1290 OSPNT = 1
C
C     WRITE NEXT OSCAR ENTRY ON DATA POOL TAPE
C
 1300 CALL WRITE (IDP,OSCAR(OSPNT),OSCAR(OSPNT),1)
      IF (OSCAR(OSPNT+3) .EQ. IXTIM) GO TO 1330
      I = ANDF(OSCAR(OSPNT+2),MASKHI)
      IF (I.GT.2 .OR. OSCAR(OSPNT+5).GE.0) GO TO 1340
C
C     MAKE SURE SYSTEM HAS ENOUGH FILES AVAILABLE TO HANDLE MODULE
C     REQUIREMENTS.
C     COUNT NUMBER OF I/P AND O/P FILES NEEDED
C
      J1 = 2
      IF (I .EQ. 2) J1 = 1
      K = 0
      L = OSPNT + 6
      DO 1320 J = 1,J1
      L2 = OSCAR(L)*3 - 2 + L
      L1 = L + 1
      IF (OSCAR(L1-1) .EQ. 0) GO TO 1320
      DO 1310 L = L1,L2,3
      IF (OSCAR(L) .NE. 0) K = K + 1
 1310 CONTINUE
 1320 L = L2 + 3
C
C     ADD ON NUMBER OF SCRATCH FILES NEEDED
C
      K = K + OSCAR(L)
      IF (IFIAT(1) .LT. K) GO TO 2070
      GO TO 1340
C
C     OSCAR ENTRY IS XTIME, COMPUTE ROUGH TIME ESTIMATES FOR MODULES IN
C     TIME SEGMENT, AND
C     WRITE XTIME HEADER AND TIME ESTIMATES ONTO DATA POOL
C     (THIS SECTION TEMPORARILY OMITTED)
C
 1330 GO TO 1340
C
C     INCREMENT OSPNT AND CHECK FOR END OF OSCAR
C
 1340 OSPNT = OSPNT + OSCAR(OSPNT)
      IF (OSPNT-OSBOT) 1300,1300,1350
 1350 CALL EOF (IDP)
      IF (START .EQ. ICST) GO TO 1800
C
C
C     *** RESTART ***
C
      IF (ICPBOT .LT. ICPTOP) GO TO 1800
C
C     LIST ICPDPL CONTENTS
C
      CALL XGPIMW (8,ICPTOP,ICPBOT,ICPDPL)
C
C     ELIMINATE PURGED FILES FROM ICPDPL
C
      I1 = ICPTOP
      DO 1400 I = I1,ICPBOT,3
      IF (ANDF(ICPDPL(I+2),MASKHI) .NE. 0) GO TO 1410
 1400 ICPTOP = ICPTOP + 3
 1410 IF (ICPBOT .LT. ICPTOP) GO TO 1800
      CALL CLOSE (IDP,2)
      IB1S   = IDPBUF
      IDPBUF = ICPBOT + 3
      IOPBUF = IDPBUF + IBUFSZ
      CALL GOPEN (IDP,IBUFR(IDPBUF),3)
C
C     TRANSFER CHECKPOINT INFO FROM OLD PROBLEM TAPE TO DATA POOL TAPE
C
      K = LSTDPL*3 + 4
      CALL OPEN (*1910,IOP,IBUFR(IOPBUF),2)
      DO 1580 I = ICPTOP,ICPBOT,3
      DPL(K+2) = 0
      IF (ANDF(ICPDPL(I+2),NOFLGS) .GT. PTFCT) GO TO 1420
C
C     FILE IS EQUIVALENCED TO PREVIOUS ENTRY IN DPL
C
      NDPFIL = NDPFIL - 1
      DPL(K+2) = DPL(K-1)
      GO TO 1570
C
C     MAKE SURE CORRECT REEL IS MOUNTED FOR OLD PROBLEM TAPE
C
 1420 IF (ANDF(ANDF(NOFLGS,MASKLO),ICPDPL(I+2)) .EQ. ANDF(MASKLO,PTFCT))
     1   GO TO 1480
C
C     ** NEW REEL NEEDED **
C     MOUNT REEL SPECIFIED BY ICPDPL ENTRY
C
      OTAPID(6) = RSHIFT(ANDF(NOFLGS,ICPDPL(I+2)),16)
      WRNGRL = 0
C
C     SEND OPERATOR MESSAGE
C
 1430 CALL XEOT (IOP,RSHIFT(PTFCT,16),OTAPID(6),IBUFR(IOPBUF))
      CALL OPEN (*1910,IOP,IBUFR(IOPBUF),0)
      CALL READ (*2050,*1440,IOP,IBF,LIBF,0,IOPWRD)
C
C     SEE THAT CORRECT REEL HAS BEEN MOUNTED.
C
 1440 DO 1450 II = 1,6
      IF (OTAPID(II) .NE. IBF(II)) GO TO 1460
 1450 CONTINUE
      GO TO 1470
 1460 WRNGRL = WRNGRL + 1
      IF (WRNGRL .LT. 2) GO TO 1430
      GO TO 2100
C
C     CORRECT REEL MOUNTED - CARRY ON
C
 1470 CALL SKPFIL (IOP,1)
      PTFCT = LSHIFT(OTAPID(6),16) + 1
      IF (FILCON) 1560,1480,1560
C
C     WRITE FILE ON DATA POOL
C
 1480 CALL SKPFIL (IOP,ANDF(MASKHI,ICPDPL(I+2))-(ANDF(MASKHI,PTFCT)+1))
C
C     CHECK FOR CORRECT FILE
C
C     5 OR 8 WORDS (DEPEND ON ICFIAT VALUE OF 8 OR 11) WRITTEN TO IOP
C     BY XCHK OF PREVIOUS CHECKPOINT RUN.
C     IF ICFIAT=11, READ 5 WORDS HERE FIRST, AND CHECK IF THERE ARE 3
C     MORE WORDS BEHIND.  I.E. OPTP MAY BE WRITTEN WITH A 5-WORD RECORD
C     IF ICFIAT= 8, READ 5 WORDS
C
      IF (ICFIAT .EQ. 11) GO TO 1490
      CALL READ (*2050,*2050,IOP,IBF,5,1,IOPWRD)
      IBF(8) = 0
      GO TO 1510
 1490 IBF(8) = -999
      CALL READ (*2050,*2050,IOP,IBF(1),5,0,IOPWRD)
      CALL READ (*2050,*1510,IOP,IBF(6),3,1,IOPWRD)
C
 1510 DO 1520 II = I,ICPBOT,3
      IF (IBF(1).EQ.ICPDPL(II) .AND. IBF(2).EQ.ICPDPL(II+1)) GO TO 1530
 1520 CONTINUE
      GO TO 2050
C
C     A 5-WORD RECORD READ, EXPANDED (THE TRAILERS) TO 8 WORDS
C
 1530 IF (IBF(8) .NE. -999) GO TO 1540
      IBF(8) = ANDF(IBF(5),65535)
      IBF(7) = RSHIFT(IBF(5),16)
      IBF(6) = ANDF(IBF(4),65535)
      IBF(5) = RSHIFT(IBF(4),16)
      IBF(4) = ANDF(IBF(3),65535)
      IBF(3) = RSHIFT(IBF(3),16)
C
C     COPY FILE TO POOL
C
 1540 CALL WRITE (IDP,IBF,ICFIAT-3,1)
 1560 CALL CPYFIL (IOP,IDP,IBF,LIBF,IOPWRD)
      DPL(K+2) = DPL(K+2) + IOPWRD/1000 + 1
C
C     FILE ALL ON DATA POOL TAPE
C
      CALL EOF (IDP)
      FILCON = 0
C
C     MAKE DPL ENTRY FOR ICPDPL ENTRY
C
      DPL(K+2) = ORF(ORF(LSHIFT(DPL(K+2),16),NDPFIL),
     1           ANDF(ICPDPL(I+2),IEQFLG))
 1570 DPL(K  ) = ICPDPL(I  )
      DPL(K+1) = ICPDPL(I+1)
      IF (L8 .NE. 0) CALL CONMSG (DPL(K),2,0)
      K = K + 3
      NDPFIL = NDPFIL + 1
      LSTDPL = 1 + LSTDPL
      IF (LSTDPL .GT. MAXDPL) GO TO 2040
      PTFCT = ANDF(NOFLGS,ICPDPL(I+2))
 1580 CONTINUE
C
C     FILES ALL COPIED OVER FROM OLD PROBLEM TAPE TO DATA POOL TAPE.
C
      CALL CLOSE (IOP,1)
C
C     SEE IF XVPS IS ON POOL TAPE
C
      K = LSTDPL*3 + 1
      L = NDPFIL
      IF (DPL(K) .NE. NXVPS) GO TO 1590
C
C     VPS FILE IS LAST ENTRY IN DPL - DELETE ENTRY
C
      LSTDPL = LSTDPL - 1
      NDPFIL = NDPFIL - 1
      J = K
      GO TO 1620
C
C     VPS FILE IS NOT LAST ENTRY IN DPL - SEARCH DPL FOR IT
C
 1590 DO 1600 J = 4,K,3
      IF (DPL(J) .EQ. NXVPS) GO TO 1610
 1600 CONTINUE
C
C     NO RESTART VPS TABLE
C
      GO TO 1800
C
C     XVPS FOUND - ZERO NAME WHEN NOT LAST ENTRY IN DPL
C
 1610 DPL(J  ) = 0
      DPL(J+1) = 0
C
C     XVPS FILE FOUND IN DPL - POSITION POOL TAPE AND INITIALIZE
C     VPS TABLE WITH CHECKPOINT VALUES
C
 1620 CALL CLOSE (IDP,3)
      CALL OPEN (*1940,IDP,IBUFR(IDPBUF),2)
      CALL SKPFIL (IDP,ANDF(DPL(J+2),MASKHI)-L-1)
      NAM1 = NXVPS
      NAM2 = NBLANK
      CALL SKPFIL (IDP,1)
      CALL READ (*1930,*1630,IDP,IBF,LIBF,1,IDPWRD)
 1630 IF (IBF(1) .NE. NXVPS) GO TO 1930
      CALL READ (*1930,*1640,IDP,IBF,LIBF,1,IDPWRD)
C
C     COMPARE RESTART PARAMETER NAMES WITH VPS NAMES
C
 1640 K = 3
 1650 J = 3
      IF (ANDF(VPS(K+2),MODFLG) .EQ. MODFLG) GO TO 1730
 1660 IF (IBF(2) .LT. J) GO TO 1730
      IF (IBF(J).EQ.VPS(K) .AND. IBF(J+1).EQ.VPS(K+1)) GO TO 1670
      J = J + IBF(J+2) + 3
      GO TO 1660
C
C     PARAMETER NAMES MATCH AND MODFLG NOT ON - INITIALIZE VPS WITH
C     RESTART VALUE.
C
 1670 L = IBF(J+2)
      IF (IDELET .EQ. 1) GO TO 1710
      IPARBT = MOD(IPARPT-1,31) + 2
      DO 1700 JJJ = IPARW1,IPARW2
      IF (MJMSK(JJJ) .EQ. 0) GO TO 1690
      DO 1680 III = IPARBT,32
      IF (ANDF(MJMSK(JJJ),TWO(III)) .EQ. 0) GO TO 1680
      NAMPT = 2*(31*(JJJ-1) + III - 1) - 1
      IF (MJCD(NAMPT).EQ.VPS(K) .AND. MJCD(NAMPT+1).EQ.VPS(K+1))
     1    GO TO 1730
 1680 CONTINUE
 1690 IPARBT = 2
 1700 CONTINUE
 1710 DO 1720 M = 1,L
      J1 = M + 2 + J
      K1 = M + 2 + K
 1720 VPS(K1) = IBF(J1)
C
C     CLEAR FLAGS AND TYPE CODE IN VPS ENTRY AND GET NEXT ENTRY.
C
 1730 VPS(K+2) = ANDF(VPS(K+2),MASKHI)
      K = K + VPS(K+2) + 3
      IF (K .LT. VPS(2)) GO TO 1650
C
C     FOR UNMODIFIED RESTART LOAD CEITBL FROM LAST CHECKPOINT
C
      CALL READ (*1930,*1740,IDP,IBF,LIBF,1,IDPWRD)
 1740 IF (START .EQ. IMST) GO TO 1770
      K1 = CEITBL(2)
      J1 = IBF(2)
C
C     FOR RESTART INITIALIZE REPT LOOP COUNTS WITH CHECKPOINT INFO
C
      DO 1760 J = 3,J1,4
      DO 1750 K = 3,K1,4
      IF (CEITBL(K+2).EQ.IBF(J+2) .AND. CEITBL(K+3).EQ.IBF(J+3) .AND.
     1    IBF(J+2).NE.0) CEITBL(K+1) = IBF(J+1)
 1750 CONTINUE
 1760 CONTINUE
C
C     FOR BOTH MOD AND UNMOD RESTART - LOAD VARIOUS CELLS IN /SYSTEM/
C     WITH LAST CHECKPOINT INFO
C
 1770 CALL READ (*1790,*1780,IDP,IBF,LIBF,1,IDPWRD)
 1780 MPC  = IBF(5)
      SPC  = IBF(6)
      LOAD = IBF(8)
 1790 CONTINUE
      CALL CLOSE (IDP,1)
      IDPBUF = IB1S
C
C
C     POSITION DATA POOL TAPE AT FIRST OSCAR ENTRY
C
 1800 CALL CLOSE (IDP,1)
C
C     *** FIRST, PRODUCE DMAP XREF IF REQUESTED
C
      CALL OPEN (*1940,IDP,IBUFR(IDPBUF),2)
      CALL SKPFIL (IDP,IDPFCT-1)
      CALL FWDREC (*1920,IDP)
      IF (ANDF(IFLG(5),1) .NE. 0) CALL OSCXRF (IDPFCT-1,IDPBUF-1)
      CALL CLOSE (IDP,2)
C
C     WRITE VPS TABLE ON NEW PROBLEM TAPE IF CHECKPOINT FLAG ES SET
C     CLEAR FLAGS IN VPS
C
      K = 3
 1810 VPS(K+2) = ANDF(VPS(K+2),MASKHI)
      K = K + VPS(K+2) + 3
      IF (K .LT. VPS(2)) GO TO 1810
      IF (ICPFLG .EQ. 0) GO TO 1820
C
C     POSITION TAPE FOR WRITING XVPS
C
      CALL OPEN (*1900,NPT,IBUFR(NPTBUF),0)
      CALL SKPFIL (NPT,ANDF(NRLFL,MASKHI)-1)
      CALL CLOSE (NPT,2)
      CALL OPEN (*1900,NPT,IBUFR(NPTBUF),3)
      IBF(1) = NXVPS
      IBF(2) = NBLANK
      CALL WRITE (NPT,IBF,2,1)
      CALL WRITE (NPT,VPS,VPS(2),1)
C
C     WRITE CEITBL TABLE ON NEW PROBLEM TAPE
C
      CALL WRITE (NPT,CEITBL,CEITBL(2),1)
      CALL EOF (NPT)
      CALL CLOSE (NPT,2)
C
C     INITIALIZE CHECKPOINT PARAMETERS FOR XCHK AND XCEI ROUTINES
C
      PTDIC(PTDTOP  ) = NXVPS
      PTDIC(PTDTOP+1) = NBLANK
      PTDIC(PTDTOP+2) = NRLFL
      NRLFL = NRLFL + 1
      SEQNO = 1
C
C     WRITE NEW DICTIONARY ON XPTD
C
      CALL OPEN  (*1900,NXPTDC,IBUFR(NPTBUF),1)
      CALL WRITE (NXPTDC,NXPTDC,2,1)
      CALL WRITE (NXPTDC,NRLFL, 2,1)
      CALL WRITE (NXPTDC,PTDIC(PTDTOP),3,1)
      CALL CLOSE (NXPTDC,1)
C
C     PUNCH DICTIONARY ENTRY FOR XVPS TABLE
C
      NFILE = ANDF(MASKHI,PTDIC(PTDTOP+2))
 1820 CONTINUE
      IF (NOGO.NE.0 .OR. LNOGO) GO TO 2210
      CALL XGPIMW (9,NFILE,ICPFLG,IFIAT)
      CPPGCT = PAGECT
      IF (IFLG(1) .EQ. 0) CALL PEXIT
C
C     TERMINATE RUN IF ANY OF THE DIAG (17, 25, 28, OR 30) AND DIAG 20
C     ARE REQUESTED SIMULTANEOUSLY
C
      CALL SSWTCH (20,J)
      IF (J .EQ. 0) RETURN
      CALL SSWTCH (28,I)
      CALL SSWTCH (30,J)
      IF (DIAG17+DIAG25+I+J .EQ. 0) RETURN
      WRITE  (OPTAPE,1830)
 1830 FORMAT (10X,'JOB TERMINATED BY DIAG 20')
      CALL PEXIT
C
C     E R R O R    M E S S A G E S
C
C     UNEXPECTED END OF TAPE ON NEW PROBLEM TAPE
C
 1900 CALL XGPIDG (28,0,0,0)
      GO TO 2200
C
C     UNEXPECTED END OF TAPE ON OLD PROBLEM TAPE
C
 1910 CALL XGPIDG (29,0,0,0)
      GO TO 2200
C
C     CANNOT FIND FILE ON DATA POOL TAPE
C
 1920 NAM1 = IOSHDR(1)
      NAM2 = IOSHDR(2)
 1930 CALL XGPIDG (24,NAM1,NAM2,0)
      GO TO 2200
C
C     UNEXPECTED END OF TAPE ON DATA POOL TAPE
C
 1940 CALL XGPIDG (30,0,0,0)
      GO TO 2200
C
C     CONTROL FILE INCOMPLETE OR MISSING ON NEW PROBLEM TAPE.
C
 1950 CALL XGPIDG (31,NAM1,NAM2,0)
      GO TO 2200
C
C     MED TABLE RECORD MISSING ON SCRATCH FILE
C
 1960 CALL XGPIDG (69,NXGPI(1),NXGPI(2),0)
      GO TO 2200
C
C     CARD OR FILE NAME TABLE RECORD MISSING ON SCRATCH FILE
C
 1970 CALL XGPIDG (70,NXGPI(1),NXGPI(2),JTYPE)
      GO TO 2200
C
C     ILLEGAL NUMBER OF WORDS IN MED TABLE RECORD
C
 1980 CALL XGPIDG (71,LMED,0,0)
      GO TO 2200
C
C     ILLEGAL NUMBER OF WORDS IN CARD OR FILE NAME TABLE RECORD
C
 1990 CALL XGPIDG (72,LMED,JTYPE,0)
      GO TO 2200
C
C     ILLEGAL BIT NUMBERS IN CARD OR FILE NAME TABLE
C
 2000 CALL XGPIDG (73,JTYPE,0,0)
      GO TO 2200
C
C     SCRATCH FILE CONTAINING DMAP DATA COULD NOT BE OPENED
C
 2010 CALL XGPIDG (33,NXGPI(1),NXGPI(2),0)
      GO TO 2200
C
C     PVT TABLE OVERFLOW
C
 2020 CALL XGPIDG (14,NPVT,NBLANK,0)
      GO TO 2210
C
C     XPTDIC OVERFLOWED
C
 2030 CALL XGPIDG (14,NXPTDC(1),NXPTDC(2),0)
      GO TO 2200
C
C     DPL TABLE OVERFLOW
C
 2040 CALL XGPIDG (14,NDPL,NBLANK,0)
      GO TO 2210
C
C     CANNOT FIND FILE ON OLD PROBLEM TAPE
C
 2050 CALL XGPIDG (36,ICPDPL(I),ICPDPL(I+1),0)
      GO TO 2210
 2060 CALL XGPIDG (36,PTDIC(I),PTDIC(I+1),0)
      GO TO 2210
C
C     NOT ENOUGH FILES AVAILABLE FOR MODULE REQUIREMENTS.
C
 2070 CALL XGPIDG (-37,OSPNT,K,IFIAT(1))
      GO TO 1340
C
C     NOT ENOUGH CORE FOR GPI TABLES
C
 2080 CALL XGPIDG (38,-LOSCAR,0,0)
      GO TO 2200
C
C     MED TABLE OVERFLOW
C
 2090 CALL XGPIDG (14,NMED,NBLANK,0)
      GO TO 2200
C
C     INCORRECT OLD PROBLEM TAPE MOUNTED
C
 2100 CALL XGPIDG (35,0,0,0)
      GO TO 2210
C
C     REENTRY POINT NOT WITHIN BOUNDS
C
 2110 CALL XGPIDG (46,0,0,0)
      GO TO 2210
C
C     USER DMAP ALTER CONTAINS ERROR, DIAG 14 FLAG IS NOT REQUESTED, AND
C     ECHO IS NOT 'NONO', PRINT RIGID FORMAT BEFORE QUITTING
C
 2120 IF (IECHO .NE. -2) CALL XGPIMW (13,0,0,CORE)
      GO TO 2210
C
C     TERMINATE JOB IF NOGO = 1
C
 2200 NOGO = 2
 2210 WRITE  (OPTAPE,2220)
 2220 FORMAT (//5X,'*** JOB TERMINATED DUE TO ABOVE ERRORS')
      CALL MESAGE (-37,0,NXGPI)
      RETURN
      END
