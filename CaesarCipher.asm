#Nicholas Amancio (and cesar)
#by Nicholas Amancio and Cesar Henry dePaula
#12/11/22 | CS 2640 | Caesar Cipher

 #Objectives
 #Implement Caesar Cipher
 #Encrypting a message by offsetting each letter by a user-specified amount
 
 #Pseudo
 #ask the user to enter a message and save it somewhere
 #ask the user for an offset number and save it to a register
 #enter an encryption loop where
 	#it will iterate through the string and get each letter and assign it to a number
 	#then it will add the offset number to it
 	#then it will find the same length in our declared alphabet and return the new character
 	#repeat until all characters are accounted for
 	#ignore spaces
 	#check for uppercase and lowercase
 #return the new encrypted string to the user
 
 #-----------------------------------------------------------registers---------------
 #buffer - message from user
 #$s0 - buffer
 #$s1 - key offset
 #$s2 - register that holds the space character
 #$s3 - register that holds the length of the buffer
 #$t0 - loop counter for buffer
 #$t1 - register to hold the iteration of the letters of the message
 #$t2 - loop counter for alphabet
 #$t3 - register to hold the iteration of the letters of alphabet string
 #$t4 - register to hold the encrypted letter to print out
 #$t5 - register to hold the iteration of the letters of the message to check for invalid characters
 #-----------------------------------------------------------------------------------
 
 .include "CaesarCipherMacros.asm"
 
 .data
 	buffer: .space 1024
 	alphabet: .asciiz  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
 .text
 main:
 	#print main menu selection
 	print("Select an option:\n(1) encrypt\n(2) decrypt\n(3) exit\n")
 	
 	li $v0, 5
 	syscall
 	
 	#loop counter for for loop
	li $t0, 0
	#loop counter for nested for loop
	li $t2, 0
	#register that holds the operation
	move $s2, $v0
	#register that holds the length of the message
	li $s3, 0
	#store buffer into $s0
	la $s0, buffer
 	
 	blt $s2, 1, main
 	bgt $s2, 3, main
 	beq $s2, 3, exit

__getKey:
	print("Enter the key (must be greater than 0):\n")
	#get a user input and store it into register $s0
	keyOffset
	blt $s1, 1, __getKey
	j __messagePrompt
	
 __messagePrompt:
 	#question to ask the user for a message
 	print("Enter a message:\n")
  	#get a user input and store it into buffer
	userInput
	#question to ask the user for the offset
	j __lengthOfMessage

	
__invalidMessage:
	print("Invalid Message!\n")
	j __messagePrompt

__lengthOfMessage:     #this is gonna be challenge to write about
	#load the byte of the message into $t1
	lb $t1, buffer($s3)
	#compare if the character is not null
	beqz $t1, __doSomethingToRegisters3
	#if it isn't null, increment $s3 
	addi $s3, $s3, 1
	#at the end, $s3 should have the amount of times it looped thru the string, giving the length of the message
	j __lengthOfMessage
	
__doSomethingToRegisters3:
	#decrement register $s3 by 1 in order to not have an excess char when printing the encrypted message
	subi $s3, $s3, 1
	beq $s2, 1, __encryptionLoop
	beq $s2, 2, __decryptionLoop
	
	
	
__encryptionLoop:
	#load the first byte (character) into register $t1
	lb $t1, buffer($t0)
	#conditional statement if the loop reaches the end of the character
	beq $t0, $s3, exit
	#conditional statement if char is space
	beq $t1, 32, __printSpace
	
__checkAlphabet:
	#nested for loop
	lb $t3, alphabet($t2)
	#check for invalid characters
	jal __checkValidity
	#compare the two characters
	beq $t1, $t3, __twoCharsAreEqual
	#if not, increment $t2
	addi  $t2, $t2, 1
	#jump back to __checkAlphabet until the characters are equal
	jal __checkAlphabet


__checkValidity:
	#check if characters are letters
	blt $t1, 65, __invalidMessage
	bgt $t1, 122, __invalidMessage
	bgt $t1, 90, __isUpperCase
	jr $ra
__isUpperCase:
	blt $t1, 97, __invalidMessage
	jr $ra

__incrementString:	
	#increment $0
	addi $t0, $t0, 1
	#reset loop counter for alphabet
	li $t2, 0
	#jump back to __encryptionLoop
	jal  __encryptionLoop
	
__printSpace:
	#print space character
	li $v0, 11
	la $a0, 32
	syscall
	jal __incrementString 
	
__twoCharsAreEqual:
	#checks if the character being passed through is an Uppercase character
	bge $t2, 26, __upperCase
	#checks if the character being passed through is an Uppercase character
	ble $t2, 25, __lowerCase
	
__continueEncryptLetter:
	#load the new offset byte into $t4
	lb $t4, alphabet($t2)
	#print the character
	li $v0, 11
	move $a0, $t4
	syscall
	#jump to __incrementString in order to go to the next letter of the message
	jal __incrementString

__upperCase:
	#add the offset
	add $t2, $t2, $s1
	#if the number is less than 'Z' then continue with the encryption
	ble $t2, 51, __continueEncryptLetter
	#if not, then it went passed the alphabet, so we need to loop it back through "A"
	subi $t2, $t2, 26
	#jump to continueEncryptLetter
	jal __continueEncryptLetter
	
__lowerCase:
	#add the offset
	add $t2, $t2, $s1
	#if the number is less than 'z' then continue with the encryption
	ble $t2, 25, __continueEncryptLetter
	#if not, then it went passed the alphabet, so we need to loop it back through "a"
	subi $t2, $t2, 26
	#jump to continueEncryptLetter
	jal __continueEncryptLetter
	
	
	
	
	
__decryptionLoop:
	#load the first byte (character) into register $t1
	lb $t1, buffer($t0)
	#conditional statement if the loop reaches the end of the character
	beq $t0, $s3, exit
	#conditional statement if char is space
	beq $t1, 32, __printSpaceDecryption

__checkAlphabetDecryption:
	#nested for loop
	lb $t3, alphabet($t2)
	#check for invalid characters
	jal __checkValidity
	#compare the two characters
	beq $t1, $t3, __twoCharsAreEqualDecryption
	#if not, increment $t2
	addi  $t2, $t2, 1
	#jump back to __checkAlphabet until the characters are equal
	jal __checkAlphabetDecryption


__incrementStringDecryption:	
	#increment $0
	addi $t0, $t0, 1
	#reset loop counter for alphabet
	li $t2, 0
	#jump back to __encryptionLoop
	jal  __decryptionLoop
	
__printSpaceDecryption:
	#print space character
	li $v0, 11
	la $a0, 32
	syscall
	jal __incrementStringDecryption
	
__twoCharsAreEqualDecryption:
	#checks if the character being passed through is an Uppercase character
	bge $t2, 26, __upperCaseDecryption
	#checks if the character being passed through is an Uppercase character
	ble $t2, 25, __lowerCaseDecryption
	
__continueDecryptLetter:
	#load the new offset byte into $t4
	lb $t4, alphabet($t2)
	#print the character
	li $v0, 11
	move $a0, $t4
	syscall
	#jump to __incrementString in order to go to the next letter of the message
	jal __incrementStringDecryption

__upperCaseDecryption:
	#subtract the offset
	sub $t2, $t2, $s1
	#if the number is less than 'Z' then continue with the encryption
	bge $t2, 26, __continueDecryptLetter
	#if not, then it went passed the alphabet, so we need to loop it back through "A"
	addi $t2, $t2, 26
	#jump to continueEncryptLetter
	jal __continueDecryptLetter
	
__lowerCaseDecryption:
	#subtract the offset
	sub $t2, $t2, $s1
	#if the number is less than 'z' then continue with the encryption
	bge $t2, 0, __continueDecryptLetter
	#if not, then it went passed the alphabet, so we need to loop it back through "a"
	addi $t2, $t2, 26
	#jump to continueEncryptLetter
	jal __continueDecryptLetter

exit:
	print("\nGoodbye")
	quitProgram
	
	
	

	
	
	
