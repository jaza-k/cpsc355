// JAZA KHAN UCID 30119100
// CPSC 355 W22 Assignment 1B

// Assembly program to find the minimum of the polynomial y = 3x^4 - 287x^2 -63x + 37 within
// the given range -10 <= x <= 10 by stepping through the range  one by one in a loop and testing

// Version B (optimized): Program now uses the madd instruction as well as macros (m4) for better readability, 
// in particular for heavily used registers

currentXY:  .string "\nCurrent x = %d, current y = %d"                                                   // Formats output for printing out current x, y values
currentMin: .string "\nCurrent min is y = %d \n"                                                         // Formats output for printing out current minimum y
finalMin:   .string "\n***** The minimum of this function in the given range is %d. *****\n"             // Formats output for printing out final minimum y value
		    
            .balign 4										         // Ensures instructions are properly aligned by 4 bits
	    .global main										 // Makes the label "main" visible to the linker

main:	    stp     x29, x30, [sp, -16]!								 // Stores the x29 frame pointer and x30 link register to the stack
	    mov	    x29, sp										 // Updates frame pointer to current stack pointer

	    define(x_var, x19)                                                                           // Define macro for x19 which stores x value
            define(y_var, x20)                                                                           // Define macro for x20 which stores y value
            define(current_min, x21)                                                                     // Define macro for x21, which stores current minimum y value

            mov	    x_var, -10									         // Give x a value of -10 (also loop counter)
	    mov	    y_var, 0										 // Give y a value of 0
	    mov	    current_min, 100                                                                     // Make current minimum y 100 
            b       check                                                                                // Branch to check for first iteration

            define(first_term, x22)                                                                      // Define macro for x22, which stores the first term
            define(second_term, x23)                                                                     // Define macro for x23, which stores the second term
            define(third_term, x24)                                                                      // Define macro for x24, which stores the third term

test:       mov     y_var, 0                                                                             // Resets value of y to 0 each time loop is run 

            // 3x^4
            mov     first_term, 3                                                                        // Assigns register to coefficient of first term
            mul     first_term, first_term, x_var                                                        // first_term = 3x
            mul     first_term, first_term, x_var                                                        // first_term = 3x^2
            mul     first_term, first_term, x_var                                                        // first_term = 3x^3
            madd    y_var, first_term, x_var, y_var                                                      // y_var = 0 + 3x^4 

            // -287x^2
            mov     second_term, -287                                                                    // Assigns register to coefficient of second term
            mul     second_term, second_term, x_var                                                      // second_term = -287x
            madd    y_var, second_term, x_var, y_var                                                     // y_var = y_var + (-287x^2)

            // -63x
            mov     third_term, -63                                                                      // Assigns register to coefficient of third term
            madd    y_var, third_term, x_var, y_var                                                      // y_var = y_var + (-63)
            
            add     y_var, y_var, 37                                                                     // Adds constant value to y_var

            cmp     y_var, current_min                                                                   // Compares the current y value to minimum y value
            b.lt    newMin                                                                               // If current y is less than minimum y, make it new minimum y
            b       loopEnd                                                                              // Branches to end of loop to display info

loopEnd:    adrp    x0, currentXY                                                                        // Sets first argument for printf (higher bits)
            add     x0, x0, :lo12:currentXY                                                              // Sets first argument for printf (lower 12 bits)
            mov     x1, x_var                                                                            // Value for first %d is x
            mov     x2, y_var                                                                            // Value for second %d is y
            bl      printf                                                                               // Calls printf

            add     x_var, x_var, 1                                                                      // Increments loop counter by 1

            adrp    x0, currentMin                                                                       // Sets first argument for printf (higher bits)
            add     x0, x0, :lo12:currentMin                                                             // Sets first argument for printf (lower 12 bits)
            mov     x1, current_min                                                                      // Sets value of %d to the minimum y value
            bl      printf                                                                               // Calls printf

            b       check                                                                                // Returns to check and carry next iteration of loop if needed

newMin:     mov     current_min, y_var                                                                   // Moves value of current y to make it new minimum y
            b       loopEnd                                                                              // Branches to end of the loop (displays info)

check:      cmp     x_var, 10                                                                            // Compares x_var to 10
            b.le    test                                                                                 // If x <= 10 return to test

printMin:   adrp    x0, finalMin                                                                         // Sets first argument for printf (higher bits)
            add     x0, x0, :lo12:finalMin                                                               // Sets first argument for printf (lower 12 bits)
            mov     x1, current_min
            bl      printf                                                                               // Calls printf
            b       end                                                                                  // Branch to end

end:	    mov     x0, 0										 // Returns code 0
	    ldp     x29, x30, [sp], 16								         // Restores the state of the FP and LR registers
	    ret											         // Returns control to calling code
