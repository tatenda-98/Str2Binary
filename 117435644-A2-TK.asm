.data 
	float: .float 4
	user_input: .asciiz "Enter a real number [xxx.yyy]: "
	sign_bit: .asciiz "The sign bit of your number is: "
	exponent_str: .asciiz "\nThe exponent of your number is: "
	fraction_str: .asciiz "\nThe fraction of your number is: "
 	buffer: .space 32
	numChars: .word 32
	str2float: .word 0 
	inputStr: .word 0
	ten: .float 10
	space: .asciiz " " 
.text 
.globl main
main:

 
	la $a0, user_input
	li $v0, 4
	syscall
	
	la $a0, user_input
	la $a0, buffer
	la $a1, numChars 
	lw $a1, ($a1)
	li $v0, 8
	syscall 
	
	move $t7, $a0
	sw $t7, inputStr
	add $t0, $zero, $a0
	
	li $t4, 46
	
	lb $t1, ($t0)
	li $a0, 0 
	addi $t1, $t1, -48
	add $a0, $a0, $t1
	addi $t0, $t0, 1
	lb $t1, ($t0) 

str2int:
	#beq $t1, $a1, print
	beq $t1, $t4  int2float 
	addi $t1, $t1, -48

	mul $t2, $a0, 10
	add $a0, $t2, $t1	#CHANGED THE $RD FROM $A0 TO $T3
	addi $t0, $t0, 1
	lbu $t1, ($t0)
	b str2int

pre_decimal:
	li $t4, 3			#loads the value 3 inro $t4 for the counter of the decimals 
	l.s $f10, ten			#loads the label with the float value 10 into the FP register 
	l.s $f9, ten			#loads the label with the float value 10 into the FP register 
decimal:
	beqz $t4, concatonation		#if the counter is equal to 0 then jump to concatonation
	addi $t0, $t0, 1		#increment $t0 for next bit
	lb $t1, ($t0)			#load next bit into $t1
	addi $t1, $t1, -48		#convert the next bit in the str into an int 
	mtc1 $t1, $f11			#move the converted int into an FP register 
	cvt.s.w $f11, $f11		#convert that value to a single precision float
	div.s $f11, $f11, $f10 		#divide the float by the value in $f10
	add.s $f1, $f1,  $f11		#add the new value into $f1
	mul.s $f10, $f10, $f9		#multiply $f10 by 10 for the next deimal point number 
	addi $t4, $t4, -1		#decrement $t4 
	j decimal 	
	

int2float: 
	move $t3, $a0			#move the value in a0 into t3
	mtc1 $t3, $f12 			#move the value in t3 into them FP register 
	cvt.s.w $f12, $f12		#convert the integer in the f12 register to a single precision floating point
	b pre_decimal

concatonation:
	add.s $f12, $f12, $f1		#add the value in f1 to the value in f12 and store in f12
	mfc1 $t3, $f12			#move from the core processor to the t3 register
	move $t7, $t3			#move the value in t3 into t7
	sw $t7, str2float		#store the int in t7 into the variable str2float 

binary_prep:
	li $t7, 0			#load the value 0 into t7 
	addi $t7, $t7, 1 		#load the value 1 into t7 to set the mask 
	sll $t7, $t7, 31 		#shift the mask to the 31 bits to the left
	li $t4, 1			#store 1 in t4 (sign counter)
	li $t6, 8			#store 8 in t6 (exponent counter)
	li $t1, 23			#store 23 in t1 (fraction counter)
	li $t2, 0			#limit for exponent and fraction counter
	li $s1, 0			#counter for space between the exponent nibbles 
	li $s2, 4			#limit for space in between nibbles 
	li $s3, 0			#counter for space in between the fraction nibbles 
	j sign_string
	
get_sign:
	and $t5, $t3, $t7		#compare the bit in t3 to the mask and store the value in t5
	beqz $t5, sign_print		#branch to function if t5 is 0
	li $t5, 0 			#else put 0 in t5
	addi $t5, $t5, 1		#and add 1 to t5
	j sign_print

exponent:
	
	and $t5, $t3, $t7
	beqz $t5, exponent_print
	li $t5, 0 
	addi $t5, $t5, 1
	j exponent_print
	
fraction:
	
	and $t5, $t3, $t7
	beqz $t5, fraction_print
	li $t5, 0 
	addi $t5, $t5, 1
	beqz $t1, fraction_print
	j fraction_print	
	
sign_print:
	
	la $a0, ($t5)			#load the address of the value of t5 into a0 
	li $v0, 1			#load 1 into v0
	syscall	
	
	srl $t7, $t7, 1			#shift to the mask to the right by 1
	addi $t4, $t4, -1		#SIGN COUNTER	
	beqz $t4, exponent_string
	 
	 
exponent_print:
	la $a0, ($t5)
	li $v0, 1
	syscall
	
	srl $t7, $t7, 1
	addi $t6, $t6, -1		#EXPONENT COUNTER 
	addi $s1, $s1, 1		#incremenet s1
	beq $s1,$s2, exponent_space
	
	beq $t6, $t2,  fraction_string
	b exponent
 


fraction_print:
	la $a0, ($t5)
	li $v0, 1
	syscall
	
	srl $t7, $t7, 1
	addi $t1, $t1, -1
	addi $s3, $s3, 1
	beq $s3,$s2, fraction_space
	beq $t1,$t2, exit
	j fraction

sign_string:
	la $a0, sign_bit		#load the string in sign_bit into the a0 and print
	li $v0, 4
	syscall
	j get_sign
	
exponent_string:
	la $a0, exponent_str		#load the string in exponenet_string into the a0 and print
	li $v0, 4
	syscall
	j exponent
fraction_string:
	la $a0, fraction_str		#load the string in fraction_string into the a0 and print
	li $v0, 4
	syscall
	j fraction
	
exponent_space:
	la $a0, space			#load the space string into a0 and print
	li $v0, 4 
	syscall
	
	j exponent

fraction_space:
	la $a0, space
	li $v0, 4 
	syscall
	
	addi $s2, $s2, 4
	j fraction

	
exit:	
	li $v0, 10			#exit the program
	syscall


