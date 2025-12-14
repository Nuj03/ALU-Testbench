class transaction;
  rand logic [3:0] a;
  rand logic [3:0] b;
  rand logic [1:0] select;
  
  logic [3:0] out;
  logic zero, carry, sign, parity, overflow;
  
  function new();
  endfunction
  
  constraint select_dist{
    select dist {
      2'd0 := 3,
      2'd1 := 3,
      2'd2 := 2,
      2'd3 := 2
    };
  }
  constraint div_nonzero {
    (select == 2'd3) -> (b dist {4'd0 := 1, [1:15] := 9 });
  }
  
  function void display(string tag = "");
    if (tag != "")
      $write("[%s] ", tag);

    $display("a=%0d b=%0d sel=%0d -> out=%0d z=%0b c=%0b s=%0b p=%0b ovf=%0b",
             a, b, select, out, zero, carry, sign, parity, overflow);
  endfunction
  
  function void do_copy(ref transaction dst);
    dst.a        = this.a;
    dst.b        = this.b;
    dst.select   = this.select;

    dst.out      = this.out;
    dst.zero     = this.zero;
    dst.carry    = this.carry;
    dst.sign     = this.sign;
    dst.parity   = this.parity;
    dst.overflow = this.overflow;
  endfunction
  
  function bit do_compare(const ref transaction rhs);
    return (this.a        == rhs.a)        &&
           (this.b        == rhs.b)        &&
           (this.select   == rhs.select)   &&
           (this.out      == rhs.out)      &&
           (this.zero     == rhs.zero)     &&
           (this.carry    == rhs.carry)    &&
           (this.sign     == rhs.sign)     &&
           (this.parity   == rhs.parity)   &&
           (this.overflow == rhs.overflow);
  endfunction
  
endclass