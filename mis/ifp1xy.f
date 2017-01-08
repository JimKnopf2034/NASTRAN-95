      SUBROUTINE IFP1XY (CARD,XYCARD)
C
C     THIS ROUTINE PROCESSES THE XRCARD IMAGES OF THE XY-PLOT CONTROL
C     CARDS AND CREATES THE -XYCDB- FILE WHICH IS OPENED AND CLOSED BY
C     THE CALLING ROUTINE.
C
C     THE ARGUMENT -CARD- IS = 1 ON THE FIRST CALL TO THIS ROUTINE
C                            = 0 ON OTHER CALLS WHEN AN IMAGE IS SENT
C                            =-1 ON LAST CALL AND NO IMAGE IS SENT
C
C     TWO RECORDS WILL BE FORMED BY THIS ROUTINE.
C     THE FIRST RECORD HAS XY-PLOT, XY-PRINT, AND XY-PUNCH DATA AND IS
C     USED BY THE XYTRAN MODULE.
C     THE SECOND RECORD IS A SORTED NX6 MATRIX STORED BY ROWS. EACH ROW
C     CONTAINS THE FOLLOWING.
C
C          1 - SUBCASE ID OR 0 INDICATING ALL.
C          2 - VECTOR CODE NUMBER E.G. DISP,STRESS,SPCF, ETC.
C          3 - POINT OR ELEMENT ID NUMBER.
C          4 - COMPONENT NUMBER.
C          5 - TYPE OF PLOT (1=RESP,2=AUTO,3=PSDF)
C          6 - DESTINATION CODE 1-7 (BIT1=PRINT,BIT2=PLOT,BIT3=PUNCH).
C              CODE 8 ADDED - BIT 4 PAPERPLOT
C
      IMPLICIT INTEGER (A-Z)
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF
      LOGICAL         CONTIN,SLASH,PAIRS,OFBCD,TAPBIT,XYCM,BIT64
      CHARACTER       UFM*23
      COMMON /XMSSG / UFM
      DIMENSION       BUF(10),MODID(2),XYCARD(1),KWORD(3),RWORD(14),
     1                IWORD(26),BWORD(16),ICSE(400),INCARD(20),
     2                BUFF(150),SUBCAS(200),Z(1),COREY(771)
      COMMON /MACHIN/ MACH,IHALF
      COMMON /SYSTEM/ KSYSTM(21),ILINK,SKP63(63),INTR
      COMMON /IFP1A / DUM3(3),NWPC,DUMMY(11),A377
      COMMON /XIFP1 / BLANK,BIT64
C     COMMON /ZZIFP1/ ICSE(400),INCARD(20),BUFF(150),SUBCAS(200),Z(1)
      COMMON /ZZZZZZ/ COREX(1)
      COMMON /IFPX0 / LBD,LCC,BITS(1)
      EQUIVALENCE     (KSYSTM( 1),SYSBUF    ), (KSYSTM( 2),L      ),
     1                (KSYSTM( 3),NOGO      ), (KSYSTM( 9),NLPP   ),
     2                (KSYSTM(12),LINE      ), (KSYSTM(21),IRESRT ),
     3                (ICSE(1)   ,COREX(1   ), COREY(1)           ),
     4                (INCARD(1) ,COREY(401)), (BUFF(1),COREY(421)),
     5                (SUBCAS(1) ,COREY(571)), (Z(1)   ,COREY(771))
      DATA    NRWORD/ 14 /,  NIWORD / 26    /, NBWORD  / 16 /
      DATA    ILNK  / 4HNS01        /
      DATA    KWORD / 4HFILM, 4HPAPE, 4HBOTH/
      DATA    RWORD / 4HXMIN, 4HXMAX, 4HYMIN, 4HYMAX, 4HYTMI, 4HYTMA,
     1                4HYBMI, 4HYBMA, 4HYINT, 4HXINT, 4HYTIN, 4HYBIN,
     2                4HXPAP, 4HYPAP/
      DATA    IWORD / 4HXDIV, 4HYDIV, 4HYTDI, 4HYBDI, 4HXVAL, 4HYVAL,
     1                4HYTVA, 4HYBVA, 4HUPPE, 4HLOWE, 4HLEFT, 4HRIGH,
     2                4HTLEF, 4HTRIG, 4HBLEF, 4HBRIG, 4HALLE, 4HTALL,
     3                4HBALL, 4HCURV, 4HDENS, 4HCAME, 4HPENS, 4HSKIP,
     4                4HCSCA, 4HCOLO/
      DATA    BWORD / 4HXAXI, 4HYAXI, 4HXTAX, 4HXBAX, 4HXLOG, 4HYLOG,
     1                4HYTLO, 4HYBLO, 4HXGRI, 4HYGRI, 4HXTGR, 4HXBGR,
     2                4HPLOT, 4HYTGR, 4HYBGR, 4HLONG/
      DATA    CLEA  / 4HCLEA /,   YES   / 4HYES  /,   NO    / 4HNO   /,
     1        T1    / 4HT1   /,   R1    / 4HR1   /,   T1RM  / 4HT1RM /,
     2        T2    / 4HT2   /,   R2    / 4HR2   /,   T2RM  / 4HT2RM /,
     3        T3    / 4HT3   /,   R3    / 4HR3   /,   T3RM  / 4HT3RM /,
     4        T1IP  / 4HT1IP /,   R1RM  / 4HR1RM /,   R1IP  / 4HR1IP /,
     5        T2IP  / 4HT2IP /,   R2RM  / 4HR2RM /,   R2IP  / 4HR2IP /,
     6        T3IP  / 4HT3IP /,   R3RM  / 4HR3RM /,   R3IP  / 4HR3IP /,
     7        XYPL  / 4HXYPL /,   XYPU  / 4HXYPU /,   XYPR  / 4HXYPR /,
     8        SLAS  / 4H/    /,   THRU  / 4HTHRU /,   FRAM  / 4HFRAM /,
     9        XY    / 4HXY   /,   AUTO  / 4HAUTO /,   RESP  / 4HRESP /
      DATA    PSDF  / 4HPSDF /,   VDUM  / 4HVDUM /,   DISP  / 4HDISP /,
     1        VELO  / 4HVELO /,   SVEL  / 4HSVEL /,   ELST  / 4HELST /,
     2        ACCE  / 4HACCE /,   SPCF  / 4HSPCF /,   SACC  / 4HSACC /,
     3        OLOA  / 4HOLOA /,   LOAD  / 4HLOAD /,   STRE  / 4HSTRE /,
     4        NONL  / 4HNONL /,   SUBC  / 4HSUBC /,   FORC  / 4HFORC /,
     5        SDIS  / 4HSDIS /,   ELFO  / 4HELFO /,   XTIT  / 4HXTIT /,
     6        YTIT  / 4HYTIT /,   YTTI  / 4HYTTI /,   TCUR  / 4HTCUR /,
     7        YBTI  / 4HYBTI /,   XYPE  / 4HXYPE /,   VECT  / 4HVECT /,
     8        PLT1  / 4HPLT1 /,   PLT2  / 4HPLT2 /,   EOR   /  1     /,
     9        XYPA  / 4HXYPA /,   XYCM  / .FALSE./,   NOEOR /  0     /
      DATA    IDEN  / 4HDENS /,   IEQUAL/ 4H=    /,   OPAREN/ 4H(    /,
     1        FILE  / 4HXYCD /,   VG    / 2HVG   /,   IMODEL/ 4HMODE /,
     2        REAL  / -2     /,   INTE  / -1     /,   CONT  / 0      /,
     3        G     / 1HG    /,   F     / 1HF    /
C
      BITWRD = LBD + 1
      N = 1
      IF (INTR.LE.1 .AND. ILINK.EQ.ILNK) GO TO 5
      INCARD(1) = XYCARD(1)
      CALL XRCARD (BUFF,149,XYCARD)
      BUFF(150) = RSHIFT(COMPLF(0),1)
      A377 = BUFF(150)
      FILE = 301
    5 CONTINUE
      IF (CARD) 710,20,10
C
C     FIRST CALL AND FIRST CARD IMAGE.
C
   10 IAT    = 0
      CARD   = 0
      PLOTS  = 0
      PLOTER = 0
      SDRBIT = 0
      VDRBIT = 0
      BINPLT = 0
      CONTIN = .FALSE.
      A777   = COMPLF(0)
      ICORE  = KORSZ(Z) - 2*SYSBUF - NWPC - 1
C
C     RETURNING WITH ANOTHER CARD IMAGE
C
   20 IF (BUFF(N) .EQ. A377) RETURN
C
      IF (.NOT.CONTIN) GO TO 30
      CONTIN = .FALSE.
      GO TO ICONT, (370,410,430,460,520,540,570,680,640)
C
C     BEGIN PROCESSING NON-CONTINUATION CARD (MUST BEGIN WITH BCD FIELD)
C
   30 IWRD = INCARD(1)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD.EQ.XTIT .OR. IWRD.EQ.YTIT .OR. IWRD.EQ.YTTI .OR.
     1    IWRD.EQ.YBTI .OR. IWRD.EQ.TCUR) GO TO 70
      IF (BUFF(N) .EQ. 0) RETURN
C
      IF (BUFF(N) .LT. 0) GO TO 730
      BCD = BUFF(N+1)
      IF (BIT64) CALL MVBITS (BLANK,0,32,BCD,0)
      DO 40 I = 1,NRWORD
      IF (BCD .EQ. RWORD(I)) GO TO 120
   40 CONTINUE
C
      DO 50 I = 1,NIWORD
      IF (BCD .EQ. IWORD(I)) GO TO 80
   50 CONTINUE
C
      DO 60 I = 1,NBWORD
      IF (BCD .EQ. BWORD(I)) GO TO 130
   60 CONTINUE
C
      IF (BCD.EQ.CLEA .OR. BCD.EQ.VDUM) GO TO 110
      IF (BCD.EQ.XYPE .OR. BCD.EQ.XYPL .OR. BCD.EQ.XYPR .OR.
     1    BCD.EQ.XYPU .OR. BCD.EQ.XYPA) GO TO 140
      GO TO 750
C
C     TITLE CARD
C
   70 CALL WRITE (FILE,INCARD(1),1,NOEOR)
      CALL WRITE (FILE,BUFF(1),32,NOEOR )
      RETURN
C
C     VERB FOLLOWED BY AN INTEGER VALUE
C     ON CAMERA CARD BCD ALSO ACCEPTED
C
   80 N = N + 2*BUFF(N) + 1
      IF (I.EQ.22 .AND. BUFF(N).NE.INTE) GO TO 81
      IF (BUFF(N) .NE. INTE) GO TO 770
      IF (I .EQ. 26) GO TO 95
      IF (BUFF(N+1).GE.0 .AND. I.LE.8) GO TO 90
      IF (I .LE. 8) GO TO 770
      IF (BUFF(N+1).EQ.0 .OR. I.GT.19) GO TO 90
      BUFF(N+1) = BUFF(N+1)/IABS(BUFF(N+1))
   90 BUF(1) = BCD
      BUF(2) = BUFF(N+1)
  100 CALL WRITE (FILE,BUF(1),2,NOEOR)
      RETURN
C
   95 BUF(1) = BCD
      BUF(2) = BUFF(N+1)
      BUF(3) = BUFF(N+3)
      CALL WRITE (FILE,BUF(1),3,NOEOR)
      RETURN
C
  110 CALL WRITE (FILE,BCD,1,NOEOR)
      RETURN
C
   81 IWRD = BUFF(N-2)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      DO 85 I = 1,3
      IF (IWRD .NE. KWORD(I)) GO TO 85
      BUFF(N+1) = I
      GO TO 90
   85 CONTINUE
      GO TO 770
C
C     VERB FOLLOWED BY A REAL VALUE
C
  120 N = N + 2*BUFF(N) + 1
      IF (BUFF(N) .NE. REAL) GO TO 770
      GO TO 90
C
C     VERB FOLLOWED BY BCD YES OR NO, UNLESS BCD = PLOT...
C
  130 IF (I .EQ. 13) GO TO 138
      N = N + 2*BUFF(N) - 2
      J = N
C
C     SEARCH FOR EQUAL SIGN
C
  132 IWRD = BUFF(N)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .EQ. IEQUAL) GO TO 133
      N = N - 2
      IF (N .GT. 0) GO TO 132
      N = J
  133 CONTINUE
      I = -1
  134 IWRD = BUFF(N+1)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .EQ. YES) I = 1
      IF (IWRD .EQ. NO ) I = 0
      IF (I .LT. 0) GO TO 135
      BUF(1) = BCD
      BUF(2) = I
      GO TO 100
  135 IF (I .LT. -3) GO TO 136
      I = I - 1
      N = N + 1
      GO TO 134
  136 N = J
      GO TO 750
C
C     PLOTTER SPECIFICATION CARD LOGIC
C
  138 IF (BUFF(N+3) .EQ. A777) N = N + 2
      N    = N + 2
      NMOD = N + 3
      IWRD = BUFF(NMOD)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .EQ. IMODEL) NMOD = NMOD + 2
      IF (IWRD .EQ.   IDEN) GO TO 147
      MODID(1) = 0
      MODID(2) = 0
      IF (BUFF(NMOD) .EQ. A377) GO TO 147
      IF (BUFF(NMOD) .EQ.   -1) MODID(1) = BUFF(NMOD+1)
      IF (BUFF(NMOD) .NE.   -1) MODID(1) = BUFF(NMOD  )
      NMOD = NMOD + 2
      IF (BUFF(NMOD) .EQ.    1) NMOD = NMOD + 1
      IWRD = BUFF(NMOD)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD       .EQ. IDEN) GO TO 147
      IF (BUFF(NMOD) .EQ. A377) GO TO 147
      IF (BUFF(NMOD) .EQ.   -1) MODID(2) = BUFF(NMOD+1)
      IF (BUFF(NMOD) .NE.   -1) MODID(2) = BUFF(NMOD  )
  147 CALL FNDPLT (PLOTER,MODEL,MODID(1))
      BUF(1) = BCD
      BUF(2) = ORF(LSHIFT(PLOTER,IHALF),MODEL+100)
      BINPLT = BINPLT + 1
      GO TO 100
C
C     PRINT, PLOT, OR PUNCH COMMAND CARD
C
  140 XTYPE = 0
      TYPE  = 0
      XVECT = 0
      VECTOR= 0
      PRINT = 0
      PLOT  = 0
      PUNCH = 0
      PAPLOT= 0
      SLASH = .FALSE.
      N1    = 2
      N2    = 2*BUFF(N) + N
C
C     PROCESS ALL WORDS
C
      DO 360 I = N1,N2,2
      BCD = BUFF(I)
      IF (BCD .EQ. A777) GO TO 350
      IF (BIT64) CALL MVBITS (BLANK,0,32,BCD,0)
      IF (BCD .EQ. XYPL) GO TO 150
      IF (BCD .EQ. XYPR) GO TO 160
      IF (BCD .EQ. XYPU) GO TO 170
      IF (BCD .EQ. XYPE) GO TO 359
      IF (BCD .EQ. XYPA) GO TO 175
      IF (BCD .EQ. RESP) GO TO 180
      IF (BCD .EQ. AUTO) GO TO 190
      IF (BCD .EQ. PSDF) GO TO 200
      IF (BCD .EQ. SUBC) GO TO 220
      IF (BCD .EQ. DISP) GO TO 230
      IF (BCD .EQ. VECT) GO TO 230
      IF (BCD .EQ. VELO) GO TO 240
      IF (BCD .EQ. ACCE) GO TO 250
      IF (BCD .EQ. SPCF) GO TO 260
      IF (BCD .EQ. LOAD) GO TO 270
      IF (BCD .EQ. STRE) GO TO 280
      IF (BCD .EQ. FORC) GO TO 290
      IF (BCD .EQ. SDIS) GO TO 300
      IF (BCD .EQ. SVEL) GO TO 310
      IF (BCD .EQ. SACC) GO TO 320
      IF (BCD .EQ. NONL) GO TO 330
      IF (BCD .EQ. ELFO) GO TO 290
      IF (BCD .EQ. ELST) GO TO 280
      IF (BCD .EQ. OLOA) GO TO 270
      IF (BCD .EQ. VG  ) GO TO 270
      N = I - 1
      GO TO 750
  150 PLOT  = 2
      PLOTS = 1
      IF (PLOTER .NE. 0) GO TO 359
      PLOTER = 1
      MODEL  =-1
      BUF(1) = BWORD(13)
      BUF(2) = ORF(LSHIFT(PLOTER,IHALF),MODEL+100)
      BINPLT = BINPLT + 1
      CALL WRITE (FILE,BUF(1),2,NOEOR)
      GO TO 359
  160 PRINT = 1
      GO TO 359
  170 PUNCH = 4
      GO TO 359
  175 PAPLOT = 1
      GO TO 359
  180 TYPE = 1
      GO TO 210
  190 TYPE = 3
      GO TO 210
  200 TYPE = 2
      GO TO 210
  210 IF (XTYPE .NE. 0) GO TO 790
      XTYPE = 1
  220 GO TO 360
  230 VECTOR = 1
      GO TO 291
  240 VECTOR = 2
      GO TO 291
  250 VECTOR = 3
      GO TO 291
  260 VECTOR = 4
      GO TO 291
  270 VECTOR = 5
      GO TO 291
  280 VECTOR = 6
      GO TO 291
  290 VECTOR = 7
  291 SDRBIT = 16
      GO TO 340
  300 VECTOR = 8
      GO TO 331
  310 VECTOR = 9
      GO TO 331
  320 VECTOR = 10
      GO TO 331
  330 VECTOR = 11
  331 VDRBIT = 2
      GO TO 340
  340 IF (XVECT .NE. 0) GO TO 790
      XVECT = 1
      GO TO 360
C
C     DELIMETER HIT OF SOME KIND. IGNORE IF NOT LAST WORD OF BCD GROUP.
C
  350 IF (I .NE. N2-1) GO TO 360
      IWRD = BUFF(I+1)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .EQ. SLAS) SLASH = .TRUE.
      IF (.NOT.SLASH) GO TO 810
      GO TO 360
  359 XYCM = .TRUE.
  360 CONTINUE
C
C     WRITE PLOT CONTROL INFORMATION
C
      BUF(1) = XY
      BUF(2) = PRINT
      BUF(3) = PLOT
      BUF(4) = PUNCH
      IF (PAPLOT .EQ. 1) PLOT = 2
      DESTIN = PRINT + PLOT + PUNCH
      IF (TYPE .EQ. 0) TYPE = 1
      BUF(5) = TYPE
      IF (VECTOR .EQ. 0) GO TO 1030
      BUF(6) = VECTOR
      BUF(7) = PAPLOT
      CALL WRITE (FILE,BUF(1),7,NOEOR)
C
C     ALL WORDS PROCESSED. IF SLASH HAS NOT BEEN HIT, START READING
C     SUBCASE NUMBERS.
C
      NSUBS = 0
      N = N2 + 1
      IF (SLASH) GO TO 490
C
C     FORM LIST OF SUBCASES, MAXIMUM OF 200 FOR THIS COMMAND CARD.
C
  370 IF (BUFF(N) .NE. CONT) GO TO 380
      ASSIGN 370 TO ICONT
      GO TO 700
C
  380 SUBCAS(1) = 0
      IF (BUFF(N) .NE. INTE) GO TO 830
C
C     SUBCASES ARE NOT APPLICABLE IN AUTO AND PSDF
C
      IF (TYPE .NE. 1) GO TO 850
C
  390 NSUBS = NSUBS + 1
      IF (NSUBS   .GT. 200) GO TO 890
      IF (BUFF(N+1) .LE. 0) GO TO 910
      SUBCAS(NSUBS) = BUFF(N+1)
  400 N = N + 2
  410 IF (BUFF(N) .EQ. A377) GO TO 1080
      IF (BUFF(N) .NE. CONT) GO TO 420
      ASSIGN 410 TO ICONT
      GO TO 700
C
  420 IF (BUFF(N) .NE. INTE) GO TO 430
      IF (SUBCAS(NSUBS)-BUFF(N+1)) 390,400,910
  430 IF (BUFF(N) .NE. CONT) GO TO 440
      ASSIGN 430 TO ICONT
      GO TO 700
C
  440 IF (BUFF(N) .LT. 0) GO TO 830
      IWRD = BUFF(N+2)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .NE. SLAS) GO TO 450
      SLASH = .TRUE.
      N = N + 3
      GO TO 490
C
  450 IF (IWRD .NE. THRU) GO TO 830
      N = N + 3
  460 IF (BUFF(N) .NE. CONT) GO TO 470
      ASSIGN 460 TO ICONT
      GO TO 700
C
  470 IF (BUFF(N  ) .NE.         INTE ) GO TO 830
      IF (BUFF(N+1) .LT. SUBCAS(NSUBS)) GO TO 910
      IF (BUFF(N+1) .EQ. SUBCAS(NSUBS)) GO TO 400
  480 NSUBS = NSUBS + 1
      IF (NSUBS .GT. 200) GO TO 890
      SUBCAS(NSUBS) = SUBCAS(NSUBS-1) + 1
      IF (SUBCAS(NSUBS) .LT. BUFF(N+1)) GO TO 480
      GO TO 400
C
C     SLASH HIT. BEGIN PROCESSING FRAME DATA. FIRST WRITE SUBCASE
C     NUMBERS.
C
  490 CALL WRITE (FILE,NSUBS,1,NOEOR)
      IF (NSUBS .NE. 0) CALL WRITE (FILE,SUBCAS(1),NSUBS,NOEOR)
      IF (NSUBS .EQ. 0) SUBCAS(1) = 0
      IF (NSUBS .EQ. 0) NSUBS = 1
  500 SLASH  = .FALSE.
      CALL WRITE (FILE,FRAM,1,NOEOR)
      PAIRS  = .FALSE.
      NCURVE = 0
  520 IF (BUFF(N) .NE. CONT) GO TO 530
      ASSIGN 520 TO ICONT
      GO TO 700
C
  530 IF (BUFF(N) .NE. INTE) GO TO 830
      BUF(1) = BUFF(N+1)
      BUF(2) = 0
      BUF(3) = 0
      IDCOM  = 0
      NCURVE = NCURVE + 1
      IF (BUF(1) .LE. 0) GO TO 930
C
C     GET COMPONENT. POSITIVE INTEGER.
C     MAY BE T1,T2,T3,R1,R2,R3 ETC. IF THE VECTOR IS NOT STRESS OR FORCE
C
      N = N + 2
  540 IF (BUFF(N) .NE. CONT) GO TO 550
      ASSIGN 540 TO ICONT
      GO TO 700
C
  550 IWRD = BUFF(N+2)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (BUFF(N).GT.0 .AND. IWRD.EQ.OPAREN) GO TO 560
      GO TO 830
C
  560 OFBCD = .FALSE.
      IF (BUFF(N) .GT. 1) GO TO 590
C
C     FALL HERE AND A POSITIVE INTEGER COMPONENT IS EXPECTED.
C
      N = N + 3
  570 IF (BUFF(N) .NE. CONT) GO TO 580
      ASSIGN 570 TO ICONT
      GO TO 700
C
  580 IF (BUFF(N  ) .NE. INTE) GO TO 830
      IF (BUFF(N+1) .LE.    0) GO TO 950
      OFBCD  =.FALSE.
      COMPON = BUFF(N+1)
      N = N + 2
      GO TO 620
C
C     FALL HERE AND A BCD COMPONENT IS EXPECTED. T1,T2,T3,R1,R2,R3
C
  590 N1  = N + 3
  600 N   = N + 2*BUFF(N) + 1
  610 BCD = BUFF(N1)
      IF (BIT64) CALL MVBITS (BLANK,0,32,BCD,0)
      IF (BCD .EQ. BLANK) GO TO 615
      IF (VECTOR .EQ.6 .OR. VECTOR.EQ.7) GO TO 970
 615  OFBCD  = .TRUE.
      COMPON = 3
      IF (BCD.EQ.T1 .OR. BCD.EQ.T1RM) GO TO 620
      IF (BCD .EQ. G) GO TO 620
      COMPON = 4
      IF (BCD.EQ.T2 .OR. BCD.EQ.T2RM) GO TO 620
      IF (BCD .EQ. F) GO TO 620
      COMPON = 5
      IF (BCD.EQ.T3 .OR. BCD.EQ.T3RM) GO TO 620
      COMPON = 6
      IF (BCD.EQ.R1 .OR. BCD.EQ.R1RM) GO TO 620
      COMPON = 7
      IF (BCD.EQ.R2 .OR. BCD.EQ.R2RM) GO TO 620
      COMPON = 8
      IF (BCD.EQ.R3 .OR. BCD.EQ.R3RM) GO TO 620
      COMPON = 9
      IF (BCD .EQ. T1IP) GO TO 620
      COMPON = 10
      IF (BCD .EQ. T2IP) GO TO 620
      COMPON = 11
      IF (BCD .EQ. T3IP) GO TO 620
      COMPON = 12
      IF (BCD .EQ. R1IP) GO TO 620
      COMPON = 13
      IF (BCD .EQ. R2IP) GO TO 620
      COMPON = 14
      IF (BCD .EQ. R3IP) GO TO 620
      COMPON = 1000
      IF (BCD .EQ. BLANK) GO TO 620
      GO TO 990
C
  620 IDCOM = IDCOM + 1
      BUF(IDCOM+1) = COMPON
C
C     CHECK RANGE OF COMPONENT
C
      IF (COMPON .EQ. 1000) GO TO 631
      IF ((TYPE.EQ.2 .OR. TYPE.EQ.3) .AND. (COMPON.LT.3 .OR.COMPON.GT.8)
     1   .AND. (VECTOR.NE.6 .AND. VECTOR.NE.7)) GO TO 1130
      IF ((COMPON.LT.3 .OR. COMPON.GT.14) .AND.
     1   (VECTOR.NE.6 .AND. VECTOR.NE.7)) GO TO 1150
      IF (NOGO .NE. 0) GO TO 631
C
C     ADD THIS COMPONENT-ID TO XY-MASTER SET IN OPEN CORE.
C
      DO 630 I = 1,NSUBS
      IF (IAT+6 .GT. ICORE) GO TO 1090
      Z(IAT+1) = SUBCAS(I)
      Z(IAT+2) = VECTOR
      Z(IAT+3) = BUF(1)
      Z(IAT+4) = COMPON
      Z(IAT+5) = TYPE
      Z(IAT+6) = DESTIN
  630 IAT = IAT + 6
C
C     PROCEED TO NEXT COMPONENT OR ID OF THIS FRAME
C
  631 IF (NCURVE.EQ.1 .AND. IDCOM.EQ.2) PAIRS = .TRUE.
      IF (PAIRS .AND. (TYPE.EQ.2 .OR. TYPE.EQ.3)) GO TO 1110
      IF (.NOT.PAIRS .AND. IDCOM.EQ.2) GO TO 1050
      IF (IDCOM .GT. 2) GO TO 1050
      IF (.NOT.OFBCD  ) GO TO 640
      IF (N1 .GE.  N-2) GO TO 640
      N1   = N1 + 2
      IWRD = BUFF(N1+1)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .NE. SLAS) GO TO 610
      SLASH = .TRUE.
      GO TO 670
C
C     IS NEXT FIELD AN INTEGER FOLLOWED BY AN OPAREN
C
  640 IF (BUFF(N) .NE. CONT) GO TO 650
      ASSIGN 640 TO ICONT
      GO TO 700
C
  650 IF (BUFF(N  ) .NE. INTE) GO TO 660
      IF (BUFF(N+2) .EQ. A377) GO TO 580
      IWRD = BUFF(N+4)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .EQ. OPAREN) GO TO 670
      GO TO 580
  660 IF (BUFF(N) .EQ. A377) GO TO 670
      IWRD = BUFF(N+2)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (BUFF(N).LE.0 .OR. IWRD.EQ.SLAS) GO TO 670
      N1 = N + 1
      GO TO 600
  670 IF (PAIRS .AND. IDCOM.EQ.1) GO TO 1050
      CALL WRITE (FILE,BUF(1),3,NOEOR)
      IF (.NOT.SLASH .AND. BUFF(N).EQ.INTE) GO TO 520
      BUF(1) = -1
      BUF(2) = -1
      BUF(3) = -1
      CALL WRITE (FILE,BUF(1),3,NOEOR)
      IF (BUFF(N) .EQ. A377) RETURN
C
  680 IF (BUFF(N) .NE. CONT) GO TO 690
      ASSIGN 680 TO ICONT
      GO TO 700
  690 IF (SLASH) GO TO 500
      IWRD = BUFF(N+2)
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)
      IF (IWRD .NE. SLAS) GO TO 830
      N = N + 2*BUFF(N) + 1
      GO TO 500
C
C     RETURN FOR A CONTINUATION CARD
C
  700 CONTIN = .TRUE.
      RETURN
C
C     NO MORE CARDS AVAILABLE. RAP IT UP IF NO ERROR. WRITE XY-SET
C     RECORD
C
  710 IF (CONTIN) GO TO 1010
      CALL WRITE (FILE,Z(1),0,EOR)
      IF (IAT .EQ. 0) GO TO 720
      J = 7
      DO 715 I = 1,6
      J = J - 1
      CALL SORT (0,0,6,-J,Z(1),IAT)
  715 CONTINUE
  720 CALL WRITE (FILE,Z(1),IAT,EOR)
C
C     SET CARD = 0 IF NO PLOTS
C     SET CARD = 1 IF PLOTS
C
      CARD = PLOTS
C
C     SET RESTART BITS FOR VDR AND SDR
C
      IF (IRESRT .LT. 0) BITS(BITWRD) = ORF(BITS(BITWRD),VDRBIT+SDRBIT)
C
C     CHECK FOR COMMAND OP CARD
C
      IF (.NOT.XYCM) GO TO 1170
C
C     CHECK PLOT TAPE BITS
C
      IF (PLOTS .EQ. 0) RETURN
C
C     CHECK FOR TAPE SETUPS
C
      IF (BINPLT.NE.0 .AND. .NOT.TAPBIT(PLT1) .AND. .NOT.TAPBIT(PLT2))
     1   CALL IFP1D (-618)
      RETURN
C
C     FATAL ERROR CONDITIONS
C
  730 J = 675
      WRITE  (L,740) UFM,J
  740 FORMAT (A23,I4,', ABOVE CARD DOES NOT BEGIN WITH A NON-NUMERIC ',
     1        'WORD.')
      GO TO 2000
  750 J = 676
      WRITE  (L,760) UFM,J,BUFF(N+1),BUFF(N+2)
  760 FORMAT (A23,I4,1H,,2A4,' IS NOT RECOGNIZED AS AN XYPLOT COMMAND ',
     1        'CARD OR PARAMETER.')
      GO TO 2000
  770 J = 677
      WRITE  (L,780) UFM,J
  780 FORMAT (A23,I4,', ILLEGAL VALUE SPECIFIED.')
      GO TO 2000
  790 J = 678
      WRITE  (L,800) UFM,J,BUFF(I),BUFF(I+1)
  800 FORMAT (A23,I4,1H,,2A4,' CONTRADICTS PREVIOUS DEFINITION.')
      GO TO 2000
  810 J = 679
      WRITE  (L,820) UFM,J,BUFF(I+1)
  820 FORMAT (A23,I4,1H,,A4,' DELIMITER ILLEGALLY USED.')
      GO TO 2000
  830 IF (BUFF(N) .EQ. REAL) GO TO 850
      IF (BUFF(N) .EQ. INTE) GO TO 870
      J = 680
      WRITE  (L,840) UFM,J,BUFF(N+1),BUFF(N+2)
  840 FORMAT (A23,I4,1H,,2A4,' IS ILLEGAL IN STATEMENT.')
      GO TO 2000
  850 J = 681
      WRITE  (L,860) UFM,J,BUFF(N+1)
  860 FORMAT (A23,I4,1H,,E16.8,' IS ILLEGAL IN STATEMENT.')
      GO TO 2000
  870 J = 682
      WRITE  (L,880) UFM,J,BUFF(N+1)
  880 FORMAT (A23,I4,1H,,I10,' IS ILLEGAL IN STATEMENT.')
      GO TO 2000
  890 J = 683
      WRITE  (L,900) UFM,J
  900 FORMAT (A23,I4,', TOO MANY SUBCASES. MAXIMUM = 200 ON ANY ONE XY',
     1       '-OUTPUT COMMAND CARD.')
      GO TO 2000
  910 J = 684
      WRITE  (L,920) UFM,J
  920 FORMAT (A23,I4,', SUBCASE-ID IS LESS THAN 1 OR IS NOT IN ',
     1        'ASCENDING ORDER.')
      GO TO 2000
  930 J = 685
      WRITE  (L,940) UFM,J,BUF(1)
  940 FORMAT (A23,I4,1H,,I12,' = POINT OR ELEMENT ID IS ILLEGAL (LESS ',
     1        'THAN 1).')
      GO TO 2000
  950 J = 686
      WRITE  (L,960) UFM,J
  960 FORMAT (A23,I4,', NEGATIVE OR ZERO COMPONENTS ARE ILLEGAL.')
      GO TO 2000
  970 J = 687
      WRITE  (L,980) UFM,J
  980 FORMAT (A23,I4,', ALPHA-COMPONENTS ARE NOT PERMITTED FOR STRESS ',
     1        'OR FORCE XY-OUTPUT REQUESTS.')
      GO TO 2000
  990 J = 688
      WRITE  (L,1000) UFM,J,BCD
 1000 FORMAT (A23,I4,1H,,A4,' COMPONENT NAME NOT RECOGNIZED.')
      GO TO 2000
 1010 J = 689
      WRITE  (L,1020) UFM,J
 1020 FORMAT (A23,I4,', LAST CARD ENDED WITH A DELIMITER BUT NO ',
     1       'CONTINUATION CARD WAS PRESENT.')
      GO TO 2000
 1030 J = 690
      WRITE  (L,1040) UFM,J
 1040 FORMAT (A23,I4,', TYPE OF CURVE WAS NOT SPECIFIED. (E.G. ',
     1        'DISPLACEMENT, STRESS, ETC.).')
      GO TO 2000
 1050 J = 691
      WRITE  (L,1060) UFM,J
 1060 FORMAT (A23,I4,', MORE THAN 2 OR UNEQUAL NUMBER OF COMPONENTS ',
     1        'FOR ID-S WITHIN A SINGLE FRAME.')
      GO TO 2000
 1070 FORMAT (A23,I4,', XY-OUTPUT COMMAND IS INCOMPLETE.')
 1080 J = 692
      WRITE  (L,1070) UFM,J
      GO TO 2000
 1090 J = 693
      WRITE  (L,1100) UFM,J
 1100 FORMAT (A23,I4,', INSUFFICIENT CORE FOR SET TABLE.')
      ICRQ = (NSUBS-I+1) * 6
      WRITE  (L,1101) ICRQ
 1101 FORMAT (5X,8HAT LEAST,I8,19H MORE WORDS NEEDED.)
      GO TO 2000
 1110 J = 694
      WRITE  (L,1120) UFM,J
 1120 FORMAT (A23,I4,', AUTO OR PSDF REQUESTS MAY NOT USE SPLIT FRAME',
     1       ', THUS ONLY ONE COMPONENT PER ID IS PERMITTED.')
      GO TO 2000
 1130 J = 695
      WRITE  (L,1140) UFM,J,COMPON
 1140 FORMAT (A23,I4,', COMPONENT VALUE =',I8,', IS ILLEGAL FOR AUTO ',
     1        'OR PSDF VECTOR REQUESTS.')
      GO TO 2000
 1150 J = 696
      WRITE  (L,1160) UFM,J,COMPON
 1160 FORMAT (A23,I4,', COMPONENT VALUE =',I8,', IS ILLEGAL FOR VECTOR',
     1       ' TYPE SPECIFIED.')
      GO TO 2000
 1170 J = 697
      WRITE  (L,1180) UFM,J
 1180 FORMAT (A23,I4,', XYPLOT, XYPRINT, XYPUNCH, XYPEAK, OR XYPAPLOT',
     1    /5X,' COMMAND CARD NOT FOUND IN XY PLOTTER OUT PUT PACKAGE.')
      GO TO 2000
 2000 NOGO = 1
      LINE = LINE + 2
      IF (LINE .GE. NLPP) CALL PAGE
      RETURN
      END
