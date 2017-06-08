require "substitution.k"

module LAMBDA-SYNTAX
    syntax Val ::= Id
                 | "lambda" Id "." Exp  [binder, latex(\lambda{#1}.{#2})]
    syntax Exp ::= Val
                 | Exp Exp              [left, strict]
                 | "(" Exp ")"          [bracket]

    syntax KVariable ::= Id
    syntax KResult ::= Val

    syntax Val ::= Int | Bool
    syntax Exp ::= Exp "*" Exp        [strict, left]
               | Exp "/" Exp          [strict]
               > Exp "+" Exp          [strict, left]
               > Exp "<=" Exp         [strict]

    syntax Exp ::= "if" Exp "then" Exp "else" Exp   [strict(1)]

    syntax Let ::= "let" Id "=" Exp "in"  Exp
    syntax Exp ::= "letrec" Id Id "=" Exp "in" Exp
    syntax Exp ::= "mu" Id "." Exp [binder, latex(\mu{#1}.{#2})]
    syntax Exp ::= "callcc" Exp [strict]
endmodule

module LAMBDA
    imports LAMBDA-SYNTAX
    imports SUBSTITUTION

    rule (lambda X:Id . E:Exp) V:Val => E[V / X]

    rule I1 * I2 => I1 *Int I2
    rule I1 / I2 => I1 /Int I2  requires I2 =/=Int 0
    rule I1 + I2 => I1 +Int I2
    rule I1 <= I2 => I1 <=Int I2

    rule if true  then E:Exp else _     => E
    rule if false then _     else E:Exp => E

    rule let X = E in E':Exp => (lambda X . E') E   [macro]
    rule letrec F:Id X:Id = E in E' => let F = mu F . lambda X . E in E' [macro]
    rule mu X . E => E[(mu X . E) / X]

    syntax Val ::= cc(K)
    rule <k> (callcc V:Val => V cc(K)) ~> K </k>
    rule <k> cc(K) V ~> _ => V ~> K </k>
endmodule
