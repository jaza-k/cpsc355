// JAZA KHAN UCID 30119100
// CPSC 355 W22 Assignment 4

// Assembly program that implements the given C program. Implements all subroutines as closed subroutines, 
// using stack variables to store all local variables. Does not work lol

// ------------------------------------------------------------------------------------------------------------ //

printBox:       .string "Box %s origin = (%d, %d)\nWidth = %d  Height = %d\nArea = %d\n\n"          // Format output for printing out box info
printInitial:   .string "Initial values: \n"                        // Format output for printing out initial box values
printChanged:   .string "Changed values: \n"                        // Format output for printing out changed box values
printFirst:     .string "first"                                     // Format string for subroutine argument 
printSecond:    .string "second"                                    // Format string for subroutine argument

                .balign 4                                           // Ensures instructions are properly aligned
                .global main                                        // Makes label "main" visible to the linker

                define(b_r, x19)                                    // Assign 64-bit register x19 to b
                define(first_r, x20)                                // Assign 64-bit register x20 to first  
                define(second_r, x21)                               // Assign 64-bit register x21 to second
                define(result, w19)                                 // Assign 32-bit register w19 to result
                define(factor, w20)                                 // Assign 32-bit register w20 to factor

                x_offset = 0                                        // Stack offset for x variable
                y_offset = 4                                        // Stack offset for y variable
                point_size = 8                                      // Stack offset for nested struct (point)

                width_offset = 0                                    // Stack offset for width variable
                height_offset = 4                                   // Stack offset for height variable
                dimension_size = 8                                  // Stack offset for nested struct (dimension)

                result_offset = 16                                  // Stack offset for result variable
    
                box_origin = 0                                      // Stack offset for box origin (point)
                box_size = 8                                        // Stack offset for box size (dimension)
                box_area = 16                                       // Stack offset for area variable

                box_one = 16                                        // Size of box 1
                box_two = 16                                        // Size of box 2

                first_s = 16                                        // Offset for first
                second_s = first_s + 16                             // Offset for second

                b_size = 16                                         // Size of b
                result_size = 4                                     // Size of result 
                factor_size = 4                                     // Size of factor 

                alloc = -(16 + first_s + second_s) & -16            // Allocating memory   
                dealloc = -alloc                                    // Deallocating memory

                fp      .req x29                                    // Rename frame pointer x29 register to fp
                lr      .req x30                                    // Rename link register x30 register to lr

		        // NEW BOX SUBROUTINE
newBox:         newBox_alloc = -(16 + b_size) & -16                 // Allocate memory for subroutine
                newBox_dealloc = -newBox_alloc                      // Deallocate memory for subroutine

                stp     fp, lr, [sp, newBox_alloc]!                 // Store frame pointer and link register
                mov     fp, sp                                      // Update frame pointer to current stack pointer

                mov     b_r, x8                                     // Move box into local variable b

                str     wzr, [b_r, point_size + x_offset]           // Set b.origin.x to 0
                str     wzr, [b_r, point_size + y_offset]           // Set b.origin.y to 0

                mov     w27, 1                                      // Move value 1 into w27
                str     w27, [b_r, dimension_size + width_offset]   // Store value into box width

                mov     w28, 1                                      // Move value 1 into w28
                str     w28, [b_r, dimension_size + height_offset]  // Store value into box height

                mul     w28, w28, w27                               // Calculate box area 
                str     w28, [b_r, box_area]                        // Store value of box area

                ldp     fp, lr, [sp], newBox_dealloc                // Restore state of frame pointer and link register, deallocate memory
                ret                                                 // Return from this subroutine

                // MOVE SUBROUTINE
                move_alloc = -(16 + alloc) & -16                    // Allocate memory for subroutine
                move_dealloc = -move_alloc                          // Deallocate memory for subroutine

move:           stp     fp, lr, [sp, -16]!                          // Store frame pointer and link register
                mov     fp, sp                                      // Update frame pointer to current stack pointer
    
                ldr     w23, [x8, x_offset + point_size]            // Load value of b.origin.x                
                add     w23, w23, w1                                // Add deltaX
                str     w23, [x8, x_offset + point_size]            // Store new value
    
                ldr     w23, [x8, y_offset + point_size]            // Load value of b.origin.y
                add     w23, w23, w2                                // Add deltaY
                str     w23, [x8, y_offset + point_size]            // Store new value

                ldp     fp, lr, [sp], move_dealloc                  // Restore state of frame pointer and link register, deallocate memory
                ret                                                 // Return from this subroutine

                // EXPAND SUBROUTINE
                expand_alloc = -(16 + b_size + factor_size) & -16   // Allocate memory for subroutine               
                expand_dealloc = -expand_alloc                      // Deallocate memory for subroutine     

expand:         stp     fp, lr, [sp, -16]!                          // Store frame pointer and link register
                mov     fp, sp                                      // Update frame pointer to current stack pointer
                    
                ldr     w10, [x8, dimension_size + width_offset]    // Load value of b.size.width       
                mul     w10, w10, w1                                // Multiply by factor
                str     w10, [x8, dimension_size + width_offset]    // Store new value  
                ldr     w10, [x8, dimension_size + height_offset]   // Load value of b.size.height         
                mul     w10, w10, w1                                // Multiply by factor 
                str     w10, [x8, dimension_size + height_offset]   // Store new value           

                mul     w28, w28, w10                               // Calculate box area
                str     w28, [x8, box_area]                         // Store new value of area

                ldp     fp, lr, [sp], 16                            // Restore state of frame pointer and link register, deallocate memory
                ret                                                 // Return from subroutine

		        // MAIN
main:           stp     fp, lr, [sp, alloc]!                        // Store frame pointer and link register
                mov     fp, sp                                      // Update frame pointer to current stack pointer

                add     first_r, fp, first_s                        // Calculate base address for first
                add     second_r, fp, second_s                      // Calculate based address for second
                mov     x0, first_r                                 // Subroutine argument is first box
                bl      newBox                                      // Branch to newBox

                mov     x0, second_r                                // Subroutine argument is second box
                bl      newBox                                      // Branch to newBox

                adrp    x0, printInitial                            // Set first argument of printf (higher bits)
                add     x0, x0, :lo12:printInitial                  // Set first argument of printf (lower 12 bits)
                bl      printf                                      // Calls printf

                adrp    x0, printFirst                              // Set first argument of printf (higher bits)
                add     x0, x0, :lo12:printFirst                    // Set first argument of printf (lower 12 bits)
                bl      printf                                      // Calls printf
                mov     x8, first_s                                 // Pass in first for subroutine argument 
                bl      printBox                                    // Branch to printBox
    
                adrp    x0, printSecond                             // Set first argument of printf (higher bits)
                add     x0, x0, :lo12:printSecond                   // Set first argument of printf (lower 12 bits)
                bl      printf                                      // Calls printf
                mov     x8, second_s                                // Pass in second for subroutine argument
                bl      printBox                                    // Branch to printBox

                mov     x0, first_r                                 // Pass in first argument for subroutine
                mov     x1, second_r                                // Pass in second argument for subroutine
                bl      equalBox                                    // Branch to equalBox

                ldr     result, [fp, result_offset]
                cmp     result, 0                                   // Compare result to 0
                b.eq    ifStatement                                 // If result = 0 (false), branch to ifStatement

                b       printNew                                    // Otherwise, branch to printNew

		        // EQUAL SUBROUTINE
		        equalBox_alloc = -(16 + alloc + result_size) & -16  // Allocate memory for subroutine
                equalBox_dealloc = -equalBox_alloc                  // Deallocate memory for subroutine

equalBox:      	stp     fp, lr, [sp, alloc]!                        // Store frame pointer and link register
                mov     fp, sp                                      // Update frame pointer to current stack pointer

                mov     result, 0                                   // Set result to false initially   

                ldr     w24, [first_r, x_offset + point_size]       // Load b.origin.x for box 1
                ldr     w25, [second_r, x_offset + point_size]      // Load b.origin.x for box 2
                cmp     w24, w25                                    // Compare both values
                b.ne    notEqual                                    // If not equal, branch to notEqual

                ldr     w24, [first_r, y_offset + point_size]       // Load b.origin.y for box 1
                ldr     w25, [second_r, y_offset + point_size]      // Load b.origin.y for box 2
                cmp     w24, w25                                    // Compare both values
                b.ne    notEqual                                    // If not equal, branch to notEqual

                ldr     w24, [first_r, width_offset + dimension_size]     // Load b.size.width for box 1            
                ldr     w25, [second_r, width_offset + dimension_size]    // Load b.size.width for box 2
                cmp     w24, w25                                          // Compare both values
                b.ne    notEqual                                          // If not equal, branch to notEqual
                    
                ldr     w24, [first_r, height_offset + dimension_size]    // Load b.size.height for box 1     
                ldr     w25, [second_r, height_offset + dimension_size]   // Load b.size.height for box 2
                cmp     w24, w25                                          // Compare both values
                b.ne    notEqual                                          // If not equal, branch to notEqual

                mov     result, 1                                    // Set result to true

notEqual:	    str     result, [fp, result_offset]                  // Store value of result
                ldp     fp, lr, [sp], dealloc                        // Restore state of frame pointer and link register, deallocate memory
                ret                                                  // Return from subroutine

ifStatement:    mov     x0, first_r                                  // Pass in first for subroutine argument
                mov     w1, -5                                       // Argument for move function
                mov     w2, 7                                        // Argument for move function
                bl      move                                         // Branch to move subroutine

                mov     x8, second_r                                 // Pass in second for subroutine argument
                mov     w1, 3                                        // Argument for expand subroutine
                bl      expand                                       // Branch to expand subroutine

printNew:       adrp    x0, printChanged                             // Set first argument of printf (higher bits)
                add     x0, x0, :lo12:printChanged                   // Set first argument of printf (lower 12 bits)
                bl      printf                                       // Calls printf

                adrp    x0, printFirst                               // Set first argument of printf (higher bits)
                add     x0, x0, :lo12:printFirst                     // Set first argument of printf (lower 12 bits)
                bl      printf                                       // Calls printf
                mov     x8, first_r                                  // Move first_r as argument for function
                bl      printBox                                     // Branch to printBox
                    
                adrp    x0, printSecond                              // Set first argument of printf (higher bits)
                add     x0, x0, :lo12:printSecond                    // Set first argument of printf (lower 12 bits)
                bl      printf                                       // Calls printf
                mov     x8, second_r                                 // Move second_r as argument for function
                bl      printBox                                     // Branch to printBox

end:			mov	    x0, 0									 	 // Return code 0 for successful termination
			    ldp     fp, lr, [sp], dealloc					     // Restore state of frame pointer and link register, deallocate memory
			    ret											 	     // Returns control to calling code
