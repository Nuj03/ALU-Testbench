program test(alu_interface inter);
  environment env;
  initial begin
    env = new(inter);
    env.run();
  end
endprogram