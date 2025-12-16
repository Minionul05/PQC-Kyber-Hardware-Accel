`include "defines.vh"

module butterfly (
    input  wire [`DWIDTH-1:0] a,
    input  wire [`DWIDTH-1:0] b,
    input  wire [`DWIDTH-1:0] zeta, // Factorul "twiddle"
    output wire [`DWIDTH-1:0] out_a,
    output wire [`DWIDTH-1:0] out_b
);

    wire [`DWIDTH-1:0] t; 

    // 1. Calculam t = b * zeta (Montgomery)
    montgomery_mult mult_unit (
        .a(b),
        .b(zeta),
        .out(t)
    );

    // 2. Calculam out_a = a + t
    mod_add add_unit (
        .a(a),
        .b(t),
        .out(out_a)
    );

    // 3. Calculam out_b = a - t
    mod_sub sub_unit (
        .a(a),
        .b(t),
        .out(out_b)
    );

endmodule