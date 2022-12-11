#Group Name: Nicholas Amancio (and cesar)
#by Nicholas Amancio and Cesar Henry dePaula
#12/11/22 | CS 2640 | Caesar Cipher

 #-----------------------------------------------------------objectives--------------
 #Implement Caesar Cipher
 #Encrypting a message by offsetting each letter by a user-specified amount
 #-----------------------------------------------------------------------------------
 
 #-----------------------------------------------------------pseudocode--------------
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
 #-----------------------------------------------------------------------------------
 
 #-----------------------------------------------------------registers---------------
 #buffer - message from user
 #$s0 - buffer
 #$s1 - key offset
 #$s2 - register that holds the operation
 #$s3 - register that holds the length of the buffer
 #$t0 - loop counter for buffer
 #$t1 - register to hold the iteration of the letters of the message
 #$t2 - loop counter for alphabet
 #$t3 - register to hold the iteration of the letters of alphabet string
 #$t4 - loop counter for valid check loop
 #$t5 - register to hold the iteration of the letters of the message to check for invalid characters
 #$t6 - register to hold the encrypted letter to print out
 #-----------------------------------------------------------------------------------
 
 .include "CaesarCipherMacros.asm"
 
 .data
 	buffer: .space 1024
 	alphabet: .asciiz  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
 	
 .text
 main:
 	#print main menu selection
 	print("\n---------Welcome to the Caesar Cipher-------------------------")
 	print("\nSelect an option:\n(1) encrypt\n(2) decrypt\n(3) exit\n")
 	
 	#retrieve the user input of the int and save it to register $s2
 	li $v0, 5
 	syscall
	move $s2, $v0
 	
 	#loop counter for for loop
	li $t0, 0
	#loop counter for nested for loop
	li $t2, 0
	#store buffer into $s0
	la $s0, buffer
	
 	#cases if the user inputs anything other than 1, 2, or 3
 	blt $s2, 1, main
 	bgt $s2, 3, main
 	beq $s2, 3, exit

__getKey:
	#print the message to ask the user to enter the key
	print("Enter the key (must be greater than 0):\n")
	#get a user input and store it into register $s0
	keyOffset
	#checks to see if the user enters a positive number. If not, the program will ask the user for another number
	blt $s1, 1, __getKey
	#jump to __messagePrompt
	j __messagePrompt
	
 __messagePrompt:
 	#question to ask the user for a message
 	print("Enter a message:\n")
  	#get a user input and store it into buffer
	userInput
	
	#loop counter for valid check loop
	li $t4, 0
	#reset counter for length
	li $s3, 0
	
	#jump to __lengthOfMessage
	j __lengthOfMessage

__lengthOfMessage:
	#load the byte of the message into $t1
	lb $t1, buffer($s3)
	#compare if the character is not null
	beqz $t1, __decrementRegisters3
	#if it isn't null, increment $s3 
	addi $s3, $s3, 1
	#at the end, $s3 should have the amount of times it looped thru the string, giving the length of the message
	j __lengthOfMessage
	
__decrementRegisters3:
	#decrement register $s3 by 1 in order to not have an excess char when printing the encrypted message
	subi $s3, $s3, 1
	j __validLoop
	
__validLoop:
	#load the first character of message
	lb $t5, buffer($t4)
	#checks to see if the character is a letter. If not, then jump to __invalidMessage 
	blt $t5, 65, __checkSpace
__backToValidLoop:
	bgt $t5, 122, __invalidMessage
	beq $t5, 91, __invalidMessage
	beq $t5, 92, __invalidMessage
	beq $t5, 93, __invalidMessage
	beq $t5, 94, __invalidMessage
	beq $t5, 95, __invalidMessage
	beq $t5, 96, __invalidMessage
	#if it passes all the cases, then increment $t6
	addi $t4, $t4, 1
	#checks to see if it reaches the end of the message
	bne $t4, $s3, __validLoop
	print("\n-new message-\n")
	#if it reaches the end, then it checks to see if the user inputted Encryption or Decryption
	beq $s2, 1, __encryptionLoop
	beq $s2, 2, __decryptionLoop

__checkSpace:
	#check to see if it is a space
	bne $t5, 32, __invalidMessage
	#jump back to __backToValidLoop
	j __backToValidLoop
	
__invalidMessage:
	#print out invalid message
	print("Invalid Message!\n\n")
	#jump to __messagePrompt
	j __messagePrompt
	
#-----------------------------------------------------------encryption---------------
__encryptionLoop:
	#load the first byte (character) into register $t1
	lb $t1, buffer($t0)
	#conditional statement if the loop reaches the end of the character
	beq $t0, $s3, main
	#conditional statement if char is space
	beq $t1, 32, __printSpaceEncryption
	
__checkAlphabetEncryption:
	#load the first byte (character) into register $t3
	lb $t3, alphabet($t2)
	#compare the two characters
	beq $t1, $t3, __twoCharsAreEqualEncryption
	#if not, increment $t2
	addi  $t2, $t2, 1
	#jump back to __checkAlphabetEncryption until the characters are equal
	jal __checkAlphabetEncryption

__twoCharsAreEqualEncryption:
	#checks if the character being passed through is an Uppercase character
	bge $t2, 26, __upperCaseEncryption
	#checks if the character being passed through is an Uppercase character
	ble $t2, 25, __lowerCaseEncryption

__upperCaseEncryption:
	#add the offset
	add $t2, $t2, $s1
	#if the number is less than 'Z' then continue with the encryption
	ble $t2, 51, __continueEncryptLetter
	#if not, then it went passed the alphabet, so we need to loop it back through "A"
	subi $t2, $t2, 26
	#jump to continueEncryptLetter
	jal __continueEncryptLetter
	
__lowerCaseEncryption:
	#add the offset
	add $t2, $t2, $s1
	#if the number is less than 'z' then continue with the encryption
	ble $t2, 25, __continueEncryptLetter
	#if not, then it went passed the alphabet, so we need to loop it back through "a"
	subi $t2, $t2, 26
	#jump to continueEncryptLetter
	jal __continueEncryptLetter
	
__continueEncryptLetter:
	#load the new offset byte into $t6
	lb $t6, alphabet($t2)
	#print the character
	li $v0, 11
	move $a0, $t6
	syscall
	#jump to __incrementString in order to go to the next letter of the message
	jal __incrementStringEncryption

__printSpaceEncryption:
	#print space character
	li $v0, 11
	la $a0, 32
	syscall
	#jump to __incrementString in order to go to the next letter of the message
	jal __incrementStringEncryption

__incrementStringEncryption:	
	#increment $0
	addi $t0, $t0, 1
	#reset loop counter for alphabet
	li $t2, 0
	#jump back to __encryptionLoop
	jal  __encryptionLoop
	
#-----------------------------------------------------------decryption---------------
__decryptionLoop:
	#load the first byte (character) into register $t1
	lb $t1, buffer($t0)
	#conditional statement if the loop reaches the end of the character
	beq $t0, $s3, main
	#conditional statement if char is space
	beq $t1, 32, __printSpaceDecryption

__checkAlphabetDecryption:
	#nested for loop
	lb $t3, alphabet($t2)
	#compare the two characters
	beq $t1, $t3, __twoCharsAreEqualDecryption
	#if not, increment $t2
	addi  $t2, $t2, 1
	#jump back to __checkAlphabet until the characters are equal
	jal __checkAlphabetDecryption

__twoCharsAreEqualDecryption:
	#checks if the character being passed through is an Uppercase character
	bge $t2, 26, __upperCaseDecryption
	#checks if the character being passed through is an Uppercase character
	ble $t2, 25, __lowerCaseDecryption

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

__continueDecryptLetter:
	#load the new offset byte into $t6
	lb $t6, alphabet($t2)
	#print the character
	li $v0, 11
	move $a0, $t6
	syscall
	#jump to __incrementString in order to go to the next letter of the message
	jal __incrementStringDecryption

__printSpaceDecryption:
	#print space character
	li $v0, 11
	la $a0, 32
	syscall
	#jump to __incrementString in order to go to the next letter of the message
	jal __incrementStringDecryption

__incrementStringDecryption:	
	#increment $0
	addi $t0, $t0, 1
	#reset loop counter for alphabet
	li $t2, 0
	#jump back to __encryptionLoop
	jal  __decryptionLoop

#---------------------------------------------------------------exit-----------------
exit:
	print("\nGoodbye")
	quitProgram
	
	
	

	
	
	
