# CRYSTALS-Kyber Hardware Accelerator (NTT Core)

Acest repository conține implementarea hardware (în limbajul Verilog) a nucleului de procesare **NTT (Number Theoretic Transform)**. Aceasta este componenta computațională critică a algoritmului criptografic Post-Quantum **CRYSTALS-Kyber**, standardizat de NIST.

Proiectul este modular, axat pe optimizarea operațiilor aritmetice modulare și verificarea funcțională prin simulare.

---

## 📂 Structura Proiectului

Codul este organizat ierarhic pentru a separa logica de procesare (RTL) de modulele de verificare (Testbenches), conform bunelor practici de design hardware.

```text
PQC-Kyber-Hardware-Accel/
├── rtl/                        # (Register Transfer Level) - Codul sursă hardware
│   ├── defines.vh              # Parametrii globali (Modulul q=3329, lățime date)
│   ├── arithmetic/             # Unitățile aritmetice de bază
│   │   ├── mod_add.v           # Adunare modulară
│   │   ├── mod_sub.v           # Scădere modulară
│   │   └── montgomery_mult.v   # Înmulțire optimizată (Montgomery Reduction)
│   ├── ntt/                    # Logica specifică NTT
│   │   ├── butterfly.v         # Unitatea de calcul "Butterfly" (Cooley-Tukey)
│   │   └── ntt_core.v          # Modulul principal (FSM + Datapath)
│   └── bram/                   # Memoria
│       └── dual_port_ram.v     # Memorie RAM cu acces simultan
├── tb/                         # (Testbenches) - Fișiere de verificare
│   ├── tb_mod_arith.v          # Test pentru unitățile aritmetice
│   ├── tb_butterfly.v          # Test pentru unitatea Butterfly
│   └── tb_ntt_core.v           # Test de sistem (Top-Level)
└── README.md                   # Documentația proiectului

🛠️ Detalii Tehnice și Arhitectură
1. Aritmetică Modulară (rtl/arithmetic)
Algoritmul Kyber lucrează în inelul de polinoame modulo q = 3329. Deoarece operația modulo este costisitoare în hardware (împărțire), am implementat unități optimizate:

Adunare/Scădere: Verifică depășirea pragului q și corectează rezultatul într-un singur ciclu de ceas.

Înmulțire Montgomery: Permite realizarea înmulțirii modulare (A * B) mod q folosind doar adunări și shiftări de biți, evitând împărțirea clasică.

2. Unitatea Butterfly (rtl/ntt/butterfly.v)
Aceasta este "inima" acceleratorului. Implementează operația de bază din algoritmul Cooley-Tukey FFT/NTT:
-Primește doi coeficienți ($a, b$) și o constantă twiddle ($\zeta$)
-Calculează simultan a + b*zeta și a - b*zeta.

3. Memoria și Controlul (rtl/ntt/ntt_core.v)
Dual-Port RAM: Permite citirea a doi coeficienți simultan pentru a alimenta unitatea Butterfly la viteză maximă.
Finite State Machine (FSM): Un automat de stări care coordonează citirea datelor, execuția calculelor și scrierea rezultatelor înapoi în memorie.

Instrucțiuni de Rulare (Quick Start)
Pentru a verifica funcționalitatea, proiectul folosește simulatorul open-source Icarus Verilog.

Cum se rulează testul complet (System Test)
Acest test verifică tot lanțul: scrierea în memorie, procesarea prin NTT Core și validarea rezultatului final.
Compilare cu : iverilog -I rtl -o test_system tb/tb_ntt_core.v rtl/ntt/ntt_core.v rtl/ntt/butterfly.v rtl/bram/dual_port_ram.v rtl/arithmetic/mod_add.v rtl/arithmetic/mod_sub.v rtl/arithmetic/montgomery_mult.v
Rulare cu : vvp test_system

Dacă sistemul funcționează corect, veți vedea în consolă:
=== 1. Incarcare Memorie (Coeficienti Initiali) ===
=== 2. Pornire Procesare NTT ===
[INFO] Procesare terminata (Done signal primit).
=== 3. Verificare Rezultate ===
Adresa 0 (Initial 100) -> Acum este: [Valoare Nouă]
[PASS] Memoria a fost actualizata de NTT Core!