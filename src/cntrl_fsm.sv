// Kip Macsai-Goren and Decaln O'Neill
// kmacsaigoren@hmc.edu	 and doneill@hmc.edu
// 6 November 2022
// FSM to control the data being sent to the screen. Deciding when and what to send after SPI transactions

module dataCntrl_FSM (  input   logic   nReset, clk, spiLoad, titleNote, sendCharDone, spiDone,
                        input   logic   [127:0] title, 
                        input   logic   [23:0]  note,
                        output  logic   dataReady, RSin, RWin, //spiDone, // sent to sendcharFSM
                        output  logic   [7:0]   charIn // sent to sendCharFSM
    
);

    typedef enum logic [3:0] {init, setup,setup1, wait4Data, 
                            titlePos, titleGetNext, titleSendChar, dispOn,
                            notePos, noteGetNext, noteSendChar} statetype;

    statetype currState, nextState;  
    logic [31:0] count40ms, nextCount40ms;
    logic [4:0] countTitleChar, nextCountTitleChar, countNoteChar, nextCountNoteChar;
    logic [7:0] nextCharIn;
    logic nextDataReady, nextRSin, nextRWin;

    // next state register
    always_ff @(posedge clk) begin
        if (~nReset) begin
            currState <= init;
            count40ms <= 32'd0;
            countTitleChar <= 4'd0;
            countNoteChar <= 4'd0;
        end else begin
            currState <= nextState;
            count40ms <= nextCount40ms;
            countNoteChar <= nextCountNoteChar;
            countTitleChar <= nextCountTitleChar;
        end
    end

    // next output registers
    always_ff @(posedge clk) begin // at some points, we have to send the same value we sent when we were in the 
    // previous states. to prevent a latch, we register all the outputs so we have the option of updating them or not.
        if (~nReset) begin
            charIn <= 8'b0;
            dataReady <= 0;
            RSin <= 0;
            RWin <= 0;
        end else begin
            charIn <= nextCharIn;
            dataReady <= nextDataReady;
            RSin <= nextRSin;
            RWin <= nextRWin;
        end
    end

    // nextState logic
    always_comb begin
        case (currState)
            init: nextState <= (count40ms > 32'd90000) ? setup : init; // wait until the count gets to 40 ms to setup the device. // a 2 MHz clock gives 80kcycles but I'm adding just to be sure
            setup: nextState <= sendCharDone ? setup1 : setup; // wait to send setup char
            setup1: nextState <= sendCharDone ? wait4Data : setup1; // wait to send incrimentation data
            wait4Data: casex ({spiDone, titleNote})
                2'b0x: nextState <= wait4Data; // loading from spi
                2'b11: nextState <= titlePos; // loaded a title
                2'b10: nextState <= notePos; // loaded a note
                default: nextState <= wait4Data; // shouldn't happen
            endcase
            
            titlePos: nextState <= sendCharDone ? titleGetNext : titlePos; // send cursor position to screen
            titleGetNext: nextState <= (countTitleChar == 5'd16) ? dispOn : titleSendChar; // get next character to print
            titleSendChar: nextState <= sendCharDone ? titleGetNext : titleSendChar; // send char to screen
            dispOn: nextState <= sendCharDone ? wait4Data : dispOn; // turn on the display

            notePos: nextState <= sendCharDone ? noteGetNext : notePos; // send note position to screen
            noteGetNext: nextState <= (countNoteChar == 5'd3) ? wait4Data : noteSendChar; // get next character to print
            noteSendChar: nextState <= sendCharDone ? noteGetNext : noteSendChar; // send char to screen

            default: nextState <= init;
        endcase
    end

    // count next state logic: decide when to count up  or reset the various counters that are part of the state for this FSM
    always_comb begin
        nextCount40ms <= (currState == init) ? count40ms + 1 : 0;
        
        case (currState)
            titleGetNext: nextCountTitleChar <= countTitleChar + 1'b1;
            titleSendChar: nextCountTitleChar <= countTitleChar;
            default: nextCountTitleChar <= 0;
        endcase

        case (currState)
            noteGetNext: nextCountNoteChar <= countNoteChar + 1'b1;
            noteSendChar: nextCountNoteChar <= countNoteChar;
            default: nextCountNoteChar <= 0;
        endcase
    end

    // next output logic
    always_comb begin

        case (nextState)
            setup: begin // send setup signal to the screen
                nextCharIn <= 8'b00111000; // set up for 2 lines, 8 bit data line, 5x8 font.
                nextRSin <= 0;
                nextRWin <= 0;
                nextDataReady <= 1;
            end

            setup1: begin // send setup signal to the screen
                nextCharIn <= 8'b00000110; // set up to incriment each time a character is written
                nextRSin <= 0;
                nextRWin <= 0;
                nextDataReady <= 1;
            end
            
            // send title data
            titlePos: begin // send title cursor position to the screen
                nextCharIn <= 8'b10000000; // first position of line 1
                nextRSin <= 0;
                nextRWin <= 0;
                nextDataReady <= 1;
            end
            titleGetNext: begin
                case (countTitleChar) // get the correct value of the title to send out
                    15: nextCharIn <= title[7:0];
                    14: nextCharIn <= title[15:8];
                    13: nextCharIn <= title[23:16];
                    12: nextCharIn <= title[31:24];
                    11: nextCharIn <= title[39:32];
                    10: nextCharIn <= title[47:40];
                    9: nextCharIn <= title[55:48];
                    8: nextCharIn <= title[63:56];
                    7: nextCharIn <= title[71:64];
                    6: nextCharIn <= title[79:72];
                    5: nextCharIn <= title[87:80];
                    4: nextCharIn <= title[95:88];
                    3: nextCharIn <= title[103:96];
                    2: nextCharIn <= title[111:104];
                    1: nextCharIn <= title[119:112];
                    0: nextCharIn <= title[127:120];
                    default: nextCharIn <= 8'b0;
                endcase
                nextRSin <= 1;
                nextRWin <= 0;
                nextDataReady <= 0; // get correct outputs, then send them.
            end
            titleSendChar: begin
               nextCharIn <= charIn;
               nextRSin <= RSin;
               nextRWin <= RWin;
               nextDataReady <= 1; // keep the same outputs and send the data to the screen. 
            end

            dispOn: begin // turn the display on after putting the title in
                nextCharIn <= 8'b00001111;
                nextRSin <= 0;
                nextRWin <= 0;
                nextDataReady <= 1;
            end

            // send note data
            notePos: begin // send note cursor position to the screen
                nextCharIn <= 8'b11000000; // first position of line 2
                nextRSin <= 0;
                nextRWin <= 0;
                nextDataReady <= 1;
            end
            noteGetNext: begin
                case (countNoteChar)
                    2: nextCharIn <= note[7:0]; 
                    1: nextCharIn <= note[15:8];
                    0: nextCharIn <= note[23:16];
                    default: nextCharIn <= 8'b0;
                endcase
                nextRSin <= 1;
                nextRWin <= 0;
                nextDataReady <= 0;
            end
            noteSendChar: begin
               nextCharIn <= charIn;
               nextRSin <= RSin;
               nextRWin <= RWin;
               nextDataReady <= 1; // keep the same outputs and send the data to the screen. 
            end

            default: begin
                nextCharIn <= 8'b0;
                nextRSin <= 0;
                nextRWin <= 0;
                nextDataReady <= 0;
            end
        endcase    
    end
endmodule
