// Jaza Khan UCID 30119100
// CPSC 355 W22 Assignment 3

// ARMv8 assembly language program to implement given sorting algorithm. Creates space on the stack to store all local variables. 
// Uses m4 macros or assembler equates for all stack variable offsets. Reads or writes memory when using or assigning local variables. 

// -------------------------------------------------------------------------------------------------------------------------------------------- //

labelUnsortedArray:         .string "\nUnsorted array:    \n"                   // Format output for printing out unsorted array
labelSortedArray:           .string "\nSorted array:  \n"                       // Format output for printing out sorted array
printElements:              .string "v[%d] = %d\n"                              // Prints elements in array
                            
                            .balign 4                                           // Ensures instructions are properly aligned
                            .global main                                        // Makes label "main" visible to the linker

                            // Assembler equates
                            size      =    50                                   // Array contains 50 elements
                            v_size    =    size * 4                             // Block size of array (50 * 4 bytes each) = 200 bytes for array
                            i_size    =    4                                    // 4 bytes for i index
                            j_size    =    4                                    // 4 bytes for j index
                            temp_size =    4                                    // 4 bytes for temp
                           
                            i_s       =    16                                   // Stack offset for variable i
                            j_s       =    20                                   // Stack offset for variable j
                            temp_s    =    24                                   // Stack offset for temp variable
                            v_s       =    28                                   // Stack offset for array base

                            alloc     =    -(16 + i_s + j_s + temp_s + v_s + v_size) & -16      // Allocate memory
                            dealloc   =    -alloc                                               // Deallocate memory

                            fp      .req x29                                    // Rename frame pointer x29 register to fp
                            lr      .req x30                                    // Rename link register x30 register to lr

main:                       stp     fp, lr, [sp, alloc]!                        // Store frame pointer and link register
                            mov     fp, sp                                      // Update frame pointer to current stack pointer

                            // Define m4 macros
                            define(v_base_r, x19)                               // Assign 64-bit register x19 to v_base_r
                            define(i, w20)                                      // Assign 32-bit register w20 to i
                            define(j, w21)                                      // Assign 32-bit register w21 to j
                            define(temp, w22)                                   // Assign 32-bit register w22 to temp
                            define(j1, w23)                                     // Assign 32-bit register w23 to j1 to store value of j-1
                            define(vi, w24)                                     // Assign 32-bit register w24 to vi
                            define(vj, w25)                                     // Assign 32-bit register w25 to vj
                            define(vj1, w26)                                    // Assign 32-bit register w26 to vj1 to store value of v[j-1]

                            add     v_base_r, fp, v_s                           // Calculate base address for array 

                            ldr     i, [fp, i_s]                                // Load i value from address
                            mov     i, 0                                        // Set index value to 0
                            str     i, [fp, i_s]                                // Value found in index register stored to address found in [fp, i_s]

                            ldr     j, [fp, j_s]                                // Load j value from address
                            mov     j, 0                                        // Set j value to 0
                            str     j, [fp, j_s]                                // Value found in adress stored to j

                            ldr     temp, [fp, temp_s]                          // Value found in address loaded into temp variable
                            mov     temp, 0                                     // Value of temp set to 0
                            str     temp, [fp, temp_s]                          // Value found in temp stored to address found in [fp, temp_s]

                            b       checkRandLoop                               // Branch to first loop check (check i value)

randArray:                  ldr	    i, [fp, i_s]					            // Value at address found in [fp, i_s] loaded into index register
                            bl      rand                                        // Calls rand
                            and     vi, w0, 0xFF                                // Add 0xFF in vi
                            str     vi, [v_base_r, i, SXTW 2]                   // Value in vi register stored to address
                            
			                add	    i, i, 1									    // Increment index value by 1 at end of each iteration
			                str	    i, [fp, i_s]							    // Value found in index register is stored to address found in [fp, i_s]

checkRandLoop:              cmp     i, size                                     // Compare index value to 50 (array elements size)
                            b.lt    randArray                                   // If less than 50, branch to randArray loop again

// --------------------------------------------------------------------- //
                            adrp    x0, labelUnsortedArray                      // Set first argument of printf (higher bits)
                            add     x0, x0, :lo12:labelUnsortedArray            // Set first argument of printf (lower 12 bits)
                            bl      printf                                      // Calls printf

                            mov     i, 0                                        // Initialize i to 0
                            str     i, [fp, i_s]                                // Value  found in index register stored to address found in [fp, i_s]
                            b       printUnsortedCheck                          // Branch to printUnsortedCheck

printUnsortedArray:         ldr     i, [fp, i_s]                                // Value from address loaded into index register (i)
                            ldr     vi, [v_base_r, i, SXTW 2]                   // Value from address loaded into vi (v[i])

                            adrp    x0, printElements                           // Set first argument of printf (higher bits)
                            add     x0, x0, :lo12:printElements                 // Set first argument of printf (lower 12 bits)
                            mov     w1, i                                       // First %d in statement is index value
                            mov     w2, vi                                      // Second %d in statement is value at v[i]
                            bl      printf                                      // Calls printf

                            add     i, i, 1                                     // Increment index value by 1
                            str     i, [fp, i_s]                                // Store index value at address found in [fp, i_s]

printUnsortedCheck:         cmp     i, size                                     // Compares index value with 50
                            b.lt    printUnsortedArray                          // If i < 50, repeat print loop
// --------------------------------------------------------------------- //

                            // INSERTION SORT

                            ldr     i, [fp, i_s]                                // Load value of i from address
                            mov     i, 1                                        // Set value of i to 1
                            str     i, [fp, i_s]                                // Set new value of i to address [fp, i_s]
                            b       checkFirstLoop                              // Branch to test for first loop

firstLoop:                  ldr     i, [fp, i_s]                                // Load value of i from address
                            ldr     vi, [v_base_r, i, SXTW 2]                   // Load value into  v[i] from address
                            str     vi, [fp, temp_s]                            // Move v[i] into temp and store it to address
                                                                
                            ldr     i, [fp, i_s]                                // Load value of i from address
                            str     i, [fp, j_s]                                // Move j into i and store it to address
                            b       checkSecondLoop                             // Branch to test for second loop

secondLoop:                 ldr     j, [fp, j_s]                                // Load value of j from address
                            sub     j1, j, 1                                    // Subtract j-1 and store it in j1
                            ldr     vj1, [v_base_r, j1, SXTW 2]                 // Load value into v[j-1] from address using j1
                            add     j1, j1, 1                                   // Increment value of j1
                            str     vj1, [v_base_r, j1, SXTW 2]                 // Move value of v[j-1] to v[j] and store it to address

                            ldr     j, [fp, j_s]                                // Load value of j from address
                            sub     j, j, 1                                     // Decrement value of j (loop counter)
                            str     j, [fp, j_s]                                // Store value found in j to address

checkSecondLoop:            ldr     j, [fp, j_s]                                // Load value of j from address
                            cmp     j, 0                                        // Compare value of j to 0
                            b.le    done                                        // If j < 0 (first condition fails) then branch to done
                            sub     j1, j, 1                                    // Subtract j-1 and store in j1
                            ldr     vj1, [x19, j1, sxtw 2]                      // Load value into v[j-1] from address using j1
                            ldr     temp, [fp, temp_s]                          // Load value into temp from its address
                            cmp     temp, vj1                                   // Compare value of temp and v[j-1]
                            b.ge    done                                        // If temp > v[j-1] (second condition fails) branch to done
                            b       secondLoop                                  // Branch to second loop if conditions pass

done:                       ldr     j, [fp, j_s]                                // Load value of j from its address
                            ldr     temp, [fp, temp_s]                          // Load value of temp from its address
                            str     temp, [v_base_r, j, SXTW 2]                 // Move value of temp into v[j] and store it to address

                            ldr     i, [fp, i_s]                                // Load value of i from address
                            add     i, i, 1                                     // Increment value of index i
                            str     i, [fp, i_s]                                // Store new value of i into address

checkFirstLoop:             ldr     i, [fp, i_s]                                // Load value of index i from address
                            cmp     i, size                                     // Compare value of i with size (50)
                            b.lt    firstLoop                                   // If i < 50 then repeat sorting loop
                           
// ----------------------------------------------------------------------- //
                            adrp    x0, labelSortedArray				        // Set first argument of printf (higher bits)
		       	            add     x0, x0, :lo12:labelSortedArray	            // Set first argument of printf (lower 12 bits)
			                bl	    printf										// Calls printf

                            mov     i, 0                                        // Initialize i to 0
                            str     i, [fp, i_s]                                // Value found in index register stored to address found in [fp, i_s]
                            b       printSortedCheck                            // Branch to printSortedCheck

printSortedArray:           ldr     i, [fp, i_s]                                // Value from address loaded into index register (i)
                            ldr     vj, [v_base_r, i, SXTW 2]                   // Value from address loaded into vj (v[j])

                            adrp    x0, printElements                           // Set first argument of printf (higher bits)
                            add     x0, x0, :lo12:printElements                 // Set first argument of printf (lower 12 bits)
                            mov     w1, i                                       // First %d in statement is index value
                            mov     w2, vj                                      // Second %d in statement is value at v[j]
                            bl      printf                                      // Calls printf

                            add     i, i, 1                                     // Increment index value by 1
                            str     i, [fp, i_s]                                // Store index value at address found in [fp, i_s]

printSortedCheck:           cmp     i, size                                     // Compares index value with 50
                            b.lt    printSortedArray                            // If i < 50, repeat print loop
// ----------------------------------------------------------------------- //

end:			            mov	    x0, 0									 	// Return code 0 for successful termination
			                ldp     fp, lr, [sp], dealloc				        // Restore state of frame pointer and link register, deallocate memory
			                ret											 	    // Returns control to calling code
