module blinz(
    input wire clk,
    input wire rst,
    output reg led_out,

    // Standard APB Slave Interface Ports
    input wire apb_rst,
    input wire apb_psel,
    input wire [31:0] apb_paddr,
    input wire apb_penable,
    input wire apb_pwrite,
    input wire [31:0] apb_pwdata,

    output reg [31:0] apb_prdata,
    output reg apb_pready,
    output reg apb_pslverr
);

parameter CLK_FREQ = 1_000_000;

reg clk_1Hz = 0;
reg [31:0] counter_main = 0;
reg [2:0] choice = 0; // Expanded to 3 bits to cleanly hold '4' (3'b100)

// ===================================================================
// 1. CLOCK DOWNSCALING: Generates a 1Hz Heartbeat Reference
// ===================================================================
always @(posedge clk)
begin
    if(rst) begin
        clk_1Hz <= 0;
        counter_main <= 0;
    end
    else if(counter_main == CLK_FREQ/2 - 1) begin
        clk_1Hz <= ~clk_1Hz;
        counter_main <= 0;
    end
    else begin
        counter_main <= counter_main + 1;
    end
end

// ===================================================================
// 2. FREQUENCY RIPPLE CHAIN: Generates 3 Different Blink Rates
// ===================================================================
reg clk_1 = 0;
reg clk_2 = 0;
reg clk_4 = 0;

always @(posedge clk_1Hz) clk_1 <= ~clk_1;
always @(posedge clk_1)   clk_2 <= ~clk_2;
always @(posedge clk_2)   clk_4 <= ~clk_4;

// ===================================================================
// 3. APB BUS REGISTER INTERFACE: Decodes Bus Writing on Fast 'clk'
// ===================================================================
always @(posedge clk)
begin
    // Continuous protocol drive requirements to prevent CPU deadlock
    apb_pready  <= 1'b1;  // Signal to CPU that peripheral is always ready
    apb_pslverr <= 1'b0;  // Signal no bus communication errors
    apb_prdata  <= 32'h0; // Return zero during an accidental register read

    // Latch data only during a valid APB write window to our specific address
    if (apb_psel && apb_penable && apb_pwrite && (apb_paddr == 32'h40050000)) begin
        choice <= apb_pwdata[2:0]; // Captures up to 3'b100 safely
    end
end

// ===================================================================
// 4. HARDWARE MULTIPLEXER: Immediate Combinatorial Routing to Pin
// ===================================================================
always @(*)
begin
    case(choice)
        3'b001:  led_out = clk_1; // Mode 1 Selected
        3'b010:  led_out = clk_2; // Mode 2 Selected
        3'b100:  led_out = clk_4; // Mode 4 Selected
        default: led_out = clk_1; // Safe system fallback setting
    endcase
end

endmodule
