covergroup alu_covergroup with function sample(transaction trans);
  op_cvp : coverpoint trans.select {
    bins add = {2'd0};
    bins sub = {2'd1};
    bins mul = {2'd2};
    bins div = {2'd3};
  }
  
  a_cvp : coverpoint trans.a {
    bins zero = {4'd0};
    bins little = {[4'd1 : 4'd7]};
    bins mid = {[4'd8:4'd11]};
    bins max = {4'd15};
  }
  
  b_cvp : coverpoint trans.b {
    bins zero = {4'd0};
    bins little = {[4'd1 : 4'd7]};
    bins mid = {[4'd8:4'd11]};
    bins max = {4'd15};
  }
  
  zero_flag_cvp : coverpoint trans.zero { bins zero0 = {0}; bins zero1 = {1}; }
  sign_flag_cvp : coverpoint trans.sign { bins sign0 = {0}; bins sign1 = {1}; }
  parity_flag_cvp : coverpoint trans.parity { bins parity0 = {0}; bins parity1 = {1}; }
  carry_flag_cvp : coverpoint trans.carry { bins carry0 = {0}; bins carry1 = {1}; }
  ovf_flag_cvp : coverpoint trans.overflow {bins ovf0 = {0}; bins ovf1 = {1}; }
  
  op_a_cross     : cross op_cvp, a_cvp;
  op_b_cross     : cross op_cvp, b_cvp;

  op_zero_cross   : cross op_cvp, zero_flag_cvp;
  op_sign_cross   : cross op_cvp, sign_flag_cvp;
  op_parity_cross : cross op_cvp, parity_flag_cvp;
  op_carry_cross  : cross op_cvp, carry_flag_cvp;
  op_ovf_cross    : cross op_cvp, ovf_flag_cvp;

endgroup