// Testbench del periferico de media movil (variante A). Autoverificable.
//
// IMPORTANTE: los precios son bytes de 1 a 255 (enunciado, seccion 2.2).
//
// Correr:  iverilog -g2012 -s tb_pochoco_movavg_periph -o /tmp/tb_mv \
//            rtl/ext/pochoco_movavg_periph.v sim/tb_pochoco_movavg_periph.v \
//            && vvp -n /tmp/tb_mv

`timescale 1ns/1ps

module tb_pochoco_movavg_periph;

  reg         clk = 0, rst_n = 0;
  reg         sel = 1, req = 0, we = 0;
  reg  [7:0]  addr = 0;
  reg  [31:0] wdata = 0;
  wire [31:0] rdata;

  integer errors = 0;

  // Reloj: 10 ns por periodo (como el SoC)
  always #5 clk = ~clk;

  pochoco_movavg_periph #(.WINDOW_LOG2(3)) dut (
    .clk_i(clk), .rst_ni(rst_n), .sel_i(sel), .req_i(req),
    .we_i(we), .addr_i(addr), .wdata_i(wdata), .rdata_o(rdata)
  );

  task wr(input [7:0] a, input [31:0] d);
    begin
      @(negedge clk); req = 1; we = 1; addr = a; wdata = d;
      @(negedge clk); req = 0; we = 0;
    end
  endtask

  task rd(input [7:0] a);
    begin
      @(negedge clk); req = 1; we = 0; addr = a;
      @(negedge clk); req = 0;
      #1; // rdata_o ya esta estable
    end
  endtask

  task check_rd(input [7:0] a, input [31:0] expected, input [127:0] name);
    begin
      rd(a);
      if (rdata !== expected) begin
        errors = errors + 1;
        $display("FAIL %0s: leido %0d, esperado %0d", name, rdata, expected);
      end
    end
  endtask

  // Serie concreta con precios LEGALES (1..255):
  //   100,110,120,130,140,150,160,170 -> suma = 1080
  reg [7:0] serie [0:7];
  integer i;
  reg [31:0] acum;

  initial begin
    serie[0]=100; serie[1]=110; serie[2]=120; serie[3]=130;
    serie[4]=140; serie[5]=150; serie[6]=160; serie[7]=170;

    // Reset
    rst_n = 0; @(negedge clk); @(negedge clk); rst_n = 1;

    // Llenar la ventana: tras escribir k precios, count = k y sum = suma
    acum = 0;
    for (i = 0; i < 8; i = i + 1) begin
      wr(8'h00, serie[i]);
      acum = acum + serie[i];
      check_rd(8'h04, acum,      "suma durante llenado");
      check_rd(8'h08, i + 1,     "count durante llenado");
    end

    // Ventana llena: sum = 1080, count = 8
    check_rd(8'h04, 32'd1080, "suma ventana llena");
    check_rd(8'h08, 32'd8,    "count ventana llena");

    // Tick nuevo: 200. Sale el 100 (el mas antiguo), entra el 200:
    // suma = 1080 - 100 + 200 = 1180. Igual que upd_ventana en trade.s
    wr(8'h00, 32'd200);
    check_rd(8'h04, 32'd1180, "suma tras tick 9");
    check_rd(8'h08, 32'd8,   "count tras tick 9");

    // Precio 255 (maximo legal): suma = 1180 - 110 + 255 = 1325
    wr(8'h00, 32'd255);
    check_rd(8'h04, 32'd1325, "suma tras tick 10");

    // Reset por software (CTRL bit0): suma y count vuelven a 0
    wr(8'h0C, 32'd1);
    check_rd(8'h04, 32'd0, "suma tras reset");
    check_rd(8'h08, 32'd0, "count tras reset");

    // Despues del reset la ventana vuelve a llenarse desde 0
    wr(8'h00, 32'd10);
    wr(8'h00, 32'd20);
    check_rd(8'h04, 32'd30, "suma tras reset + 2 precios");
    check_rd(8'h08, 32'd2,  "count tras reset + 2 precios");

    if (errors == 0) $display("ALL TESTS PASSED");
    else             $display("FAILED: %0d errores", errors);
    $finish;
  end

endmodule
