module blinz(
    input  wire        clk,
    input  wire        rst,
    output reg         led_out,
    input  wire        apb_rst,
    input  wire        apb_psel,
    input  wire [31:0] apb_paddr,
    input  wire        apb_penable,
    input  wire        apb_pwrite,
    input  wire [31:0] apb_pwdata,
    output reg  [31:0] apb_prdata,
    output reg         apb_pready,
    output reg         apb_pslverr
);

// ── Clock Divider: input → 1Hz ────────────────────────────
parameter CLK_FREQ = 1_000_000;  // 1MHz
reg        clk_1Hz       = 0;
reg [31:0] counter_main  = 0;
reg [1:0]  choice        = 0;

always @(posedge clk) begin
    if(rst) begin
        clk_1Hz      <= 0;
        counter_main <= 0;
    end
    else if(counter_main == CLK_FREQ/2 - 1) begin
        clk_1Hz      <= ~clk_1Hz;
        counter_main <= 0;
    end
    else begin
        counter_main <= counter_main + 1;
    end
end

// ── Divided Clocks ────────────────────────────────────────
reg clk_1 = 0;
reg clk_2 = 0;
reg clk_4 = 0;

always @(posedge clk_1Hz) begin
    clk_1 <= ~clk_1;   // 1 sec
end

always @(posedge clk_1) begin
    clk_2 <= ~clk_2;   // 2 sec
end

always @(posedge clk_2) begin
    clk_4 <= ~clk_4;   // 4 sec
end

// ── APB Slave: ARM writes choice via APB ──────────────────
always @(posedge clk_1Hz) begin
    if(apb_rst    == 1 &&
       apb_psel   == 1 &&
       apb_penable== 1 &&
       apb_pwrite == 1) begin
        if(apb_paddr == 32'h40050000)
            choice <= apb_pwdata[1:0];
    end
    else begin
        choice <= 0;
    end

    // ── LED Output ────────────────────────────────────────
    case(choice)
        2'b00:   led_out <= clk_1;
        2'b01:   led_out <= clk_2;
        2'b10:   led_out <= clk_4;
        default: led_out <= 1;
    endcase
end

endmodule
