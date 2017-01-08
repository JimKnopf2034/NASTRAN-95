C*DECK,DMPALT
      SUBROUTINE DMPALT (ISIZE, IOPEN      , IPTAPE)
C******************************************************************
C                              NOTICE                             *
C                              ------                             *
C                                                                 *
C     THIS PROGRAM BELONGS TO RPK CORPORATION.  IT IS CONSIDERED  *
C  A TRADE SECRET AND IS NOT TO BE DIVULGED OR USED BY PARTIES    *
C  WHO HAVE NOT RECEIVED WRITTEN AUTHORIZATION FROM RPK.          *
C******************************************************************
C
      INTEGER   ALTFIL, OLDALT, XALTER(2)
C
      DIMENSION IALTER(2), IOPEN(1), ISUBR(2), ICARD(18)
C
      COMMON /ALTRXX/ ALTFIL, NEWALT, NOGO
      COMMON /SYSTEM/ ISYSBF, NOUT
      COMMON /XRGDXX/ IDUM(115), NMDMAP
C
      DATA OLDALT /0/
      DATA ISUBR  /4HDMPA, 4HLT  /
      DATA XALTER /4HXALT, 4HER  /
C
      IPOINT = 1
      CALL WRITE (IPTAPE, XALTER, 2, 1)
      IF (NEWALT .EQ. 0) GO TO 200
      N2DMAP = 2*NMDMAP
      CALL SKPFIL (ALTFIL, 1)
      CALL READ (*2000, *100, ALTFIL, IOPEN, ISIZE, 1, IEND)
      IREQD = N2DMAP - ISIZE
      CALL MESAGE (-8, IREQD, ISUBR)
  100 IF (IEND .NE. N2DMAP) GO TO 2100
      IPOINT = IPOINT + IEND
      CALL REWIND (ALTFIL)
C
  200 CALL READ (*3000, *300, ALTFIL, IOPEN(IPOINT), 19, 1, IFLAG)
      NWORDS = 19
      LOGIC = 200
      GO TO 2200
C
  300 IF (IFLAG .NE. 2) GO TO 400
      LOGIC = 300
      ASSIGN 320 TO JGOTO
      GO TO 1200
C
C     PROCESS ALTER CARDS HERE
C
  320 IALTER(1) = IOPEN(IPOINT  )
      IALTER(2) = IOPEN(IPOINT+1)
      IF (IALTER(2).EQ.0 .OR. IALTER(2).GE.IALTER(1)) GO TO 1000
      ITEMP = IALTER(2)
      IALTER(2) = IALTER(1)
      IALTER(1) = ITEMP
      GO TO 1000
C
  400 IF (IFLAG .NE. 4) GO TO 500
      NWORDS = 4
      LOGIC = 400
      IF (NEWALT .EQ. 0) GO TO 2200
      LOGIC = 410
      ASSIGN 420 TO JGOTO
      GO TO 1200
C
C     PROCESS INSERT CARDS HERE
C
  420 IDMAP1 = IOPEN(IPOINT  )
      IDMAP2 = IOPEN(IPOINT+1)
      IOCCUR = IOPEN(IPOINT+2)
      IOFFST = IOPEN(IPOINT+3)
      ASSIGN 470 TO IGOTO
      GO TO 1500
  470 IALTER(1) = INUMBR
      IALTER(2) = 0
      GO TO 1000
C
  500 IF (IFLAG .NE. 5) GO TO 600
      NWORDS = 5
      LOGIC = 500
      IF (NEWALT .EQ. 0) GO TO 2200
      LOGIC = 510
      ASSIGN 520 TO JGOTO
      GO TO 1200
C
C     PROCESS DELETE CARDS WITH ONE FIELD HERE
C
  520 IDMAP1 = IOPEN(IPOINT  )
      IDMAP2 = IOPEN(IPOINT+1)
      IOCCUR = IOPEN(IPOINT+2)
      IOFFST = IOPEN(IPOINT+3)
      ICHECK = IOPEN(IPOINT+4)
      LOGIC = 520
      IF (ICHECK .NE. 0) GO TO 2300
      ASSIGN 570 TO IGOTO
      GO TO 1500
  570 IALTER(1) = INUMBR
      IALTER(2) = INUMBR
      GO TO 1000
C
  600 IF (IFLAG .NE. 9) GO TO 700
      NWORDS = 9
      LOGIC = 600
      IF (NEWALT .EQ. 0) GO TO 2200
      LOGIC = 610
      ASSIGN 620 TO JGOTO
      GO TO 1200
C
C     PROCESS DELETE CARDS WITH TWO FIELDS HERE
C
  620 IDMAP1 = IOPEN(IPOINT  )
      IDMAP2 = IOPEN(IPOINT+1)
      IOCCUR = IOPEN(IPOINT+2)
      IOFFST = IOPEN(IPOINT+3)
      ICHECK = IOPEN(IPOINT+4)
      LOGIC = 620
      IF (ICHECK .NE. 1) GO TO 2300
      ASSIGN 670 TO IGOTO
      GO TO 1500
  670 IALTER(1) = INUMBR
      IDMAP1 = IOPEN(IPOINT+5)
      IDMAP2 = IOPEN(IPOINT+6)
      IOCCUR = IOPEN(IPOINT+7)
      IOFFST = IOPEN(IPOINT+8)
      ASSIGN 690 TO IGOTO
      GO TO 1500
  690 IALTER(2) = INUMBR
      IF (IALTER(2).EQ.0 .OR. IALTER(2).GE.IALTER(1)) GO TO 1000
      ITEMP = IALTER(2)
      IALTER(2) = IALTER(1)
      IALTER(1) = ITEMP
      GO TO 1000
C
C     PROCESS DMAP STATEMENTS HERE
C
  700 NWORDS = IFLAG
      LOGIC = 700
      IF (IFLAG .NE. 18) GO TO 2200
      CALL WRITE (IPTAPE, IOPEN(IPOINT), 18, 1)
      GO TO 200
C
C     WRITE ALTER CONTROL DATA ON THE NEW PROBLEM TAPE
C
 1000 IF (IALTER(1) .EQ. 0) GO TO 200
      IF (IALTER(1) .GT. OLDALT) GO TO 1100
 1050 NOGO = 1
      WRITE (NOUT, 3300) ICARD
      GO TO 200
 1100 IF (IALTER(2).NE.0 .AND. IALTER(1).GT.IALTER(2)) GO TO 1050
      CALL WRITE (IPTAPE, IALTER, 2, 1)
      OLDALT = IALTER(1)
      IF (IALTER(2) .NE. 0) OLDALT = IALTER(2)
      GO TO 200
C
C     INTERNAL SUBROUTINE TO READ IN AN ALTER CONTROL CARD IMAGE
C
 1200 CALL READ (*2000, *1230, ALTFIL, ICARD, 19, 1, IFLAG)
      NWORDS = 19
      GO TO 2200
 1230 GO TO JGOTO, (320, 420, 520, 620)
C
C     INTERNAL SUBROUTINE TO FIND THE DMAP STATEMENT NUMBER
C     FOR A DMAP STATEMENT WITH A GIVEN OCCURENCE FLAG AND
C     AN OFFSET FLAG
C
 1500 ICOUNT = 0
      DO 1600 J = 1, IEND, 2
      IF (IDMAP1.NE.IOPEN(J) .OR. IDMAP2.NE.IOPEN(J+1)) GO TO 1600
      ICOUNT = ICOUNT + 1
      IF (ICOUNT .LT. IOCCUR) GO TO 1600
      INUMBR = (J+1)/2 + IOFFST
      IF (INUMBR.GE.1 .AND. INUMBR.LE.NMDMAP) GO TO 1700
      NOGO = 1
      INUMBR = 0
      WRITE (NOUT, 3500) ICARD
      GO TO 1700
 1600 CONTINUE
      NOGO = 1
      INUMBR = 0
      IF (ICOUNT .GT. 0) WRITE (NOUT, 3600) ICARD
      IF (ICOUNT .EQ. 0) WRITE (NOUT, 3700) ICARD
 1700 GO TO IGOTO, (470, 570, 670, 690)
C
C     ERROR MESSAGES
C
 2000 CALL MESAGE (-2, ALTFIL, ISUBR)
 2100 WRITE (NOUT, 4100) IEND, N2DMAP
      GO TO 2900
 2200 WRITE (NOUT, 4200) NWORDS, LOGIC
      GO TO 2900
 2300 WRITE (NOUT, 4300) LOGIC
      GO TO 2900
 2900 CALL MESAGE (-61, 0, 0)
C
 3000 RETURN
C***********************************************************************
 3300 FORMAT ('0*** USER FATAL MESSAGE, THE DATA ON THE ',
     *        'FOLLOWING ALTER CONTROL CARD IS NOT IN PROPER ',
     *        'SEQUENCE OR ORDER --'//
     *        5X, 18A4)
 3500 FORMAT ('0*** USER FATAL MESSAGE, ILLEGAL OFFSET FLAG ',
     *         'SPECIFIED ON THE FOLLOWING ALTER CONTROL CARD --'//
     *        5X, 18A4)
 3600 FORMAT ('0*** USER FATAL MESSAGE, ILLEGAL OCCURENCE FLAG ',
     *         'SPECIFIED ON THE FOLLOWING ALTER CONTROL CARD --'//
     *        5X, 18A4)
 3700 FORMAT ('0*** USER FATAL MESSAGE, NON-EXISTENT NOMINAL ',
     *        'DMAP STATEMENT SPECIFIED ON THE FOLLOWING ',
     *        'ALTER CONTROL CARD --'//
     *        5X, 18A4)
 4100 FORMAT ('0*** SYSTEM FATAL MESSAGE, ILLEGAL NUMBER OF ',
     *        'WORDS (', I5, ') ENCOUNTERED IN THE SECOND ',
     *        'FILE OF THE ALTER SCRATCH FILE.'/
     *        '     EXPECTED NUMBER OF WORDS = ', I5)
 4200 FORMAT ('0*** SYSTEM FATAL MESSAGE, ILLEGAL NUMBER OF ',
     *        'WORDS (', I5, ') ENCOUNTERED WHILE READING ',
     *        'A RECORD IN THE FIRST FILE OF THE ALTER SCRATCH ',
     *        'FILE.'/
     *        '     LOGIC ERROR NO. = ', I5)
 4300 FORMAT ('0*** SYSTEM FATAL MESSAGE, ILLEGAL CONTROL WORD ',
     *        'WHILE PROCESSING THE FOLLOWING ALTER CONTROL CARD'//
     *        5X, 18A4)
C***********************************************************************
C                              NOTICE                             *
C                              ------                             *
C                                                                 *
C     THIS PROGRAM BELONGS TO RPK CORPORATION.  IT IS CONSIDERED  *
C  A TRADE SECRET AND IS NOT TO BE DIVULGED OR USED BY PARTIES    *
C  WHO HAVE NOT RECEIVED WRITTEN AUTHORIZATION FROM RPK.          *
C******************************************************************
      END
