module CPU(
    input clk,
    input rst,
    output LEDR0,
    output LEDR1,
    output LEDR2,
    output LEDR3,
    output LEDR4,
    output LEDR5
);
    wire [31:0] alu_a, alu_b, alu_result;
    wire [2:0] alu_ctrl;
    wire zero;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] read_data1, read_data2;
    wire we_reg;
    wire we_mem;
    wire load;
    wire [7:0] mem_addr;
    wire [31:0] mem_data_in, mem_data_out;
    wire [31:0] pc, next_pc, instruction;
    wire [31:0] reg7_out;
    wire [31:0] reg8_out;
    wire [2:0] state_out;
    wire [31:0] alu_result_reg_out;
    reg [31:0] write_data;

    assign instruction = mem_data_out;
assign LEDR0 = reg7_out[0];
    assign LEDR1 = state_out[0];
    assign LEDR2 = state_out[1];
    assign LEDR3 = we_reg;
    assign LEDR4 = pc[3];
    assign LEDR5 = pc[4];

    always @(*) begin
        if (load == 1) begin
            write_data = mem_data_out;
        end else begin
            write_data = alu_result_reg_out;
        end
    end

    alu u_alu(
        .input_a(alu_a),
        .input_b(alu_b),
        .alu_control(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    regfile u_regfile(
        .clk(clk),
        .rst(rst),
        .we(we_reg),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .reg7_out(reg7_out),
        .reg8_out(reg8_out)
    );

    IPWiz u_instr_mem(
        .address(mem_addr),
        .clock(clk),
        .data(32'd0),
        .wren(1'b0),
        .q(mem_data_out)
    );

    PC u_pc(
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc(pc)
    );

    FSM u_fsm(
        .clk(clk),
        .rst(rst),
        .zero(zero),
        .instruction(instruction),
        .alu_ctrl(alu_ctrl),
        .we_reg(we_reg),
        .we_mem(we_mem),
        .load(load),
        .next_pc(next_pc),
        .pc(pc),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .alu_result(alu_result),
        .instr_addr(mem_addr),
        .data_addr(),
        .mem_data_in(mem_data_in),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .state_out(state_out),
        .alu_result_reg_out(alu_result_reg_out)
    );

endmodule