module SPI_SLAVE #(
    parameter MEM_DEPTH = 256 , ADDR_SIZE = 8
) (
    input CLK , RST ,
    input MOSI  , SS_n ,
    input [ADDR_SIZE + 1 : 0] tx_data ,
    input tx_valid ,
    output reg [ADDR_SIZE + 1 : 0] rx_data ,
    output reg rx_valid , 
    output reg MISO
);


    reg internal_signal ;
    reg [2:0] current_state , next_state ;
    reg [ADDR_SIZE + 1 : 0] current_data , next_data;
    reg [3:0] counter , counter_next ;
    reg [2:0] counter_8 , counter_next_8 ;

    reg Flag ,Flag8 ;


    localparam  IDLE      = 0 ,
                CHK_CMD   = 1 ,
                WRITE     = 2 ,
                READ_ADD  = 3 ,
                READ_DATA = 4 ;
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            current_state   <= IDLE ;
        //    internal_signal <= 0 ;
            current_data    <= 0;
            counter <= 0;
            counter_8 <= 0;
        end

        else begin
            current_state   <= next_state ;
            current_data    <= next_data;
            counter <= counter_next ;
            counter_8<= counter_next_8;
        end
    end


    always @(*) begin
        next_data = current_data;
        next_state = current_state ;
        case(current_state) 

        IDLE : begin
            if(SS_n) 
            next_state = IDLE ;
            else
                next_state = CHK_CMD ;
        end

        CHK_CMD : begin
            if(SS_n) 
            next_state = IDLE ;
            else if(~SS_n && ~MOSI)
                next_state = WRITE ;
            else if (~SS_n && MOSI && ~internal_signal )
                next_state = READ_ADD ;
            else if (~SS_n && MOSI && internal_signal ) 
                next_state = READ_DATA ;
            else
            next_state = IDLE ;
        end
        WRITE : begin
            if(~SS_n) begin
                if(~Flag) begin
                    next_data = {current_data[ADDR_SIZE + 1 : 1],MOSI} ;
                    next_state = WRITE ;
                end
                else begin
                   next_state = IDLE ;
                end
            end
            else begin
                next_state = IDLE ;
            end
        end
        READ_ADD : begin
            if(~SS_n) begin
                if(~Flag) begin
                    next_data = {current_data[ADDR_SIZE + 1 : 1],MOSI} ;
                    next_state = READ_ADD ;
                end
                else begin
                   next_state = IDLE ;
                end
            end
            else begin
                next_state = IDLE ;
            end
        end

        READ_DATA : begin
            if(~SS_n) begin
                if(~Flag) begin
                    next_data = {current_data[ADDR_SIZE + 1 : 1],MOSI} ;
                    next_state = READ_ADD ;
                end
                else if(Flag && ~Flag8 ) begin
                   next_state = READ_ADD ;
                end
                else begin
                    next_state = IDLE ;
                end
            end
            else begin
                next_state = IDLE ;
            end
        end
        endcase
    end

    always @(*) begin
        case (current_state)
        IDLE , CHK_CMD : begin
            counter_next = 0 ;
            Flag = 0 ;
            counter_next_8 = 0 ;
            Flag8 = 0 ;
        end
        WRITE , READ_ADD : begin
            if(counter == 10 )begin
                counter_next = 0 ;
                Flag = 1;
            end
            else begin
                counter_next = counter + 1 ;
                Flag = 0 ;
            end
        end
        READ_DATA : begin
            if(counter == 10 )begin
                counter_next = 0 ;
                Flag = 1;
            end
            else begin
                counter_next = counter + 1 ;
                Flag = 0 ;
            end
            if(tx_valid && Flag ) begin
                counter_next_8 = counter_8 + 1 ;
                Flag8 = 0 ;
            end
            else if(counter_8 == 7) begin
                counter_next_8 = 0 ;
                Flag8 = 1 ;
            end
            else begin
                counter_next_8 = 0 ;
                Flag8 = 0 ;
            end
        end
        endcase
    end

    always @(posedge CLK) begin
        if(~RST) begin
            internal_signal <= 0;
        end
        else if (current_state == READ_ADD ) begin
            internal_signal <= 1;
        end
        else if(current_state == READ_DATA ) begin
            internal_signal <= 0;
        end

    end

    always @(posedge CLK) begin
        if(~RST) begin
            rx_data <= 0 ;
            MISO <=0 ;
            rx_valid <=0;
        end
        else begin
          if((current_state == WRITE)|| (current_state == READ_ADD) || (current_state == READ_DATA) && Flag) begin
            rx_data <= current_data ;
            rx_valid <= 1;
          end
          else if ((current_state == READ_DATA) && ~Flag8 && Flag) begin
                MISO <= current_data[counter_8];
          end
        end
    end
    
endmodule