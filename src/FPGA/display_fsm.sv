// Kip Macsai-Goren and Decaln O'Neill
// kmacsaigoren@hmc.edu	 and doneill@hmc.edu
// 6 November 2022
// FSM for sending the control signals of the display at the correct time.

module sendChar_FSM (input  logic   clk, nReset, RSin, RWin, dataReady,
                     input  logic   [7:0] charIn,
                     output logic   RSout, RWout, enable, sendCharDone,
                     output logic   [7:0] charOut);

    typedef enum logic [3:0] {wait4data, sendData0, sendData1, sendData2} statetype;

    statetype currState, nextState;

    // next state register
    always_ff @(posedge clk) begin
        if (~nReset) currState <= wait4data;
        else currState <= nextState;
    end

    // next state logic
    always_comb begin
        case (currState)
            wait4data:  nextState <= dataReady ? sendData0 : wait4data;
            sendData0:  nextState <= sendData1;
            sendData1:  nextState <= sendData2;
            sendData2:  nextState <= wait4data;
            default: nextState <= wait4data;
        endcase
    end

    // output logic
    always_comb begin
        case (currState)
            wait4data: begin
                enable <= 0;
                charOut <= 8'd0;
                RWout <= 0;
                RSout <= 0;
                sendCharDone <= 0; 
            end
            sendData0: begin
                enable <= 0;
                charOut <= charIn;
                RWout <= RWin;
                RSout <= RSin;
                sendCharDone <= 0;
            end
            sendData1: begin
                enable <= 1;
                charOut <= charIn;
                RWout <= RWin;
                RSout <= RSin;
                sendCharDone <= 0;
            end
            sendData2: begin
                enable <= 0;
                charOut <= charIn;
                RWout <= RWin;
                RSout <= RSin;
                sendCharDone <= 1;
            end
            default: begin
                enable <= 0;
                charOut <= 8'd0;
                RWout <= 0;
                RSout <= 0;
                sendCharDone <= 0;
            end
        endcase
    end

endmodule

