# Computer Organization Project: x86 Quantum Implementation

This project explores two methods for implementing a time quantum in task scheduling on microprocessors, in assembly:

1. **Software-based Quantum:**  
   Uses loops and counters within the running program to create time delays. This method is simple but consumes processor time, reducing overall efficiency.

   - *Single loop example:*
     ```asm
     mov cx, 0ffffh
     encore:
         loop encore
     ```
   - *Nested loops example:*
     ```asm
     mov cx, 0ffffh
     boucle_externe:
         mov si, 0ffffh
     boucle_interne:
         dec si
         jnz boucle_interne
         loop boucle_externe
     ```

2. **Hardware-based Quantum:**  
   Utilizes an external timer (TIMER) to manage time delays, freeing the processor from time management tasks. The timer triggers interrupt 08h (IRQ0) every 55 ms, which in turn calls software interrupt 1Ch. This interrupt can be redirected to implement a quantum.

## Project Structure

- `src/` — Assembly source codes for different scheduling scenarios:
  - `1_tache.asm`, `1_tache5.asm` — Single task implementations.
  - `4_taches.asm`, `4_taches5.asm` — Multi-task implementations.
- `screenshots/` — Screenshots and videos demonstrating program execution and results.

### NB:
Comments are in *french*.

## How to Use

Assemble and run the programs using an x86 emulator or compatible environment.


## References

- x86 Interrupts and Timer documentation

