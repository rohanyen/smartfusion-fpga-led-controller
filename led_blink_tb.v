`timescale 1ns/1ps

module led_tb;

reg clk;
reg rst_n;
wire led_out;

led_1s uut(
    .clk(clk),
    .rst_n(rst_n),
    .led_out(led_out)
);

initial
begin
    clk = 0;
    rst_n = 0;

    #100;
    rst_n = 1;

    #100000000;
    $finish;
end

always #10 clk = ~clk;

endmodule