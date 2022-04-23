// Jaza Khan UCID 30119100
// CPSC 355 W22 Assignment 1A

// Assembly program to find the minimum of the polynomial y = 3x^4 - 287x^2 - 63x + 37 within
// the range -10 <= x <= 10 by stepping through the range one by one in a loop and testing

// Version A: Written without the use of macros, and a pre-test loop with the test at the top of the loop

currentXY:  .string "\nCurrent x = %d, current y = %d"                                                  // Formats output for printing out current x, y values
currentMin: .string "\nCurrent min is y = %d \n"                                                        // Formats output for printing out current minimum y
finalMin:   .string "\n***** The minimum of this function in the given range is %d. *****\n"            // Formats output for printing out final minimum y value
		    
            .balign 4										        // Ensures instructions are properly aligned by 4 bits
	    .global main										// Makes the label "main" visible to the linker

main:       stp     x29, x30, [sp, -16]!								// Stores the x29 frame pointer and x30 link register to the stack
	    mov	    x29, sp							                	// Updates frame pointer to current stack pointer

	    mov	    x19, -10										// Register for x, set to -10 (also loop counter)
	    mov	    x20, 0								        	// Register for y
	    mov	    x21, 100							                	// Register for the minimum y 

	    // PRE-TEST (WHILE) LOOP
test:	    cmp	    x19, 10							               		// Compares loop counter to 10 (max X value in range)
	    b.gt    printMin                                                                		// If loop counter > 10, branch to end
            
            mov     x20, 0                                                                              // Resets value of y to 0 each time loop is run 

            // 3x^4
            mov     x22, 3                                                                              // Assigns register to coefficient of first term
            mul     x22, x22, x19                                                                       // Multiply value of x22 (3) by x to give 3x
            mul     x22, x22, x19                                                                       // Multiply value of x22 (3x) by x to give 3x^2
            mul     x22, x22, x19                                                                       // Multiply value of x22 (3x^2) by x to give 3x^3
            mul     x22, x22, x19                                                                       // Multiply value of x22 (3x^3) by x to give 3x^4 

            // -287x^2
            mov     x23, -287                                                                           // Assigns register to coefficient of second term
            mul     x23, x23, x19                                                                       // Multiply value of x23 (-287) by x to give -287x
            mul     x23, x23, x19                                                                       // Multiply value of x23 (-287x) by x to give -287x^2

            // -63x
            mov     x24, -63                                                                            // Assigns register to coefficient of third term
            mul     x24, x24, x19                                                                       // Multiply value of x24 (-63) by x to give -63x
            
            // 37
            mov     x25, 37                                                                             // Assigns register to last term of function

            add     x20, x20, x22                                                                       // Add result of 3x^4 (x22) to y
            add     x20, x20, x23                                                                       // Add result of -287x^2 (x23) to y
            add     x20, x20, x24                                                                       // Add result of -63x (x24) to y
            add     x20, x20, x25                                                                       // Add constant term (x25) to y

            cmp     x20, x21                                                                            // Compares the current y value to minimum y value
            b.lt    newMin                                                                              // If current y is less than minimum y, make it new minimum y 
            b       loopEnd                                                                             // Branch to end of loop in order to print info

loopEnd:    adrp    x0, currentXY                                                                   	// Sets first argument for printf (higher bits)
            add     x0, x0, :lo12:currentXY                                                             // Sets first argument for printf (lower 12 bits)
            mov     x1, x19                                                                             // Value for first %d is x
            mov     x2, x20                                                                             // Value for second %d is y
            bl      printf                                                                              // Calls printf

            add     x19, x19, 1                                                                         // Increments loop counter by 1

            adrp    x0, currentMin                                                                      // Sets first argument for printf (higher bits)
            add     x0, x0, :lo12:currentMin                                                            // Sets first argument for printf (lower 12 bits)
            mov     x1, x21                                                                             // Sets value of %d to the minimum y value
            bl      printf                                                                              // Calls printf

            b       test                                                                                // Returns to test and carry next iteration of loop

newMin:	    mov     x21, x20                                                                        	// Moves value of current y to make it new minimum y
            b       loopEnd                                                                             // Branches to end of the loop (displays info)

printMin:   adrp    x0, finalMin                                                                        // Sets first argument for printf (higher bits)
            add     x0, x0, :lo12:finalMin                                                              // Sets first argument for printf (lower 12 bits)
            mov     x1, x21
            bl      printf                                                                              // Calls printf

end:	    mov 	x0, 0										// Returns code 0
	    ldp 	x29, x30, [sp], 16					                 	// Restores the state of the FP and LR registers
	    ret												// Returns control to calling code
