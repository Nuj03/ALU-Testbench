class generator;
  rand int num_trans;
  
  constraint num_trans_interval {
    num_trans inside {[100:200]};
  }
  
  function new();
    $display("Initializing generator");
  endfunction
  
  task run(ref transaction gen2drv[$]);
    assert(this.randomize()) else $fatal(1, "[GEN] Randomization failed for num_trans");
    
    repeat (num_trans)
      begin
        transaction trans = new();
        assert(trans.randomize()) else $fatal(1, "[GEN] Randomization failed for transaction");
        gen2drv.push_back(trans);
      end
    $display("[GEN] Created %0d transactions", num_trans);
  endtask
  
endclass