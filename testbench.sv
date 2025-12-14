
module alu_tb;
  bit clk_tb;
  alu_interface intf(.clk(clk_tb));
  
  alu dut (
    .a       (intf.a),
    .b       (intf.b),
    .select  (intf.select),
    .zero    (intf.zero),
    .carry   (intf.carry),
    .sign    (intf.sign),
    .parity  (intf.parity),
    .overflow(intf.overflow),
    .out     (intf.out)
  );
  
  test tst(intf);
  
  initial begin
    clk_tb = 1'b0;
    forever #5 clk_tb = ~clk_tb;
  end
  
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
