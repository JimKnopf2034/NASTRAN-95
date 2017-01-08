      FUNCTION ITTYPE(ITEMX)
C
C*****
C
C     THIS FUNCTION RETURNS AN INTEGER CODE NUMBER TO INDICATE
C     WHETHER A PARTICULAR SOF ITEM IS A MATRIX OR TABLE.
C     THE RETURN CODES ARE
C
C          1 - MATRIX ITEM
C          0 - TABLE ITEM
C         -1 - ILLEGAL ITEM NAME
C
C*****
C
      COMMON / ITEMDT /       NITEM    ,ITEM(7,1)
C
      DO 10 I=1,NITEM
      IF(ITEMX .EQ. ITEM(1,I)) GO TO 20
   10 CONTINUE
C
C     ILLIGAL ITEM - RETURN -1
C
      ITTYPE = -1
      RETURN
C
C     ITEM FOUND - RETURN TYPE
C
   20 IF(ITEM(2,I) .LE. 0) ITTYPE = 0
      IF(ITEM(2,I) .GT. 0) ITTYPE = 1
      RETURN
      END
