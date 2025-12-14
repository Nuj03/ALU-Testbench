interface alu_interface (input clk);
  logic [3:0] a, b;
  logic [1:0] select;
  
  logic [3:0] out;
  logic zero, carry, sign, parity, overflow;
  
  
  task drive_transaction(transaction trans);
    a <= trans.a;
    b <= trans.b;
    select <= trans.select;
  endtask
  
  
  function transaction sample_transaction();
    automatic transaction trans = new();
    trans.a = a;
    trans.b = b;
    trans.select = select;
    
    trans.out = out;
    trans.zero = zero;
    trans.carry = carry;
    trans.sign = sign;
    trans.parity = parity;
    trans.overflow = overflow;
    
    return trans;
  endfunction
  
endinterface