module tb;
  
  reg clk;
  reg reset;
  reg start;
  
  wire tx;
  wire [7:0] data_out;
  wire done;
  
  uart_transmiter uut_tx(
    .clk(clk),
    .reset(reset),
    .start(start),
    .tx(tx)
  );
  
  uart_receiver uut_rx(
      .clk(clk),
      .reset(reset),
      .rx(tx),
      .data_out(data_out),
      .done(done)
  );
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    reset = 1'b1;
    start = 1'b0;
    
    #12;
    reset = 1'b0;
    
    #8;
    start = 1'b1;
    
    #10;
    start = 1'b0;
    wait(done == 1'b1);
    
    $display("Received data = %h", data_out);
    $display("Done = %b", done);

    #10
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end 
  initial begin
        #300;
        $display("Timeout: receiver did not finish.");
        $finish;
    end

endmodule


