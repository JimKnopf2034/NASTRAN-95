      SUBROUTINE ALG05
C
      REAL LOSS,LAMI,LAMIP1,LAMIM1
C
      DIMENSION XX1(21),XX2(21),XX3(21),XX4(21),XX5(21)
C
      COMMON /UD300C/ NSTNS,NSTRMS,NMAX,NFORCE,NBL,NCASE,NSPLIT,NREAD,
     1NPUNCH,NPAGE,NSET1,NSET2,ISTAG,ICASE,IFAILO,IPASS,I,IVFAIL,IFFAIL,
     2NMIX,NTRANS,NPLOT,ILOSS,LNCT,ITUB,IMID,IFAIL,ITER,LOG1,LOG2,LOG3,
     3LOG4,LOG5,LOG6,IPRINT,NMANY,NSTPLT,NEQN,NSPEC(30),NWORK(30),
     4NLOSS(30),NDATA(30),NTERP(30),NMACH(30),NL1(30),NL2(30),NDIMEN(30)
     5,IS1(30),IS2(30),IS3(30),NEVAL(30),NDIFF(4),NDEL(30),NLITER(30),
     6NM(2),NRAD(2),NCURVE(30),NWHICH(30),NOUT1(30),NOUT2(30),NOUT3(30),
     7NBLADE(30),DM(11,5,2),WFRAC(11,5,2),R(21,30),XL(21,30),X(21,30),
     8H(21,30),S(21,30),VM(21,30),VW(21,30),TBETA(21,30),DIFF(15,4),
     9FDHUB(15,4),FDMID(15,4),FDTIP(15,4),TERAD(5,2),DATAC(100),
     1DATA1(100),DATA2(100),DATA3(100),DATA4(100),DATA5(100),DATA6(100),
     2DATA7(100),DATA8(100),DATA9(100),FLOW(10),SPEED(30),SPDFAC(10),
     3BBLOCK(30),BDIST(30),WBLOCK(30),WWBL(30),XSTN(150),RSTN(150),
     4DELF(30),DELC(100),DELTA(100),TITLE(18),DRDM2(30),RIM1(30),
     5XIM1(30),WORK(21),LOSS(21),TANEPS(21),XI(21),VV(21),DELW(21),
     6LAMI(21),LAMIM1(21),LAMIP1(21),PHI(21),CR(21),GAMA(21),SPPG(21),
     7CPPG(21),HKEEP(21),SKEEP(21),VWKEEP(21),DELH(30),DELT(30),VISK,
     8SHAPE,SCLFAC,EJ,G,TOLNCE,XSCALE,PSCALE,PLOW,RLOW,XMMAX,RCONST,
     9FM2,HMIN,C1,PI,CONTR,CONMX
C
      L1=NDIMEN(I)+1
      GO TO(100,120,140,160),L1
100   DO 110 J=1,NSTRMS
110   XX5(J)=R(J,I)
      GO TO 180
120   DO 130 J=1,NSTRMS
130   XX5(J)=R(J,I)/R(NSTRMS,I)
      GO TO 180
140   DO 150 J=1,NSTRMS
150   XX5(J)=XL(J,I)
      GO TO 180
160   DO 170 J=1,NSTRMS
170   XX5(J)=XL(J,I)/XL(NSTRMS,I)
180   L2=IS2(I)
      L3=NDATA(I)
      L4=NTERP(I)
      CALL ALG01(DATAC(L2),DATA1(L2),L3,XX5,WORK  ,X1,NSTRMS,L4,0)
      CALL ALG01(DATAC(L2),DATA3(L2),L3,XX5,TANEPS,X1,NSTRMS,L4,0)
      DO 190 J=1,NSTRMS
190   TANEPS(J)=TAN(TANEPS(J)/C1)
      IW=NWORK(I)
      IL=NLOSS(I)
      IF(IW.EQ.7.OR.IL.LE.3)
     1CALL ALG01(DATAC(L2),DATA2(L2),L3,XX5,LOSS  ,X1,NSTRMS,L4,0)
      IF(IW.GE.5)
     1CALL ALG01(DATAC(L2),DATA6(L2),L3,XX5,XX1,X1,NSTRMS,L4,0)
      IF(IL.NE.4)GO TO 350
      DO 200 II=I,NSTNS
      IF(NLOSS(II).EQ.1)GO TO 210
200   CONTINUE
210   L2=IS2(II)
      L3=NDATA(II)
      L4=NTERP(II)
      L1=NDIMEN(II)+1
      GO TO(220,240,260,280),L1
220   DO 230 J=1,NSTRMS
230   XX5(J)=R(J,II)
      GO TO 300
240   DO 250 J=1,NSTRMS
250   XX5(J)=R(J,II)/R(NSTRMS,II)
      GO TO 300
260   DO 270 J=1,NSTRMS
270   XX5(J)=XL(J,II)
      GO TO 300
280   DO 290 J=1,NSTRMS
290   XX5(J)=XL(J,II)/XL(NSTRMS,II)
300   CALL ALG01(DATAC(L2),DATA2(L2),L3,XX5,LOSS,X1,NSTRMS,L4,0)
      III=I+NL1(I)+1
      DO 320 J=1,NSTRMS
      XX2(J)=0.0
      DO 310 IK=III,II
      XX2(J)=XX2(J)+SQRT((X(J,IK)-X(J,IK-1))**2+(R(J,IK)-R(J,IK-1))**2)
      IF(IK.EQ.I)XX3(J)=XX2(J)
310   CONTINUE
320   XX3(J)=XX3(J)/XX2(J)
      L1=NCURVE(I)
      L2=NM(L1)
      L3=NRAD(L1)
      DO 340 J=1,NSTRMS
      DO 330 K=1,L3
330   CALL ALG01(DM(1,K,L1),WFRAC(1,K,L1),L2,XX3(J),XX2(K),X1,1,0,0)
      X2=(R(J,II)-R(1,II))/(R(NSTRMS,II)-R(1,II))
      CALL ALG01(TERAD(1,L1),XX2,L3,X2,X1,X1,1,0,0)
340   LOSS(J)=LOSS(J)*X1
350   IF(IW.LT.5)GO TO 420
      IF(IW.NE.5)GO TO 370
      DO 360 J=1,NSTRMS
360   TBETA(J,I)=TAN((WORK(J)+XX1(J))/C1)
      GO TO 420
370   IF(IW.EQ.7)GO TO 400
      DO 380 J=1,NSTRMS
380   XX2(J)=TAN((ATAN((R(J,I+1)-R(J,I))/(X(J,I+1)-X(J,I)))+ATAN((R(J,I)
     1-R(J,I-1))/(X(J,I)-X(J,I-1))))/2.0)
      L1=IS1(I)
      CALL ALG01(RSTN(L1),XSTN(L1),NSPEC(I),R(1,I),X1,XX3,NSTRMS,0,1)
      DO 390 J=1,NSTRMS
390   TBETA(J,I)=TAN(ATAN((TAN(WORK(J)/C1)*(1.0-XX3(J)*XX2(J))-XX2(J)*TA
     1NEPS(J)*SQRT(1.0+XX3(J)**2))/SQRT(1.0+XX2(J)**2))+XX1(J)/C1)
      GO TO 420
400   XN=SPEED(I)*SPDFAC(ICASE)*PI/(30.0*SCLFAC)
      CALL ALG01(DATAC(L2),DATA7(L2),L3,XX5,XX2,X1,NSTRMS,L4,0)
      CALL ALG01(DATAC(L2),DATA8(L2),L3,XX5,XX3,X1,NSTRMS,L4,0)
      CALL ALG01(DATAC(L2),DATA9(L2),L3,XX5,XX4,X1,NSTRMS,L4,0)
      II=I+NL1(I)
      DO 410 J=1,NSTRMS
      X1=C1*ATAN((VW(J,II)-XN*R(J,II))/VM(J,II))
      X2=XX3(J)
      IF(X1.LT.XX1(J))X2=XX4(J)
      LOSS(J)=LOSS(J)*(1.0+((X1-XX1(J))/(X2-XX1(J)))**2)
      IF(LOSS(J).GT.0.5)LOSS(J)=0.5
410   TBETA(J,I)=TAN((WORK(J)+(X1-XX1(J))*XX2(J))/C1)
420   RETURN
      END
