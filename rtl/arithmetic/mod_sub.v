`include "defines.vh"

module mod_sub (
    input  wire [`DWIDTH-1:0] a,
    input  wire [`DWIDTH-1:0] b,
    output wire [`DWIDTH-1:0] out
);

    wire [`DWIDTH:0] diff_raw;
    wire [`DWIDTH:0] diff_add_q;

    // 1. Calculam a - b (standard)
    assign diff_raw = a - b;

    // 2. Calculam a - b + 3329 (pentru cazul in care a < b)
    assign diff_add_q = a + `KYBER_Q - b;

    // 3. Alegem rezultatul:
    // Daca a >= b, facem scaderea normala.
    // Daca a < b, folosim varianta cu +3329 ca sa nu avem numar negativ.
    assign out = (a >= b) ? diff_raw[`DWIDTH-1:0] : diff_add_q[`DWIDTH-1:0];

endmodule