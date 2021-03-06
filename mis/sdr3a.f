      SUBROUTINE SDR3A (OFPFIL)
C
C     SORT-2  MODULE
C
      INTEGER         INAME(2),TRAIL(7),ID(146),IDTEMP(146),VECTOR(50),
     1                SCRTCH(8),OFILE(6),IFILE(6),BUFF(10),OFPFIL(6),Z,
     2                WORDS,EOF,CORE,BUFF9,BUFF10,GROUP,OUFILE,FILE,RECS
     3,               RECPT,EOR,OUTRWD,RWD,FULL,OVRLAP,V IN BK,W PER BK,
     4                V PER BK,TOTAL1,TOTAL2,AHEAD,ENTRYS(85)
      CHARACTER       UFM*23,UWM*25
      COMMON /XMSSG / UFM,UWM
      COMMON /SYSTEM/ IBUFSZ, L
      COMMON /ZZZZZZ/ Z(1)
      EQUIVALENCE     (NWDS,ID(10))
C
C     IF THE NUMBER OF SCRATCH FILES CHANGE, ONE SHOULD SET NSCRAT EQUAL
C     TO THE NEW NUMBER AND INCREASE THE DATA BELOW
C
C     NFILES BELOW EQUALS THE NUMBER OF INPUT FILES AND ALSO EQUALS
C     THE NUMBER OF OUTPUT FILES.  IF NFILES CHANGES, CHANGE THE DATA
C     BELOW TO CONFORM...
C     ALSO CHANGE DIMENSIONS OF BUFF,IFILE,OFILE,SCRTCH, AS REQUIRED...
C
      DATA    IFILE / 101,102,103,104,105,106 /
      DATA    OFILE / 201,202,203,204,205,206 /
      DATA    SCRTCH/ 301,302,303,304,305,306,307,308 /
      DATA    TRAIL / 0,1,2,3,4,5,6 /
      DATA    EOR   , NOEOR,RWD,INPRWD,OUTRWD / 1,0,1,0,1 /
C
      NFILES = 6
      NSCRAT = 8
      DO 4 I = 1,6
    4 OFPFIL(I) = 0
      DO 5 I = 1,146
      IDTEMP(I) = 0
    5 CONTINUE
C
C     BUFFERS AND OPEN CORE
C
      CORE = KORSZ(Z)
C
      BUFF(1) = CORE - IBUFSZ + 1
      DO 10 I = 2,10
      BUFF(I) = BUFF(I-1) - IBUFSZ
   10 CONTINUE
      BUFF9  = BUFF( 9)
      BUFF10 = BUFF(10)
      CORE   = BUFF(10) - 1
      IF (CORE .LT. 1) GO TO 700
C
C     OPEN SCRATCH FILES FOR OUTPUT
C
      IERROR = 0
      DO 30 I = 1,NSCRAT
      IBUFF = BUFF(I)
      CALL OPEN (*20,SCRTCH(I),Z(IBUFF),OUTRWD)
      GO TO 30
   20 IERROR = 1
      WRITE  (L,21) UWM,I
   21 FORMAT (A25,' 985, SDR3 FINDS SCRATCH',I1,' PURGED.')
   30 CONTINUE
C
C     EXECUTE FOR NFILES FILES
C
      DO 460 FILE = 1,NFILES
      EOF = 0
      INFILE = IFILE(FILE)
      OUFILE = OFILE(FILE)
C
      CALL OPEN (*460,INFILE,Z(BUFF9),INPRWD)
      CALL OPEN (*480,OUFILE,Z(BUFF10),OUTRWD)
      CALL FWDREC (*520,INFILE)
C
C     HEADER RECORD FOR OUFILE
C
      CALL FNAME (OUFILE,INAME(1))
      CALL WRITE (OUFILE,INAME(1),2,EOR)
C
C     WRITE SOME JUNK IN TRAILER FOR NOW
C
      TRAIL(1) = OUFILE
      CALL WRTTRL (TRAIL(1))
      NO FRQ = 0
C
C     PROCEED WITH TRANSPOSE OF DATA = SORT-2
C
C     GROUP WILL BE THE NUMBER OF THE FIRST REC IN THE PRESENT GROUP OF
C     DATA BLOCKS BEING OPERATED ON, LESS 1
C
      NRECS = 1
C
   50 ASSIGN 120 TO IRETRN
C
   60 CALL READ (*80,*620,INFILE,ID(1),146,EOR,IAMT)
      IF (ID(1)/10 .EQ. 1) NOFRQ = 1
      IDATA = 1
C
   70 ICORE = CORE
      RECS  = 0
      GROUP = NRECS
C
C     READ FIRST DATA BLOCK INTO CORE
C
      CALL READ (*530,*90,INFILE,Z(1),ICORE,NOEOR,IAMT)
C
C     INSUFFICIENT CORE,  IF FALL HERE, TO DO SORT II ON THIS FILE..
C
      GO TO 670
   80 CALL CLOSE (INFILE,RWD)
      CALL CLOSE (OUFILE,RWD)
      GO TO 460
C
   90 IF (IAMT .EQ. 0) GO TO 441
      ENTRYS(1) = IAMT/NWDS
C
C     SET UP IN-CORE ENTRY BLOCKS
C     SPOT FOR TRANSPOSE HEADING DATA IS AT Z(ICORE-ENTRYS(1)+1)
C
      IHD2  = ICORE + 1
      ICORE = ICORE - ENTRYS(1)
      IHEAD = ICORE
      IF (ICORE .LT. IAMT) GO TO 680
C
C     NOTATION - W PER BK = WORDS PER ENTRY BLOCK
C                V PER BK = VECTORS PER ENTRY BLOCK
C                V IN  BK = VECTORS NOW IN ENTRY BLOCKS
C
      W PER BK = ICORE/ENTRYS(1)
      V PER BK = W PER BK/NWDS
      W PER BK = V PER BK*NWDS
      IF (V PER BK .LT. 1) GO TO 690
C
C     DISTRIBUTE FIRST DATA BLOCK TO INCORE ENTRY BLOCKS (BOTTOM TO TOP)
C
      NENTRY = ENTRYS(1)
      TOTAL1 = W PER BK*ENTRYS(1) + 1
      TOTAL2 = NWDS*ENTRYS(1) + 1
      DO 110 I = 1,NENTRY
      N1  = TOTAL1 - W PER BK*I
      N2  = TOTAL2 - NWDS    *I
      IHD = IHD2 - I
      Z(IHD) = Z(N2)
      Z(N1 ) = ID(5)
C
C     SAVE TRANSPOSE HEADING
C
      DO 100 J = 2,NWDS
      N1 = N1 + 1
      N2 = N2 + 1
      Z(N1) = Z(N2)
  100 CONTINUE
  110 CONTINUE
C
      V IN BK = 1
      GO TO IRETRN, (120,150)
C
  120 NTYPES = 1
  130 CALL READ (*159,*630,INFILE,IDTEMP(1),146,EOR,IAMT)
      IF ((ID(2).EQ.IDTEMP(2) .AND. ID(3).EQ.IDTEMP(3) .AND.
     1     ID(5).NE.IDTEMP(5)) .OR. (ID(5).NE.IDTEMP(5)) .OR.
     2    (ID(4).NE.IDTEMP(4))) GO TO 160
C
      NTYPES = NTYPES + 1
      NWORDS = IDTEMP(10)
C
C     WILL READ DATA AND COUNT ENTRYS
C
      IF (NTYPES .GT. 30) GO TO 472
      ENTRYS(NTYPES) = 0
  140 CALL READ (*540,*130,INFILE,IDTEMP(1),NWORDS,NOEOR,IAMT)
      ENTRYS(NTYPES) = ENTRYS(NTYPES) + 1
      GO TO 140
C
  150 AHEAD = 2*NTYPES - 2
      IF (NDATA .EQ. 1) GO TO 260
      GO TO 170
C
C     AT THIS POINT IT IS KNOWN HOW MANY TYPES ARE IN THE PRESENT GROUP
C     OF DATA BLOCKS AND ALSO HOW MANY ENTRYS IN EACH TYPE
C
  159 IF (NTYPES .EQ. 1) EOF = 1
  160 ITYPE = 1
      NDATA = 1
      IDATA = 1
C
C     POSITION TO READ 2-ND ID OF TYPE(ITYPE) IF NOT JUST READ
C
      IF (NTYPES .EQ. 1) GO TO 200
      CALL REWIND (INFILE)
      AHEAD = GROUP + 2*NTYPES
  170 DO 180 I = 1,AHEAD
      CALL FWDREC (*550,INFILE)
  180 CONTINUE
C
  190 CALL READ (*260,*640,INFILE,IDTEMP(1),146,EOR,IAMT)
C
C     CHECK FOR BREAK POINT
C
  200 IF (NOFRQ .EQ. 1) GO TO 201
      IF (ID(4) .NE. IDTEMP(4)) GO TO 270
  201 CONTINUE
      IF (EOF .EQ. 1) GO TO 270
      IF (ITYPE .EQ. 1) NDATA = NDATA + 1
      IDATA  = IDATA + 1
      NENTRY = ENTRYS(ITYPE)
C
C     CHECK TO SEE IF THERE IS ENOUGH ROOM IN EACH OF THE INCORE
C     ENTRY BLOCKS FOR ANOTHER VECTOR
C     IF NOT DO SCRATCH FILE  OPERATIONS
C
      IF (V IN BK .LT. V PER BK) GO TO 220
C
C     NOT ENOUGH ROOM THUS DUMP CORE ENTRY BLOCKS ONTO SCRATCH FILES
C
      IF (IERROR .EQ. 1) GO TO 451
      NPOINT = 1
      NFILE  = NSCRAT
      DO 210 I = 1,NENTRY
      NFILE  = NFILE + 1
      IF (NFILE .GT. NSCRAT) NFILE = 1
      CALL WRITE (SCRTCH(NFILE),Z(NPOINT),W PER BK,EOR)
      NPOINT = NPOINT + W PER BK
  210 CONTINUE
      RECS = RECS + NENTRY
C
C     IN CORE ENTRY BLOCKS ARE NOW EMPTY
C
      V IN BK = 0
C
C     DISTRIBUTE DATA TO INCORE ENTRY BLOCKS
C
  220 NPOINT = V IN BK*NWDS + 1
      DO 230 I = 1,NENTRY
      IEOR = I/NENTRY
      CALL READ (*560,*650,INFILE,Z(NPOINT),NWDS,IEOR,IAMT)
      Z(NPOINT) = IDTEMP(5)
      NPOINT = NPOINT + W PER BK
  230 CONTINUE
      V IN BK = V IN BK + 1
C
      IF (NTYPES .EQ. 1) GO TO 190
      IF (ITYPE  .EQ. 1) GO TO 240
      IF (IDATA .EQ. NDATA) GO TO 270
C
C     NOW POSITION AHEAD TO READ NEXT ID FOR TYPE(ITYPE)
C
  240 AHEAD = 2*NTYPES - 2
      DO 250 I = 1,AHEAD
      CALL FWDREC (*570,INFILE)
  250 CONTINUE
      GO TO 190
C
C     ONE DATA TYPE IN THIS GROUP IS COMPLETE
C
C     OUTPUT IS IN CORE, AND ON SCRATCH FILES IF RECS IS NOT 0
C
C     NOW DUMP SCRATCHES AND (OR JUST) CORE ONTO FINAL OUTPUT TAPE
C
C     ID WILL BE WRITTEN BEFORE EACH ENTRY INSERTING INTO IT THE NEW
C     HEADER VALUE REPLACING FREQUENCY OR TIME ETC
C
  260 EOF = 1
  270 IF (RECS .EQ. 0) GO TO 290
C
      LAYERS = RECS/NENTRY
C
C     CLOSE SCRATCH FILES AND OPEN AS INPUT FILES
C
      DO 280 I = 1,NSCRAT
      CALL CLOSE (SCRTCH(I),RWD)
      IBUFF = BUFF(I)
      CALL OPEN (*500,SCRTCH(I),Z(IBUFF),INPRWD)
  280 CONTINUE
C
C     COMPUTE OVERLAPS PER LAYER
C
      OVRLAP = (NENTRY-1)/NSCRAT
C
C     COMPUTE HOW MANY TAPES HAVE ALL THE OVERLAPS
C
      FULL = NENTRY - OVRLAP*NSCRAT
C
C
C     WRITE FINAL FILE THEN
C
  290 NFILE = 0
      ID(2) = ID(2) + 2000
      DO 400 I = 1,NENTRY
      NFILE = NFILE + 1
      IF (NFILE .GT. NSCRAT) NFILE = 1
C
      NPOINT = IHEAD + I
      ID(5)  = Z(NPOINT)
      CALL WRITE (OUFILE,ID(1),146,EOR)
C
C     ANYTHING ON SCRATCH FILES IS NOW WRITTEN
C
      IF (RECS .EQ. 0) GO TO 390
C
      DO 380 J = 1,LAYERS
C
C     FORWARD REC IF NECESSARY
C
      IF (J .GT. 1) GO TO 320
C
C     AHEAD TO FIRST PART IF NECESSARY
C
      IF (LAYERS .EQ. 1) GO TO 350
      AHEAD = (I-1)/NSCRAT
C
      IF (AHEAD) 300,350,300
  300 DO 310 K = 1,AHEAD
      CALL FWDREC (*590,SCRTCH(NFILE))
  310 CONTINUE
      GO TO 350
C
  320 RECPT = OVRLAP
      IF (NFILE .GT. FULL) RECPT = RECPT - 1
      IF (RECPT) 350,350,330
  330 DO 340 K = 1,RECPT
      CALL FWDREC (*600,SCRTCH(NFILE))
  340 CONTINUE
C
C     COPY RECORD FROM SCRTCH TO OUTFILE
C
  350 DO 370 K = 1,VPERBK
      IEOR = K/V PER BK
      CALL READ (*610,*660,SCRTCH(NFILE),VECTOR(1),NWDS,IEOR,IAMT)
      CALL WRITE (OUFILE,VECTOR(1),NWDS,NOEOR)
  370 CONTINUE
  380 CONTINUE
      IF (LAYERS .GT. 1) CALL REWIND (SCRTCH(NFILE))
C
C     COPY INCORE VECTORS TO OUTFILE
C
  390 WORDS  = V IN BK*NWDS
      NPOINT = W PER BK*I - W PER BK + 1
      CALL WRITE (OUFILE,Z(NPOINT),WORDS,EOR)
  400 CONTINUE
      IF (RECS .EQ. 0) GO TO 420
C
C     CLOSE SCRTCH FILES AND OPEN AS OUTPUT FILES
C
      DO 410 I = 1,NSCRAT
      CALL CLOSE (SCRTCH(I),RWD)
      IBUFF = BUFF(I)
      CALL OPEN (*490,SCRTCH(I),Z(IBUFF),OUTRWD)
  410 CONTINUE
C
  420 IF (ITYPE .EQ. NTYPES) GO TO 440
C
      ITYPE = ITYPE + 1
      CALL REWIND (INFILE)
      AHEAD = GROUP + ITYPE*2 - 2
      DO 430 I = 1,AHEAD
      CALL FWDREC (*580,INFILE)
  430 CONTINUE
      ASSIGN 150 TO IRETRN
      EOF = 0
      GO TO 60
C
C     THIS GROUP IS ABSOLUTELY COMPLETE AND WE ARE AT BREAK POINT
C
  440 IF (EOF .EQ. 1) GO TO 80
      NRECS = NRECS + 2*NDATA*NTYPES
      IF (NTYPES .GT. 1) GO TO 50
  441 CONTINUE
      DO 450 I = 1,146
  450 ID(I) = IDTEMP(I)
      GO TO 70
C
C
C     ERROR CONDITIONS FOR THIS DATA BLOCK
C
C     FORMAT OF INPUT DATA BLOCK MAY BE INCORRECT (N=TRACEBACK CODE)
C
  490 N = 23
      GO TO 452
  500 N = 3
      GO TO 452
  520 N = 4
      GO TO 452
  530 N = 5
      GO TO 452
  540 N = 6
      GO TO 452
  550 N = 7
      GO TO 452
  560 N = 8
      GO TO 452
  570 N = 9
      GO TO 452
  580 N = 10
      GO TO 452
  590 N = 11
      GO TO 452
  600 N = 12
      GO TO 452
  610 N = 13
      GO TO 452
  620 N = 14
      GO TO 452
  630 N = 15
      GO TO 452
  640 N = 16
      GO TO 452
  650 N = 17
      GO TO 452
  660 N = 18
      GO TO 452
  452 OFPFIL(FILE) = N
      WRITE  (L,453) UWM,FILE
  453 FORMAT (A25,' 982, FORMAT OF SDR3 INPUT DATA BLOCK ',I3,
     1        ' DOES NOT PERMIT SUCCESSFUL SORT-2 PROCESSING.')
      GO TO 80
  472 WRITE  (L,475) UFM,NTYPES
  475 FORMAT (A23,' 3129, SDR3 CAN ONLY PROCESS 30 ELEMENT TYPES, ',
     1        'PROBLEM HAS',I5)
      CALL MESAGE (-61,0,0)
C
C     CORRESPONDING OUTPUT FILE IS PURGED.
C
  480 OFPFIL(FILE) = 2
      WRITE  (L,481) UWM,FILE
  481 FORMAT (A25,' 984,  SDR3 FINDS OUTPUT DATA-BLOCK',I4,' PURGED.')
      GO TO 80
C
C     ATTEMPT TO USE SCRATCH FILES 1 OR MORE OF WHICH ARE PURGED.
C
  451 OFPFIL(FILE) = 1
      GO TO 80
C
C     INSUFFICIENT CORE
C
  670 N = 19
      GO TO 701
  680 N = 20
      GO TO 701
  690 N = 21
      GO TO 701
  701 WRITE  (L,702) UWM,FILE
  702 FORMAT (A25,' 983, SDR3 HAS INSUFFICIENT CORE TO PERFORM SORT-2',
     1       ' ON INPUT DATA BLOCK',I4, /5X,
     2       'OR DATA-BLOCK IS NOT IN CORRECT FORMAT.')
      OFPFIL(FILE) = N
      GO TO 80
C
  460 CONTINUE
C
C     CLOSE SCRATCH FILES
C
      DO 470 I = 1,NSCRAT
      CALL CLOSE (SCRTCH(I),RWD)
  470 CONTINUE
C
      GO TO 801
  700 DO 704 I = 1,5
  704 OFPFIL(I) = 22
      WRITE  (L,703) UWM
  703 FORMAT (A25,' 986, INSUFFICIENT CORE FOR SDR3.')
  801 RETURN
      END
