module alu(
input [31:0]input_a,
input [31:0]input_b,
input [2:0]alu_control,
output reg[31:0]result,
output zero);


assign zero = (result == 32'd0);
always @(*) begin

	result = 32'd0;

	if (alu_control == 3'd0) begin
		
		 result = input_a + input_b;
		end
		
	if (alu_control == 3'd1) begin
	
		result = input_a - input_b;
		end
// dont think i need these but ill keep them incase		
	if (alu_control == 3'd2) begin
	
		 if (input_a > input_b) begin
			result[0] = 1'b1;
			end	
		end
		
	if (alu_control == 3'd3) begin
		
		if (input_a == input_b) begin
			result[0] = 1'b1;
			end
		end
		
	if (alu_control == 3'd4) begin
	
		result = input_a ^ input_b;
		end
	
	if (alu_control == 3'd5) begin
	
		result = input_a & input_b;
		end
		
	if (alu_control == 3'd6) begin
	
		result = input_a | input_b;
		end
		
	if (alu_control == 3'd7) begin
	
		result = ~input_a;
		end

	end

endmodule
