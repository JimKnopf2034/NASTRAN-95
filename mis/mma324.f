      SUBROUTINE MMA324 ( ZI, ZD )
C
C     MMA324 PERFORMS THE MATRIX OPERATION IN COMPLEX DOUBLE PRECISION
C       (+/-)A(T & NT) * B (+/-)C = D
C     
C     MMA324 USES METHOD 32 WHICH IS AS FOLLOWS:
C       1.  THIS IS FOR "A" NON-TRANSPOSED AND TRANSPOSED
C       2.  CALL MMARM1 TO PACK AS MANY COLUMNS OF "A" INTO MEMORY 
C           AS POSSIBLE LEAVING SPACE FOR ONE COLUMN OF "B" AND "D".
C       3.  ADD EACH ROW TERM OF "C" TO "D" MATRIX COLUMN
C       4.  CALL MMARC1,2,3,4 TO READ COLUMNS OF "B" AND "C".
C
      INTEGER           ZI(2)      ,T
      INTEGER           TYPEI      ,TYPEP    ,TYPEU ,SIGNAB, SIGNC
      INTEGER           RD         ,RDREW    ,WRT   ,WRTREW, CLSREW,CLS
      INTEGER           OFILE      ,FILEA    ,FILEB ,FILEC , FILED
      DOUBLE PRECISION  ZD(2)
      DOUBLE COMPLEX    CDTEMP    ,CD
      INCLUDE           'MMACOM.COM'     
      COMMON / NAMES  / RD         ,RDREW    ,WRT   ,WRTREW, CLSREW,CLS
      COMMON / TYPE   / IPRC(2)    ,NWORDS(4),IRC(4)
      COMMON / MPYADX / FILEA(7)   ,FILEB(7) ,FILEC(7)    
     1,                 FILED(7)   ,NZ       ,T     ,SIGNAB,SIGNC ,PREC1 
     2,                 SCRTCH     ,TIME
      COMMON / SYSTEM / KSYSTM(152)
      COMMON / ZBLPKX / D(4)       ,KDROW
      COMMON / UNPAKX / TYPEU      ,IUROW1   ,IUROWN, INCRU
      COMMON / PACKX  / TYPEI      ,TYPEP    ,IPROW1, IPROWN , INCRP
      EQUIVALENCE       ( D(1)     ,CD    )
      EQUIVALENCE       (KSYSTM( 1),SYSBUF)  , (KSYSTM( 2),IWR   ) 
      EQUIVALENCE       (FILEA(2)  ,NAC   )  , (FILEA(3)  ,NAR   )
     1,                 (FILEA(4)  ,NAFORM)  , (FILEA(5)  ,NATYPE)
     2,                 (FILEA(6)  ,NANZWD)  , (FILEA(7)  ,NADENS)
      EQUIVALENCE       (FILEB(2)  ,NBC   )  , (FILEB(3)  ,NBR   )
     1,                 (FILEB(4)  ,NBFORM)  , (FILEB(5)  ,NBTYPE)
     2,                 (FILEB(6)  ,NBNZWD)  , (FILEB(7)  ,NBDENS)
      EQUIVALENCE       (FILEC(2)  ,NCC   )  , (FILEC(3)  ,NCR   )
     1,                 (FILEC(4)  ,NCFORM)  , (FILEC(5)  ,NCTYPE)
     2,                 (FILEC(6)  ,NCNZWD)  , (FILEC(7)  ,NCDENS)
      EQUIVALENCE       (FILED(2)  ,NDC   )  , (FILED(3)  ,NDR   )
     1,                 (FILED(4)  ,NDFORM)  , (FILED(5)  ,NDTYPE)
     2,                 (FILED(6)  ,NDNZWD)  , (FILED(7)  ,NDDENS)
C
C   OPEN CORE ALLOCATION AS FOLLOWS:
C     Z( 1        ) = ARRAY FOR ONE COLUMN OF "B" MATRIX IN COMPACT FORM
C     Z( IDX      ) = ARRAY FOR ONE COLUMN OF "D" MATRIX
C     Z( IAX      ) = ARRAY FOR MULTIPLE COLUMNS OF "A" MATRIX
C        THROUGH
C     Z( LASMEM   )
C     Z( IBUF4    ) = BUFFER FOR "D" FILE
C     Z( IBUF3    ) = BUFFER FOR "C" FILE
C     Z( IBUF2    ) = BUFFER FOR "B" FILE 
C     Z( IBUF1    ) = BUFFER FOR "A" FILE
C     Z( NZ       ) = END OF OPEN CORE THAT IS AVAILABLE
C
      FILED( 2 ) = 0
      FILED( 6 ) = 0
      FILED( 7 ) = 0
      IDROW = IBROW 
      DO 60000 II = 1, NBC
      CALL BLDPK ( NDTYPE, NDTYPE, OFILE, 0, 0 )
C      PRINT *,' PROCESSING B MATRIX COLUMN, II=',II
C      
C READ A COLUMN FROM THE "B" MATRIX
C
      SIGN   = 1
      IRFILE = FILEB( 1 )        
      CALL MMARC4 ( ZI, ZD )
      LASINDB = LASIND
C
C NOW READ "C", OR SCRATCH FILE WITH INTERMEDIATE RESULTS.
C IF NO "C" FILE AND THIS IS THE FIRST PASS, INITIALIZE "D" COLUMN TO ZERO.
C
      IF ( IFILE .EQ. 0 ) GO TO 950            
      IF ( IPASS .EQ. 1 ) SIGN = SIGNC
      IRFILE = IFILE
C      
C READ A COLUMN FROM THE "C" MATRIX
C
      CALL MMARC4 ( ZI( IDX ), ZD( IDX2+1 ) )
      LASINDC = LASIND + IDX - 1
950   CONTINUE
C
C CHECK IF COLUMN OF "B" IS NULL
C
      IF ( ZI( 1 ) .NE. 0 ) GO TO 1000
      IF ( IFILE .NE. 0 ) GO TO 960
951   CD = ( 0.0D0, 0.0D0)
      KDROW = 1
      CALL ZBLPKI
      GO TO 55000
960   IF ( ZI( IDX ) .EQ. 0 ) GO TO 951
      INDXC = IDX     
961   IF ( INDXC .GE. LASINDC ) GO TO 55000
      IROWC1 = ZI( INDXC )
      ICROWS = ZI( INDXC+1 )
      IROWCN = IROWC1 + ICROWS - 1
      INDXCV = ( INDXC+3 ) / 2 
      DO 970 I = IROWC1, IROWCN
      CD = DCMPLX( ZD( INDXCV ), ZD( INDXCV+1 ) ) 
      KDROW  = I
      CALL ZBLPKI
      INDXCV = INDXCV + 2
970   CONTINUE
      INDXC  = INDXC + 2 + ICROWS*NWDD
      GO TO 961
1000  CONTINUE
      IROWB1 = ZI( 1 )
      IROWS  = ZI( 2 ) 
      IROWBN = IROWB1 + IROWS - 1
      INDXB  = 1
      INDXA  = IAX
      INDXC  = IDX  
      IF ( IFILE .EQ. 0 .OR. INDXC .GE. LASINDC ) GO TO 9000
      IROWC1 = ZI( INDXC )
      ICROWS = ZI( INDXC+1 )
      IROWCN = IROWC1 + ICROWS - 1
1010  CONTINUE
C
C CHECK TO ADD TERMS FROM "C" OR INTERIM SCRATCH FILE BEFORE CURRENT ROW
C
      IF ( IDROW .EQ. 0 .OR. IROWC1 .GT. IDROW ) GO TO 9000
4000  CONTINUE
      IROWN = IDROW
      IF ( IROWCN .LT. IDROW ) IROWN = IROWCN
5000  CONTINUE
      INDXCV = ( INDXC+3 ) / 2
      NROWS = IROWN - IROWC1 + 1
      DO 6000 I = 1, NROWS
      KDROW = IROWC1 + I - 1
      CD = DCMPLX( ZD( INDXCV ), ZD( INDXCV+1 ) ) 
      INDXCV = INDXCV + 2
      CALL ZBLPKI
6000  CONTINUE
      IF ( IROWCN .GE. IDROW ) GO TO 9000
      INDXC = INDXC + 2 + ICROWS*NWDD
      IF ( INDXC .GE. LASINDC ) GO TO 9000
      IROWC1 = ZI ( INDXC )
      ICROWS = ZI ( INDXC+1 )
      IROWCN = IROWC1 + ICROWS - 1
      GO TO 4000
9000  CONTINUE
C      
C CHECK FOR NULL COLUMN FROM "B" MATRIX
C
      IF ( IROWB1 .EQ. 0 ) GO TO 50000
C
C  TRANSPOSE CASE ( A(T) * B + C )
C
C COMPLEX DOUBLE PRECISION
10000 CONTINUE
      DO 15000 I = 1, NCOLPP
      CD  = ( 0.0D0, 0.0D0 )
      KDROW  = IDROW + I
      ICOLA  = IBROW + I
      IF ( ICOLA .NE. IABS( ZI( INDXA ) ) ) GO TO 70001
      INDXAL = ZI( INDXA+1 ) + IAX - 1
      INDXA  = INDXA + 2
      INDXB  = 1
11000 IF ( INDXB .GE. LASINDB ) GO TO 14500
      IROWB1 = ZI( INDXB )
      IROWS  = ZI( INDXB+1 )
      IROWBN = IROWB1 + IROWS - 1
      INDXBS = INDXB
      INDXB  = INDXB + 2 + IROWS*NWDD
12000 CONTINUE
      IF ( INDXA .GE. INDXAL ) GO TO 14500
      IROWA1 = ZI( INDXA )
      NTMS   = ZI( INDXA+1 )
      IROWAN = IROWA1 + NTMS - 1
      IF ( IROWBN .LT. IROWA1 ) GO TO 11000
      IF ( IROWAN .LT. IROWB1 ) GO TO 14200
      IROW1  = MAX0( IROWA1, IROWB1 )
      IROWN  = MIN0( IROWAN, IROWBN )
      INDXAV = ( ( INDXA +3 ) / 2 ) + 2*( IROW1 - IROWA1 ) - 1
      INDXBV = ( ( INDXBS+3 ) / 2 ) + 2*( IROW1 - IROWB1 ) - 1
      CDTEMP = ( 0.0D0, 0.0D0)
      KCNT   = ( IROWN - IROW1 ) * 2 + 1
      DO 14000 K = 1, KCNT, 2
      CDTEMP = CDTEMP +  
     &         DCMPLX( ZD( INDXAV+K), ZD( INDXAV+K+1 ) ) * 
     &         DCMPLX( ZD( INDXBV+K), ZD( INDXBV+K+1 ) ) 
14000 CONTINUE                                                
      CD = CD + CDTEMP
      IF ( IROWAN .GT. IROWBN ) GO TO 11000
14200 CONTINUE
      INDXA  = INDXA + 2 + NTMS*NWDD
      GO TO 12000
14500 INDXA  = INDXAL
14510 IF ( INDXC .GE. LASINDC .OR. IFILE .EQ. 0 ) GO TO 14600
      IF ( KDROW .LT. IROWC1 ) GO TO 14600
      IF ( KDROW .GT. IROWCN ) GO TO 14550
      INDXCV  = ( INDXC+3 ) / 2 + 2*( KDROW - IROWC1 )
      CD = CD + DCMPLX( ZD( INDXCV ), ZD( INDXCV+1 ) )
      GO TO 14600
14550 INDXC   = INDXC + 2 + ICROWS*NWDD
      IF ( INDXC .GE. LASINDC ) GO TO 14600
      IROWC1  = ZI( INDXC )
      ICROWS  = ZI( INDXC+1 )
      IROWCN  = IROWC1 + ICROWS - 1
      GO TO 14510
14600 CONTINUE
      CALL ZBLPKI
15000 CONTINUE
50000 CONTINUE
      IF ( KDROW .EQ. NDR .OR. IFILE .EQ. 0 .OR. INDXC .GE. LASINDC ) 
     &    GO TO 55000
C
C ADD REMAINING TERMS FROM EITHER THE "C" MATRIX OR INTERIM SCRATCH MATRIX
C
      IROW1 = KDROW + 1
50100 CONTINUE
      INDXCV = ( INDXC+3 ) / 2
      IF ( IROW1 .LT. IROWC1 ) GO TO 51000
      IF ( IROW1 .LE. IROWCN ) GO TO 50900
      INDXC   = INDXC + 2 + ICROWS*NWDD
      IF ( INDXC .GE. LASINDC ) GO TO 55000
      IROWC1  = ZI( INDXC )
      ICROWS  = ZI( INDXC+1 )
      IROWCN  = IROWC1 + ICROWS - 1
      GO TO 50100
50900 CONTINUE
      INDXCV = ( INDXC+3 ) / 2 + 2*( IROW1 - IROWC1 )
      IROWC1 = IROW1
51000 CONTINUE
      NROWS = IROWCN - IROWC1 + 1
      DO 51500 K = 1, NROWS
      KDROW = IROWC1 + K - 1
      CD = DCMPLX( ZD( INDXCV ), ZD( INDXCV+1 ) ) 
      INDXCV = INDXCV + 2
      CALL ZBLPKI
51500 CONTINUE
      INDXC   = INDXC + 2 + ICROWS*NWDD
      IF ( INDXC .GE. LASINDC ) GO TO 55000
      IROWC1  = ZI( INDXC )
      ICROWS  = ZI( INDXC+1 )
      IROWCN  = IROWC1 + ICROWS - 1
      INDXCV  = ( INDXC+3 ) / 2
      GO TO 51000
55000 CONTINUE
      CALL BLDPKN ( OFILE, 0, FILED )
C END OF PROCESSING THIS COLUMN FOR THIS PASS
60000 CONTINUE
      GO TO 70000
70001 CONTINUE
      WRITE ( IWR, 90001 ) ICOLA, ZI( INDXA ), IAX, INDXA
90001 FORMAT(' UNEXPECTED COLUMN FOUND IN PROCESSING MATRIX A'
     &,/,' COLUMN EXPECTED:',I6
     &,/,' COLUND FOUND   :',I6
     &,/,' IAX =',I7,' INDXA=',I7 )
      CALL MESAGE ( -61, 0, 0 )
70000 RETURN
      END
