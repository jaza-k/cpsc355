// Jaza Khan UCID 30119100
// CPSC 355 W22 Assignment 2C

// ARMv8 assembly language program to implement given C code. Performs multiplication using bitwise logical and shift
// operations. Uses 32-bit registers for variables declared using int. Uses 64-bit registers for variables declared
// using long int. Uses m4 macros to name registers for better code readability. 

// VERSION C - multiplicand value is -252645136 and multiplier is -256
// --------------------------------------------------------------------------------------------------------------------------------------------------------- //

printInfo:      .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"      // Format output for printing out initial values
printAnswer:    .string "product = 0x%08x  multiplier = 0x%08x\n"                       // Format output for printing out the resulting values
printAnswer64:  .string "64 bit result = 0x%016lx (%ld)\n"                              // Format output for printing out the result in 64-bit

                .balign 4                                                               // Ensures instructions are properly aligned by 4 bits
                .global main                                                            // Make label "main" visible to the linker

main:	        stp     x29, x30, [sp, -16]!                                            // Store x29 frame pointer and x30 link register to the stack
	            mov	    x29, sp										                    // Update faame pointer to current stack pointer

                // Defining macros for variables in C code
                // 32-bit
                define(multiplier, w19)                                                 // Assign 32-bit register w19 to multiplier variable
                define(multiplicand, w20)                                               // Assign 32-bit register w20 to multiplicand variable
                define(product, w21)                                                    // Assign 32-bit register w21 to product variable
                define(i, w22)                                                          // Assign 32-bit register w22 to i variable
                define(negative, w23)                                                   // Assign 32-bit register w23 to negative variable
                // 64-bit
                define(result, x24)                                                     // Assign 64-bit register x24 to result variable
                define(temp1, x25)                                                      // Assign 64-bit register x25 to temp1 variable
                define(temp2, x26)                                                      // Assign 64-bit register x26 to temp2 variable

                // Set variable values
                mov     multiplier, -256                                                // Set multiplier value to -256
                mov     multiplicand, -252645136                                        // Set multiplicand value to -252645136 
                mov     product, 0                                                      // Set product value to 0
                mov     i, 0                                                            // Set value of i to 0
                
                // Prints current values for multiplier and multiplicand
                adrp    x0, printInfo                                                   // Set first argument for printf (higher bits)
                add     x0, x0, :lo12:printInfo                                         // Set first argument for printf (lower 12 bits)
                mov     w1, multiplier                                                  // Value of 0x%08x is the multiplier (in hex)
                mov     w2, multiplier                                                  // Value of %d is the multiplier (in decimal)
                mov     w3, multiplicand                                                // Value of next 0x%08x is the multiplicand (in hex)
                mov     w4, multiplicand                                                // Value of next %d is the multiplicand (in decimal)
                bl      printf                                                          // Call printf

                // Determines if multiplier is negative
                cmp     multiplier, 0                                                   // Compare multiplier with 0
                b.lt    setFalse                                                        // If multiplier >= 0, branch to setFalse  

                b       setTrue                                                         // Otherwise, branch to setTrue
                b       begin                                                           // Branch to begin to begin loop

setFalse:       mov     negative, 0                                                     // Multiplier is >= 0 so set negative to 0 (FALSE)
setTrue:        mov     negative, 1                                                     // Multiplier is <= 0, set negative to 1 (TRUE)

begin:          mov     i, 0                                                            // Set value of i to 0
                b       loopCheck                                                       // Branch to loopCheck to check for i value

loopStart:      tst     multiplier, 1                                                   // Compare multiplier to 1, using tst instead of cmp to compute the bitwise AND of multiplier and 1
                b.eq    then                                                            // If equal, branch to then to continue
                add     product, product, multiplicand                                  // Otherwise, repeatedly perform addition

then:           asr     multiplier, multiplier, 1                                       // Arithmetic shift right on multiplier by 1
                tst     product, 1                                                      // Compare product to 1, using tst instead of cmp to compute the bitwise AND of product and 1
                b.eq    then1                                                           // If equal, branch to then1

                orr     multiplier, multiplier, 0x80000000                              // Performs bitwise OR operation on multiplier and 0x80000000
                b       close                                                           // Branch to close

then1:          and     multiplier, multiplier, 0x7FFFFFFF                              // Performs bitwise AND operation on multiplier and 0x7FFFFFFF

close:          asr     product, product, 1                                             // Arithmetic shift right on product by 1
                add     i, i, 1                                                         // Increment loop counter by 1

loopCheck:      cmp     i, 32                                                           // Compares value of i to 32
                b.lt    loopStart                                                       // If i is less than 32, branch to begin back to loop

                cmp     negative, 1                                                     // Check if value of negative is 1 (TRUE)
                b.ne    printResult                                                     // If negative is false, branch to printResult

                sub     product, product, multiplicand                                  // Otherwise, subtract multiplicand and update product

printResult:    adrp    x0, printAnswer                                                 // Set first argument for printf (higher bits)
                add     x0, x0, :lo12:printAnswer                                       // Set first argument for printf (lower 12 bits)
                mov     w1, product                                                     // Value of 0x%08x is product (in hex)
                mov     w2, multiplier                                                  // Value of next 0x%08x is the multiplier (in hex)
                bl      printf                                                          // Call printf

                sxtw    temp1, product                                                  // Convert product to 64 bits (typecast)
                and     temp1, temp1, 0xFFFFFFFF                                        // Move 0xFFFFFFFF into same register
                lsl     temp1, temp1, 32                                                // Perform left shift by 32
                sxtw    temp2, multiplier                                               // Convert multiplier to 64 bits (typecast)
                and     temp2, temp2, 0xFFFFFFFF                                        // Move 0xFFFFFFFF into same register
                add     result, temp1, temp2                                            // Add temp1 and temp2, and update result
    
                adrp    x0, printAnswer64                                               // Set first argument for printf (higher bits)
                add     x0, x0, :lo12:printAnswer64                                     // Set first argument for printf (lower 12 bits)
                mov     x1, result                                                      // Set value of first placeholder to result (in hex)
                mov     x2, result                                                      // Set value of second placeholder to result (in decimal)
                bl      printf                                                          // Call printf

end:	        mov     x0, 0										                    // Return code 0
	            ldp     x29, x30, [sp], 16								                // Restore the state of the FP and LR registers
                ret                                                                     // Return control to calling code
