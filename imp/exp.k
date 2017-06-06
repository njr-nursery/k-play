module EXP-SYNTAX
    syntax AExp ::= Int | Id
                  | AExp "/" AExp             [left, strict]
                  > AExp "+" AExp             [left, strict]
                  | AExp "-" AExp             [left, strict]
                  | "(" AExp ")"              [bracket]
    syntax BExp ::= Bool
                  | AExp "<=" AExp            [seqstrict, latex({#1}\le{#2})]
                  | AExp ">=" AExp            [seqstrict, latex({#1}\ge{#2})]
                  | "!" BExp                  [strict]
                  > BExp "&&" BExp            [left, strict(1)]
                  | "(" BExp ")"              [bracket]
endmodule

module EXP
    imports EXP-SYNTAX

    rule M::Int +  N::Int =>  M +Int N
    rule M::Int /  N::Int =>  M /Int N      requires N =/=Int 0

    rule M::Int <= N::Int =>  M <=Int N
    rule M::Int >= N::Int =>  M >=Int N

    rule true && B => B
    rule false && _ => false
endmodule

