class driver;
  virtual alu_interface inter;
  
  function new(virtual alu_interface inter);
    this.inter = inter;
    $display("[DRV] Initializing driver");
  endfunction
  
  task run(ref transaction gen2drv[$]);
    if(gen2drv.size() == 0) begin
      $display("[DRV] No transactions to drive");
      return;
    end
    
    
    foreach(gen2drv[i]) begin
      @(posedge inter.clk);
      inter.drive_transaction(gen2drv[i]);
      #1;
      $display("[DRV] Drove: a=%0d b=%0d sel=%0d", gen2drv[i].a, gen2drv[i].b, gen2drv[i].select); 
    end
    
  endtask
  
endclass