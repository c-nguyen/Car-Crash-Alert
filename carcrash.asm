#  Data Area
.data

options:
	.byte 'A', 'B', 'C', 'S'
	
option1:
	.asciiz "car acel\n"
	
option2:
	.asciiz "car brak\n"
	
option3:
	.asciiz "car crash\n"

noairbag:
	.asciiz "Airbag no deploy\n"
	
noambu:
	.asciiz "Airbags deploy Ambulance no alert\n"
	
ambualert:
	.asciiz "Airbags deploy Ambulance alerted!\n"
	
airbag:
	.asciiz "Airbags deployed\n"
	
speed:
	.asciiz "S\n"

#Text Area (i.e. instructions)
.text

main:
    li		$s0, 0xFFFF0000		# Load address of receiver control
	la		$t1, options
	lb		$s1, 1($t1)			# $s1 = B (current mode)
	lb		$s2, 0($t1)			# $s2 = A
	lb		$s3, 1($t1)			# $s3 = B
	lb		$s4, 2($t1)			# $s4 = C
	lb		$s5, 3($t1)			# $s5 = S
	addi	$s6, $0, 0			# $s6 = speed (default 0)
	addi	$t8, $0, 15			# $t8 = 15
	addi	$t9, $0, 45			# $t9 = 45

PULLR:
	lw		$v0, 0($s0)			# Load receiver control
	andi	$v0, $v0, 1			# Screen ready bit
	beq		$v0, $0, PULLR		# if (ready bit == 0), check again
	lw		$v0, 4($s0)			# Load receiver data
	andi	$t1, $v0, 0xFF		# Screen data
	
	beq		$t1, $s2, ACCEL		# if (user input == A), jump to ACCEL
	beq		$t1, $s3, BRAKE		# if (user input == B), jump to BRAKE
	beq		$t1, $s4, CRASH		# if (user input == C), jump to CRASH
	addi	$t2, $0, 0			# $t2 = 0
	addi	$s6, $0, 0			# $s6 = 0
	beq		$t1, $s5, SPEED		# if (user input == S), jump to SPEED
	
ACCEL:
	beq		$t1, $s1, PULLR		# if already accel, jump to PULLR
	la		$t2, option1		# $t1 = label option1
	addi	$s1, $t1, 0			# $s1 = accel mode
	j		PULLT
	
BRAKE:
	beq		$t1, $s1, PULLR		# if already brake, jump to PULLR
	la		$t2, option2		# $t2 = label option2
	addi	$s1, $t1, 0			# $s1 = brake mode
	j		PULLT
	
CRASH:
	la		$t2, option3		# $t2 = label option3
	jal		PULLTC				# Jump and link to PULLTC
	ble		$s6, $t8, NODEPLOY	# if (speed <= 15), jump to NODEPLOY
	bge		$s6, $t9, AMBU		# if (speed >= 45), jump to AMBU
	la		$t2, airbag			# else $t2 = airbag
	j		PULLT				# Jump to PULLT
	
NODEPLOY:
	la		$t2, noairbag		# $t2 = label noairbag
	j		PULLT				# Display label noairbag
	
AMBU:
	beq		$s1, $s3, NOAMBU	# if already in brake mode, jump to NOAMBU
	la		$t2, ambualert		# $t2 = label ambualert
	j		PULLT				# Display label ambualert
	
NOAMBU:
	la		$t2, noambu			# $t2 = label noambu
	j		PULLT				# Display label noambu
	
SPEED:
	addi	$t2, $s5, 0			# $t2 = S
	jal		PULLTS
	
SPEED2:
	lw		$v0, 0($s0)			# Load receiver control
	andi	$v0, $v0, 1			# Screen ready bit
	beq		$v0, $0, SPEED2		# if (ready bit == 0), check again
	lw		$v0, 4($s0)			# Load receiver data
	andi	$t1, $v0, 0xFF		# Screen data
	addi	$t2, $t1, 0			# $t2 = user input
	beq		$t1, $s5, ENDSPEED	# if (user input == S), jump to ENDSPEED
	bge		$s6, 100, OVERSPEED	# if (speed >= 100), jump to OVERSPEED
	addi	$t3, $t1, -48		# $t3 = int rep. of ASCII value
	addi	$t4, $0, 9			# $t4 = 9
	addi	$t5, $0, 10			# $t5 = 10
	bltz	$t3, PULLR			# if ($t3 < 0), jump to PULLR
	bgt		$t3, $t4, PULLR		# if ($t3 > $t4), jump to PULLR
	mul		$s6, $s6, $t5		# $s6 = $s6 * 10
	add		$s6, $s6, $t3		# $s6 = $s6 + new int
	jal		PULLTS
	j		SPEED2
	
OVERSPEED:
	jal		PULLTS
	j		SPEED2
	
ENDSPEED:
	la		$t2, speed			# $t2 = label speed
	j		PULLT
	
PULLT:
	lw		$v0, 8($s0)			# Load transmitter control
	andi	$v0, $v0, 1			# Screen ready bit
	beq		$v0, $0, PULLT		# if (ready bit == 0), check again
	lb		$t3, 0($t2)			# $t3 = message.charAt($t2)
	beq		$t3, $0, PULLR		# if (character == null pointer), jump to PULLR
	sb		$t3, 12($s0)		# Display character
	addi	$t2, $t2, 1			# Offset .charAt by 1
	j		PULLT
	
PULLTC:
	lw		$v0, 8($s0)			# Load transmitter control
	andi	$v0, $v0, 1			# Screen ready bit
	beq		$v0, $0, PULLTC		# if (ready bit == 0), check again
	lb		$t3, 0($t2)			# $t3 = message.charAt($t2)
	beq		$t3, $0, RETURN		# if (character == null pointer), jump to RETURN
	sb		$t3, 12($s0)		# Display character
	addi	$t2, $t2, 1			# Offset .charAt by 1
	j		PULLTC
	
PULLTS:
	lw		$v0, 8($s0)			# Load transmitter control
	andi	$v0, $v0, 1			# Screen ready bit
	beq		$v0, $0, PULLTS		# if (ready bit == 0), check again
	sb		$t2, 12($s0)		# Display character
	jr		$ra
	
RETURN:
	jr		$ra
