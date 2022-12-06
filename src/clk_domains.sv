// Kip Macsai-Goren and Decaln O'Neill
// kmacsaigoren@hmc.edu	 and doneill@hmc.edu
// 6 November 2022
// FSM and clock divider to manage the clock domains in this project


module synchronize_FSM #(parameter CLK_DIV = 200) (
    input logic clk, nReset, pulse,
    output logic pulseDone);
    // The spi load signal rises and falls much faster than the clock for the fsm that needs to detect it.
    // that clock however needs to be slow so the screen can have the correct timing.
    // since we know the ratio of the faster and slower clocks from CLK_DIV, this FSM can detect the fast load signal
    // using a faster clock, and then raise a signal until at least the slower clock has gone through one cycle, making sure it can detect spiload. 

    typedef enum logic [1:0] { waitState, pulseStart, pulseEnd } statetype;

    statetype currState, nextState;
    logic [$clog2(CLK_DIV):0] count, nextCount;

    // state register
    always_ff @( posedge clk ) begin
        if (~nReset) begin
            currState <= waitState;
            count <= 0;
        end else begin
            currState <= nextState;
            count <= nextCount;
        end
    end

    // nextState logic
    always_comb begin
        case (currState)
            waitState: begin
                nextState <= pulse ? pulseStart : waitState;
                nextCount <= 1'b0;
            end
            pulseStart: begin
                nextState <= ~pulse ? pulseEnd : pulseStart;
                nextCount <= 1'b0;
            end
            pulseEnd: begin
                nextState <= (count > (CLK_DIV)) ? waitState : pulseEnd; 
                nextCount <= count + 1'b1;
            end
            default: begin
                nextState <= waitState;
                nextCount <= 1'b0;
            end
        endcase
    end

    // output logic
    assign pulseDone = (currState == pulseEnd);
endmodule



module clkDiv #(parameter CLK_DIV = 200)(
	input	logic	fastClk, nReset,
	output	logic	slowClk
);

	// use a counter to know when the slow clock period has passed.
	logic [17:0] 	counter;

	always_ff @(posedge fastClk) begin
		if (~nReset) begin
			counter <= 0;
			slowClk <= 1;
		end else if (counter == CLK_DIV) begin 
			counter <= 18'd0; 
			// every 12 positive edges at 48 MHz, 250 ns passes.
            // If we toggle a clock every time that happens, we will get a clock signal with period 500 ns.
			slowClk <= ~slowClk;
        end else counter <= counter + 1'b1;
	end


endmodule