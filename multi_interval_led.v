module multi_interval_led(
    input clk,
    input reset,
    input [1:0] sel,
    output reg led
);

reg [31:0] counter;
reg [31:0] max_count;

always @(*)
begin
    case(sel)
        2'b00: max_count = 50000000;
        2'b01: max_count = 100000000;
        2'b10: max_count = 200000000;
        default: max_count = 50000000;
    endcase
end

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        counter <= 0;
        led <= 0;
    end
    else
    begin
        if(counter >= max_count)
        begin
            counter <= 0;
            led <= ~led;
        end
        else
        begin
            counter <= counter + 1;
        end
    end
end

endmodule