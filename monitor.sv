class monitor;
  virtual alu_interface inter;
  
  function new(virtual alu_interface inter);
    this.inter = inter;
    $display("[MON] Monitor created");
  endfunction
  
  task run(ref transaction mon2cmp[$], ref transaction mon2cvg[$]);
    transaction trans;
    forever begin
      @(posedge inter.clk);
      #1
      trans = inter.sample_transaction();
      mon2cmp.push_back(trans);
      mon2cvg.push_back(trans);
    end
  endtask

endclass