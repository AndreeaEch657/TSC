module instr_register
import instr_register_pkg::*;
(input  logic         clk,
 input  logic         load_en,
 input  logic         reset_n,
 input  operand_t     operand_a,
 input  operand_t     operand_b,
 input  opcode_t      opcode,
 input  address_t     write_pointer,
 input  address_t     read_pointer,
 output instruction_t instruction_word
);
  

  timeunit 1ns/1ns;
 
  instruction_t iw_reg[0:31];
  operand_res rezultat;

  // Write to the register
  always @(posedge clk, negedge reset_n) 
    if (!reset_n) begin
      foreach (iw_reg[i]) 
        iw_reg[i] = '{opc:ZERO, default:0};
    end
    else if (load_en) begin
        case (opcode)
        ZERO: rezultat <= 0;
        PASSA: rezultat <= operand_a;
        PASSB: rezultat <= operand_b;
        ADD: rezultat <= operand_a + operand_b;
        SUB: rezultat <= operand_a - operand_b;
        MULT: rezultat <= operand_a * operand_b;
        DIV: rezultat <= operand_a / operand_b;
        MOD: rezultat <= operand_a % operand_b;
        

          /*ADD: begin
            iw_reg[write_pointer] = '{ADD, operand_a, operand_b, operand_a + operand_b};
          end
          PASSA: begin
            iw_reg[write_pointer] = '{PASSA, operand_a, operand_b, operand_a};
          end
          PASSB: begin
            iw_reg[write_pointer] = '{PASSB, operand_a, operand_b, operand_b};
          end
          SUB: begin
            iw_reg[write_pointer] = '{SUB, operand_a, operand_b, $signed(operand_a - operand_b)};
          end
          MULT: begin
            iw_reg[write_pointer] = '{MULT, operand_a, operand_b, $signed(operand_a * operand_b)};
          end
          DIV: begin
            iw_reg[write_pointer] = '{DIV, operand_a, operand_b, $signed(operand_a / operand_b)};
          end
          MOD: begin
            iw_reg[write_pointer] = '{MOD, operand_a, operand_b, $signed(operand_a % operand_b)};
          end
          default: begin
            iw_reg[write_pointer] = '{opcode, operand_a, operand_b, 0};
          end*/

        endcase
      end



  // Read from the register
  assign instruction_word = iw_reg[read_pointer];

  // Inject a functional bug for verification
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a;
end
`endif

endmodule: instr_register
