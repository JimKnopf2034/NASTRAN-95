      DOUBLE PRECISION FUNCTION DADOTB( A, B )
      DOUBLE PRECISION A(3), B(3)
C*****
C  DOUBLE PRECISION VERSION
C
C  DOT PRODUCT  A . B
C*****
      DADOTB = A(1)*B(1) + A(2)*B(2) + A(3)*B(3)
      RETURN
      END
