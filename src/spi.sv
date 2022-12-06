// Kip Macsai-Goren and Decaln O'Neill
// kmacsaigoren@hmc.edu	 and doneill@hmc.edu
// 6 November 2022
// SPI Modules for the whistle display. Adapted from the files given to us by prof Brake for lab 7. 

module character_spi(input  logic sck, 
               input  logic sdi, spiLoad,
               //output logic sdo,
               input  logic titleNote,
               output logic [127:0] title,
               output logic [23:0] note);

    // A module for the FPGA to receive characters from the microcontroller when load is high.
    // depending on another pin, FPGA will fill up either the lines for title or those for note.
               
    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).

    always_ff @(posedge sck)
        if (spiLoad) begin
          if (titleNote) title = {title[126:0], sdi};
          else           note = {note[22:0], sdi};  
        end
endmodule