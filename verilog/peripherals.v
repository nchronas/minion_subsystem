
//////////////////////////////////////////////////////////////////
///                                                            ///
/// APB Slave 0: APB UART interface                            ///
///                                                            ///
//////////////////////////////////////////////////////////////////

module leds
  (
   // Clock and Reset
   input logic  clk,
   input logic  rst,

   //I/O wires to pins
   output wire leds[7:0],

   input wire bus_addr,

   //bus enable
   input wire bus_ce,
   input wire bus_we,

   //
   output wire bus_read,
   input wire bus_write

   );

   always @(posedge clk or negedge rst)
     if (!rst) begin
         leds <= 0;
     end else begin
         if (bus_ce) begin
              leds <= bus_read[7:0];
              $display("LEDS %x\n", leds);
         end
     end

endmodule

   //////////////////////////////////////////////////////////////////
   ///                                                            ///
   /// APB Slave 0: APB UART interface                            ///
   ///                                                            ///
   //////////////////////////////////////////////////////////////////

   module uart
     (
      // Clock and Reset
      input logic  clk,
      input logic  rst,

      //I/O wires to pins
      output wire uart_tx,
      input wire uart_rx,

      input wire bus_addr,

      //bus enable
      input wire bus_ce,
      input wire bus_we,

      //
      output wire bus_read,
      input wire bus_write

      );

   reg u_trans_en;
   reg u_recv;
   reg [15:0] u_baud;
   wire received, recv_err, is_recv, is_trans, uart_maj;
   wire uart_almostfull, uart_full, uart_rderr, uart_wrerr, uart_empty;
   wire [11:0] uart_wrcount, uart_rdcount;
   wire [8:0] uart_fifo_data_out;
   reg  [7:0] u_tx_byte;

   assign u_status = {uart_wrcount, uart_almostfull, uart_full,uart_rderr,uart_wrerr,uart_fifo_data_out[8],is_trans,is_recv,~uart_empty,uart_fifo_data_out[7:0]};

   always @(posedge clk or negedge rst)
     if (!rst) begin
         u_baud <= 16'd651;
         u_trans_en <= 1'b0;
     end else begin
         u_recv = received;
         u_trans_en <= 1'b0;
         u_rdata_en <= 1'b0;
         case(bus_addr)
           0: begin
                if (bus_ce) begin
                  u_trans_en <= 1'b1;
                  u_tx_byte <= bus_write[7:0];
                  $display("Tx byte %c\n", bus_write[7:0]);
                end
              end
           1: if (bus_ce)
                u_baud <= bus_write;
                $display("Tx baud %x\n", bus_write);
           2: if (bus_we)
                u_rdata_en <= 1'b1;
                bus_read <= u_status;
                $display("Tx status %x\n", u_status);
         endcase
     end

   rx_delay uart_rx_dly(
   .clk(clk),
   .in(uart_rx),
   .maj(uart_maj));

   uart i_uart(
       .clk(clk), // The master clock for this module
       .rst(rstn), // Synchronous reset.
       .rx(uart_maj), // Incoming serial line
       .tx(uart_tx), // Outgoing serial line
       .transmit(u_trans_en), // Signal to transmit
       .tx_byte(u_tx_byte), // Byte to transmit
       .received(received), // Indicated that a byte has been received.
       .rx_byte(u_rx_byte), // Byte received
       .is_receiving(is_recv), // Low when receive line is idle.
       .is_transmitting(is_trans), // Low when transmit line is idle.
       .recv_error(recv_err), // Indicates error in receiving packet.
       .baud(u_baud),
       .recv_ack(u_recv)
       );

    my_fifo #(.width(9)) uart_rx_fifo (
      .rd_clk(~msoc_clk),      // input wire read clk
      .wr_clk(~msoc_clk),      // input wire write clk
      .rst(~rstn),      // input wire rst
      .din({recv_err,core_u_rx_byte}),      // input wire [width-1 : 0] din
      .wr_en(received&&!u_recv),  // input wire wr_en
      .rd_en(u_rdata_en),  // input wire rd_en
      .dout(uart_fifo_data_out),    // output wire [width-1 : 0] dout
      .rdcount(uart_rdcount),         // 12-bit output: Read count
      .rderr(uart_rderr),             // 1-bit output: Read error
      .wrcount(uart_wrcount),         // 12-bit output: Write count
      .wrerr(uart_wrerr),             // 1-bit output: Write error
      .almostfull(uart_almostfull),   // output wire almost full
      .full(uart_full),    // output wire full
      .empty(uart_empty)  // output wire empty
    );

endmodule
