// Kip Macsai-Goren and Decaln O'Neill
// kmacsaigoren@hmc.edu	 and doneill@hmc.edu
// 6 November 2022
// Top level module for the FPGA controlling the display of the whistle.

`define divisor 200

module display_hw (input logic nReset,
                input logic sck, sdi, spiLoad, titleNote,
                output  logic   screenRS, screenRW, screenEn, spiDone,
                output  logic   [7:0] screenData 
 ); // top level module containing everyhting needed to drive the display for this project.

    logic fastClk, clk;//, spiDone;

    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(fastClk)); // 48 MHz clock signal

    clkDiv #(.CLK_DIV(`divisor)) divider(.fastClk, .nReset, .slowClk(clk)); // divide into 

    synchronize_FSM #(.CLK_DIV(`divisor*2)) spiDoneSync(.clk(fastClk), .nReset, .pulse(spiLoad), .pulseDone(spiDone));

    display disp(.nReset, .clk, .sck, .sdi, .spiLoad, .spiDone, .titleNote, .screenRS, .screenRW, .screenEn, .screenData);

endmodule

module display (// mcu communication signals
                input   logic   nReset, clk,
                input   logic   spiLoad, spiDone, titleNote, // coming in from MCU
                
                // SPI: (MCU controller, FPGA peripheral) 
                input   logic   sck, sdi,

                // output to LCD display
                output  logic   screenRS, screenRW, screenEn,
                output  logic   [7:0] screenData
                
); 

    logic [127:0] title;
    logic [23:0] note;

    logic dataReady, RSin, RWin, sendCharDone;
    logic [7:0] charIn;

    character_spi spi(.sck, .sdi, .spiLoad, .titleNote, .title, .note);

    dataCntrl_FSM controller(.nReset, .clk, .spiLoad, .spiDone, .titleNote, .sendCharDone,
                             .title, .note, .dataReady, .RSin, .RWin, .charIn);

    sendChar_FSM charSender(.nReset, .clk, .RSin, .RWin, .dataReady, .charIn, .sendCharDone,
                            .RSout(screenRS), .RWout(screenRW), .enable(screenEn), .charOut(screenData));

endmodule