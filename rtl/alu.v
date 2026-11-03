module alu #(
    parameter WIDTH = 8
)
(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,

    input  wire [3:0] ALU_SEL,

    output reg  [WIDTH-1:0] RESULT,

    output reg CARRY,
    output reg ZERO,
    output reg OVERFLOW
);

    // Operation codes

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam NOT  = 4'b0101;
    localparam SLL  = 4'b0110;
    localparam SRL  = 4'b0111;
    localparam GT   = 4'b1000;

    reg [WIDTH:0] TEMP;

    always @(*) begin

        RESULT   = {WIDTH{1'b0}};
        CARRY    = 1'b0;
        OVERFLOW = 1'b0;
        TEMP     = {(WIDTH+1){1'b0}};

        case(ALU_SEL)

            ADD: begin

                TEMP = {1'b0,A} + {1'b0,B};

                RESULT = TEMP[WIDTH-1:0];

                CARRY = TEMP[WIDTH];

                OVERFLOW =
                    (~(A[WIDTH-1] ^ B[WIDTH-1])) &
                    (RESULT[WIDTH-1] ^ A[WIDTH-1]);

            end

            SUB: begin

                RESULT = A - B;

                CARRY = (A < B);

                OVERFLOW =
                    (A[WIDTH-1] ^ B[WIDTH-1]) &
                    (RESULT[WIDTH-1] ^ A[WIDTH-1]);

            end

            AND: begin

                RESULT = A & B;

            end

            OR: begin

                RESULT = A | B;

            end

            XOR: begin

                RESULT = A ^ B;

            end

            NOT: begin

                RESULT = ~A;

            end

            SLL: begin

                RESULT = A << B;

            end

            SRL: begin

                RESULT = A >> B;

            end

            GT: begin

                RESULT = (A > B);

            end

            default: begin

                RESULT = {WIDTH{1'b0}};

            end

        endcase

        ZERO = (RESULT == {WIDTH{1'b0}});

    end

endmodule