// JAZA KHAN UCID 30119100
// CPSC 355 W22 Assignment 5A

// ARMv8 assembly language program that implements given C program for a LIFO (Last In First Out) stack data structure. Translates
// all functions except main() into assembly. These functions will be called from the main() function, stored in a5aMain.c. Assembly
// functions use the printf() library routine. Global variables are stored here. Receives input from standard input. 

// ------------------------------------------------------------------------------------------------------------------------------------------- //

                    // Define constants
                    STACKSIZE = 5                               // Assembler equate for stack size
                    TRUE = 1                                    // Assembler equate for defining true
                    FALSE = 0                                   // Assembler equate for defining false
                    
                    // m4 macros
                    define(i, w21)                              // Assign 32-bit register w21 to i variable
                    define(value, w22)                          // Assign 32-bit register w22 to value variable
                    define(temp, w23)                           // Assign 32-bit register w23 to a temporary variable

                    fp      .req x29                            // Rename frame pointer x29 register to fp
                    lr      .req x30                            // Rename link register x30 register to lr

                    base_r  .req x20                            // Rename x20 to hold base address
                    
                    .bss                                        // .bss section
                    .global dest                                // Globalize the stack
dest:               .skip   STACKSIZE * 4                       // Each stack has size 5

                    .data                                       // .data section
                    .global top                                 // Globalize top
top:                .word   -1                                  // Points to an integer

                    .text                                       // Program code is read-only so goes in .text section
printOverflowError: .string "\nStack overflow! Cannot push value onto stack.\n"             // Format output string for printing overflow error
printUnderflowError:.string "\nStack underflow! Cannot pop an empty stack.\n"               // Format output string for printing underflow error
printEmptyStack:    .string "\nEmpty stack\n"                   // Format output string for printing out empty stack error
printContents:      .string "\nCurrent stack contents:\n"       // Format output string for printing out current stack contents label
printStackTopLabel: .string " <-- top of stack"                 // Format output string for printing out top of stack label
printNewLineLabel:  .string "\n"                                // Format output string for printing out new line
printArgument:      .string " %d"                               // Format output string for printing out argument


                    .balign 4                                   // Ensures instructions are properly aligned
                    .global push                                // Makes label "push" visible to the linker
push:               stp     fp, lr, [sp, -16]!                  // Store frame pointer and link register 
                    mov     fp, sp                              // Update frame pointer to current stack pointer
                    mov     value, w0                           // Move value into w0

                    bl      stackFull                           // Branch to and link (calls) stackFull method
                    cmp     w0, FALSE                           // Check if function returned false (stack is !full)
                    b.eq    pushElse                            // If stack is !full, branch to else block for push

                    adrp    x0, printOverflowError              // Otherwise, set first argument of printf (higher bits)
                    add     x0, x0, :lo12:printOverflowError    // Set first argument of printf (lower 12 bits)
                    bl      printf                              // Calls printf
                    b       done                                // Branch to end

pushElse:           adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top           //
                    ldr     w1, [base_r]                        // Load value of top stored at address into w1
                    mov     temp, w1                            // Move value of top into temporary register
                    add     temp, temp, 1                       // Increment top by 1
                    str     temp, [base_r]                      // Store value of top back into address
                    adrp    base_r, dest                        // Get base address of top pointer
                    add     base_r, base_r, :lo12:dest          //
                    str     value, [base_r, temp, SXTW 2]       // Store value back into address

done:               ldp     fp, lr, [sp], 16                    // Restore state of frame pointer and link register, deallocate memory
                    ret                                         // Return control to calling code

                    .global pop                                 // Makes label "pop" visible to the linker
pop:                stp     fp, lr, [sp, -16]!                  // Store frame pointer and link register
                    mov     fp, sp                              // Update frame pointer to current stack pointer
                    
                    bl      stackEmpty                          // Branch to and link (calls) stackEmpty method
                    cmp     w0, FALSE                           // Check if function returned false (stack is !empty)
                    b.eq    popElse                             // If stack is !empty, branch to else block for pop

                    adrp    x0, printUnderflowError             // Otherwise, set first argument of printf (higher bits)
                    add     x0, x0, :lo12:printUnderflowError   // Set first argument of printf (lower 12 bits)
                    bl      printf                              // Calls printf
                    mov     w0, -1                              // Assign return value of -1
                    b       done1                               // Branch to end

popElse:            adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top           
                    ldr     w1, [base_r]                        // Load value of top stored at address into w1
                    mov     temp, w1                            // Move value of top into temporary register
                    adrp    base_r, dest                        // Get base address of top pointer
                    add     base_r, base_r, :lo12:dest          //
                    ldr     value, [base_r, temp, SXTW 2]       // Load the value at index of top into value register
                    sub     temp, temp, 1                       // Decrement top by 1
                    adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top
                    str     temp, [base_r]                      // Store value of top into memory at address
                    mov     w0, value                           // Return value

done1:              ldp     fp, lr, [sp], 16                    // Restore state of frame pointer and link register, deallocate memory
                    ret                                         // Return control to calling code

                    .global stackFull                           // Makes label "stackFull" visible to the linker
stackFull:          stp     fp, lr, [sp, -16]!                  // Store frame pointer and link register
                    mov     fp, sp                              // Update frame pointer to current stack pointer

                    mov     w19, STACKSIZE                      // Move size of stack into temporary register
                    sub     w19, w19, 1                         // Decrement stack size by 1
                    adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top           //
                    ldr     w1, [base_r]                        // Load value of top stored at address into w1
                    mov     temp, w1                            // Move value of top into temporary register
                    cmp     temp, w19                           // Compare value of top with 1 less than stack size

                    b.eq    continue                            // If top is equal to 1 less than stack size branch to continue
                    mov     w0, FALSE                           // Otherwise, assign false to return value
                    b       done2                               // Branch to end

continue:           mov     w0, TRUE                            // Assign value of true to result

done2:              ldp     fp, lr, [sp], 16                    // Restore state of frame pointer and link register, deallocate memory
                    ret                                         // Return control to calling code

                    .global stackEmpty                          // Makes label "stackEmpty" visible to the linker
stackEmpty:         stp     fp, lr, [sp, -16]!                  // Store frame pointer and link register
                    mov     fp, sp                              // Update frame pointer to current stack pointer

                    adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top
                    ldr     w1, [base_r]                        // Load value of top stored at address into w1
                    mov     temp, w1                            // Move value of top into temporary register
                    cmp     temp, -1                            // Compare value of top with -1

                    b.eq    continue1                           // Branch to continue1 if top is equal to -1
                    mov     w0, FALSE                           // Otherwise, assign false to return value
                    b       done3                               // Branch to end

continue1:          mov     w0, TRUE                            // Assign value of true to result

done3:              ldp     fp, lr, [sp], 16                    // Restore state of frame pointer and link register, deallocate memory
                    ret                                         // Return control to calling code

                    .global display                             // Makes label "display" visible to the linker
display:            stp     fp, lr, [sp, -16]!                  // Store frame pointer and link register
                    mov     fp, sp                              // Update frame pointer to current stack pointer

                    bl      stackEmpty                          // Branch to and link (calls) stackEmpty method
                    cmp     w0, FALSE                           // Check if function returned false (stack is !empty)
                    b.eq    displayElse                         // If stack is !empty, branch to else block for display
                    adrp    x0, printEmptyStack                 // Otherwise, set first argument of printf (higher bits) 
                    add     x0, x0, :lo12:printEmptyStack       // Set first argument of printf (lower 12 bits)
                    bl      printf                              // Calls printf
                    b       end                                 // Branch to end 

displayElse:        adrp    x0, printContents                   // Set first argument of printf (higher bits)
                    add     x0, x0, :lo12:printContents         // Set first argument of printf (lower 12 bits)
                    bl      printf                              // Calls printf

                    adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top
                    ldr     w1, [base_r]                        // Load value of top stored at address into w1
                    mov     i, w1                               // Set index equal to top
                    b       test                                // Branch to test (for loop)

displayLoop:        adrp    base_r, dest                        // Get base address of top pointer
                    add     base_r, base_r, :lo12:dest
                    ldr     value, [base_r, i, SXTW 2]          // Load value from stack at i = top into valuee
                    adrp    x0, printArgument                   // Set first argument of printf (higher bits)
                    add     w0, w0, :lo12:printArgument         // Set first argument of printf (lower 12 bits)
                    mov     w1, value                           // Move value into w1 register
                    bl      printf                              // Calls printf
                    adrp    base_r, top                         // Get base address of top pointer
                    add     base_r, base_r, :lo12:top
                    ldr     w1, [base_r]                        // Load value of top stored at address into w1
                    cmp     i, w1                               // Compare index value with top
                    sub     i, i, 1                             // Decrement index by 1
                    b.eq    printStackTop                       // If index = top, branch to printStackTop
                    b       printNewLine                        // Branch to printNewLine

printStackTop:      adrp    x0, printStackTopLabel              // Set first argument of printf (higher bits)
		       	    add     x0, x0, :lo12:printStackTopLabel    // Set first argument of printf (lower 12 bits)
			        bl	    printf						        // Calls printf

printNewLine:       adrp    x0, printNewLineLabel               // Set first argument of printf (higher bits)
                    add     x0, x0, :lo12:printNewLineLabel     // Set first argument of printf (lower 12 bits)
                    bl      printf                              // Calls printf
                    
test:               cmp     i, 0                                // Compare index value with 0
                    b.ge    displayLoop                         // If i > 0, return to loop

end:                ldp     fp, lr, [sp], 16                    // Restore state of frame pointer and link register, deallocate memory
                    ret                                         // Return control to calling code
