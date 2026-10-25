module uart_transmiter(
  input clk,
  input reset,
  input start,
  output reg tx
);
  
  localparam IDLE  = 2'd0;
  localparam START = 2'd1;
  localparam DATA  = 2'd2;
  localparam STOP  = 2'd3;
  
  reg [1:0] state;
  reg [7:0] shift_reg;
  reg [2:0] bit_count;
  
  always @(posedge clk) begin
    
    if (reset) begin
      state     <= IDLE;
      tx        <= 1'b1;
      shift_reg <= 8'h00;
      bit_count <= 3'd0;
    end else begin
      case (state)
        
        IDLE: begin
          tx <= 1'b1;
          if(start) begin
            shift_reg <= 8'hA5;
            bit_count <= 3'd0;
            state <= START;
          end
          else begin
            state <= IDLE;
          end
        end
        
        START: begin
          tx <= 1'b0;
          state <= DATA;
        end
        
        DATA: begin
          tx <= shift_reg[0];
          shift_reg <= shift_reg >> 1;
          
          if (bit_count == 3'd7) begin
              state <=STOP;
          end
          else begin
            bit_count <= bit_count + 1'b1;
            state <= DATA;
          end
        end
        
        STOP: begin
          tx <=1'b1;
          bit_count <=3'd0;
          state <= IDLE;
        end
        
        default: begin
          state <= IDLE;
          tx <= 1'b1;
        end
        
      endcase
    end
  end  
endmodule

module uart_receiver(
    input clk,
    input reset,
    input rx,
    output reg [7:0] data_out,
    output reg done
);

    localparam IDLE = 2'd0;
    localparam DATA = 2'd1;
    localparam STOP = 2'd2;

    reg [1:0] state;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;

    always @(negedge clk) begin
        if (reset) begin
            state     <= IDLE;
            bit_count <= 3'd0;
            shift_reg <= 8'd0;
            data_out  <= 8'd0;
            done      <= 1'b0;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx == 1'b0) begin
                        bit_count <= 3'd0;
                        shift_reg <= 8'd0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    shift_reg[bit_count] <= rx;

                    if (bit_count == 3'd7) begin
                        state <= STOP;
                    end else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end

                STOP: begin
                    if (rx == 1'b1) begin
                        data_out <= shift_reg;
                        done <= 1'b1;
                    end
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
