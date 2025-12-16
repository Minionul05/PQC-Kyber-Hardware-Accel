// rtl/ntt/ntt_core.v
`include "defines.vh"

module ntt_core (
    input  wire clk,
    input  wire rst,
    input  wire start,             // Semnal de start
    output reg  done,              // Semnal cand terminam
    // Porturi de debug (ca sa putem scrie date initiale din testbench)
    input  wire ext_we,
    input  wire [7:0] ext_addr,
    input  wire [`DWIDTH-1:0] ext_data,
    output wire [`DWIDTH-1:0] debug_out
);

    // --- Semnale Interne ---
    reg [7:0] read_addr_a, read_addr_b; // Adresele de citire
    reg [7:0] write_addr_a, write_addr_b; // Adresele de scriere
    reg we_ram; // Write Enable pentru RAM intern

    wire [`DWIDTH-1:0] ram_out_a, ram_out_b; // Ce citim din RAM
    wire [`DWIDTH-1:0] butt_out_a, butt_out_b; // Ce iese din Butterfly
    
    // Zeta (Twiddle Factor) - Hardcodam o valoare pt test
    reg [`DWIDTH-1:0] current_zeta; 

    // --- 1. Instantierea MEMORIEI (BRAM) ---
    // Folosim un multiplexor: Daca ext_we e activ (scriem din testbench), folosim adresele externe.
    // Daca nu, folosim adresele interne generate de FSM.
    dual_port_ram #(.ADDR_WIDTH(8)) memory_unit (
        .clk(clk),
        .we(ext_we || we_ram), // Scriem daca vrea testbench-ul SAU vrea algoritmul
        .addr_a(ext_we ? ext_addr : (we_ram ? write_addr_a : read_addr_a)),
        .addr_b(read_addr_b), // Portul B e doar de citire in acest design simplu
        .din_a(ext_we ? ext_data : butt_out_a), // Scriem data externa SAU rezultatul A
        // Nota: Scrierea portului B simultan ar necesita un RAM true-dual-port de scriere. 
        // Aici simplificam scriind pe rand sau modificand arhitectura.
        // Pentru demo, vom scrie doar rezultatul A.
        .dout_a(ram_out_a),
        .dout_b(ram_out_b)
    );
    
    assign debug_out = ram_out_a;

    // --- 2. Instantierea UNITATII BUTTERFLY ---
    butterfly compute_unit (
        .a(ram_out_a),
        .b(ram_out_b),
        .zeta(current_zeta),
        .out_a(butt_out_a),
        .out_b(butt_out_b)
    );

    // --- 3. STATE MACHINE (Control Unit) ---
    // Simplu: Asteapta START -> Citeste adresa 0 si 1 -> Calculeaza -> Scrie inapoi -> GATA
    
    localparam STATE_IDLE  = 0;
    localparam STATE_READ  = 1;
    localparam STATE_CALC  = 2; // O asteptare mica pt propagare
    localparam STATE_WRITE = 3;
    localparam STATE_DONE  = 4;

    reg [2:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            done <= 0;
            we_ram <= 0;
            read_addr_a <= 0; read_addr_b <= 0;
            current_zeta <= 12'd10; // Valoare dummy
        end else begin
            case (state)
                STATE_IDLE: begin
                    done <= 0;
                    we_ram <= 0;
                    if (start) state <= STATE_READ;
                end

                STATE_READ: begin
                    // Setam adresele pentru a citi primii doi coeficienti
                    read_addr_a <= 8'd0;
                    read_addr_b <= 8'd1;
                    state <= STATE_CALC;
                end

                STATE_CALC: begin
                    // Datele ies din RAM, trec prin Butterfly (combinational)
                    // Rezultatul este deja la butt_out_a/b.
                    // Pregatim scrierea.
                    state <= STATE_WRITE;
                end

                STATE_WRITE: begin
                    // Scriem rezultatul A inapoi la adresa 0
                    write_addr_a <= 8'd0;
                    we_ram <= 1; 
                    // (Intr-o implementare completa am scrie si B la adresa 1 in ciclul urmator)
                    state <= STATE_DONE;
                end

                STATE_DONE: begin
                    we_ram <= 0;
                    done <= 1;
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule