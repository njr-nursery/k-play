module IMP-SYNTAX
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

    syntax Stmt ::= Id "=" AExp ";"           [strict(2)]
                  | Stmt Stmt
                  | "if" "(" BExp ")" Stmt    [strict(1)]
                  | "{" Stmt "}"

    syntax Pgm ::= "int" Ids ";" Stmt
    syntax Ids ::= List{Id, ","}
endmodule


module IMP
    imports IMP-SYNTAX
    syntax KResult ::= Int | Bool

    rule M::Int +  N::Int =>  M +Int N
    rule M::Int /  N::Int =>  M /Int N      requires N =/=Int 0
    rule M::Int <= N::Int =>  M <=Int N
    rule M::Int >= N::Int =>  M >=Int N

    rule true && B => B
    rule false && _ => false

    configuration <T>
                    <k> $PGM:Pgm </k>
                    <state> .Map </state>
                  </T>
    rule <k> int (X,Xs => Xs) ; _ </k> <state> Rho:Map (.Map => X|->0)</state>
        requires notBool (X in keys(Rho))
    rule <k> X = I:Int; => . ... </k> <state> ... X |-> (_ => I) ...</state>
    rule int .Ids; S => S [structural]
    rule S1:Stmt S2:Stmt => S1 ~> S2 [structural]
    rule <k> X:Id => I ...</k> <state>... X |-> I ...</state>

    rule if ( true  ) S:Stmt => S
    rule if ( false ) S:Stmt => .
endmodule
