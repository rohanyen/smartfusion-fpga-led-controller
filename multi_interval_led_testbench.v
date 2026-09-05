`timescale 1ns/1ps

module blinz_tb;

// ── Inputs (driven by testbench) ──────────────────────────
reg        clk        = 0;
reg        rst        = 0;
reg        apb_rst    = 0;
reg        apb_psel   = 0;
reg        apb_penable= 0;
reg        apb_pwrite = 0;
reg [31:0] apb_paddr  = 0;
reg [31:0] apb_pwdata = 0;

// ── Outputs (observed by testbench) ───────────────────────
wire        led_out;
wire [31:0] apb_prdata;
wire        apb_pready;
wire        apb_pslverr;

// ── Instantiate DUT (Device Under Test) ───────────────────
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
    .apb_prdata (apb_prdata),
    .apb_pready (apb_pready),
    .apb_pslverr(apb_pslverr)
);

// ── Clock Generation: 1MHz → period = 1000ns ──────────────
always #500 clk = ~clk;  // toggle every 500ns = 1MHz

// ── Task: APB Write ───────────────────────────────────────
task apb_write;
    input [31:0] addr;
    input [31:0] data;
    begin
        // Setup phase
        @(posedge clk);
        apb_rst    = 1;
        apb_psel   = 1;
        apb_pwrite = 1;
        apb_paddr  = addr;
        apb_pwdata = data;

        // Access phase
        @(posedge clk);
        apb_penable = 1;

        // Done
        @(posedge clk);
        apb_psel    = 0;
        apb_penable = 0;
        apb_pwrite  = 0;
    end
endtask

// ── Stimulus ──────────────────────────────────────────────
initial begin
    // Apply reset
    rst = 1;
    #2000;          // hold reset for 2 clock cycles
    rst = 0;
    #2000;

    // Test 1: Write choice = 0 → 1 sec blink
    $display("TEST 1: choice = 0 → 1 sec blink");
    apb_write(32'h40050000, 32'd0);
    #5000000;       // wait 5ms to observe

    // Test 2: Write choice = 1 → 2 sec blink
    $display("TEST 2: choice = 1 → 2 sec blink");
    apb_write(32'h40050000, 32'd1);
    #5000000;

    // Test 3: Write choice = 2 → 4 sec blink
    $display("TEST 3: choice = 2 → 4 sec blink");
    apb_write(32'h40050000, 32'd2);
    #5000000;

    // Test 4: Wrong address → choice should not change
    $display("TEST 4: wrong address → no change");
    apb_write(32'hDEADBEEF, 32'd1);
    #2000;

    $display("All tests done");
    $finish;
end

// ── Monitor: print whenever led_out changes ───────────────
initial begin
    $monitor("Time=%0t | led_out=%b", $time, led_out);
end

endmodule
