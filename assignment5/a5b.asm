// JAZA KHAN UCID 30119100
// CPSC 355 W22 Assignment 5B

// ARMv8 assembly language program which accepts as command line arguments two strings representing a date in the format mm dd. Prints the name 
// of month, the day (with the appropriate suffix), and the season for this date. Exits with an error message if user does not supply two
// command-line arguments. Calls atoi() to convert strings to numbers, and printf() to produce the output. Performs range checking for the day and month.

// ----------------------------------------------------------------------------------------------------------------------------------- //

        .data                                                   // .data section
        define(monthsArr, x27)                                  // Assign 64-bit register x27 to monthsArr for storing address
        define(suffixArr, x28)                                  // Assign 64-bit register x28 to suffixArr for storing address
        define(seasonsArr, x26)                                 // Assign 64-bit register x26 to seasonArr for storing address

        .text                                                   // Program code is read-only so goes in .text section
        finalResult:.string "%s %d%s is %s\n"                   // Formats output for printing out final result
        january:    .string "January"                           // String literal for month
        february:   .string "Febuary"                           // String literal for month
        march:      .string "March"                             // String literal for month
        april:      .string "April"                             // String literal for month
        may:        .string "May"                               // String literal for month
        june:       .string "June"                              // String literal for month
        july:       .string "July"                              // String literal for month
        august:     .string "August"                            // String literal for month
        september:  .string "September"                         // String literal for month
        october:    .string "October"                           // String literal for month
        november:   .string "November"                          // String literal for month
        december:   .string "December"                          // String literal for month
        st:         .string "st"                                // String literal for suffix
        nd:         .string "nd"                                // String literal for suffix
        rd:         .string "rd"                                // String literal for suffix
        th:         .string "th"                                // String literal for suffix
        summer:     .string "Summer"                            // String literal for season
        winter:     .string "Winter"                            // String literal for season
        spring:     .string "Spring"                            // String literal for season
        autumn:     .string "Autumn"                            // String literal for season

        invalidError:   .string "usage: a5b mm dd\n"            // Formats output for printing out error message

        .balign 8                                               // Ensures instructions are properly aligned
        
        // Define months (external array of pointer)
        months:         .dword  january, february, march, april, may, june, july, august, september, october, november, december
        
        // Define suffixes for numbers 1 - 31 (for each day in month) using array
        suffix:         .dword  st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st
        
        // Define seasons using array
        seasons:        .dword  summer, winter, spring, autumn

        argc    .req w23                                        // Rename w23 to argc (# of command line arguments)
        argv    .req x24                                        // Rename x24 to argv (argument vector, stores values of provided arguments)

        define(month, w19)                                      // Assign 32-bit register w19 to month
        define(day, w20)                                        // Assign 32-bit register w20 to day
        define(season, w21)                                     // Assign 32-bit register w21 to seasonr

        .balign 4                                               // Ensures instructions are properly aligned
        .global main                                            // Makes label "main" visible to the linker

        fp      .req x29                                        // Rename frame pointer x29 register to fp
        lr      .req x30                                        // Rename link register x30 register to lr

error:      adrp        x0, invalidError                        // Set first argument of printf (higher bits)
            add         x0, x0, :lo12:invalidError              // Set first argument of printf (lower 12 bits)
            bl          printf                                  // Calls printf
            b           end                                     // Branch to end

main:       stp         fp, lr, [sp, -16]!                      // Store frame pointer and link register
            mov         fp, sp                                  // Update frame pointer to current stack pointer

            mov         argc, w0                                // mov given argc into permanent register defined above
            mov         argv, x1                                // mov given argv into permanent register defined above

            mov         w25, 1                                  // First arg provided after program name = month
            mov         w26, 2                                  // Second arg provided after program name = day
        
            b           check                                   // Branch to check to validate input

check:      cmp         argc, 3                                 // Compare number of arguments provided with 3
            b.ne        error                                   // If number of arguments != 3, print error and end program

            ldr         x0, [argv, w25, SXTW 3]                 // Get month value from arguments given (argv)
            bl          atoi                                    // Parse int from string
            mov         month, w0                               // Store result in month register

            cmp         month, 12                               // Compare month given with 12
            b.gt        error                                   // If month given is > 12, print error and end program
            cmp         month, 0                                // Compare month given  with 0
            b.le        error                                   // If month given is < 0, print error and end program

            ldr         x0, [argv, w26, SXTW 3]                 // Get day value from arguments given (argv)
            bl          atoi                                    // Parse int from string
            mov         day, w0                                 // Store result in day register

            cmp         day, 31                                 // Compare day value with 31
            b.gt        error                                   // If day value is greater than 31, print error and end program
            cmp         day, 0                                  // Compare day value with 0
            b.le        error                                   // If day value is negative, print error and end program

            cmp         month, 1                                // Compare month with 1 (january)
            b.ge        continue                                // If month > 1, branch to continue
            cmp         month, 12                               // Compare month with 12 (december)
            b.eq        setWinter                               // If month == 12, branch to setWinter

            cmp         month, 3                                // Compare month with 3 (march)
            b.gt        continue1                               // If month > 3, branch to continue1
            cmp         month, 3                                // Compare month with 3 (march)
            b.eq        setSpring                               // If month == 3, branch to setSpring

            cmp         month, 12                               // Compare month with 12 (december)
            b.eq        setWinter                               // If month == 12, branch to setWinter

            cmp         month, 6                                // Compare month with 6 (june)
            b.eq        setSummer                               // If month == 6, branch to setSummer
            cmp         month, 6                                // Compare month with 6 (june)
            b.gt        continue2                               // If month > 6, branch to continue2

            cmp         month, 9                                // Compare month with 9 (september)
            b.gt        continue3                               // If month > 9, branch to continue3
            cmp         month, 9                                // Compare month with 9 (september)
            b.eq        setAutumn                               // If month == 9, branch to setAutumn

continue:   cmp         month, 3                                // Compare month with 3 (march)
            b.lt        setWinter                               // If month < 3, branch to setWinter

continue1:  cmp         month, 6                                // Compare month with 6 (june)
            b.lt        setSpring                               // If month < 6, branch to setSpring

continue2:  cmp         month, 9                                // Compare month with 9 (september)
            b.lt        setSummer                               // If month < 9, branch to setSummer

continue3:  cmp         month, 12                               // Compare month with 12 (december)
            b.lt        setAutumn                               // If month < 12, set to setAutumn
            
            // summer
setSummer:  adrp        seasonsArr, seasons                     // Get correct season using seasonsArr address
            add         seasonsArr, seasonsArr, :lo12:seasons   // Lower 12 bits of array address
            mov         season, 0                               // Set season (index in array) to 0
            b           printInfo                               // Branch to printInfo

            // winter
setWinter:  adrp        seasonsArr, seasons                     // Get correct season using seasonsArr address
            add         seasonsArr, seasonsArr, :lo12:seasons   // Lower 12 bits of array address
            mov         season, 1                               // Set season (index in array) to 1
            b           printInfo                               // Branch to printInfo

            // spring
setSpring:  adrp        seasonsArr, seasons                     // Get correct season using seasonsArr addresis
            add         seasonsArr, seasonsArr, :lo12:seasons   // Lower 12 bits of array address
            mov         season, 2                               // Set season (index in array) to 2
            b           printInfo                               // Branch to printInfo

            // autumn
setAutumn:  adrp        seasonsArr, seasons                     // Get correct season using seasonsArr address
            add         seasonsArr, seasonsArr, :lo12:seasons   // Lower 12 bits of array address
            mov         season, 3                               // Set season (index in array) to 3
            b           printInfo                               // Branch to printInfo

printInfo:  adrp        monthsArr, months                       // Get correct month using monthsArr address
            add         monthsArr, monthsArr, :lo12:months      // Lower 12 bits of array address
            sub         month, month, 1                         // Take month - 1 to get its index in monthsArr

            adrp        suffixArr, suffix                       // Get correct suffix using suffixArr address
            add         suffixArr, suffixArr, :lo12:suffix      // Lower 12 bits of array address

            adrp        x0, finalResult                         // Set first arg of printf (higher bits)
            add         x0, x0, :lo12:finalResult               // Set first arg of printf (lower 12 bits)
            ldr         x1, [monthsArr, month, SXTW 3]          // Set first %s in printf to correct month name from month array
            mov         w2, day                                 // Set %d in printf output to day
            sub         day, day, 1                             // Take day - 1 in order to get suffix array index
            ldr         x3, [suffixArr, day, SXTW 3]            // Set next %s in printf to be the correct suffix from the suffix array
            ldr         x4, [seasonsArr, season, SXTW 3]        // Set last %s in printf to be the correct season name from the season array
            bl          printf                                  // Calls printf

end:        ldp         fp, lr, [sp], 16                        // Restore state of frame pointer and link register, deallocate memory
            ret                                                 // Return control to calling code
