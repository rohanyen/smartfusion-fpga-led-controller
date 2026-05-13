module led_1s(
    input wire clk,
    input wire rst_n,
    output reg led_out
);

parameter clk_freq = 50000000;
parameter blink_rate_hz = 1;

reg [31:0] counter;
localparam period_cycles = clk_freq / blink_rate_hz;
localparam half_period_cycles = period_cycles / 2;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        counter <= 0;
        led_out <= 0;
    end
    else
    begin
        if(counter >= half_period_cycles - 1)
        begin
            counter <= 0;
            led_out <= ~led_out;
        end
        else
        begin
            counter <= counter + 1;
        end
    end
end

endmodule