module RAM #(parameter MEM_DEPTH = 256 , ADDR_SIZE = 8)(
    input  CLK ,RST ,
    input  [9:0] din ,
    input  rx_valid,
    output reg [7:0] dout ,
    output reg tx_valid
);

    reg [ADDR_SIZE-1:0] MY_MEM [MEM_DEPTH-1:0];
    reg [ADDR_SIZE-1:0] MEM_WRITE ;
    reg [ADDR_SIZE-1:0] MEM_READ ;

    integer I ;
    always @(posedge CLK , negedge RST) begin
        if(~RST) begin
          //  for(I = 0 ; I <MEM_DEPTH ; I = I+1)
         //       MY_MEM[I] <= 0 ;
            $readmemh("memory_initial_content.dat", MY_MEM, 0, 255);
            MEM_WRITE <= 0;
            MEM_READ  <= 0 ;
            tx_valid <= 0;
        end
        else if (rx_valid) begin
            case(din[ADDR_SIZE+1: ADDR_SIZE]) 
                2'b00 : MEM_WRITE <= din[ADDR_SIZE-1 : 0] ;
                2'b01 : MY_MEM[MEM_WRITE] <= din[ADDR_SIZE-1 : 0] ;
                2'b10 : MEM_READ <= din[ADDR_SIZE-1 : 0] ;
                2'b11 : begin 
                        dout <= MY_MEM[MEM_READ] ;
                        tx_valid <= 1 ;
                end



            endcase
        end
    end
    
endmodule