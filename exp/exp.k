module EXP-SYNTAX
    syntax Exp ::= Int
                | Exp "+" Exp
                | Exp "*" Exp
                | Exp "/" Exp
                | "read"
                | "print" "(" Exp ")"
                | "(" Exp ")"
endmodule

module EXP
    imports EXP-SYNTAX
endmodule

