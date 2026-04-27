module FSM(
    input clk,
    input rst,
    input zero,
    input [31:0] instruction,
    output reg [2:0] alu_ctrl,
    output reg we_reg,
    output reg we_mem,
    output reg load,
    output reg [31:0] next_pc,
    input [31:0] pc,
    input [31:0] read_data1,
    input [31:0] read_data2,
    input [31:0] alu_result,
    output reg [7:0] instr_addr,
    output reg [7:0] data_addr,
    output reg [31:0] mem_data_in,
    output reg [31:0] alu_a,
    output reg [31:0] alu_b,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output [2:0] state_out,
    output [31:0] alu_result_reg_out
);
    parameter FETCH     = 3'd0;
    parameter DECODE    = 3'd1;
    parameter EXECUTE   = 3'd2;
    parameter MEMORY    = 3'd3;
    parameter WRITEBACK = 3'd4;

    reg [2:0] state, next_state;
    reg zero_reg;
    reg [31:0] branch_target;
    reg [31:0] jump_target;
    reg [31:0] alu_result_reg;
    reg [31:0] read_data2_reg;

    assign state_out          = state;
    assign alu_result_reg_out = alu_result_reg;

    wire [6:0] opcode;
    wire [4:0] r_rs1, r_rs2, r_rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm_i, imm_s, imm_b;

    assign opcode = instruction[6:0];
    assign r_rd   = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign r_rs1  = instruction[19:15];
    assign r_rs2  = instruction[24:20];
    assign funct7 = instruction[31:25];

    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    assign imm_b = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

    always @(posedge clk) begin
        if (state == EXECUTE) begin
            alu_result_reg <= alu_result;
            zero_reg       <= zero;
            branch_target  <= pc + imm_b;
            jump_target    <= pc + {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            read_data2_reg <= read_data2;
        end
    end

    always @(posedge clk) begin
        if (rst == 0)
            state <= FETCH;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state  = FETCH;
        we_reg      = 0;
        we_mem      = 0;
        load        = 0;
        alu_ctrl    = 3'd0;
        alu_a       = 32'd0;
        alu_b       = 32'd0;
        instr_addr  = pc[9:2];
        data_addr   = 8'd0;
        mem_data_in = 32'd0;
        next_pc     = pc;
        rs1         = r_rs1;
        rs2         = r_rs2;
        rd          = r_rd;

        if (state == FETCH) begin
            instr_addr = pc[9:2];
            next_state = DECODE;

        end else if (state == DECODE) begin
            instr_addr = pc[9:2];
            rs1        = r_rs1;
            rs2        = r_rs2;
            next_state = EXECUTE;

        end else if (state == EXECUTE) begin

            // ADD
            if (opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000) begin
                alu_ctrl   = 3'd0;
                alu_a      = read_data1;
                alu_b      = read_data2;
                next_state = WRITEBACK;
            end

            // SUB
            if (opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0100000) begin
                alu_ctrl   = 3'd1;
                alu_a      = read_data1;
                alu_b      = read_data2;
                next_state = WRITEBACK;
            end

            // ADDI
            if (opcode == 7'b0010011 && funct3 == 3'b000) begin
                alu_ctrl   = 3'd0;
                alu_a      = read_data1;
                alu_b      = imm_i;
                next_state = WRITEBACK;
            end

            // LW
            if (opcode == 7'b0000011 && funct3 == 3'b010) begin
                alu_ctrl   = 3'd0;
                alu_a      = read_data1;
                alu_b      = imm_i;
                next_state = MEMORY;
            end

            // SW
            if (opcode == 7'b0100011 && funct3 == 3'b010) begin
                alu_ctrl   = 3'd0;
                alu_a      = read_data1;
                alu_b      = imm_s;
                next_state = MEMORY;
            end

            // BEQ
            if (opcode == 7'b1100011 && funct3 == 3'b000) begin
                alu_ctrl   = 3'd1;
                alu_a      = read_data1;
                alu_b      = read_data2;
                next_state = WRITEBACK;
            end

            // BNE
            if (opcode == 7'b1100011 && funct3 == 3'b001) begin
                alu_ctrl   = 3'd1;
                alu_a      = read_data1;
                alu_b      = read_data2;
                next_state = WRITEBACK;
            end

            // J
            if (opcode == 7'b1101111) begin
                next_state = WRITEBACK;
            end

        end else if (state == MEMORY) begin

            // SW
            if (opcode == 7'b0100011) begin
                data_addr   = alu_result_reg[9:2];
                mem_data_in = read_data2_reg;
                we_mem      = 1;
                next_state  = WRITEBACK;
            end

            // LW
            if (opcode == 7'b0000011) begin
                data_addr  = alu_result_reg[9:2];
                next_state = WRITEBACK;
            end

        end else if (state == WRITEBACK) begin

            // ADD, SUB, ADDI
            if (opcode == 7'b0110011 || opcode == 7'b0010011) begin
                we_reg     = 1;
                next_pc    = pc + 4;
                next_state = FETCH;
            end

            // LW
            if (opcode == 7'b0000011) begin
                we_reg     = 1;
                load       = 1;
                next_pc    = pc + 4;
                data_addr  = alu_result_reg[9:2];
                next_state = FETCH;
            end

            // SW
            if (opcode == 7'b0100011) begin
                next_pc    = pc + 4;
                next_state = FETCH;
            end

            // BEQ
            if (opcode == 7'b1100011 && funct3 == 3'b000) begin
                if (zero_reg == 1) begin
                    next_pc = branch_target;
                end else begin
                    next_pc = pc + 4;
                end
                next_state = FETCH;
            end

            // BNE
            if (opcode == 7'b1100011 && funct3 == 3'b001) begin
                if (zero_reg == 0) begin
                    next_pc = branch_target;
                end else begin
                    next_pc = pc + 4;
                end
                next_state = FETCH;
            end

            // J
            if (opcode == 7'b1101111) begin
                next_pc    = jump_target;
                next_state = FETCH;
            end

        end
    end

endmodule