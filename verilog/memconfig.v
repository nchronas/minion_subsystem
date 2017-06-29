
module uart
  (
   // Clock and Reset
   input logic  clk,
   input logic  rst,

   //from core lsu
   input wire [31:0] core_lsu_addr ,
   input wire [31:0] core_lsu_wdata ,
   input wire core_lsu_we ,
   input wire core_lsu_req ,
   input wire core_lsu_be ,
   input wire [31:0] core_lsu_rdata ,
   input wire core_lsu_gnt ,
   input wire core_lsu_rvalid ,

   //minion bus to peripherals
   input wire [31:0] bus_addr,

   //bus enable
   input wire bus_ce[15:0],
   input wire bus_we[15:0],

   input wire [31:0] bus_read[15:0],
   input wire [31:0] bus_write

   );

assign   bus_write <= core_lsu_wdata;
assign   bus_addr <= core_lsu_addr[19:0];

//handles the reads
always_comb
  begin:onehot
     integer i;
     core_lsu_rdata = 32'b0;
     for (i = 0; i < 16; i++)
       begin
         one_hot_data_addr[i] = core_lsu_addr[23:20] == i;
         core_lsu_rdata |= (one_hot_data_addr[i] ? bus_read[i] : 32'b0);
       end
  end

  // handles the writes
  always @(posedge clk or negedge rst)
    if (!rst) begin

    end else begin
      for (i = 0; i < 16; i++)
        begin
          one_hot_data_addr[i] = core_lsu_addr[23:20] == i;
          bus_ce[i] = one_hot_data_addr[i] & ce_d;
          bus_we[i] = one_hot_data_addr[i] & we_d;
        end
    end

//CE = core_lsu_req
//WE = core_lsu_req & core_lsu_we

 coremem coremem_d
 (
  .clk_i(msoc_clk),
  .rst_ni(rstn),
  .data_req_i(core_lsu_req),
  .data_gnt_o(core_lsu_gnt),
  .data_rvalid_o(core_lsu_rvalid),
  .data_we_i(core_lsu_we),
  .CE(ce_d),
  .WE(we_d)
  );

  endmodule
