.section ".text.boot"     // Make sure the linker puts this at the start of the kernel image

.global _start            // Execution starts here

_start:
  mrs  x1, mpidr_el1      // Read the Multiprocessor Affinity Register, EL1
  and  x1, x1, #3         // Get the core number (the 2 less significant bits)
  cbnz x1, hang           // Hang the core if it is not the main core (core zero)

init_stack:
  ldr  x1, =_start        // Load this code address into x1
  mov  sp, x1             // Set the stack pointer to start below this code address

init_bss:                 // Init the block starting symbol to store uninitialized variables
  ldr  x1, =__bss_start   // BSS start address. It'll configured via link file
  ldr  w2, =__bss_size    // BSS section size. It'll configured via link file

init_bss_block:
  cbz  w2, execute_main   // If all BSS blocks were initialized execute the main
  str  xzr, [x1], #8      // Store zero (XZR register - 8 bytes) into the BSS address aligning it in 8 bytes (64 bits)
  sub  w2, w2, #1         // Subtract BSS size by one
  cbnz w2, init_bss_block // Loop if non-zero going to the next BSS block

execute_main:
  bl   main               // Execute main from C code

hang:                     // Hang the core
  wfe                     // Wait for exception
  b    hang               // Branch to hang (infinite loop)
