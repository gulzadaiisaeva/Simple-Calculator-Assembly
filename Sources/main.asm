;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

;* GULZADA IISAEVA 131044085

;***********************ACIKLAMALAR*******************************
;* Bu odevde en fazla 2 basamak alabilecek sekilde yaptim.
;* 3 basamakli sayilar icin calismayacak
;* 



; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data
MYSTRING    EQU  $1200  
INT1        EQU  $1400
DEC1        EQU  $1408
INT2        EQU  $1418
DEC2        EQU  $1420
COUNTER     EQU  $1428
NOKTA       EQU  $1430
ARTI        EQU  $1432
EKSI        EQU  $1434
OPERATOR    EQU  $1438
ESIT        EQU  $1440
RESULT1     EQU  $1500
RESULT2     EQU  $1501
COUNTOFDEC1 EQU  $1441
COUNTOFDEC2 EQU  $1442


; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart
            ORG   MYSTRING
            FCC   "13.91+56.7="
           
            


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
            LDAA  #135 
            LDAA  #$2E
            STAA  NOKTA
            LDAA  #$2B
            STAA  ARTI
            LDAA  #$2D
            STAA  EKSI
            LDAA  #$3D
            STAA  ESIT
            LDAA  #0
            STAA  COUNTER
           
           
            
            
            LDX   #MYSTRING      ;X e string in baslangic adresini atama
            LDY   #INT1          ; ye ilk int part i atama
           
            
            JSR   FIRSTINT     ;ilk int part in basamak sayisi
            INX                   ; noktayi skip ettim
            CLR   COUNTER  
            JSR   SIZEOFDEC       ;decimal partin kac basamak oldugu
            
            LDAA  COUNTER
            JSR   DECRX0          ;decimal konumuna geri gelme
           
            LDY   #DEC1            ;dec1 adresini y 
            
            JSR   FIRSTDEC         ;decimali dec1'e atama
            LDAB  0,X                ; + OR - saklama
            STAB  OPERATOR
            INX
            CLR   COUNTER
            
            JSR   SIZEOFINT         ;2 int basamak sayisi
            LDAA  COUNTER           
            JSR   DECRX             ; X in konumunu geri alma
            LDY   #INT2            ;INT2 adresini y 
            JSR   SECINT          ;ikinci int basamak sayisi
            INX
           
            CLR   COUNTER
            
            JSR   SIZEOFDEC2     ; 2.decimal basamak sayisi
            
            LDAA  COUNTER          
            JSR   DECRX2          ;2.decimal konumuna geri gelme
            LDY   #DEC2            ;DEC2 adresini y 
            JSR   SECDEC           ; 2.basamak sayisnini dec2'ye atama
            
            
            LDAB  OPERATOR
            CMPB  ARTI             ;arti ise
            BEQ   HESAPARTI        
            JSR   HESAPEKSI        ;eksi ise
            JMP   ENDOF
;***************************************************************************            
;* Burda tek decimal sayilarin toplami 10 dan fazla ise ya da cift decimal 
;* sayilarin toplami 100 den fazla ise eldeyi alarak toplamaya calistim
;* ama toplam 126 yi gecince -sayilar ciktigi icin olmadi
;      
;  HESAPARTI:JSR   HESAP 
;            JMP   ENDOF         
;  HESAP:    LDAB  #1
;            CMPB  COUNTOFDEC1
;            BEQ   CONTROL
;  ISLEM:    LDAA  DEC1
;            LDAB  DEC2
;            ABA
;            STAA  RESULT2   
;            LDAA  INT1
;            LDAB  INT2
;            ABA
;            STAA RESULT1
;            RTS
;  CONTROL:  LDAB  #1
;            CMPB  COUNTOFDEC2
;            LDAA  DEC1
;            ADDA  DEC2
;            STAA  RESULT2
;            CMPA  #10
;            BHS   ISLEM2
;            LDAA  INT1
;            ADDA  INT2
;            STAA  RESULT1
;            RTS 
;  ISLEM2:   LDD   RESULT2 
;            LDX   #10
;            IDIV
;            STD   RESULT2
;            STX   RESULT1
;            LDAA  INT1
;            ADDA  INT2
;            ADDA  RESULT1
;            STAA  RESULT1
;            RTS

HESAPARTI:  LDAA  DEC1
            ADDA  DEC2
            STAA  RESULT2
            LDAA  INT1
            ADDA  INT2
            STAA  RESULT1
            JMP   ENDOF
HESAPEKSI:  LDAB  DEC1
            SUBB  DEC2
            STAB  RESULT2
            LDAB  INT1
            SUBB  INT2
            STAB  RESULT1
            RTS
                 
            
            
   
FIRSTINT:   LDAB  0,X            ;1 int kac basamak oldugunu belirtme
            CMPB  NOKTA 
            BEQ   NUMCHECK   
            INX
            INC   COUNTER
            BRA   FIRSTINT
            
NUMCHECK:   LDAB  #1              ;eger 1 basamakli ise
            CMPB  COUNTER
            BNE   ONEMORE
            LDX   #MYSTRING
            LDAB  0,X  
            INX
            SUBB  #48   
            STAB  INT1
            RTS
        
ONEMORE:    LDX   #MYSTRING       ;eger 1 den fazla basamak ise
            LDAA  #10
            LDAB  0,X
            INX
            SUBB  #48
            MUL
            STD   INT1
            LDAA  1,Y
            LDAB  0,X
            INX
            SUBB  #48
            ABA
            STAA  INT1      
            RTS
                      
            
SIZEOFDEC:  LDAB  0,X            ; decimal partin basamak sayisini belirtme
            CMPB  ARTI
            BEQ   RETURNJSR2
            CMPB  EKSI
            BEQ   RETURNJSR2
            INX
            INC   COUNTER
            LDAB  COUNTER
            STAB  COUNTOFDEC1
            BRA   SIZEOFDEC
RETURNJSR2: RTS   

DECRX0:     DEX 
            DECA
            BEQ   RETURNJSR1
            BRA   DECRX0
RETURNJSR1: RTS

FIRSTDEC:   LDAB  #1              ;decimal parti dec1 e atama eger 1 ise
            CMPB  COUNTER
            BNE   ONEMORE2
            LDAB  0,X
            INX
            SUBB  #48   
            STAB  DEC1
            RTS
   
 ONEMORE2:  LDAA  #10            ;eger 1 den fazla basamak varsa
            LDAB  0,X
            INX
            SUBB  #48
            MUL
            STD   DEC1
            LDAA  1,Y
            LDAB  0,X
            INX
            SUBB  #48
            ABA
            STAA  DEC1      
            RTS                 
                
SIZEOFINT:  LDAB  0,X            ;2in partin basamak sayisini belirtme
            CMPB  NOKTA
            BEQ   RETURNJSR3
            INX
            INC   COUNTER
            BRA   SIZEOFINT   
RETURNJSR3: RTS   
                                
DECRX:      DEX 
            DECA
            BEQ   RETURNJSR4
            BRA   DECRX
RETURNJSR4: RTS     

SECINT:     LDAB  #1              ;2.int parti int2 e atama eger 1 ise
            CMPB  COUNTER
            BNE   ONEMORE3
            LDAB  0,X
            INX
            SUBB  #48   
            STAB  INT2
            RTS
   
ONEMORE3:   LDAA  #10            ;eger 1 den fazla basamak varsa
            LDAB  0,X
            INX
            SUBB  #48
            MUL
            STD   INT2
            LDAA  1,Y
            LDAB  0,X
            INX
            SUBB  #48
            ABA
            STAA  INT2      
            RTS                   
SIZEOFDEC2: LDAB  0,X            ; 2.decimal partin basamak sayisini belirtme
            CMPB  ESIT
            BEQ   RETURNJSR5
            INX
            INC   COUNTER
            LDAB  COUNTER
            STAB  COUNTOFDEC2
            BRA   SIZEOFDEC2
RETURNJSR5: RTS 

DECRX2:     DEX 
            DECA
            BEQ   RETURNJSR6
            BRA   DECRX2
RETURNJSR6: RTS  

SECDEC:     LDAB  #1              ;2.decimal parti dec2 e atama eger 1 ise
            CMPB  COUNTER
            BNE   ONEMORE4
            LDAB  0,X
            INX
            SUBB  #48   
            STAB  DEC2
            RTS
   
ONEMORE4:   LDAA  #10            ;eger 1 den fazla basamak varsa
            LDAB  0,X
            SUBB  #48
            MUL
            STD   DEC2
            LDAA  1,Y
            INX
            LDAB  0,X
            SUBB  #48
            ABA
            STAA  DEC2      
            RTS              

ENDOF:      SWI
            RTS                               

; result in D

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
