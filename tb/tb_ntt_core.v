// tb/tb_ntt_core.v
`timescale 1ns / 1ps
`include "defines.vh"

module tb_ntt_core;

    reg clk, rst, start;
    wire done;
    
    // Semnale pentru incarcarea datelor de test
    reg ext_we;
    reg [7:0] ext_addr;
    reg [`DWIDTH-1:0] ext_data;
    wire [`DWIDTH-1:0] debug_data;

    // Instantiem Core-ul (Top Level)
    ntt_core dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .ext_we(ext_we),
        .ext_addr(ext_addr),
        .ext_data(ext_data),
        .debug_out(debug_data)
    );

    // Generator de ceas
    always #5 clk = ~clk;

    initial begin
        $dumpfile("ntt_core_test.vcd");
        $dumpvars(0, tb_ntt_core);

        // Initializare
        clk = 0; rst = 1; start = 0; ext_we = 0;
        #20;
        rst = 0;

        $display("=== 1. Incarcare Memorie (Coeficienti Initiali) ===");
        // Scriem valoarea 100 la adresa 0
        ext_we = 1; ext_addr = 0; ext_data = 12'd100; #10;
        // Scriem valoarea 50 la adresa 1
        ext_we = 1; ext_addr = 1; ext_data = 12'd50;  #10;
        ext_we = 0; // Oprim scrierea

        $display("=== 2. Pornire Procesare NTT ===");
        start = 1;
        #10;
        start = 0;

        // Asteptam sa termine (DONE signal)
        wait(done);
        $display("[INFO] Procesare terminata (Done signal primit).");

        $display("=== 3. Verificare Rezultate ===");
        // Citim memoria la adresa 0
        // Ne asteptam ca valoarea sa fie modificata de Butterfly
        // Butterfly face: A_nou = A + B*zeta. 
        // Daca memoria s-a schimbat din 100 in altceva, circuitul merge!
        #10;
        
        // Putem verifica doar vizual in simulator sau logic aici
        // Daca hardware-ul merge, la adresa 0 nu mai trebuie sa fie 100.
        
        // Citire "manuala" prin portul de debug (setam ext_we pe 0 si adresa)
        ext_addr = 0;
        #10;
        $display("Adresa 0 (Initial 100) -> Acum este: %d", debug_data);
        
        if (debug_data !== 12'd100) 
            $display("[PASS] Memoria a fost actualizata de NTT Core!");
        else 
            $display("[FAIL] Memoria a ramas neschimbata.");

        $finish;
    end

endmodule