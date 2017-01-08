      SUBROUTINE TRD1D
C
C     THIS ROUTINE COMPUTES NON-LINEAR LOADS FOR TRANSIENT ANALYSIS
C
C     THIS ROUTINE IS SUITABLE FOR SINGLE PRECISION OPERATION
C
      LOGICAL         DEC
      INTEGER         IZ(1),PNL,DIT,FILE,SYSBUF,ITLIST(13),NAME(2),
     1                NMTD(2)
      CHARACTER       UFM*23,UWM*25
      COMMON /XMSSG / UFM,UWM
      COMMON /SYSTEM/ SYSBUF,IOUT
      COMMON /MACHIN/ MACH
      COMMON /ZZZZZZ/ Z(1)
      COMMON /PACKX / IT1,IT2,II,NROW,INCR
      COMMON /TRDD1 / NLFT,DIT,NLFTP,NOUT,ICOUNT,ILOOP,MODAL,LCORE,
     1                ICORE,IU,IP,IPNL(7),NMODES,NSTEP,PNL,IST,IU1,
     2                DELTAT,IFRST,TABS,SIGMA,TIM
      EQUIVALENCE     (Z(1),IZ(1))
      DATA    ITLIST/ 4,1105,11,1,1205,12,2,1305,13,3,1405,14,4/
      DATA    NAME  / 4HNLFT,4HTRDD/
      DATA    NMTD  / 4HTRD1,4HD   /
      DATA    KOUNT / 0            /
C
C     IDENTIFICATION OF VARIABLES
C
C     NLFT    NON-LINEAR FUNCTION TABLE
C     PNL     NON-LINEAR FORCES --MATRIX
C     DIT     DIRECT INPUT TABLES
C     NLFTP   NON-LINEAR FUNCTION SET SELECTION
C     NOUT    OUT PUT  EVERY NOUT TIME STEPS( PLUS 1 AND NSTEP)
C     ICOUNT  CURRENT INTERATION COUNTER
C     ILOOP   LOOP ON NUMBER OF TIME STEP CHANGES
C     MODAL   LESS THAN ZERO IMPLIES THIS IS A DIRECT FORMULATION
C     LCORE   AMOUNT OF CORE FOR TRD1D
C     ICORE   POINTER TO FIRST CELL OF OPEN CORE
C     IU      POINTER TO LATEST DISPLACEMENT VECTOR
C     IU1     POINTER TO DISPLACEMENT VECTOR -- ONE TIME STEP BACK
C     IP      POINTER TO LOAD VECTOR
C     NMODES  NUMBER OF MODES IN PROBLEM
C     NSTEP   NUMBER OF TIME STEPS
C     ITLIST  LIST OF CARD TYPES FOR DYNAMIC TABLES
C     NROW    SIZE OF SOLUTION SET
C     IBUF1   POINTER TO BUFFER
C     NCARDS  NUMBER OF LOAD CARDS IN SELECTED SET
C     ICARDS  POINTER TO FIRST CARD
C     NTABL   NUMBER OF TABLES
C     ITABL   POINTER TO FIRST TABLE
C     IPNL    MATRIX CONTROL BLOCK FOR PNL
C
C     DESCRIPTION OF TYPES OF NON-LINEAR LOADING
C
C     TYPE    DESCRIPTION
C     ----    -----------
C
C       1     DISPLACEMENT-DEPENDENT NOLIN1 LOAD
C       2     DISPLACEMENT-DEPENDENT/DISPLACEMENT-DEPENDENT NOLIN2 LOAD
C       3     DISPLACEMENT-DEPENDENT NOLIN3 LOAD
C       4     DISPLACEMENT-DEPENDENT NOLIN4 LOAD
C       5     VELOCITY-DEPENDENT NOLIN1 LOAD
C       6     VELOCITY-DEPENDENT/DISPLACEMENT-DEPENDENT NOLIN2 LOAD
C       7     VELOCITY-DEPENDENT NOLIN3 LOAD
C       8     VELOCITY-DEPENDENT NOLIN4 LOAD
C       9     VELOCITY-DEPENDENT/VELOCITY-DEPENDENT NOLIN2 LOAD
C      10     DISPLACEMENT-DEPENDENT/VELOCITY-DEPENDENT NOLIN2 LOAD
C      11     TEMPERATURE-DEPENDENT CONVECTION NON-LINEAR LOAD (FTUBE)
C      12     TEMPERATURE-DEPENDENT EMISSIVITIES-ABSORPTIVITIES, NOLIN5
C      13     DISPLACEMENT-DEPENDENT/VELOCITY-DEPENDENT NOLIN6 LOAD
C      14     VELOCITY-DEPENDENT/DISPLACEMENT-DEPENDENT NOLIN6 LOAD
C
C     DETERMINE ENTRY NUMBER
C
      DEC = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21
      IPX = IP
C
      IF ((ILOOP.EQ.1 .AND. ICOUNT.GT.1) .OR. (ILOOP.GT.1 .AND.
     1     ICOUNT.GT.0)) GO TO 170
      IF (IFRST  .NE. 0) GO TO 170
C
C     FIRST TIME FOR TIME STEP
C
      CALL SSWTCH (10,IALG)
      IBUF1 = LCORE + ICORE - SYSBUF
      FILE  = NLFT
      LCORE = LCORE - SYSBUF - 1
      ICRQ  =-LCORE
      IF (LCORE .LE. 0) GO TO 430
      CALL OPEN (*400,NLFT,IZ(IBUF1),0)
C
C     FIND SELECTED SET ID
C
      CALL READ (*420,*10,NLFT,IZ(ICORE+1),LCORE,0,IFLAG)
      ICRQ = LCORE
      GO TO 430
   10 DO 20 I = 3,IFLAG
      K = I + ICORE
      IF (IZ(K) .EQ. NLFTP) GO TO 30
   20 CONTINUE
      CALL MESAGE (-31,NLFTP,NAME)
C
C     FOUND SET ID -- POSITION TO RECORD IN NLFT
C
   30 K = I - 3
      IF (K .EQ. 0) GO TO 50
      DO 40 I = 1,K
      CALL FWDREC (*420,NLFT)
   40 CONTINUE
C
C     BRING IN  8 WORDS PER CARD
C     FORMAT =    TYPE,SILD,SILE,A,SILD,SILE,A OR SILD,SILE
C     CONVERT TO  TYPE,ROWP,ROWP,A,ROWP OR A
C     COUNT NUMBER OF CARDS
C
   50 NCARDS = 0
      ICARDS = ICORE + 1
      K      = ICARDS
   60 ICRQ   = 8 - LCORE
      IF (ICRQ .GT. 0) GO TO 430
      CALL READ (*420,*80,NLFT,IZ(K),8,0,IFLAG)
      IF (MODAL .LT. 0) GO TO 70
C
C     MODAL FORM -- CONVERT SILE TO ROW POSITIONS AND STORE IN SILD
C
      IF (IZ(K+2) .EQ. 0) GO TO 440
      IZ(K+1) = IZ(K+2) + NMODES
      IF (IZ(K+5) .EQ. 0) GO TO 440
      IZ(K+4) = IZ(K+5) + NMODES
      IF (IZ(K).NE.2 .AND. IZ(K).NE.6 .AND. IZ(K).NE.9 .AND.
     1    IZ(K).NE.10) GO TO 70
      IF (IZ(K+7) .EQ. 0) GO TO 440
      IZ(K+6) = IZ(K+7) + NMODES
   70 CONTINUE
C
C     MOVE UP
C
      IZ(K+2) = IZ(K+4)
      IZ(K+4) = IZ(K+6)
      K       = K + 5
      LCORE   = LCORE  - 5
      NCARDS  = NCARDS + 1
      GO TO 60
C
C     END OF RECORD-- DONE
C
   80 CALL CLOSE (NLFT,1)
C
C     EXTRACT LIST OF  UNIQUE TABLES FROM CARD TYPES 1,5,11 THRU 14
C
      L     = ICARDS
      NTABL = 0
      ITABL = K
      NUMTB = 1
      DO 120 I = 1,NCARDS
      IZL = IZ(L)
      IF (IZL.NE.1 .AND. IZL.NE.5 .AND. (IZL.LT.11 .OR. IZL.GT.14))
     1    GO TO 110
      IF (IZL.NE.11 .AND. IZL.NE.12) GO TO 85
      IZL = IZ(L+4)
      IF (IZ(L) .NE. 11) GO TO 83
C
C     NFTUBE CARD
C
   81 NXX = NUMTYP(IZL)
      IF (DEC .AND. IZL.GT.16000 .AND. IZL.LE.99999999) NXX = 1
      IF (NXX-1) 110,85,110
C
C     NOLIN5 CARD
C
   83 NXX = NUMTYP(IZ(L+3))
      IF (DEC .AND. IZ(L+3).GT.16000 .AND. IZ(L+3).LE.99999999)
     1    NXX = 1
      IF (NXX .NE. 1) GO TO 81
      ITID1 = IZ(L+3)
      NXX   = NUMTYP(IZL)
      IF (DEC .AND. IZL.GT.16000 .AND. IZL.LE.99999999) NXX = 1
      IF (NXX .NE. 1) GO TO 87
      ITID2 = IZ(L+4)
      NUMTB = 2
      GO TO 89
   85 ITID1 = IZ(L+4)
   87 NUMTB = 1
   89 CONTINUE
C
C     FIND OUT IF UNIQUE TABLE
C
      IF (NTABL .EQ. 0) GO TO 100
      DO 90 M = 1,NTABL
      K = ITABL + M
      IF (IZ(K) .EQ. ITID1) GO TO 110
   90 CONTINUE
C
C     NEW TABLE
C
  100 NTABL = NTABL + 1
      K     = ITABL + NTABL
      IZ(K) = ITID1
  110 CONTINUE
      IF (NUMTB .EQ. 1) GO TO 115
      NUMTB = 1
      ITID1 = ITID2
      GO TO 89
  115 L     = L + 5
  120 CONTINUE
C
      IZ(ITABL) = NTABL
      LCORE = LCORE - NTABL - 1
      ICRQ  =-LCORE
      IF (LCORE .LE. 0) GO TO 430
      IF (NTABL .EQ. 0) GO TO 150
C
C     INITIALIZE TABLES
C
      K     = ITABL + NTABL + 1
      CALL PRETAB (DIT,IZ(K),IZ(K),IZ(IBUF1),LCORE,L,IZ(ITABL),ITLIST)
      LCORE = LCORE - L
      IF (IALG .EQ. 0) GO TO 140
      IN1   = K + L - 1
      IN2   = IN1 + NROW
      IN3   = IN2 + NROW
      LCORE = LCORE - 3*NROW
      ICRQ  =-LCORE
      IF (LCORE .LT. 0) GO TO 430
C
C     ZERO LOAD VECTORS
C
      DO 130 I = 1,NROW
      K    = IN1 + I
      Z(K) = 0.0
      K    = IN2 + I
      Z(K) = 0.0
      K    = IN3 + I
      Z(K) = 0.0
  130 CONTINUE
  140 CONTINUE
  150 RETURN
C
C     COMPUTE LOADS
C
  170 K   = ICARDS + NCARDS*5 - 1
      IF (IALG .EQ. 0) GO TO 180
      IPX = IN1
      DO 175 I = 1,NROW
      L   = IN1 + I
      Z(L)= 0.0
  175 CONTINUE
C
C     LOOP THRU EACH LOAD CARD OR COLLECTION (NOLIN5, NOLIN6)
C
  180 H  = 1.0/DELTAT
      I  = ICARDS
  190 CONTINUE
      FX = 0.0
      FY = 1.0
      M  = IU  + IZ(I+2)
      MM = IU  + IZ(I+4)
      N  = IU1 + IZ(I+2)
      NN = IU1 + IZ(I+4)
      X  = Z(M)
      Y  = (X-Z(N))*H
      L  = IZ(I)
C     L  =     1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14
      GO TO (200,210,220,230,205,213,225,235,215,217,250,260,240,245), L
C
C     NOLIN 1
C
  200 CALL TAB (IZ(I+4),X,FX)
      GO TO 290
  205 X = Y
      GO TO 200
C
C     NOLIN 2
C
  210 Y = Z(MM)
      FX= X*Y
      GO TO 290
  213 X = Y
      GO TO 210
  215 X = Y
  217 FX= X*(Z(MM)-Z(NN))*H
      GO TO 290
C
C     NOLIN  3
C
  220 IF (X .LE. 0.0) GO TO 290
      FX = X**Z(I+4)
      GO TO 290
  225 X = Y
      GO TO 220
C
C     NOLIN 4
C
  230 IF(X .GE. 0.0) GO TO 290
      FX =-ABS(X)**Z(I+4)
      GO TO 290
  235 X = Y
      GO TO 230
C
C     NOLIN 6
C
  240 X  = Y
      FY = X*ABS(X)
      X  = Z(M)
      GO TO 200
  245 Y  = Z(MM)
      FY = Y*ABS(Y)
      GO TO 200
C
C     NFTUBE.  LOOKUP VDOT IF NEEDED
C
  250 FX  = Z(I+4)
      IZL = IZ(I+4)
      NXX = NUMTYP(IZL)
      IF (DEC .AND. IZL.GT.16000 .AND. IZL.LE.99999999) NXX = 1
      IF (NXX .EQ.  1) CALL TAB (IZ(I+4),TIM,FX)
      IF (FX .GE. 0.0) M=IU+IZ(I+1)
      FX  = FX*Z(M)
      L   = IPX + IZ(I+2)
      Z(L)= Z(L) + FX*Z(I+3)
      FY  =-1.0
      GO TO 290
C
C     NOLIN5
C
C     A. COMPUTE SURFACE AVERAGE TEMPERATURES
C
  260 MM = 0
      NN = 0
      TAVGA = 0.0
      TAVGB = 0.0
      J  = 1
      DO 270 L = 1,4
      IF (L .EQ. 3) J = 6
      M  = IZ(I+J)
      IF (M .EQ. 0) GO TO 265
      M  = IU + M
      TAVGA = TAVGA+Z(M)
      MM = MM + 1
  265 M  = IZ(I+J+10)
      IF (M .EQ. 0) GO TO 270
      M  = IU + M
      TAVGB = TAVGB+Z(M)
      NN = NN + 1
  270 J  = J  + 1
      TAVGA = TAVGA/FLOAT(MM)
      TAVGB = TAVGB/FLOAT(NN)
      AA    = Z(I+3)
      AB    = Z(I+4)
      FAB   = Z(I+8)
      FABSQ = FAB*FAB
      ETA   = Z(I+13)
      ETB   = Z(I+14)
      NXX   = NUMTYP(IZ(I+13))
      IF (DEC .AND. IZ(I+13).GT.16000 .AND. IZ(I+13).LE.99999999)
     1    NXX = 1
      IF (NXX .EQ. 1) CALL TAB (IZ(I+13),TAVGA,ETA)
      NXX   = NUMTYP(IZ(I+14))
      IF (DEC .AND. IZ(I+14).GT.16000 .AND. IZ(I+14).LE.99999999)
     1    NXX = 1
      IF (NXX .EQ. 1) CALL TAB (IZ(I+14),TAVGB,ETB)
      ALPHA = Z(I+18)
      ALPHB = Z(I+19)
      NXX   = NUMTYP(IZ(I+18))
      IF (DEC .AND. IZ(I+18).GT.16000 .AND. IZ(I+18).LE.99999999)
     1    NXX = 1
      IF (NXX .EQ. 1) CALL TAB (IZ(I+18),TAVGA,ALPHA)
      NXX   = NUMTYP(IZ(I+19))
      IF (DEC .AND. IZ(I+19).GT.16000 .AND. IZ(I+19).LE.99999999)
     1    NXX = 1
      IF (NXX .EQ. 1) CALL TAB (IZ(I+19),TAVGB,ALPHB)
      ALPHA = ALPHA - 1.0
      ALPHB = ALPHB - 1.0
C
C     B. COMPUTE DENOMINATOR
C
      XH  = SIGMA*ETA*(TAVGA+TABS)**4
      XK  = SIGMA*ETB*(TAVGB+TABS)**4
      FX  = ALPHA*FAB*XK - AA*XH +FAB*XK - (ALPHB*FABSQ*XH)/AB
      FY  = ALPHB*FAB*XH - AB*XK +FAB*XH - (ALPHA*FABSQ*XK)/AA
      FAB = 1.0 - (ALPHA*ALPHB/AA)*(FABSQ/AB)
      FX  = FX/(FAB*FLOAT(MM))
      FY  = FY/(FAB*FLOAT(NN))
C
C     C. APPLY FORCES ON AREAS A AND  B
C
      J = 1
      DO 280 L = 1,4
      IF (L .EQ. 3) J = 6
      M = IZ(I+J)
      IF (M .EQ. 0) GO TO 275
      M = IPX + M
      Z(M) = Z(M) + FX
  275 M = IZ(I+J+10)
      IF (M .EQ. 0) GO TO 280
      M = IPX + M
      Z(M) = Z(M) + FY
  280 J = J + 1
      I = I + 20
      GO TO 320
C
C     FINISH APPLYING SCALE FACTOR AND ADD
C
  290 L = IPX + IZ(I+1)
      Z(L) = Z(L) + FX*FY*Z(I+3)
      IF (ABS(Z(L)) .LT. 1.0E-36) Z(L) = 0.0
      IF (ABS(Z(L)) .LT. 1.0E+36) GO TO 310
      KOUNT = KOUNT + 1
      IF (KOUNT.EQ.1 .OR. KOUNT.EQ.4) WRITE (IOUT,295)
      IF (KOUNT .LE. 3) WRITE (IOUT,300) UWM,Z(L)
  295 FORMAT (/1X,28(4H****),/)
  300 FORMAT (A25,' 3309, UNUSUALLY LARGE VALUE COMPUTED FOR NONLINEAR',
     1       ' FORCING FUNCTION',5X,E15.5)
  310 I = I + 5
  320 IF (I .LT. K) GO TO 190
C
C     END OF LOAD LOOP
C
C
C     DONE
C
      IF (IALG .EQ. 0) GO TO 380
      DO 370 I = 1,NROW
C
C     SUM OVER LAST THREE LOADS
C
      L  = IP  + I
      K  = IN1 + I
      M  = IN2 + I
      KK = IN3 + I
      Z(L) = Z(L) + (Z(K)+Z(M)+Z(KK))/3.0
  370 CONTINUE
C
C     SWITCH POINTERS
C
      K   = IN1
      IN1 = IN2
      IN2 = IN3
      IN3 = K
  380 RETURN
C
C     ERROR MESSAGES
C
  400 WRITE  (IOUT,405) UFM
  405 FORMAT (A23,', NON-LINEAR FORCING LOAD (NLFT) WAS NOT GENERATED ',
     1       'PREVIOUSLY')
      IP1 = -37
  410 CALL MESAGE (IP1,FILE,NMTD)
      RETURN
  420 IP1 = -2
      GO TO 410
  430 IP1 = -8
      FILE= ICRQ
      GO TO 410
C
C     LOADED POINT  NOT E-POINT IN MODAL FORMULATION
C
  440 CALL MESAGE (-44,NLFTP,IZ(K))
      RETURN
      END
