`include "defines.vh"

module mod_add (
    input  wire [`DWIDTH-1:0] a,
    input  wire [`DWIDTH-1:0] b,
    output wire [`DWIDTH-1:0] out
);

    wire [`DWIDTH:0] sum_raw;    // Suma initiala (poate depasi 12 biti)
    wire [`DWIDTH:0] sum_sub_q;  // Suma din care scadem q (3329)

    // 1. Calculam a + b
    assign sum_raw = a + b;

    // 2. Calculam (a + b) - 3329
    assign sum_sub_q = sum_raw - `KYBER_Q;

    // 3. Alegem rezultatul:
    // Daca suma >= 3329, trebuie sa scadem 3329 (rezultatul e sum_sub_q).
    // Altfel, pastram suma simpla.
    assign out = (sum_raw >= `KYBER_Q) ? sum_sub_q[`DWIDTH-1:0] : sum_raw[`DWIDTH-1:0];

endmodule