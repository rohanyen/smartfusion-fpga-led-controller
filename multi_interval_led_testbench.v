`timescale 1ns/1ps

module blinz_tb;

// ── Inputs ────────────────────────────────────────────────
reg        clk         = 0;
reg        rst         = 1;
reg        apb_rst     = 0;
reg        apb_psel    = 0;
reg        apb_penable = 0;
reg        apb_pwrite  = 0;
reg [31:0] apb_paddr   = 0;
reg [31:0] apb_pwdata  = 0;

// ── Outputs ───────────────────────────────────────────────
wire led_out;

// ── DUT ───────────────────────────────────────────────────
blinz DUT (
    .clk        (clk),
    .rst        (rst),
    .led_out    (led_out),
    .apb_rst    (apb_rst),
    .apb_psel   (apb_psel),
    .apb_paddr  (apb_paddr),
    .apb_penable(apb_penable),
    .apb_pwrite (apb_pwrite),
    .apb_pwdata (apb_pwdata),
    .apb_prdata (),
    .apb_pready (),
    .apb_pslverr()
);

// ── Clock: 1MHz ───────────────────────────────────────────
always #500 clk = ~clk;

// ── Stimulus ──────────────────────────────────────────────
initial begin
    // Reset
    rst = 1; #2000;
    rst = 0; #2000;

    // Write choice = 0 → 1 sec blink
    apb_rst=1; apb_psel=1; apb_pwrite=1;
    apb_paddr=32'h40050000; apb_pwdata=32'd0;
    #500; apb_penable=1;
    #500; apb_psel=0; apb_penable=0;
    #5000000;

    // Write choice = 1 → 2 sec blink
    apb_psel=1; apb_pwdata=32'd1;
    #500; apb_penable=1;
    #500; apb_psel=0; apb_penable=0;
    #5000000;

    // Write choice = 2 → 4 sec blink
    apb_psel=1; apb_pwdata=32'd2;
    #500; apb_penable=1;
    #500; apb_psel=0; apb_penable=0;
    #5000000;

    $finish;
end

// ── Monitor: 4 signals only ───────────────────────────────
initial begin
    $monitor("t=%0t | clk=%b | rst=%b | choice=%b | led=%b",
              $time, clk, rst, apb_pwdata[1:0], led_out);
end

endmodule
