	;; N: Device Handler written for MADS

	;; Author: Thomas Cherryhomes
	;;   <thom.cherryhomes@gmal.com>

	org 	$2300

	;; Page 0
	
BOOT	equ	$09
DOSINI	equ	$0C
ZIOCB	equ	$20
ZICHID	equ	ZIOCB
ZICDNO	equ	ZIOCB+1
ZICCOM	equ	ZIOCB+2
ZICSTA	equ	ZIOCB+3
ZICBAL	equ	ZIOCB+4
ZICBAH	equ	ZIOCB+5
ZICPTL	equ	ZIOCB+6
ZICPTH	equ	ZIOCB+7
ZICBLL	equ	ZIOCB+8
ZICBLH	equ	ZIOCB+9
ZICAX1	equ	ZIOCB+10
ZICAX2	equ	ZIOCB+11
ZICAX3	equ	ZIOCB+12
ZICAX4	equ	ZIOCB+13
ZICAX5	equ	ZIOCB+14
ZICAX6	equ	ZIOCB+15
	
	;; Page 2

VPRCED	equ	$0202
COLOR2	equ	$02C6
MEMLO	equ	$02E7
DVSTAT	equ	$02EA
	
	;; Page 3

	;; Device Control Block
	
DCB	equ	$0300
DDEVIC	equ	DCB
DUNIT	equ	DCB+1
DCOMND	equ	DCB+2
DSTATS	equ	DCB+3
DBUFL	equ	DCB+4
DBUFH	equ	DCB+5
DTIMLO	equ	DCB+6
DRSVD	equ	DCB+7
DBYTL	equ	DCB+8
DBYTH	equ	DCB+9
DAUXL	equ	DCB+10
DAUXH	equ	DCB+11

HATABS	equ	$031A

	;; IO Control Blocks (IOCB) x 8

IOCB	equ	$0340
ICHID	equ	IOCB
ICDNO	equ	IOCB+1
ICCOM	equ	IOCB+2
ICSTA	equ	IOCB+3
ICBAL	equ	IOCB+4
ICBAH	equ	IOCB+5
ICPTL	equ	IOCB+6
ICPTH	equ	IOCB+7
ICBLL	equ	IOCB+8
ICBLH	equ	IOCB+9
ICAX1	equ	IOCB+10
ICAX2	equ	IOCB+11
ICAX3	equ	IOCB+12
ICAX4	equ	IOCB+13
ICAX5	equ	IOCB+14
ICAX6	equ	IOCB+15

	;; Hardware registers

PACTL	equ	$D302

	;; OS ROM Vectors

CIOV	equ	$E456
SIOV	equ	$E459

	;; Constants

PUTREC	equ	$09
DEVIDN	equ	$71
DSREAD	equ	$40
DSWRIT	equ	$80
MAXDEV	equ	4
EOF	equ	$88
EOL	equ	$9B

	;; Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org	$2300

START	jsr	IHTBS		; Go ahead and install driver; adjust MEMLO

	;; Save current DOSINI, also patch RESET so that we
	;; can jump to it, when reset starts.
	
	lda	DOSINI		
	sta	DSAV
	sta	RESET+1		; Modify LO address of JSR instruction
	lda	DOSINI+1
	sta	DSAV+1
	sta	RESET+2		; Modify HI address of JSR instruction

	;; And install the new DOSINI vector.
	
	lda	#<RESET	
	sta	DOSINI
	lda	#>RESET
	sta	DOSINI+1
	jmp	(DSAV)		; go ahead and jump through old vector.

	;; The new DOSINI vector, calls IHTBS to reinsert our N:
	;; driver into HATABS, thereby being able to survive a warm start.

RESET	jsr	$FFFF		; self-modified address to saved DOSINI.	
	jsr	IHTBS		; Re-install driver. also adjusts MEMLO.
	rts			; and we're done.

	;; Install driver into HATABS

IHTBS	ldy	#$00
H1	lda	HATABS,y
	beq	HFND
	cmp	#'N'
	beq	HFND
	iny
	iny
	iny
	cpy	#11*3
	bcc	H1

	;; Either found empty spot, or extant N: entry

HFND	lda	#'N'
	sta	HATABS,y
	lda	#<CIOHND
	sta	HATABS+1,y
	lda	#>CIOHND
	sta	HATABS+2,y

	;; move MEMLO

	lda	#<PGEND
	sta	MEMLO
	lda	#>PGEND
	sta	MEMLO+1

	;; Query #FujiNet

	jsr	STPOLL

	;; Output appropriate banner

OBANR	ldx	#$00		; IOCB 0
	lda	#PUTREC
	sta	ICCOM,x
	sta	ICBLH,x
	lda	#$28		; 40 columns max
	sta	ICBLL,x
	lda	DSTATS		; get poll status
	bpl	OBRDY		; Ready if < 128 :)

	;; Status poll failed, show error banner.
	
OBERR	lda	#<BERROR
	sta	ICBAL,X
	lda	#>BERROR
	sta	ICBAH,X
	bvc	OBCIO		; always branch.

	;; Status poll succeeded, show ready banner.
	
OBRDY	lda	#<BREADY
	sta	ICBAL,x
	lda	#>BREADY
	sta	ICBAH,x
	bvc	OBCIO		; always branch.

OBCIO	jsr	CIOV
	

	;; Vector in PROCEED interrupt

SPRCED	lda	#<PRCVEC
	sta	VPRCED
	lda	#>PRCVEC
	sta	VPRCED+1

	;; Done with initialization

	rts

	;; Proceed ISR
	
PRCVEC	lda	#$01
	sta	TRIP
	pla
	rti
	
	;; CIO Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Open
	
OPEN	jsr	GDIDX
	
	;; Fill in DCB

	lda	ZICDNO
	sta	OPNDCB+1
	lda	ZICBAL
	sta	OPNDCB+4
	lda	ZICBAH
	sta	OPNDCB+5
	lda	ZICAX1
	sta	OPNDCB+10
	lda	ZICAX2
	sta	OPNDCB+11

	;; set up DCB
	ldy	#$0C
OPNL	lda	OPNDCB,y
	sta	DCB,y
	dey
	bpl	OPNL
	jsr	SIOV

	;; Did we get an error 144? Get extended error code

OPERR	ldy	DSTATS
	cpy	#$90		; 144?
	bne	OPDONE		; nope, return DSTATS

	;; We got a 144, get STATUS for extended error.

	jsr	STPOLL
	ldy	DVSTAT+3	; Last byte of DVSTAT is ext err code

	;; Reset buffer length and offset

OPDONE	lda	#$01
	sta	trip		; Prime the interrupt
	jsr	GDIDX
	lda	#$00
	sta	RLEN,X
	sta	ROFF,X
	sta	TOFF,X
	tya
	rts

OPNDCB	.byte	$71		; DDEVIC
	.byte	$FF		; UNIT
	.byte	'O'		; Status
	.byte	$80		; Write
	.byte	$FF		; ZICBAL
	.byte	$FF		; ZICBAH
	.byte	$0F		; DTIMLO
	.byte	$00		; DRESVD
	.byte	$04		; ZICBLL
	.byte	$00		; ZICBLH
	.byte	$FF		; ZICAX1
	.byte	$FF		; ZICAX2
	
	;; Close
	
CLOSE	lda	ZICDNO
	sta	CLODCB+1
	ldy	#$0C
CLOL	lda	CLODCB,y
	sta	DCB,y
	dey
	bpl	CLOL
	jsr	SIOV
	ldy	DSTATS
	tya
	rts

CLODCB	.byte	$71		; DDEVIC
	.byte	$FF		; UNIT
	.byte	'C'		; Status
	.byte	$00		; None
	.byte	$00		; ZICBAL
	.byte	$00		; ZICBAH
	.byte	$0F		; DTIMLO
	.byte	$00		; DRESVD
	.byte	$00		; ZICBLL
	.byte	$00		; ZICBLH
	.byte	$00		; ZICAX1
	.byte	$00		; ZICAX2

	;; Get
	
GET	jsr	GDIDX
	lda	RLEN,X
	bne	GETDRB		; Drain buffer if RLEN>0

	;; len = 0, do status poll, and update len

	jsr	STPOLL
	jsr	GDIDX
	lda	DVSTAT
	sta	RLEN,x

	;; If len=0 then ret eof, othewise, get data from sio

	bne	GETDO
	ldy	#EOF
	lda	#EOF
	rts

	;; Do the SIO 'R'
	
GETDO	lda	ZICDNO
	sta	GETDCB+1
	jsr	GDIDX
	lda	RBUFPAG,x
	sta	GETBAH
	lda	DVSTAT
	sta	GETBLL
	sta	GETAX1

	ldy	#$0C
GETL	lda	GETDCB,y
	sta	DCB,y
	dey
	bpl	GETL
	
	jsr	SIOV
	
	;; Reset the buffer offset

	jsr	GDIDX
	lda	#$00
	sta	ROFF,x

	;; Drain Buffer

GETDRB	dec	RLEN,x
	ldy	ROFF,x
	cpx	#$03
	beq	GETG3
	cpx	#$02
	beq	GETG2
	cpx	#$01
	beq	GETG1

	;; Return next character in buffer

GETG0	lda	RBUF,y
	bvc	GETGX
GETG1	lda	RBUF+$100,y
	bvc	GETGX
GETG2	lda	RBUF+$200,y
	bvc	GETGX
GETG3	lda	RBUF+$300,y
	bvc	GETGX
GETGX	inc	ROFF,x
	tay

	;; Reset trip if LEN=0

	lda	RLEN,x
	bne	GETDONE
	lda	#$00
	sta	TRIP
GETDONE	tya
	ldy	#$01		; success
	rts			; done
	
GETDCB	.byte	$71		; DDEVIC
	.byte	$FF		; UNIT
	.byte	'R'		; Read
	.byte	$40		; Write
	.byte	$00		; RBUF+PAGE
GETBAH	.byte	$FF		; ZICBAH
	.byte	$0F		; DTIMLO
	.byte	$00		; DRESVD
GETBLL	.byte	$FF		; ZICBLL
	.byte	$00		; ZICBLH
GETAX1	.byte	$FF		; ZICAX1
	.byte	$00		; ZICAX2

	;; Put
	
PUT	jsr	GDIDX
	ldy	TOFF,x

	cpx	#$03
	beq	PUTP3
	cpx	#$02
	beq	PUTP2
	cpx	#$01
	beq	PUTP1

PUTP0	sta	TBUF,y
	bvc	PUTPX
PUTP1	sta	TBUF+$100,y
	bvc	PUTPX
PUTP2	sta	TBUF+$200,y
	bvc	PUTPX
PUTP3	sta	TBUF+$300,y
	bvc	PUTPX
PUTPX	inc	TOFF,x
	ldy	#$01

	;; Flush buffer if EOL or full
	cmp	#EOL
	beq	PUTFLU
	jsr	GDIDX
	ldy	TOFF,x
	cpx	#$FF
	beq	PUTFLU
	RTS

	;; Flush buffer, if asked

PUTFLU	jsr	PUTDO
	rts

	;; PUT FLUSH COMMAND
	
PUTDO	jsr	STPOLL
	lda	DVSTAT+2	; Check for disconnect
	bne	PUTDO1		; Continue with PUT if still connected

	;; We got disconnected, emit EOF.
	
	ldy	#EOF
	lda	#EOF
	rts
	
PUTDO1	jsr	GDIDX
	lda	TOFF,x
	bne	PUTDO2

	;; We were asked to flush, with no buffer. ignore.
	
	lda	#$01
	tay
	rts

	;; Fill out and do PUT DCB
	
PUTDO2	ldx	ZICDNO
	stx	PUTDCB+1
	dex
	lda	TBUFPAG,x
	sta	PUTBAH
	lda	DVSTAT
	sta	PUTBLL
	sta	PUTAX1
	jsr	SIOV

	;; Clear TX offset/len
	
	jsr	GDIDX
	lda	#$00
	sta	TOFF,x
	ldy	#$01
	rts

PUTDCB	.byte	$71		; DDEVIC
	.byte	$FF		; UNIT
	.byte	'W'		; Read
	.byte	$80		; Write
	.byte	$00		; RBUF+PAGE
PUTBAH	.byte	$FF		; ZICBAH
	.byte	$0F		; DTIMLO
	.byte	$00		; DRESVD
PUTBLL	.byte	$FF		; ZICBLL
	.byte	$00		; ZICBLH
PUTAX1	.byte	$FF		; ZICAX1
	.byte	$00		; ZICAX2

	
	;; Status
	
STATUS	jsr	ENPRCD
	jsr	GDIDX
	lda	RLEN,x
	bne	STADAT		; Is data waiting?
	lda	TRIP
	bne	STATR1		; is trip = 1?

	;; No trip, return saved length.

STADAT	lda	RLEN,x
	sta	DVSTAT		; return in dvstat
	lda	#$00
	sta	DVSTAT+1	; no more than 255 bytes
	lda	DVSTAT+2	; return connection status in A
	ldy	#$01		; successful.
	rts			; done.

	;; Trip. Do poll and update RX len

STATR1	jsr	STPOLL

	;; is <= 255?

	lda	DVSTAT+1
	bne	STATR2		; > 256
	sta	RLEN,X
	bvc	STAUPT		; update trip

	;; > 255, truncate to 255

STATR2	lda	#$FF
	sta	RLEN,x
	sta	DVSTAT
	lda	#$00
	sta	DVSTAT+1

STAUPT	bne	STADON
	sta	TRIP		; TRIP = 0

	;; Return connected? flag.
	
STADON	lda	DVSTAT+2
	ldy	#$01
	rts

	;; Do Status Poll
	
STPOLL	jsr	GDIDX
	stx	STPDCBU
	ldy	#$0C
STPL	lda	STPDCB,y
	sta	DCB,y
	dey
	bpl	STPL
	jsr	SIOV

	;; max 255 bytes waiting

	lda	DVSTAT+1
	beq	STP2
	lda	#$FF
	sta	DVSTAT
	lda	#$00
	sta	DVSTAT+1

	;; A = Connection status

STP2	lda	DVSTAT+2
	rts

STPDCB	.byte	$71		; DDEVIC
STPDCBU	.byte	$FF		; UNIT
	.byte	'S'		; Status
	.byte	$40		; Read
	.byte	$EA		; DVSTAT L
	.byte	$02		; DVSTAT H
	.byte	$0F		; DTIMLO
	.byte	$00		; DRESVD
	.byte	$04		; LEN L
	.byte	$00		; LEN H
	.byte	$00		; AUX L
	.byte	$00		; AUX H
	
	;; Special
	
SPEC	ldy	#$01
	tya
	rts

	;; Utility Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Enable PROCEED interrupt
	
ENPRCD	lda	PACTL
	ora	#$01		; bit 0 = interrupt enable
	sta	PACTL
	rts

	;; Disable PROCEED interrupt
	
DIPRCD	lda	PACTL
	and	#$FE		; bit 0 = interrupt enable
	sta	PACTL
	rts

	;; return ZIOCB as X index

GDIDX	ldx	ZICDNO
	dex
	rts

	
	
	;; End Utility Functions ;;;;;;;;;;;;;;;;;;;;;;

	;; devhdl table
	
CIOHND	.word	OPEN-1
	.word	CLOSE-1
	.word	GET-1
	.word	PUT-1
	.word	STATUS-1
	.word	SPEC-1

	;; Banners

BERROR	.by	'#FUJINET ERROR',$9B
BREADY	.by	'#FUJINET READY',$9B
	
	;; Variables

DSAV	.word	$0000		; Saved DOSINI vector
TRIP	.byte	$00		; Interrupt trip
RLEN	.byte	0,0,0,0		; Receive length
ROFF	.byte	0,0,0,0		; Receive offset
TOFF	.byte	0,0,0,0		; Transmit offset
INQDS	.byte	$00		; DSTATS Inquiry

	;; Receive Buffer page offset table
RBUFPAG	.byte	>RBUF
	.byte	>RBUF+1
	.byte	>RBUF+2
	.byte	>RBUF+3

TBUFPAG	.byte	>TBUF
	.byte	>TBUF+1
	.byte	>TBUF+2
	.byte	>TBUF+3
	
	;; Buffers

	.align	$100

RBUF	.ds	256*MAXDEV
TBUF	.ds	256*MAXDEV

PGEND	=	*

	end	START
