#macro to print program
.macro quitProgram
	li $v0, 10
	syscall
.end_macro #end quitProgram

#macro to print a string
.macro print(%string)
	li $v0, 4
.data
	message: .asciiz %string
.text
	la $a0, message
	syscall
.end_macro #end print

#macro to get userInput
.macro userInput
	li $v0, 8
	la $a0, buffer
	li $a1, 21
	syscall
	move $s0, $a0
.end_macro #end userInput

#macro for getting user int input
.macro keyOffset
	li $v0, 5
	syscall
	move $s1, $v0
.end_macro
