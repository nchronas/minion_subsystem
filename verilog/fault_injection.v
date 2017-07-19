module pseudo_random_gen
(
  // Clock and Reset
  input  logic        clk,
  input  logic        rst,

  output wire        fault,
  output wire [7:0]  index
);

  reg [8:0] data_next;
  always_comb begin
    data_next = {fault, index};
    repeat(9) begin
      data_next = {(data_next[8]^data_next[4]), data_next[8:1]};
    end
  end

  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      index <= 9'h1ff;
      fault <= 0;
      $display("Fault injected rseted\n");
    end else begin
      index <= data_next[7:0];
      fault <= data_next[8];
      if(fault == 1)
        $display("Fault injected\n");
    end
  end

endmodule
