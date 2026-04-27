module regfile(
    input clk,
    input rst,
    input we,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2,
    output [31:0] reg7_out,
	 output [31:0] reg8_out
);
    reg [31:0] registers [31:0];
    integer i;

    assign reg7_out = registers[7];
	 assign reg8_out = registers[8];


    always @(negedge clk) begin
        if (rst == 0) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else begin
            if (we == 1) begin
                if (rd != 5'd0) begin
                    registers[rd] <= write_data;
                end
            end
        end
    end

    always @(*) begin
        if (rs1 == 5'd0) begin
            read_data1 = 32'd0;
        end else begin
            read_data1 = registers[rs1];
        end
        if (rs2 == 5'd0) begin
            read_data2 = 32'd0;
        end else begin
            read_data2 = registers[rs2];
        end
    end

endmodule