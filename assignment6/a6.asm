// JAZA KHAN UCID 30119100
// CPSC 355 W22 Assignment 6

// ARMv8 assembly language program to compute the function e^x and e^-x using the series expansion given. Uses double
// precision floating-point numbers. Reads a series of input values from a file whose name is specified at the command 
// line. Takes input values in binary format, each number will be double precision (8 bytes long). Reads from the file 
// using I/O (with an exception using svc). Processes input values one at a time using a loop, calculates e^x and e^-x 
// and then prints output in table form, with a precision of 10 decimal points for all values. Continues to accumulate 
// terms in the series until the absolute value of the term is less than 1.0e-10.

// ------------------------------------------------------------------------------------------------------------------------ // 

                .data                                   // .data section
                .balign 8                               // Ensure instructions are properly aligned
stopLimit:      .double 0r1.0e-10                       // Set threshold (limit for stopping the series)

                .text                                   // .text section (program code is read-only)
                .balign 4                               // Ensure instructions are properly aligned
fileError:      .string "Error opening file!\n"         // Formats output for printing out error message
printHeading:   .string " x                   e^x                  e^-x\n"  // Formats output for printing out header at the top
printOutput:	.string "%13.10f \t %16.10f \t %13.10f \t \n"               // Creates column formatting for result

                // m4 macros
                define(fd_r, w19)                       // Assign 32-bit register w19 to file descriptor
                define(nread_r, x20)                    // Assign 64-bit register x20 for bytes read variable
                define(buf_base_r, x21)                 // Assign 64-bit register x22 to base address for buf

                define(e_x, d16)                        // Assign D register d16 to hold answer for e^x   
                define(e_negativeX, d17)                // Assign D register d17 to hold answer for e^-x 
                define(currentResult, d22)              // Assign D register d22 to currentResult
                define(result, d23)                     // Assign D register d23 to hold result for division
                define(numerator, d24)                  // Assign D register d24 to numerator
                define(denominator, d25)                // Assign D register d25 to denominator
                define(loop, d26)                       // Assign D register d26 to loop variable
                define(index, d27)                      // Assign D register d27 for index (loop counter)
                define(input, d28)                      // Assign D register d28 to hold input (x)
                define(changeSign, d29)                 // Assign D register d29 for changeSign
                define(sign, d30)                       // Assign D register d30 to hold sign of x (+ or -)

                // Assembler equates
                buf_size = 8                            // Buffer for reading 8 byte floats
                buf_s = 16                              // Stack offset for buffer 
                alloc = -(16 + buf_size) & -16          // Allocating memory
                dealloc = -alloc                        // Deallocating memory

                .global main                            // Makes label "main" visible to the linker
main:           stp     x29, x30, [sp, alloc]!          // Store frame pointer and link register
                mov     x29, sp                         // Update frame pointer to current stack pointer

                fmov	loop, 1.0e+0                    // Set loop counter to 1

	            mov	    w0, -100		                // AT_FDCWD = -100, reading input from file begins
	            ldr	    x1, [x1, 8]                     // Load input file from command line
	            mov	    w2, 0			                // O_RDONLY = 0
	            mov	    w3, 0			                // 4th arg (not used)
	            mov	    x8, 56			                // Openat I/O request (system call of 56 for open file) 
	            svc	    0			                    // Call system function

	            mov	    fd_r, w0		                // Record file descriptor 
	
	            cmp	    fd_r, 0			                // Error check
	            b.ge	fileOpened			            // Branch to fileOpened if successful, otherwise print error below

	            adrp	x0, fileError		            // Set first argument of printf (higher bits)
	            add	    x0, x0, :lo12:fileError	        // Set first argument of printf (lower 12 bits)
	            bl	    printf			                // Calls printf
	            mov	    w0, -1			                // Assign -1 to return value
	            b	    exit			                // Branch to program end

fileOpened:     adrp	x0, printHeading                // Set first argument of printf (higher bits)
	            add	    x0, x0, :lo12:printHeading	    // Set first argument of printf (lower 12 bits)
	            bl	    printf			                // Calls printf 
                add	    buf_base_r, x29, buf_s	        // Calculate base address for buffer

top:	        mov	    w0, fd_r		                // 1st arg (file to read)
	            mov	    x1, buf_base_r		            // 2nd arg (buffer)
	            mov	    w2, buf_size		            // 3rd arg (number of bytes read each time)
	            mov	    x8, 63			                // Read I/O request (system call of 63 for read)
	            svc	    0			                    // Call system function
	            mov	    nread_r, x0		                // Records number of bytes read
	            
	            cmp	    nread_r, buf_size	            // Check if the read line is buffer size
	            b.ne	end			                    // If reached end of file, branch to end of program
                
                // Taylor expansion //
                // e^x
	            ldr	    d0, [buf_base_r]                // Load x value
	            fmov    sign, 1.0                       // Set sign for x (positive)
	            fmov    d1, sign                        // Save sign for x in 2nd arg
	            bl	    taylorExp                       // Branch to subroutine for calculation
	            fmov    e_x, d0                         // Move result from subroutine into e^x
	            //  e^-x
	            ldr	    d0, [buf_base_r]                // Load x value
	            fmov    sign, -1.0                      // Set sign for x (negative)
	            fmov    d1, sign                        // Save sign for x in 2nd arg
	            bl	    taylorExp                       // Branch to subroutine for calculation
	            fmov    e_negativeX, d0                 // Move result from subroutine into e^-x

                adrp	x0, printOutput		            // Set first argument of printf (higher bits)
	            add	    x0, x0, :lo12:printOutput       // Set first argument of printf (lower 12 bits)
	            ldr	    d0, [buf_base_r]	            // 2nd arg (load the read 8 bytes from the buffer)
	            fmov    d1, e_x                         // 3rd arg (e^x)
	            fmov    d2, e_negativeX                 // 4th arg (e^-x)
	            bl	    printf			                // Calls printf
	            b	    top			                    // Branch to top 
  
end:	        mov	    w0, fd_r		                // 1st arg (fd)
	            mov	    x8, 57			                // Close I/O request (system call of 57)
	            svc	    0			                    // Call system function
	            mov	    w0, 0			                // Assign 0 to return value

exit:	        ldp	    x29, x30, [sp], dealloc         // Restore state of frame pointer and link register, deallocate memory
	            ret                                     // Return control to calling code

                // Subroutine for calculations. Takes input with sign and returns final result
taylorExp:      stp	    fp, lr, [sp, -16]!              // Store frame pointer and link register 
	            mov	    fp, sp                          // Update frame pointer to current stack pointer
	    
	            fmov    input, d0                       // Load x, input value
	            fmov    sign, d1                        // Load sign for x, + or -
	            fmov    changeSign, 1.0                 // Set to positive by default
	            fmov    numerator, input                // Move input value into numerator variable
	            fmov    index, 1.0                      // Initialize counter
	            fmov    denominator, 1.0                // Initialize denominator
	            fmov    currentResult, xzr              // Intitialize currentResult (0)

continue:       fdiv    result, numerator, denominator  // num/denom and store result in currentResult

	            // Check if stop limit has been reached, continue otherwise
	            adrp    x26, stopLimit                  // Get base address of stopLimit
	            add	    x26, x26, :lo12:stopLimit       // 
	            ldr	    loop, [x26]                     // Load current value at top
	            fcmp    result, loop                    // If current div result is bigger than stop limit, continue
	            b.le    increment                       // Otherwise, branch to increment
	   
                // Flip sign of result based on x
	            fmul    changeSign, changeSign, sign    // Change sign of div result
	            fmul    result, result, changeSign      // Change sign of div result
	            fadd    currentResult, currentResult, result // Add individual result to total (build up each time)
	            
                // Compute next term
	            fmul    numerator, input, numerator     // Numerator multiplied by original x for each iteration
	            fmov    loop, 1.0                       // Set loop counter to 1
	            fadd    index, index, loop              // Increment loop counter by 1
	            fmul    denominator, denominator, index // Denominator multiplied by the incremented index value for each iteration
	            b	    continue                        // Branch back to top to continue
                
                // Increment total result by 1 and end program
increment:      fmov    loop, 1.0                       // Set loop counter to 1
	            fadd    currentResult, currentResult, loop // Increment total result by 1
	            fmov    d0, currentResult               // Move value of total result to return value
	            ldp     x29, x30, [sp], 16              // Restore state of frame pointer and link register, deallocate memory
	            ret                                     // Return control to calling code
