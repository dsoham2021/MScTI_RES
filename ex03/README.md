# Assignment 3
## Task 1

### (a), (b)
The code is provided in the src/ along with the appropriate test bench in the tb/ folder. We test every single mode of the ALU and thus attempt to provide maximum coverage, along with testing edge cases for addition and subtraction where the carry and overflow bits are set on the status bits. All the tests pass in the test bench. We test addition overflow (without setting off the carry bit) and subtraction which sets off the carry bit but not the overflow as edge cases, along with the standard addition and subtraction. In this case our test strategy is simple: directed testing along with edge cases. 


## Task 2

### (a)

We design a debouncer using a shift register along with a 1 MHz tick based clock. Since the shift register can only be updated during a tick, which takes 1 microsecond (1 MHz = 1 us per per cycle), a total of 8 microseconds are required until the switch press is registered. This can be extended either with more bits in the shift register, or a larger counter (for e.g. 2500) which goes up on every tick and only outputs a press if the maximum value is achieved before the next counter reset, which would imply a continuous press. We use the shift register method to keep things simpler here.

### (b)
We provide a simple test bench which registers the bouncy switch which eratically oscillates before settling to a constant on value for a longer time, where our design should register it as a key press. After a certain time, the button is unpressed erratically again, which is quickly detected as not pressed any longer on the output. A waveform simulation of the same is also provided as an image showing how the output signal only registers a key press once the shift register is full of 1s. We also use the procedure intrinsics to simulate the erratic key presses and key releases in our test bench. The procedure acts as a void user-defined function here. 

### (c) 
It takes 8 microseconds for our implementation to follow changes on the input. This is because we use a shift register, where each bit is updated at 1 microsecond interval only, using the 1 MHz tick based clock. The shortest achievable latency would be the maximum physical bounce time of the specific switch, which is often provided by the manufacturer datasheet. For e.g. if it says the button bounces for a maximum of 1.50 milliseconds, the optimal debouncer latency should be exactly 1.51 milliseconds. If it is shorter, we can get ghost presses and if longer, the switch would feel laggy to the user.

#### Critical areas where debouncing is necessary
1. Emergency stop buttons on something like assembly lines or fast moving line-following robots. The millisecond delay could result in physical damage.
2. Machines like a defibrillator or patient-controlled analgesia pump with a bouncing switch could deliver accidental double shocks or a double dose of medication. 
3. Thrusters or deploying gears on aeroplanes. 
4. For MIDI controllers or high fidelity audio, delays in say hitting a drum and hearing the sound would ruin the music.

### (d) 
In a low-level software environment, button bouncing can be handled using a timer interrupt combined with a state machine to ensure non-blocking execution like this:

For sampling, a hardware timer is configured to trigger an Interrupt Service Routine (ISR) at a regular interval (e.g., every 1 ms) to sample the target GPIO pin.

The system maintains a state variable (e.g., IDLE, DEBOUNCING, PRESSED) and a counter. When the GPIO pin transitions from its default state, the state machine moves to the DEBOUNCING state and begins incrementing the counter on each timer tick. If then the pin state remains stable until the counter reaches a predefined threshold (e.g., 20 ms), the press is registered as valid, and the system transitions to the PRESSED state. If the pin fluctuates back to its default state before the threshold is reached, the counter and state reset, ignoring the mechanical bounce.


### (e) 
To say, read 64 keys without using 64 individual input pins, we can implement a Row-Column Matrix Scanning architecture (1D to 2D). This would reduce the required pin count from 64 to just 16.

The 64 buttons would be wired into an 8x8 grid. The 8 horizontal rows are connected to microcontroller output pins, and the 8 vertical columns are connected to input pins configured with internal pull-up resistors. The software would continuously loop through the rows, driving exactly one row pin LOW (active) at a time, while leaving the other seven rows HIGH. While a specific row is driven LOW, the microcontroller reads the state of all 8 column input pins. If a button is pressed, the mechanical switch bridges the row and the column, pulling that specific column pin LOW. The software would then determine the exact key pressed by mapping the intersection of the currently active row and the triggered column. In this case we can save input pins by using a 2D matrix and scanning them with a higher frequency.

### (f)

We implemented an up-down counter using our debouncer along with a top that connects the debouncer to the counter. This design is then synthesised using the build.tcl file in the scripts/ folder, which generates a top.bit which we tested. In this design, the 16 LED pins on the board act as a binary counter and the top and bottom buttons help update this visual counter, with the button in the middle acting as a reset for the counter. We tested this on the Basys 3 FPGA board and it registered far fewer bounced key presses compared to the first exercise with UART where pressing the button outputted "Hello world!" on the terminal, where we saw multiple lines being outputted on a single press of the center button key.