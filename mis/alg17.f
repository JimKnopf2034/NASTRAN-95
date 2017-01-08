      SUBROUTINE ALG17 (ISTAK,PLTSZE,ITRIG,TITLE,IKDUM,IFPLOT)
C
      DIMENSION TITLE(18)
C
      PLTTIT=PLTSZE*.1
      IF (ISTAK.LT.2) GO TO 10
      BAL=.35*PLTSZE
      XLEN1=.3*PLTSZE
      XLEN2=XLEN1
      YLEN1=.25*PLTSZE
      YLEN2=-1.*YLEN1
      XBACK1=-1.9
      XBACK2=-6.2
      GO TO 50
10    IF (ISTAK.EQ.0) GO TO 20
      XLEN1=.70*PLTSZE
      XLEN2=.15*PLTSZE
      XBACK1=-1.9-.20*PLTSZE
      XBACK2=-6.2-.20*PLTSZE
      IF (IKDUM.EQ.1) GO TO 30
      GO TO 40
20    CONTINUE
      XLEN1=.15*PLTSZE
      XLEN2=.70*PLTSZE
      XBACK1=-1.9+.20*PLTSZE
      XBACK2=-6.2+.20*PLTSZE
      IF (IKDUM.EQ.1) GO TO 40
30    BAL=.25*PLTSZE
      YLEN1=.50*PLTSZE
      YLEN2=-.15*PLTSZE
      GO TO 50
40    BAL=.50*PLTSZE
      YLEN1=.15*PLTSZE
      YLEN2=-.50*PLTSZE
50    CONTINUE
      YBACK1=-(.35+BAL)
      YBACK2=YBACK1-.01*PLTSZE-.175
      GO TO (60,70), ITRIG
60    CONTINUE
      GO TO 80
70    XBACK1=XBACK1+0.35
80    CONTINUE
      RETURN
      END
