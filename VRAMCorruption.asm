	;;;; HEADER AND COMPILER STUFF ;;;;
	.inesprg 1  ; 2 banks
	.ineschr 1  ; 
	.inesmap 0  ; mapper 0 = NROM
	.inesmir 0  ; background mirroring

; constants
_0 = $00
_1 = $01
_2 = $02
_3 = $03
_4 = $04
_5 = $05
_6 = $06
_7 = $07
_8 = $08
_9 = $09
_A = $0A
_B = $0B
_C = $0C
_D = $0D
_E = $0E
_F = $0F
_G = $10
_H = $11
_I = $12
_J = $13
_K = $14
_L = $15
_M = $16
_N = $17
_O = $18
_P = $19
_Q = $1A
_R = $1B
_S = $1C
_T = $1D
_U = $1E
_V = $1F
_W = $20
_X = $21
_Y = $22
_Z = $23
__ = $24
_. = $25
_xm = $26
_qm = $27
_sc = $28

_0. = $80
_1. = $81
_2. = $82
_3. = $83
_4. = $84
_5. = $85
_6. = $86
_7. = $87
_8. = $88
_9. = $89
_A. = $8A
_B. = $8B
_C. = $8C
_D. = $8D
_E. = $8E
_F. = $8F
_G. = $90
_H. = $91
_I. = $92
_J. = $93
_K. = $94
_L. = $95
_M. = $96
_N. = $97
_O. = $98
_P. = $99
_Q. = $9A
_R. = $9B
_S. = $9C
_T. = $9D
_U. = $9E
_V. = $9F
_W. = $A0
_X. = $A1
_Y. = $A2
_Z. = $A3
__. = $A4
_.. = $A5
_xm. = $A6
_qm. = $A7
_sc. = $A8

GenericPointer = $40
MSG_Highlight = $42
MSG_Length = $43
MainScreenNMIMode = $10
TestIndex = $80
PrevTestIndex = $81

	
	;;;; ASSEMBLY CODE ;;;;
	.org $8000
	
Reset:
	SEI	; disable interrupts
	LDA #0	; initialize the A, X, and Y registers with 0s
	LDX #0
	LDY #0

	STA $2000
	STA $2001
	
	; Stall for 2 frames
	
Loop1:
	LDA $2002
	BPL Loop1
Loop2:
	LDA $2002
	BPL Loop2	
	
	JSR MainScreen	
	
	LDA #0	; initialize the A, X, and Y registers with 0s
	LDX #0
	LDY #0

	STA $2000
	STA $2001
	
	; Okay, now the PPU is ready.
	; set up palette stuff
	
	LDA #$3F
	STA $2006
	STY $2006 ; Y = 0
	; PPU ADDR is at $3F00, the palette info

	LDX #0

PaletteLoop:
	LDA DefaultPalette, X	; load palette color from LUT
	STA $2007				; store it in the PPU
	INX						; increment X
	CPX #31 				; once X is 32, we got all the colors.
	BNE PaletteLoop			; if not X !=32, loop
	
	; overwrite the entire nametable
	
	LDA #$20
	STA $2006 
	LDA #$00
	STA $2006 
	
	LDX #$00
	LDY #$04
	LDA #$00

	JSR ResetBackground

	
	; everything is ready.
	
	; Let's enable rendering	
	; Set screen position / scroll
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006	
	STA $2005
	STA $2005
	; sets the PPU registers to enable rendering, enable NMI
	LDA #$90
	STA $2000
	LDA #$0A
	STA $2001
		
	SEI; make sure interrupts are disabled.

	LDY #0 ; for the test

InfiniteLoop;
	JMP InfiniteLoop
	; an infinite loop, as opposed to a HLT instruction.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DefaultPalette:
	.byte $0F, $2A, $36, $0C
	.byte $0F, $2A, $36, $04
	.byte $0F, $2A, $36, $0A
	.byte $0F, $2A, $36, $05
	
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	
AttributeTablePattern:
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
	.byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55


MainScreenPalette:
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainScreen:

	; set up main screen
	LDA #$3F
	STA $2006 
	LDA #$00
	STA $2006 
PaletteLoopMainScreen:
	LDA MainScreenPalette, X; load palette color from LUT
	STA $2007				; store it in the PPU
	INX						; increment X
	CPX #31 				; once X is 32, we got all the colors.
	BNE PaletteLoopMainScreen; if not X !=32, loop
	
	; overwrite the entire nametable	
	LDA #$20
	STA $2006 
	LDA #$00
	STA $2006 	
	LDX #$00
	LDY #$04
	LDA #$24	; with the value 24
NTClearMain:
	STA $2007
	DEX
	BNE NTClearMain
	DEY
	BNE NTClearMain	
	LDA #$23
	STA $2006 
	LDA #$C0
	STA $2006 
	LDX #$40	
	LDA #0
ATSetupMain:
	STA $2007
	DEX
	BNE ATSetupMain

	; now to print a bunch of messages.
	; let's simpllify, maaaan.
	
	LDX #0
MainPrintAllLoop:
	JSR PrintMessage
	INX
	CPX #13	; index 12 is the "select..." message
	BNE MainPrintAllLoop
	
	LDA #1
	STA <MSG_Highlight
	LDX <TestIndex
	JSR PrintMessage
	DEC <MSG_Highlight
	; screen is ready. enable rendering and NMI
	
	LDA #01
	STA <MainScreenNMIMode
	
	; Set screen position / scroll
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006	
	STA $2005
	STA $2005
	; and nmi stuff
	LDA #$80
	STA $2000
	LDA #$0A
	STA $2001
	
	; all interaction happens inside the NMI
MainSpin:
	LDA <MainScreenNMIMode	; main screen indicator for NMI
	BNE MainSpin

	LDA #0
	STA <$03
	
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintMessage:
	; the X register holds the message to print
	; MSG_Highlight holds 1 if the message needs highlighted

	TXA
	PHA
	ASL A
	TAX
	LDA MessageIndex, X
	STA <GenericPointer
	INX
	LDA MessageIndex, X
	STA <GenericPointer+1
	LDY #0
	LDA [GenericPointer], Y
	STA MSG_Length
	INY 
	LDA [GenericPointer], Y
	STA $2006
	INY 
	LDA [GenericPointer], Y
	STA $2006
	LDX #0
	INY
	LDA <MSG_Highlight
	BNE PrintMSGLoopHighlight
	
PrintMSGLoop:
	LDA [GenericPointer], Y
	STA $2007
	INX 
	INY
	CPX <MSG_Length
	BNE PrintMSGLoop	
	PLA
	TAX
	RTS
PrintMSGLoopHighlight:
	LDA [GenericPointer], Y
	ORA #$80
	STA $2007
	INX 
	INY
	CPX <MSG_Length
	BNE PrintMSGLoopHighlight	
	PLA
	TAX
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
MSG_Main:
	.byte 16, $20, $64, _S, _E, _L, _E, _C, _T, __, _T, _H, _E, __, _T, _E, _S, _T, _sc
	
MSG_ASL:
	.byte 3, $20, $A4, _A, _S, _L
MSG_ROL:
	.byte 3, $20, $C4, _R, _O, _L
MSG_LSR:
	.byte 3, $20, $E4, _L, _S, _R
MSG_ROR:
	.byte 3, $21, $04, _R, _O, _R
MSG_DEC:
	.byte 3, $21, $24, _D, _E, _C
MSG_INC:
	.byte 3, $21, $44, _I, _N, _C
MSG_ASL_X:
	.byte 6, $21, $64, _A, _S, _L, __, _., _X
MSG_ROL_X:
	.byte 6, $21, $84, _R, _O, _L, __, _., _X
MSG_LSR_X:
	.byte 6, $21, $A4, _L, _S, _R, __, _., _X
MSG_ROR_X:
	.byte 6, $21, $C4, _R, _O, _R, __, _., _X
MSG_DEC_X:
	.byte 6, $21, $E4, _D, _E, _C, __, _., _X
MSG_INC_X:
	.byte 6, $22, $04, _I, _N, _C, __, _., _X	
	
	
	
	
	
MessageIndex:
	.word MSG_ASL
	.word MSG_ROL
	.word MSG_LSR
	.word MSG_ROR
	.word MSG_DEC
	.word MSG_INC
	.word MSG_ASL_X
	.word MSG_ROL_X
	.word MSG_LSR_X
	.word MSG_ROR_X
	.word MSG_DEC_X
	.word MSG_INC_X
	.word MSG_Main
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.org $9000
NMI_Vector: ; Both the IRQ and NMI point here.
	; Disable NMI
	LDA #$10
	STA $2000
	
	; copy prev controller input
	
	LDA <$00
	STA <$01
	
	LDA <MainScreenNMIMode
	BEQ TestModeNMI
	
	LDA #$00
	STA $2000
	JMP MainScreenNMI
	
TestModeNMI:	
	; read controller
	
	LDA #1
	STA $4016
	LSR A
	STA $4016
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	EOR #$C0
	
	STA <$00

	CMP <$01
	BEQ TestForBButton
	AND #$80
	CMP #$80
	BNE TestForBButton
	; The A button was pressed.
	JSR RunTest	
	JMP ExitNMI
	
	
TestForBButton:
	
	LDA <$00
	CMP <$01
	BEQ TestForStart
	CMP #$40
	BNE TestForStart	
	LDX #$FD
	TXS
	JMP Reset
	
TestForStart:
	LDA <$00
	AND #$10
	CMP #$10
	BNE TestForSelect
	JSR RunTest	; start can be held for convenience
	JMP ExitNMI
	
TestForSelect:
	LDA <$00
	AND #$20
	CMP #$20
	BNE ExitNMI
	JSR RunTest2	; select can be held for convenience
	JMP ExitNMI
	
ExitNMI:
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006	
	STA $2005
	STA $2005

	
LazyWaitForLater:
	LDA $2002
	BPL LazyWaitForLater
LazyWaitForLater2:
	LDA $2002
	BPL LazyWaitForLater2
	
	; sets the PPU registers to enable rendering, enable NMI
	LDA #$0A
	STA $2001
	; Enable NMI
	LDA #$90
	STA $2000
	RTI
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainScreenNMI:

	; Real controller reading.

	LDA #1
	STA $4016
	LSR A
	STA $4016
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	EOR #$C0
	
	STA <$00

	AND #$80
	BEQ DidNotPressTheAButton
	; We pressed the A button. We're about to start a test.
	LDA #$80
	STA <$00
	STA <$01
	LDA #0
	STA <MainScreenNMIMode
	JMP ExitMainNMI
	
DidNotPressTheAButton:

	LDA <$00
	AND #$4
	BEQ DidNotPressTheDButton
	; We pressed down. increment the index, and draw some messages
	LDA <TestIndex
	STA <PrevTestIndex
	INC <TestIndex
	LDA <TestIndex
	CMP #12
	BNE PressedDownNoOverflow
	LDA #0
	STA <TestIndex
PressedDownNoOverflow:
	;clear message for prev index
	LDX <PrevTestIndex
	JSR PrintMessage
	INC <MSG_Highlight
	LDX <TestIndex
	JSR PrintMessage
	DEC <MSG_Highlight
	JMP ExitMainNMI
DidNotPressTheDButton:

	LDA <$00
	AND #$8
	BEQ DidNotPressTheUButton
	; We pressed down. increment the index, and draw some messages
	LDA <TestIndex
	STA <PrevTestIndex
	DEC <TestIndex
	LDA <TestIndex
	CMP #$FF
	BNE PressedUpNoUnderflow
	LDA #11
	STA <TestIndex
PressedUpNoUnderflow:
	;clear message for prev index
	LDX <PrevTestIndex
	JSR PrintMessage
	INC <MSG_Highlight
	LDX <TestIndex
	JSR PrintMessage
	DEC <MSG_Highlight
	JMP ExitMainNMI
DidNotPressTheUButton:
	
ExitMainNMI:

; Set screen position / scroll
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006	
	STA $2005
	STA $2005	

LazyWaitForLater3:
	LDA $2002
	BPL LazyWaitForLater3
LazyWaitForLater4:
	LDA $2002
	BPL LazyWaitForLater4

	; Set screen position / scroll
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006	
	STA $2005
	STA $2005	
	; sets the PPU registers to enable rendering, enable NMI
	LDA #$0A
	STA $2001
	; Enable NMI
	LDA #$80
	STA $2000
	RTI
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ResetBackground:
	; overwrite the entire nametable	
	LDA #$20
	STA $2006 
	LDA #$00
	STA $2006 	
	LDX #$00
	LDY #$04
	LDA #$00
NTClear:
	STA $2007
	DEX
	BNE NTClear
	DEY
	BNE NTClear	
	LDA #$23
	STA $2006 
	LDA #$D0
	STA $2006 
	LDX #$30	
ATSetup:
	LDA AttributeTablePattern-1, X
	STA $2007
	DEX
	BNE ATSetup
	
	LDX #0
	LDA #$22
	STA $2006 
	LDA #$00
	STA $2006 
	LDA #$FF
GreenLoop:
	STA $2007
	DEX
	BNE GreenLoop
	
	RTS
	
	
RunTest2:
	LDA #4
	STA <$83
RunTest:

	LDA #0
	STA $2001 ; clear rendering

	STY <$03 ; record current test number
	
	JSR ResetBackground
	
	LDY <$03 ; fetch current test number
	
	LDA #$21
	STA $2006 
	LDA #$00
	STA $2006 	
	
	LDA <$00
	AND #$01
	BEQ NotPressingRight
	LDA #$20
	STA $2006 
	LDA #$00
	STA $2006 	
NotPressingRight:

	LDA <$00
	AND #$02
	BEQ NotPressingLeft
	LDA #$22
	STA $2006 
	LDA #$00
	STA $2006 	
NotPressingLeft:
	
	LDA <$00
	AND #$08
	BEQ NotPressingUp
	LDA $2007
NotPressingUp:
	
	CPY #0
	BEQ RMW2007
TestLoop:
	LDA $2007
	DEY
	BNE TestLoop
RMW2007:


	
	
	LDA TestIndex
	ASL A
	TAX 
	LDA TestJumpTable, X
	STA <GenericPointer
	INX
	LDA TestJumpTable, X
	STA <GenericPointer+1
	JMP [GenericPointer]
	
TestJumpTable:
	.word Test_ASL
	.word Test_ROL
	.word Test_LSR
	.word Test_ROR
	.word Test_DEC
	.word Test_INC
	.word Test_ASL_X
	.word Test_ROL_X
	.word Test_LSR_X
	.word Test_ROR_X
	.word Test_DEC_X
	.word Test_INC_X

Test_ASL:
	ASL $2007
	JMP PostTest

Test_ROL:
	ROL $2007
	JMP PostTest

Test_LSR:
	LSR $2007
	JMP PostTest

Test_ROR:
	ROR $2007
	JMP PostTest
	
Test_DEC:
	DEC $2007
	JMP PostTest

Test_INC:
	INC $2007
	JMP PostTest

Test_ASL_X:
	LDX #0
	ASL $2007, X
	JMP PostTest

Test_ROL_X:
	LDX #0
	ROL $2007, X
	JMP PostTest

Test_LSR_X:
	LDX #0
	LSR $2007, X
	JMP PostTest

Test_ROR_X:
	LDX #0
	ROR $2007, X
	JMP PostTest
	
Test_DEC_X:
	LDX #0
	DEC $2007, X
	JMP PostTest

Test_INC_X:
	LDX #0
	INC $2007, X
	JMP PostTest


PostTest:

	LDA <$83
	BEQ EndTest
	DEC <$83
	JMP RMW2007

EndTest:
	LDY <$03 ; fetch current test number
	INY ; for next test
	RTS	
	
	
	.bank 1
	.org $BFFA	; Interrupt vectors go here:
	.word $9000 ; NMI
	.word $8000 ; Reset
	.word $9000 ; IRQ

	;;;; MORE COMPILER STUFF, ADDING THE PATTERN DATA ;;;;

	.incchr "Sprites.pcx"
	.incchr "Tiles.pcx"