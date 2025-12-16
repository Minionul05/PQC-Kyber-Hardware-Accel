`include "defines.vh"

module montgomery_mult (
    input  wire [`DWIDTH-1:0] a,
    input  wire [`DWIDTH-1:0] b,
    output wire [`DWIDTH-1:0] out
);

    // Constanta QINV = -3329^(-1) mod 2^16
    // Pentru q=3329, QINV este 62209 (sau -3327 in complement fata de 2 pe 16 biti)
    localparam [15:0] QINV = 16'd62209; 

    // Produsul poate avea maxim 24 de biti (12 * 12)
    wire signed [23:0] prod;
    
    // Variabile intermediare pentru reducerea Montgomery
    wire signed [15:0] m;
    wire signed [27:0] t; // Avem nevoie de spatiu extra pentru adunare
    wire signed [11:0] res_raw;

    // 1. Calculul produsului: A * B
    // Folosim $signed pentru a trata corect numerele in aritmetica
    assign prod = $signed(a) * $signed(b);

    // 2. Calculul factorului de reducere m = (prod * QINV) mod R
    // Aici ne intereseaza doar cei mai putin semnificativi 16 biti
    assign m = prod[15:0] * $signed(QINV);

    // 3. Calculul t = (prod + m * Q) / 2^16
    // Formula Montgomery: (prod + m*Q) va fi intotdeauna divizibil cu 2^16
    // ">>> 16" este shiftare aritmetica (impartire la 65536)
    assign t = (prod + m * $signed(`KYBER_Q)) >>> 16;

    // 4. Rezultatul final (t poate fi inca >= Q, deci trebuie redus)
    // Deoarece lucram cu signed, t poate fi negativ sau pozitiv
    assign res_raw = t[11:0];
    
    // Verificam daca trebuie sa ajustam rezultatul
    // Nota: Aceasta este o implementare simplificata. In hardware real, 
    // pasul de scadere conditionala se face adesea in ciclul urmator sau pipeline.
    assign out = (t >= $signed(`KYBER_Q)) ? (res_raw - `KYBER_Q) : res_raw;

endmodule