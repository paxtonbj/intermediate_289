module IR(
    input clk,
    input rst,
    input [31:0] instruction_in,
    output reg [31:0] instruction_out
);

    always @(posedge clk) begin
        if (rst == 0) begin // active low
            instruction_out <= 32'd0;
        end else begin
            instruction_out <= instruction_in;
        end
    end

endmodule