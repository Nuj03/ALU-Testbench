class compare;
  
  reference refm;
  int total_trans = 0;
  int passed_trans = 0;
  int failed_trans = 0;
  
  function new(reference refm);
    this.refm = refm;
    $display("[CMP] Comparator created");
  endfunction
  
  task run(ref transaction mon2cmp[$]);
    transaction act_tr;
    transaction exp_tr;
    
    if (mon2cmp.size() == 0) begin
      $display("[CMP] No transactions to compare");
      return;
    end
    
    foreach (mon2cmp[i]) begin
      act_tr = mon2cmp[i];
      total_trans++;
      
      exp_tr = refm.process(act_tr);
      
      if(act_tr.do_compare(exp_tr)) begin
        passed_trans++;
        $display("[CMP] PASS (%0d/%0d)", passed_trans, total_trans);
      end else begin
        failed_trans++;
        $display("[CMP] FAIL (%0d/%0d)", failed_trans, total_trans);
        $display("  ACT: out=%0d zero=%0b carry=%0b sign=%0b parity=%0b ovf=%0b",
               act_tr.out, act_tr.zero, act_tr.carry,
               act_tr.sign, act_tr.parity, act_tr.overflow);
      $display("  EXP: out=%0d zero=%0b carry=%0b sign=%0b parity=%0b ovf=%0b",
               exp_tr.out, exp_tr.zero, exp_tr.carry,
               exp_tr.sign, exp_tr.parity, exp_tr.overflow);
      end
    end
    
    $display("[CMP] SUMMARY: total=%0d, passed=%0d, failed=%0d",
             total_trans, passed_trans, failed_trans);
  endtask
endclass