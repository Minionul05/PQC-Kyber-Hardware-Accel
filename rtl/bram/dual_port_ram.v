// rtl/bram/dual_port_ram.v
`include "defines.vh"

module dual_port_ram #(
    parameter ADDR_WIDTH = 8 // 2^8 = 256 locatii (cat e n la Kyber)
)(
    input wire clk,
    input wire we,                      // Write Enable (semnal de scriere)
    input wire [ADDR_WIDTH-1:0] addr_a, // Adresa A
    input wire [ADDR_WIDTH-1:0] addr_b, // Adresa B
    input wire [`DWIDTH-1:0] din_a,     // Date de intrare (pentru scriere la adresa A)
    output reg [`DWIDTH-1:0] dout_a,    // Date de iesire A
    output reg [`DWIDTH-1:0] dout_b     // Date de iesire B
);

    // Definim memoria propriu-zisa (un vector de registre)
    reg [`DWIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // Portul A (Citire si Scriere)
    always @(posedge clk) begin
        if (we) begin
            ram[addr_a] <= din_a;
            dout_a <= din_a; // Optional: la scriere scoatem data pe iesire
        end else begin
            dout_a <= ram[addr_a];
        end
    end

    // Portul B (Doar Citire - pentru al doilea operand al Butterfly-ului)
    always @(posedge clk) begin
        dout_b <= ram[addr_b];
    end

endmodule