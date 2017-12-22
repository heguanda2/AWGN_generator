`timescale 1ns / 10ps

module gng_tb1();
    wire [63:0] data_in;
    reg clk;
    wire [15:0] awgn;
    reg  [63:0] rom [0:9999]; // load from matlab .rtl
    //reg [12:0] pointer;
    
    reg [15:0] rom1 [0:9999]; // send to matlab
    integer f;
    integer pointer;
    
    assign data_in = rom[pointer];
    gng_top try_this(.clk(clk),.unif_in(data_in),.awgn_out(awgn));
    
    
    initial begin
        clk = 1'b1;
        pointer = 0;
        $readmemb("unif_in.txt",rom,0,9999);
        while(1)
            #20 clk = ~clk;
    end
    
    initial begin
        f = $fopen("RTL_output.txt", "w");
        // Remember to copy the updated RTL_output.txt file to the matlab folder!!
    end
    
    always @(posedge clk) begin

        if (pointer == 10000)
            $finish();
            //pointer = 0;
        else begin
          $fwrite(f, "%b\n", awgn);
          $fflush(f);
          pointer = pointer + 1;
        end
    end
endmodule
