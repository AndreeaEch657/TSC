/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;

  parameter seed = 555; //Procedura prin care se initializeaza generarea nr random pt random stability si reproducere
  parameter test_name = " ";
  int number_of_errors = 0;
  instruction_t actual [0:31];
  operand_res expected [0:31];
  parameter RANDOM_CASE = 0;
  parameter NUMBER_OF_TRANSACTIONS = 20;
  int seed_variable;

    /* //covergroup declaration
  covergroup coverage_calc;
  cov_p1: coverpoint tbintf.operand_a
                              {
                                bins op_a_max = {15};
                                bins op_a_zero = {0};
                                bins op_a_min = {-15};
                              }
  cov_p2: coverpoint tbintf.operand_b 
                             {
                                bins op_b_max = {15};
                                bins op_b_zero = {0};
                                bins op_b_min = {-15};
                              }
  cov_p3: coverpoint tbintf.opcode; 
  endgroup
  //cg variable declaration
  coverage_calc  cov_calc;*/

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    seed_variable  = seed;
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    repeat (NUMBER_OF_TRANSACTIONS) begin
      @(posedge clk) 
      begin
        load_en <= 1'b1;
        randomize_transaction;
      end
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
     for (int i=0; i<NUMBER_OF_TRANSACTIONS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      //@(posedge clk) read_pointer = i;


  // cov_calc.sample();
      
       if (RANDOM_CASE == 0) begin
        @(posedge clk) read_pointer = i;
      end
      else if (RANDOM_CASE == 1) begin 
        @(posedge clk) read_pointer = i;
      end
      else if (RANDOM_CASE == 2) begin 
        @(posedge clk) read_pointer = $unsigned($urandom)%32;
      end
      else if (RANDOM_CASE == 3) begin
        @(posedge clk) read_pointer = $unsigned($urandom)%32;
      end
      actual[read_pointer].rezultat = (instruction_word.rezultat);
      @(negedge clk) print_results;

    
    end

    @(posedge clk) ;

    check_results();
     $display("\nErrors : %d", number_of_errors);
    if(number_of_errors)   $display("\n TEST FAILLED");
    else    $display("\n TEST PASSED");

    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    operand_a     <= $random(seed_variable)%16;         // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15  
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    
  if (RANDOM_CASE == 0) begin
        write_pointer <= temp++;
      end
      else if (RANDOM_CASE == 1) begin 
        write_pointer <= $unsigned($urandom)%32;
      end
      else if (RANDOM_CASE == 2) begin 
        write_pointer <= temp++;
      end
      else if (RANDOM_CASE == 3) begin
        write_pointer <= $unsigned($urandom)%32;
      end  

  actual[write_pointer] <= '{opcode, operand_a, operand_b, 'b0};

  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  rezultat = %0d\n", instruction_word.rezultat);
  endfunction: print_results

  function void check_results();
  foreach(actual[i])begin
     case(actual[i].opc) 
        ZERO  : expected[i] = 'b0;
        PASSA : expected[i] = actual[i].op_a;
        PASSB : expected[i] = actual[i].op_b;
        ADD   : expected[i] = actual[i].op_a+actual[i].op_b;
        SUB   : expected[i] = actual[i].op_a-actual[i].op_b;
        MULT  : expected[i] = actual[i].op_a*actual[i].op_b;
        DIV   : expected[i] = actual[i].op_a/actual[i].op_b;
        MOD   : expected[i] = actual[i].op_a%actual[i].op_b;
      endcase
    if(expected[i] != actual[i].rezultat) begin
      number_of_errors++;
       $error("\n i = %0d: opcode = %0d (%s)  operand_a = %0d operand_b = %0d \n expected result = %0d  actual result = %0d \n",i , actual[i].opc, actual[i].opc.name, actual[i].op_a, actual[i].op_b, expected[i],actual[i].rezultat);
    end
   end
  endfunction: check_results



endmodule: instr_register_test
