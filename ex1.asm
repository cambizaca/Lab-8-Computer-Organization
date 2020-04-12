# =============================================================
# main PROCEDURE TEMPLATE # 4b
#
# Use with "proc_template4b.asm" as the template for other procedures
#
# Based on Slide 37 of Lecture 9 (Procedures and Stacks)
#   (main is simpler than other procedures because it does not have to
#     clean up anything before exiting)
#
# Assumptions:
#
#   - main calls other procedures with no more than 4 arguments ($a0-$a3)
#   - any local variables needed are put into registers (not memory)
#   - no values are put in temporaries that must be preserved across a call from main
#       to another procedure
#
# =============================================================

.data 0x0
#
# declare global variables here\
    intprompt:		.asciiz "\n"
    one:		.asciiz "1\n"
    n:			.word 0
    p:			.word 0


.text 0x3000
.globl main


main:

    ori     $sp, $0, 0x3000     # Initialize stack pointer to the top word below .text
                                # The first value on stack will actually go at 0x2ffc
                                #   because $sp is decremented first.
    addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame



    # =============================================================
    # No need to create room for temporaries to be protected.
    # =============================================================




    # =============================================================
    # BODY OF main
    
  while:
    addi $v0, $0, 4  			# system call 4 is for printing a string
    la 	$a0, intprompt 			# address of intprompt is in $a0
    syscall 
    
    addi $v0, $0, 5			# system call 5 is for reading an integer
    syscall 				# integer value read is in $v0
    add	$a0, $0, $v0			# copy n value into $a0
    
    
    beq $a0, $0, exit_from_main		#leaves main
 
    
    addi $v0, $0, 5			# system call 5 is for reading an integer
    syscall 				# integer value read is in $v0
    add	$a1, $0, $v0			# copy k value into $a0

 
    
            # =====================================================
            # main CALLS proc1

            jal  NchooseK              # call NchooseK
                                       # valued returned by proc1 will be in $v0-$v1

            # =====================================================
   add $a0, $0, $v0         
   addi $v0, $0, 1  			# system call 1 is for printing an integer
   syscall           			# print the integer

 
   
   j while

    # =============================================================



exit_from_main:
    ori     $v0, $0, 10     # System call code 10 for exit
    syscall                 # Exit the program
end_of_main:
  addi $v0, $0, 4  			# system call 4 is for printing a string
    la 	$a0, intprompt 			# address of intprompt is in $a0
    syscall 


  addi 	$v0, $0, 4  			# system call 1 is for printing an integer
  syscall           			# print the integer 
  j exit_from_main
  
  
 .globl NchooseK                    # Simply means proc1 can be found by code residing in other files

##################

NchooseK: 
    addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    sw      $ra, 4($sp)         # Save $ra
    sw      $fp, 0($sp)         # Save $fp

    addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame

                                # From now on:
                                #     0($fp) --> $ra's saved value
                                #    -4($fp) --> caller's $fp's saved value
                   
    # =============================================================
    # Save any $sx registers that proc1 will modify
                                # Save any of the $sx registers that proc1 modifies
    addi    $sp, $sp, -12        # e.g., $s0, $s1, $s2, $s3
    sw      $s0, 8($sp)         # Save $s0
    sw      $s1, 4($sp)         # Save $s1
    sw      $s2, 0($sp)         # Save $s1
                                # From now on:
                                #    -8($fp) --> $s0's saved value
                                #   -12($fp) --> $s1's saved value

    # =============================================================
    # BODY OF proc1
  
    li $v0, 1				#loads 1 into return value
    
    beq $a0, 0, return_from_NchooseK	#if n = 0, return value of 1
    slt $t0, $a1, $a0			# checks if k < n
    beq $t0, 0, return_from_NchooseK 	#if false, leaves program
    slt $t0, $0, $a1			#checks if 0 < k
    beq $t0, 0, return_from_NchooseK 	#if false, leaves program
    
    add $s0, $0, $a0			#storing n
    add $s1, $0, $a1			#storing k
    # =====================================================    
                 
    addi $a0, $a0, -1			#NchooseK(n-1, k)
    jal NchooseK
    
    add $s2, $v0, $0			#stores value of the first recurssion sum into v0
    
    add $a0, $s0, $0
    add $a1, $s1, $0
    
    addi $a0, $a0, -1			#NchooseK(n-1, k)
    addi $a1, $a1, -1			#NchooseK(n-1, k-1);
    jal NchooseK   
    
    
    
    add $v0, $s2, $v0      		#stores value of the second recursion sum into v0
    # =====================================================
    
    # Restore $sx registers
    lw  $s0,  -8($fp)           # Restore $s0
    lw  $s1, -12($fp)           # Restore $s1
    lw  $s2, -16($fp)           # Restore $s2

    # =============================================================
    # Restore $fp, $ra, and shrink stack back to how we found it,
    #   and return to caller.

return_from_NchooseK:
    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    jr      $ra             # Return from procedure

    # =============================================================
