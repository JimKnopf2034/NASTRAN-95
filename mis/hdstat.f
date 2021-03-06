      SUBROUTINE HDSTAT(MT,NIT,IXR,X21,Y21,Z21,IIA,IV,A,B,C,
     1            IK,XA,YA,ZA,CCC,XXX,LZ)
C
C
C     THIS SUBROUTINE TAKES THE PTS OF INTERSECTION DETERMINED BY
C     SUBROUTINE SOLVE AND PICKS THE COORDINATES WITH THE MAX AND
C     MIN X COORDINATES PROVIDED THEY LIE ON THE INTERIOR/BOUNDARY
C     OF BOTH ELEMENTS.
C
C
      INTEGER       XCC
      DIMENSION     XXX(1),CCC(1),X21(1),Y21(1),Z21(1),
     1              IIA(1),IV(1),XA(1),YA(1),ZA(1)
      COMMON/HDPTRS/XDUM,XCC
      COMMON/ZZZZZZ/RZ(1)
      COMMON/GO3/L0,L1,L00,L01,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13
C
      EXX=.015
      NX=0
      IF(MT.EQ.0)GO TO 160
      DO 50 JX=1,MT
      EI=0
   10 EI=EI+.1
      IF(EI .GE. 1.) GO TO 160
      D=EI*XA(JX)-YA(JX)
      DO 40 JO=1,2
      M=IV(JO)
      JC=L13+(M-1)*LZ
      JXC=L12+(M-1)*5
      NK=XXX(5+JXC)
      I=0
      IB=NK*5
C
C
C     DETERMINE IF THE PROJECTION OF THE POINT OF INTERSECTION
C     BELONGS TO THE INTERIOR OF BOTH PLANES.
C
C
      DO 30 J=1,IB,5
      EXX=.015
      NSUB=J+1+JC
      IF(ABS(CCC(NSUB)).GE.100.)EXX=ALOG10(ABS(CCC(NSUB)))
      VE=XA(JX)
      IF(CCC(J+JC).EQ.0.)VE=YA(JX)
      S=VE-CCC(J+3+JC)
      S1=VE-CCC(J+4+JC)
      T=CCC(J+JC)*YA(JX)+CCC(J+1+JC)*XA(JX)+CCC(J+2+JC)
      IF((ABS(T).LT.EXX).AND.(S*S1.LE.0.))GO TO 40
      T=-CCC(J+2+JC)+CCC(J+JC)*D
      R=EI*CCC(J+JC)+CCC(J+1+JC)
      IF(R.EQ.0.)GO TO 30
      T=T/R
      IF(T.LT.XA(JX))GO TO 30
      IF(CCC(J+JC).NE.0.)GO TO 20
      T=EI*T-D
   20 CONTINUE
      IF((T.EQ.CCC(J+3+JC)).OR.(T.EQ.CCC(J+4+JC)))GO TO 10
      S=T-CCC(J+3+JC)
      S1=T-CCC(J+4+JC)
      IF(S*S1.GT.0.)GO TO 30
      I=I+1
   30 CONTINUE
      IF(MOD(I,2).EQ.0)GO TO 50
   40 CONTINUE
      NX=NX+1
      XA(NX)=XA(JX)
      YA(NX)=YA(JX)
      ZA(NX)=ZA(JX)
   50 CONTINUE
      IF(NX.EQ.0)GO TO 160
C
C
C
C     THIS CODE FINDS THE MAX/MIN X-COORDINATES(Y-COORDINATES) AND
C     STORES THEM. FUTHERMORE BOTH THE EQUATION OF LINE AND POINTS(2)
C     ARE TREATED LIKE ADDITIONAL EDGES. IN THIS WAY, THE ALGORITHM NEED
C     NOT BE DISTURBED. ESSENTIALLY,THEN,THIS TRICK IS TRANSPARENT TO
C     THE REST OF THE PROGRAM.
C
C
      AMAXX=-(10**6)
      AMINX=-AMAXX
      AMAXY=AMAXX
      AMINY=AMINX
      IS=5+(IK-1)*5+L12
      IS=XXX(IS)
      DO 110 JI=1,NX
      IF(A.EQ.0.)GO TO 80
      IF(XA(JI).GE.AMINX)GO TO 60
      AMINX=XA(JI)
      YI=YA(JI)
      ZI=ZA(JI)
   60 IF(XA(JI).LE.AMAXX)GO TO 70
      AMAXX=XA(JI)
      YII=YA(JI)
      ZII=ZA(JI)
   70 CONTINUE
      GO TO 110
   80 CONTINUE
      IF(YA(JI).GE.AMINY)GO TO 90
      AMINY=YA(JI)
      XI=XA(JI)
      ZI=ZA(JI)
   90 CONTINUE
      IF(YA(JI).LE.AMAXY)GO TO 100
      XII=XA(JI)
      AMAXY=YA(JI)
      ZII=ZA(JI)
  100 CONTINUE
  110 CONTINUE
      NIT=NIT+1
      K=5*(NIT-1+IS)+1
      RZ(XCC+K-1)=A
      RZ(XCC+K  )=B
      RZ(XCC+K+1)=C
      IF (A.EQ.0.) GO TO 120
      RZ(XCC+K+2)=AMINX
      RZ(XCC+K+3)=AMAXX
      AMIN=AMINX
      AMAX=AMAXX
      YE=YII
      ZE=ZII
      GO TO 130
  120 CONTINUE
      RZ(XCC+K+2)=AMINY
      RZ(XCC+K+3)=AMAXY
      AMIN=XI
      AMAX=XII
      YI=AMINY
      YE=AMAXY
      ZE=ZII
  130 CONTINUE
      IG=IXR+NIT*3
      X21(IG-2)=AMIN
      Y21(IG-2)=YI
      Z21(IG-2)=ZI
      DO 140 JK=1,2
      IE=IG-JK+1
      X21(IE)=AMAX
      Y21(IE)=YE
      Z21(IE)=ZE
  140 CONTINUE
      DO 150 JK=1,2
      IIA(IG-JK)=0
  150 CONTINUE
      IIA(IG)=1
      TX=(AMAX-AMIN)**2
      TY=(YE-YI)**2
      DX=(TX+TY)**.5
      IF(DX.LT..001)NIT=NIT-1
  160 RETURN
      END
