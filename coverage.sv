class coverage;
  
  alu_covergroup cg;
  
  function new();
    cg = new();
  endfunction
  
  task run(const ref transaction mon2cvg[$]);
    if(mon2cvg.size() == 0) begin
      $display("[COV] No transactions to sample");
      return;
    end
    
    foreach (mon2cvg[i]) begin
      cg.sample(mon2cvg[i]);
    end
    
    $display("[COV] Functional coverage = %0.2f %%", cg.get_coverage());
  endtask
    
endclass