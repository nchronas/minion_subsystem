module cls_cmp_unit
(
  // Clock and Reset
  input  logic        clk,
  input  logic        rst,

  output logic        fault,
  output logic        valid,

  // Instruction memory interface
  input  logic        instr_req_ms,
  input  logic [31:0] instr_addr_ms,

  // Data memory interface
  input  logic        data_req_ms,
  input  logic        data_we_ms,
  input  logic [3:0]  data_be_ms,
  input  logic [31:0] data_addr_ms,
  input  logic [31:0] data_wdata_ms,

  // CPU Control Signals
  input  logic        core_busy_ms,

  // Instruction memory interface
  input  logic        instr_req_sl1,
  input  logic [31:0] instr_addr_sl1,

  // Data memory interface
  input  logic        data_req_sl1,
  input  logic        data_we_sl1,
  input  logic [3:0]  data_be_sl1,
  input  logic [31:0] data_addr_sl1,
  input  logic [31:0] data_wdata_sl1,

  // CPU Control Signals
  input  logic        core_busy_sl1,

  // Instruction memory interface
  input  logic        instr_req_sl2,
  input  logic [31:0] instr_addr_sl2,

  // Data memory interface
  input  logic        data_req_sl2,
  input  logic        data_we_sl2,
  input  logic [3:0]  data_be_sl2,
  input  logic [31:0] data_addr_sl2,
  input  logic [31:0] data_wdata_sl2,

  // CPU Control Signals
  input  logic        core_busy_sl2
);

always @(posedge clk or negedge rst)
  if (!rst) begin
	   fault <= 0;
	end else begin
    if(instr_req_ms == 1 || instr_req_sl2 == 1 || instr_req_sl2 == 1) begin
      if(instr_req_ms == instr_req_sl1 && instr_req_ms == instr_req_sl2) begin
        if(instr_addr_ms == instr_addr_sl1 && instr_addr_ms == instr_addr_sl2) begin
          fault <= 0;
          $display("Valid instruction address\n");
        end else begin
          fault <= 1;
          $display("Error in instruction address\n");
        end
      end else begin
        fault <= 1;
        $display("Error in instruction req\n");
      end
    end else begin
      fault <= 0;
    end

    if (data_req_ms == 1 || data_req_sl2 == 1 || data_req_sl2 == 1) begin
      if(data_req_ms == 1 && data_req_sl1 == 1 && data_req_sl2 == 1) begin
        if(data_addr_ms == data_addr_sl1 && data_addr_ms == data_addr_sl2) begin
          if(data_we_ms == data_we_sl1 && data_we_ms == data_we_sl2) begin
            if(data_we_ms == 0) begin //read
              fault <= 0;
              $display("Valid data read\n");
            end else begin
              if(data_wdata_ms == data_wdata_sl1 && data_wdata_ms == data_wdata_sl2) begin
                fault <= 0;
                $display("Valid data write\n");
              end else begin
                fault <= 1;
                $display("Error in data write\n");
              end
            end
          end else begin
            fault <= 1;
            $display("Error in data we\n");
          end
        end else begin
          fault <= 1;
          $display("Error in data address\n");
        end
      end else begin
        fault <= 1;
        $display("Error in data req\n");
      end
    end else begin
      fault <= 0;
    end


  end

endmodule
