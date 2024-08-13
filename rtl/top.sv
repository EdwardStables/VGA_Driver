module top (input logic clk, input logic [3:0] btn, output logic [3:0] led);

    logic [3:0] led_r;

    initial begin
        led_r = 'b0;
    end


    always_ff @(posedge clk) begin
        for (int i = 0; i < 4; i++) begin
            if (btn[i]) led_r[i] <= ~led_r[i];
        end
    end

    assign led = led_r;

endmodule