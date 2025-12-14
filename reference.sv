class reference;
  function new();
    $display("[REF] Reference model created");
  endfunction
  
  function transaction process(const ref transaction in_tr);
    transaction ref_tr = new();
    logic [4:0] tmp;
    
    ref_tr.a      = in_tr.a;
    ref_tr.b      = in_tr.b;
    ref_tr.select = in_tr.select;
    
    unique case (in_tr.select)
      2'b00: tmp = in_tr.a + in_tr.b;               // ADD
      2'b01: tmp = in_tr.a - in_tr.b;               // SUB
      2'b10: tmp = in_tr.a * in_tr.b;               // MUL
      2'b11: tmp = (in_tr.b != 0) ? in_tr.a / in_tr.b : 5'bx; // DIV, guard b=0
      default: tmp = 5'b0;
    endcase
    
    ref_tr.carry = tmp[4];
    ref_tr.out = tmp[3:0];
    
    ref_tr.zero     = ~|ref_tr.out;
    ref_tr.sign     = ref_tr.out[3];
    ref_tr.parity   = ~^ref_tr.out;
    ref_tr.overflow = (in_tr.a[3] & in_tr.b[3] & ~ref_tr.out[3]) |
                      (~in_tr.a[3] & ~in_tr.b[3] &  ref_tr.out[3]);
    return ref_tr;
  endfunction
      
endclass