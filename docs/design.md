---
layout: page
title: Design
permalink: /design/
---

# Microcontroller Design

As mentioned above, the MCU will be used to control the stepper motor that will move the slide whistle to play different notes. The block diagram for the wiring of the MCU with the A4988 stepper motor driver and the stepper motor itself is shown in Appendix B. The MCU provides two main control signals to the stepper motor driver: the direction and steps. The direction pin is either high or low to indicate direction, and for each pulse sent to the step pin the motor moves one step. In order to send a known number of pulses at a certain rate, we use the timer 16 peripheral in one-shot PWM mode together with the repetition counter set to the desired number of pulses (Appendix C). All that is required now to move the slide whistle to the desired position to play notes is the physical gearing and a calibration curve to relate frequency to a position along the slide whistle. 


# FPGA Design

As mentioned above, the FPGA is capable of displaying characters on the LCD. It is set up using the schematic shown in figure 1. The LCD in this case uses a Hitachi HD44780U LCD controller chip. The FPGA was implemented in a way that could mimic what was described in this controller’s datasheet. This involved creating two finite state machines. The first FSM, used to send data works as follows: it waits for data to come in from the controller FSM, indicated by a dataready signal rising to 1. Then it goes through the steps to send the inputs of the correct RS, R/W, Data, and Enable signals to the LCD controller. Once it is done, it raises a sendchardone signal for a cycle to indicate to the controller FSM that the transaction is complete and a new one can be made. Then the sender FSM sits in a wait state again until the controller sends more data.

The controller FSM is rather more complicated, as it has to decide the setup signals being sent to the LCD and time all the data correctly. It begins in an initial state, where it waits until a counter has gone past a value corresponding to 40ms. This is due to a 40ms startup time described by the LCD controller. Then, this controller FSM sends two setup signals to the LCD to turn on the correct register values for a 16x2 LCD that increments the cursor each time a character is written. Then the controller FSM goes into a wait state until it receives data from the MCU over SPI. When the transaction is done, the controller sends a control signal to the LCD that puts the cursor in the correct position for either the title or the note. Finally, the control FSM sends all the title or note characters to the LCD. Once all the characters are sent, the control FSM goes back to the wait state to await the next chunk of data from the MCU. This entire operation relies on several counter variables that count the number of characters sent or the time passed. These are all detailed in Appendix A and D. Each time a character is sent to the LCD, the character sender FSM is activated and the controller FSM remains in the same state until the transaction is complete. This is true for both control character signals and data characters being displayed on the screen. 

Since the SPI connection between the MCU and the FPGA has not been fully tested, a fake SPI module was created. This module mimics what will actually be sent over via SPI and sends the corresponding signals to the FPGA without relying on any external inputs.

# Hardware Design

The slide whistle has a 3D printed attachment from the fan to the mouthpiece of the whistle. This allows all the air coming out of the fan to be sent into the whistle and works fairly well to play notes along the entire length of the whistle slide. A new one may have to be printed that allows 2 fans to attach to the whistle for more air power if need be. 
The gearing for the motor is still yet to be printed but should be fairly simple. It will involve a rack that will be attached to the slider of the whistle. This will be attached to gears that are driven by the motor. Because the motor is a stepper motor, it can be relied upon to give a specific distance of movement per step. When all the gears and other attachments are printed, the positions of the slide will be mapped to the notes being played. This, combined with the current position of the stepper motor, can be combined in the MCU to get the number of steps and the direction of the motor necessary to move the slide whistle to the correct next note, as described above. 
