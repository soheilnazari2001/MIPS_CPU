//`include "src/control_unit_macros.sv"
//`include "src/alu_opts.sv"

module CU(
    input wire [5:0] opcode,
    input wire [5:0] func,
    input wire rst_b,
    output reg RegDest, // ok
    output reg Jump, // ok
    output reg JumpReg, // ok
    output reg Branch, // ok
    output reg MemToReg, // ok
    output reg Link, // ok
    output reg [4:0] ALUOp, // ok
    output reg MemWrite, // ok
    output reg ALUsrc, // ok 
    output reg MemRead, // ok 
    output reg RegWrite, // ok
    output reg Halted,
    output reg SignExtend
);

    always @(*) begin
	if(~rst_b)
		Halted = 0;
	else
        casez (opcode)
        // R type opts
        `R_TYPE: begin
            case (func)
                `XOR:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_XOR;
                    end
                `SLL:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump, Branch, MemRead, MemToReg, MemWrite}=6'b000000;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_LEFT_SH_AMOUNT;
                    end
                `SLLV:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_LEFT;
                    end
                `SRL:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump, Branch, MemRead, MemToReg, MemWrite}=6'b000000;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_RIGHT_SH_AMOUNT;
                    end
                `SUB:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_SUB;
                    end
                `SRLV:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_RIGHT;
                    end
                `SLT:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_COMP_LT;
                    end
                `SUBU:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_SUB;
                    end
                `OR:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_OR;
                    end
                `NOR:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_NOR;
                    end
                `ADDU:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_ADD;
                    end
                `MULT:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_MULT;
                    end
                `DIV:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_DIV;
                    end
                `AND:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_AND;
                    end
                `ADD:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_ADD;
                    end
                `SRA:begin
                    {RegDest,Link,RegWrite}=3'b111;
                    {ALUsrc, Jump,Branch,MemRead,MemToReg,MemWrite}=6'b000000;
                    {ALUOp} = `ALU_SIGNED_SHIFT_RIGHT_SH_AMOUNT;
                    end
                `JR:begin
                    {Jump, JumpReg} = 2'b11;
                    {RegWrite, MemRead, MemWrite} = 3'b000;
                    end
                default:begin
                    $display("UNKNOWN FUNC: %b", func);
                    Halted = 1'b1;
                    end
            endcase
        end 
        // J type opts
        `J_TYPE:
            case (opcode)
                `J: begin
                    Jump = 1'b1;
                    {RegWrite, MemToReg, MemWrite, MemRead} = 4'b0000;
                end

                `JAL: begin
                    {RegWrite, Jump} = 2'b11;
                    {Link, MemRead, MemWrite, JumpReg} = 4'b0000;
                end
		default:begin
		end
            endcase

        // I type opts
        default:
            case (opcode)
                `ADDi: begin
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_ADD;
		    SignExtend = 1;
                end

                `ADDiu: begin // similar to 'ADDi' in control signals
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_ADD;
		    SignExtend = 1;
                end

                `ANDi: begin	// DO NOT EXTEND SIGN
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_AND;
		    SignExtend = 0;
                end

                `XORi: begin 	// DO NOT EXTEND SIGN
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_XOR;
		    SignExtend = 0;
                end

                `ORi: begin	// DO NOT EXTEND SIGN
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_OR;
		    SignExtend = 0;
                end

                `BEQ: begin
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_COMP_NEQ; // "out" in ALU is 0 then "zero" flag is 1
		    SignExtend = 1;
                end 

                `BNE: begin 
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_COMP_EQ; // "out" in ALU is 0 then "zero" flag is 1
		    SignExtend = 1;
                end 

                `BLEZ: begin
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_COMP_GT; // "out" in ALU is 0 then "zero" flag is 1
		    SignExtend = 1;
                end

                `BGTZ: begin
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_COMP_LT; // "out" in ALU is 0 then "zero" flag is 1
		    SignExtend = 1;
                end

                `LW: begin
                    {ALUsrc, Link, RegWrite, MemRead, MemToReg} = 5'b11111;
                    {Jump, RegDest, MemWrite} = 3'b000;
                    {ALUOp} = `ALU_ADD;
		    SignExtend = 1;
                end

                `SW: begin
                    {ALUsrc, MemWrite} = 2'b11;
                    {Jump, RegWrite, MemRead, RegDest} = 4'b0000;
                    {ALUOp} = `ALU_ADD;
		    SignExtend = 1;
                end

                `SLTi: begin
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_COMP_LE;
		    SignExtend = 1;
                end

                `LUI: begin
                    {ALUsrc, Link, RegWrite} = 3'b111;
                    {RegDest, MemToReg, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = `ALU_LUI;
		    SignExtend = 1;
                end
		default: begin
            $display("UNKOWN OPCODE: %b", opcode);
		end

                // LB and SB cases were deleted 
            endcase
        endcase
    end
endmodule
