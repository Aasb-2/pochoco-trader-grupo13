// Testbench del shifter de SLL (variante B flaca). Autoverificable.
//
// Correr:  iverilog -g2012 -s tb_espino_shifter -o /tmp/tb_sh \
//            rtl/ext/espino_shifter.v sim/tb_espino_shifter.v && vvp -n /tmp/tb_sh

`timescale 1ns/1ps

module tb_espino_shifter;

  reg  [31:0] operand;
  reg  [4:0]  shamt;
  reg         dir, arith;
  wire [31:0] result;

  integer errors = 0;

  espino_shifter dut (
    .operand_i (operand),
    .shamt_i   (shamt),
    .dir_i     (dir),
    .arith_i   (arith),
    .result_o  (result)
  );

  task check(
    input [31:0] op,
    input [4:0]  sh,
    input [31:0] expected
  );
    begin
      operand = op; shamt = sh; dir = 0; arith = 0;
      #10;
      if (result !== expected) begin
        errors = errors + 1;
        $display("FAIL: op=%h sh=%0d -> %h, esperado %h",
                 op, sh, result, expected);
      end
    end
  endtask

  initial begin
    // 5<<3 = 40 (el 8p de la senal)
    check(32'd5,      5'd3,  32'd40);
    // 1<<31 = bit mas alto
    check(32'd1,      5'd31, 32'h8000_0000);
    // x<<0 = x (sin desplazar)
    check(32'hDEAD_BEEF, 5'd0, 32'hDEAD_BEEF);
    // 200<<2 = 800 (multiplo de p para div6)
    check(32'd200,     5'd2,  32'd800);
    // 150<<5 = 4800 (multiplo de 32p, el mayor de div6)
    check(32'd150,     5'd5,  32'd4800);
    // 255<<5 = 8160 (peor caso del mayor multiplo)
    check(32'd255,     5'd5,  32'd8160);
    // 100<<4 = 1600
    check(32'd100,     5'd4,  32'd1600);
    // 0<<17 = 0
    check(32'd0,       5'd17, 32'd0);

    if (errors == 0) $display("ALL TESTS PASSED");
    else             $display("FAILED: %0d errores", errors);
    $finish;
  end

endmodule
