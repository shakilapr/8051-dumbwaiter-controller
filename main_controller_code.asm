
     ORG 0000H
     MOV R5, 0 
     LJMP    MAIN
;Timer 0 Interrupt to detect errors
     ORG 000BH
     INC R5
     MOV A, R5
     CJNE    A, #152, BELOWC
     LJMP    ALARM
BELOWC:
     RETI

MAIN:
     ACALL   CLEAR
     ACALL   INTRRUPT
     ACALL   POSITION
     ACALL   BELL
     SJMP    MAIN

; To check the door and load cell
DOORNWEIGHT:
;Check the door
     JNB P1.0, ALARM
; Check the Load cell (>= 250)
     JNB P1.1, ALARM
     RET

ALARM:
     SETB    P2.7        ; On the Alarm
     SETB    P2.3        ; ON RED LED
     MOV R0, 50
     ACALL   DELAY
     CLR P2.7
     CLR P2.3
     SETB    P1.4        ; OFF RED LED
     SJMP    MAIN

BELL:
     SETB    P2.7        ; ON Bell
     SETB    P2.3
     MOV R1, 1
     MOV R0, 10
     ACALL   DELAY
     CLR P2.7        ; OFF Bell
     LJMP    MAIN
     CLR P2.3
     RET

POSITION:
     ACALL   LEVEL
;; KITCHEN FLOOR
; If the position is kitchen floor
     JNB B.6, GROUND_FLOOR
     SETB    P3.6
; Then check whether the ground floor button is ON
     ACALL   KEYPAD
     JNB B.2, BUTTON2
     ACALL   DOORNWEIGHT
     SETB    P3.2    
     CLR P2.4
     ACALL   MOTORDOWNFK
     RET

; If the ground floor button is OFF, then check whether the 2ND floor button is ON
BUTTON2:
     JNB B.4, MAIN
     ACALL   DOORNWEIGHT
     SETB    P3.4
     ACALL   MOTORUPFK
     RET

;; GROUND FLOOR
; If the position is ground floor
GROUND_FLOOR:
     JNB B.5, SECOND_FLOOR
     SETB    P3.5
     ; Then check whether the RETURN button is ON
     ACALL   KEYPAD
     JNB B.3, MAIN
     ACALL   DOORNWEIGHT
     SETB    P3.3
     ACALL   MOTORUP
     RET

;; 2ND FLOOR
;If the position is 2ND floor
SECOND_FLOOR:
     JNB B.7, MAIN
     SETB    P3.7
     ; Then check whether the RETURN button is ON
     ACALL   KEYPAD
     JNB B.3, MAIN
     ACALL   DOORNWEIGHT
     SETB    P3.3
     ACALL   MOTORDOWN
     RET

LEVEL:
     SETB    P2.5    ; Switch ON GREEN LED
LEVEL_LOOP:
     CLR C       ; Clear the carry flag
     MOV B, P1
     CPL B.5     ; Complement the value
     CPL B.6
     CPL B.7
     ORL C, B.5      ; OR Instruction
     ORL C, B.6
     ORL C, B.7
;    MOV C, CY
     JNB CY, LEVEL_LOOP  ; Jump back to the start of the KEYLOOP loop if the carry flag is not set
     RET

KEYPAD:
     SETB    P3.1
KEYLOOP:
     CLR C       ; Clear the carry flag
     MOV B, P1
     CPL B.2     ; Complement the value
     CPL B.3
     CPL B.4
     ORL C, B.2      ; OR Instruction
     ORL C, B.3
     ORL C, B.4
     MOV C, CY
     JNB CY, KEYLOOP ; Jump back to the start of the KEYLOOP loop if the carry flag is not set
     CLR P3.1
     RET

MOTORUPFK:
     SETB    P2.4        ; Switch ON Yellow LED
     CLR     P2.5        ; Switch OFF Green LED
     SETB    TR0     ; Start Timer 0
     SETB    P2.0        ; Set bit 0 of P1 to high (CW)
     CLR P2.1        ; Clear bit 1 of P1 (CCW)
LOOP1:
     SETB    P2.2        ; Set bit 2 of P1 to high (Enable)
     SETB    P3.0
     ACALL   DELAYMS
     CLR P2.2
     ACALL   DELAYMS
     CLR C       ; Clear the carry flag
     MOV C, P1.7
     MOV C, CY
     JB  CY, LOOP1
     CLR TR0     ;stop Timer 0
     CLR P2.2
     CLR P3.0
     CLR TR0     ; Stop Timer 0
     RET

MOTORDOWNFK:
     SETB    P2.4        ; Switch ON Yellow LED
     CLR     P2.5        ; Switch OFF Green LED
     SETB    TR0     ; Start Timer 0
     CLR P2.0        ; Set bit 0 of P1 to high (CW)
     SETB    P2.1        ; Clear bit 1 of P1 (CCW)
LOOP2:
     SETB    P2.2        ; Set bit 2 of P1 to high (Enable)
     SETB    P3.0
     ACALL   DELAYMS
     CLR P2.2
     ACALL   DELAYMS
     CLR C       ; Clear the carry flag
     MOV C, P1.5
     MOV C, CY
     JB  CY, LOOP2
     CLR P2.2 ; STOP the motor
     CLR P3.0 
     CLR TR0     ; Stop Timer 0
     RET

MOTORUP:
     SETB    P2.4        ; Switch ON Yellow LED
     CLR     P2.5        ; Switch OFF Green LED
     SETB    TR0     ; Start Timer 0
     SETB    P2.0        ; Set bit 0 of P1 to high (CW)
     CLR P2.1        ; Clear bit 1 of P1 (CCW)
LOOP3:
     SETB    P2.2        ; Set bit 2 of P1 to high (Enable)
     SETB    P3.0
     ACALL   DELAYMS
     CLR P2.2
     ACALL   DELAYMS
     CLR C       ; Clear the carry flag
     MOV C, P1.6
     MOV C, CY
     JB  CY, LOOP3
     CLR P2.2
     CLR P3.0
     CLR TR0     ; Stop Timer 0
     RET

MOTORDOWN:
     SETB    P2.4        ; Switch ON Yellow LED
     CLR     P2.5        ; Switch OFF Green LED
     SETB    TR0     ; Start Timer 0
     CLR P2.0        ; Set bit 0 of P1 to high (CW)
     SETB    P2.1        ; Clear bit 1 of P1 (CCW)
LOOP4:
     SETB    P2.2        ; Set bit 2 of P1 to high (Enable)
     SETB    P3.0
     ACALL   DELAYMS
     CLR P2.2
     ACALL   DELAYMS
     CLR C       ; Clear the carry flag
     MOV C, P1.6
     MOV C, CY
     JB  CY, LOOP4
     CLR P2.2
     CLR P3.0
     CLR TR0     ; Stop Timer 0
     RET

INTRRUPT:
;to make interrupts
     MOV TMOD, #00000001B    ;both timers in Mode 1
     MOV IE, #10000010B  ;enable Timer O and 1 interrupts
     MOV TL0, #0     ;load count in Timer O 
     MOV TL0, #0     ;load count in Timer O 

CLEAR:
     MOV P3, 0
     CLR P2.3
     CLR P2.4
     CLR P2.5
     CLR P2.7
     RET

; 50 microsecond delay
DELAYMS:
     MOV R0, #24
DL0:     DJNZ    R0, DL0
     RET

; To make required delays 
DELAY:
L2: MOV R1, #210
L1: MOV R2, #255
     DJNZ    R2, $
     DJNZ    R1, L1
     DJNZ    R0, L2
     RET
     END
