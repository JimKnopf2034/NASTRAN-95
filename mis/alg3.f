      FUNCTION ALG3 (P,H)
C
      COMMON /GAS/ G,EJ,R,CP,GAMMA,ROJCP
C
      ALG3=CP*ALOG(H/CP)-R/EJ*ALOG(P)
      RETURN
      END
