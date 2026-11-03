module alu_tb;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;

    reg [3:0] ALU_SEL;

    wire [WIDTH-1:0] RESULT;

    wire CARRY;
    wire ZERO;
    wire OVERFLOW;

    integer PASS_COUNT;
    integer FAIL_COUNT;
    integer i;

    reg [WIDTH-1:0] EXPECTED_RESULT;

    reg EXPECTED_CARRY;
    reg EXPECTED_ZERO;
    reg EXPECTED_OVERFLOW;

    reg [WIDTH:0] TEMP;

    // Instantiate DUT

    alu #(.WIDTH(WIDTH)) DUT (

        .A(A),
        .B(B),
        .ALU_SEL(ALU_SEL),
        .RESULT(RESULT),
        .CARRY(CARRY),
        .ZERO(ZERO),
        .OVERFLOW(OVERFLOW)

    );

    // Calculate expected outputs

    task check_result;

        input [WIDTH-1:0] X;
        input [WIDTH-1:0] Y;
        input [3:0] OP;

        begin

            A = X;
            B = Y;
            ALU_SEL = OP;

            EXPECTED_RESULT = 0;
            EXPECTED_CARRY = 0;
            EXPECTED_OVERFLOW = 0;
            TEMP = 0;

            case(OP)

                4'b0000: begin

                    TEMP = {1'b0,X} + {1'b0,Y};

                    EXPECTED_RESULT = TEMP[WIDTH-1:0];

                    EXPECTED_CARRY = TEMP[WIDTH];

                    EXPECTED_OVERFLOW =
                        (~(X[WIDTH-1] ^ Y[WIDTH-1])) &
                        (EXPECTED_RESULT[WIDTH-1] ^ X[WIDTH-1]);

                end

                4'b0001: begin

                    EXPECTED_RESULT = X - Y;

                    EXPECTED_CARRY = (X < Y);

                    EXPECTED_OVERFLOW =
                        (X[WIDTH-1] ^ Y[WIDTH-1]) &
                        (EXPECTED_RESULT[WIDTH-1] ^ X[WIDTH-1]);

                end

                4'b0010: EXPECTED_RESULT = X & Y;

                4'b0011: EXPECTED_RESULT = X | Y;

                4'b0100: EXPECTED_RESULT = X ^ Y;

                4'b0101: EXPECTED_RESULT = ~X;

                4'b0110: EXPECTED_RESULT = X << Y;

                4'b0111: EXPECTED_RESULT = X >> Y;

                4'b1000: EXPECTED_RESULT = (X > Y);

                default: EXPECTED_RESULT = 0;

            endcase

            EXPECTED_ZERO = (EXPECTED_RESULT == 0);

            #5;

            if ((RESULT === EXPECTED_RESULT) &&
                (CARRY === EXPECTED_CARRY) &&
                (ZERO === EXPECTED_ZERO) &&
                (OVERFLOW === EXPECTED_OVERFLOW)) begin

                PASS_COUNT = PASS_COUNT + 1;

                $display("PASS | A=%h B=%h OP=%h RESULT=%h",
                         A,B,ALU_SEL,RESULT);

            end

            else begin

                FAIL_COUNT = FAIL_COUNT + 1;

                $display("FAIL | A=%h B=%h OP=%h",A,B,ALU_SEL);

                $display("Expected=%h Actual=%h",
                         EXPECTED_RESULT,RESULT);

                $display("Expected Flags: C=%b Z=%b V=%b",
                         EXPECTED_CARRY,
                         EXPECTED_ZERO,
                         EXPECTED_OVERFLOW);

                $display("Actual Flags: C=%b Z=%b V=%b",
                         CARRY,ZERO,OVERFLOW);

            end

        end

    endtask


    // Main test sequence

    initial begin

        $dumpfile("waveform/alu.vcd");
$dumpvars(0, alu_tb);

        PASS_COUNT = 0;
        FAIL_COUNT = 0;

        A = 0;
        B = 0;
        ALU_SEL = 0;

        $dumpfile("waveform/alu.vcd");

        $dumpvars(0,alu_tb);

        $display("--------------------------------");

        $display("PARAMETERIZED ALU VERIFICATION");

        $display("WIDTH = %0d",WIDTH);

        $display("--------------------------------");


        // Test 1: Arithmetic

        check_result(8'd10,8'd5,4'b0000);

        check_result(8'd10,8'd5,4'b0001);


        // Test 2: Logic operations

        check_result(8'hF0,8'h0F,4'b0010);

        check_result(8'hF0,8'h0F,4'b0011);

        check_result(8'hAA,8'h55,4'b0100);

        check_result(8'hAA,8'h00,4'b0101);


        // Test 3: Shift operations

        check_result(8'd4,8'd2,4'b0110);

        check_result(8'd16,8'd2,4'b0111);


        // Test 4: Comparison

        check_result(8'd20,8'd10,4'b1000);


        // Test 5: Boundary conditions

        check_result(8'hFF,8'h01,4'b0000);

        check_result(8'h00,8'h01,4'b0001);

        check_result(8'h7F,8'h01,4'b0000);


        // Test 6: Random testing

        for(i=0;i<100;i=i+1) begin

            check_result(
                $random,
                $random,
                i % 9
            );

        end


        // Final report

        $display("--------------------------------");

        $display("VERIFICATION SUMMARY");

        $display("TOTAL TESTS : %0d",
                 PASS_COUNT + FAIL_COUNT);

        $display("PASS        : %0d",PASS_COUNT);

        $display("FAIL        : %0d",FAIL_COUNT);

        $display("--------------------------------");


        if(FAIL_COUNT == 0)

            $display("FINAL STATUS: ALL TESTS PASSED");

        else

            $display("FINAL STATUS: VERIFICATION FAILED");

        $finish;

    end

endmodule