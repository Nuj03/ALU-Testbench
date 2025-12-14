class environment;
  
  generator gen;
  driver drv;
  monitor mon;
  reference refm;
  compare cmp;
  coverage cov;
  
  virtual alu_interface my_alu_inter;
  
  transaction gen2drv[$];
  transaction mon2cmp[$];
  transaction mon2cvg[$];
  
  function new(virtual alu_interface my_alu_inter);
    $display("Initializing environment");
    this.my_alu_inter = my_alu_inter;
    gen = new();
    drv = new(my_alu_inter);
    mon = new(my_alu_inter);
    refm = new();
    cmp = new(refm);
    cov = new();
  endfunction
  
  task test();
    $display("[ENV] Starting generator, driver, monitor");
    gen.run(gen2drv);
    fork
      drv.run(gen2drv);
      mon.run(mon2cmp, mon2cvg);
    join_any
  endtask
  
  task post_test();
    $display("[ENV] Transactions in gen2drv = %0d", gen2drv.size());
    $display("[ENV] Transactions in mon2cmp = %0d", mon2cmp.size());
    $display("[ENV] mon2cvg size = %0d", mon2cvg.size());
    
    cmp.run(mon2cmp);
    cov.run(mon2cvg);
  endtask
  
  task run;
    test();
    post_test();
    #10 $finish;
  endtask
  
endclass