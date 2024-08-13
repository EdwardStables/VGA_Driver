/*

Drives data a VGA output.

Currently fixed resolution and data.

*/

module vga_driver (
    input logic clk,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B,
    output logic HS,
    output logic VS
);

localparam WIDTH = 1280;
localparam HEIGHT = 1024;
localparam WIDTH_COUNTER_SIZE = $clog2(WIDTH);
localparam HEIGHT_COUNTER_SIZE = $clog2(HEIGHT);


typedef enum {PIXEL, FRONT_PORCH, SYNC, BACK_PORCH} SyncState;

SyncState vstate;
SyncState next_vstate;
SyncState hstate;
SyncState next_hstate;

//Count the pixel resolution
logic [WIDTH_COUNTER_SIZE-1:0] hcount;
logic [HEIGHT_COUNTER_SIZE-1:0] vcount;

initial begin
    hstate = FRONT_PORCH;
    vstate = FRONT_PORCH;
    hcount = 'b0;
    vcount = 'b0;
end

always_comb begin
    next_hstate = hstate;
    case (hstate)
        PIXEL:
            if (hcount == 1280-1) next_hstate = FRONT_PORCH;
        FRONT_PORCH:
            if (hcount == 48-1) next_hstate = SYNC;
        SYNC:
            if (hcount == 112-1) next_hstate = BACK_PORCH;
        default: //BACK_PORCH
            if (hcount == 248-1) next_hstate = PIXEL;
    endcase
end

always @(posedge clk) begin
    if (hstate != next_hstate) begin
        hstate <= next_hstate;
        hcount <= 'b0;
    end else begin
        hcount <= hcount + 1;
    end
end

always_comb begin
    next_vstate = vstate;
    case (vstate)
        PIXEL:
            if (vcount == 1024-1) next_vstate = FRONT_PORCH;
        FRONT_PORCH:
            if (vcount == 1-1) next_vstate = SYNC;
        SYNC:
            if (vcount == 3-1) next_vstate = BACK_PORCH;
        default: //BACK_PORCH
            if (vcount == 38-1) next_vstate = PIXEL;
    endcase
end

always @(posedge clk) begin
    if (vstate != next_vstate) begin
        vstate <= next_vstate;
        vcount <= 'b0;
    end else
    if (hstate == BACK_PORCH && next_hstate == PIXEL) begin
        vcount <= vcount + 1;
    end
end

//Blank during sync
assign R = vstate != PIXEL || hstate != PIXEL ? 'b0 : 4'b1111;
assign G = vstate != PIXEL || hstate != PIXEL ? 'b0 : 4'b0000;
assign B = vstate != PIXEL || hstate != PIXEL ? 'b0 : 4'b0000;

//Active low signals
assign HS = hstate != SYNC;
assign VS = vstate != SYNC;

endmodule