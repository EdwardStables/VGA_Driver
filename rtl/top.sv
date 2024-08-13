module top (
    input logic clk,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B,
    output logic HS,
    output logic VS
);

vga_driver i_vga_driver(
    .clk(clk),
    .R(R),
    .G(G),
    .B(B),
    .HS(HS),
    .VS(VS)
);

endmodule
