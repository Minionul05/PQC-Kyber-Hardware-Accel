`timescale 1ns / 1ps
`include "defines.vh"

module tb_mod_arith;

    // Semnale pentru inputs (reg pentru ca le setam noi in test)
    reg [`DWIDTH-1:0] tb_a;
    reg [`DWIDTH-1:0] tb_b;

    // Semnale pentru outputs (wire pentru ca vin din module)
    wire [`DWIDTH-1:0] res_add;
    wire [`DWIDTH-1:0] res_sub;
    wire [`DWIDTH-1:0] res_mult;

    // Instantiem modulele create de noi (DUT - Device Under Test)
    mod_add dut_add ( .a(tb_a), .b(tb_b), .out(res_add) );
    mod_sub dut_sub ( .a(tb_a), .b(tb_b), .out(res_sub) );
    montgomery_mult dut_mult ( .a(tb_a), .b(tb_b), .out(res_mult) );

    initial begin
        // Pentru vizualizare in simulator (daca folosesti unul care suporta VCD)
        $dumpfile("arith_test.vcd");
        $dumpvars(0, tb_mod_arith);

        $display("=== Start Test Aritmetica Modulara (Kyber q=3329) ===");

        // TEST 1: Adunare simpla
        tb_a = 12'd100; tb_b = 12'd200;
        #10; // Asteptam 10 ns
        if (res_add !== 300) $display("[FAIL] Add: 100+200=%d (Expected 300)", res_add);
        else $display("[PASS] Add: 100+200=%d", res_add);

        // TEST 2: Adunare cu overflow (modulare)
        // 3300 + 100 = 3400. 3400 mod 3329 = 71
        tb_a = 12'd3300; tb_b = 12'd100;
        #10;
        if (res_add !== 71) $display("[FAIL] Add: 3300+100=%d (Expected 71)", res_add);
        else $display("[PASS] Add: 3300+100=%d", res_add);

        // TEST 3: Scadere simpla
        tb_a = 12'd500; tb_b = 12'd200;
        #10;
        if (res_sub !== 300) $display("[FAIL] Sub: 500-200=%d (Expected 300)", res_sub);
        else $display("[PASS] Sub: 500-200=%d", res_sub);

        // TEST 4: Scadere cu underflow (modulare)
        // 100 - 200 = -100. -100 mod 3329 = 3229
        tb_a = 12'd100; tb_b = 12'd200;
        #10;
        if (res_sub !== 3229) $display("[FAIL] Sub: 100-200=%d (Expected 3229)", res_sub);
        else $display("[PASS] Sub: 100-200=%d", res_sub);

        // TEST 5: Inmultire Montgomery
        // Nota: Montgomery nu da rezultatul A*B direct, ci A*B*R^-1 mod q.
        // Pentru a verifica usor, folosim un caz simplu sau ar trebui sa convertim intrarile.
        // Dar sa vedem doar daca scoate ceva valid < q.
        tb_a = 12'd20; tb_b = 12'd30;
        #10;
        $display("[INFO] Mult Montgomery: input 20, 30 -> output %d (Check logic later)", res_mult);
        
        $display("=== Test Finalizat ===");
        $finish;
    end

endmodule