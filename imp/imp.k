require "exp.k"

module IMP-SYNTAX
    imports EXP-SYNTAX

    syntax Stmt ::= Id "=" AExp ";"           [strict(2)]
                  | Stmt Stmt
                  | "if" "(" BExp ")" Stmt    [strict(1)]
                  | "while" "(" BExp ")" Stmt
                  | "{" Stmt "}"

    syntax Pgm ::= "int" Ids ";" Stmt
    syntax Ids ::= List{Id, ","}
endmodule

module IMP
    imports IMP-SYNTAX
    imports EXP

    syntax KResult ::= Int | Bool

    configuration <T>
                    <k> $PGM:Pgm </k>
                    <state> .Map </state>
                  </T>

    // Control structures
    rule if ( true  ) S:Stmt => S
    rule if ( false ) S:Stmt => .
    rule while ( B:BExp  ) S:Stmt => if (B) ( S while (B) S )

    // Variable declaration, assignment and substitution
    rule <k> int (X,Xs => Xs) ; _ </k> <state> Rho:Map (.Map => X|->0)</state>
        requires notBool (X in keys(Rho))
    rule int .Ids; S     => S       [structural]
    rule <k> X = I:Int;  => . ... </k> <state> ... X |-> (_ => I) ...</state>
    rule <k> X:Id        =>  I ...</k> <state> ... X |-> I ... </state>

    // Sequencing
    rule S1:Stmt S2:Stmt => S1 ~> S2    [structural]
endmodule
