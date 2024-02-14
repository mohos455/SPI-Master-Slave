module SPI_Wrapper #(parameter MEM_DEPTH = 256, ADDR_SIZE = 8) (
    input clk, rst_n, SS_n, MOSI,
    output MISO
);
    // internal signals
    wire rx_valid_int, tx_valid_int, MISO_int;
    wire [ADDR_SIZE - 1 : 0] tx_data_int;
    wire [ADDR_SIZE + 1 : 0] rx_data_int;

    // instantiation of the SPI Slave
    SPI_SLAVE #(.ADDR_SIZE(ADDR_SIZE)) SLAVE (.CLK(clk), .RST(rst_n), .SS_n(SS_n), .MOSI(MOSI),
    .tx_valid(tx_valid_int), .tx_data(tx_data_int), .MISO(MISO_int), .rx_valid(rx_valid_int), .rx_data(rx_data_int));

    // instantiation of the memory
    RAM #(.MEM_DEPTH(MEM_DEPTH), .ADDR_SIZE(ADDR_SIZE)) MEMORY (.CLK(clk), .RST(rst_n),
    .rx_valid(rx_valid_int), .din(rx_data_int), .tx_valid(tx_valid_int), .dout(tx_data_int));
    
    // output
    assign MISO = MISO_int;
endmodule
