require "substitution.k"

module LAMBDA
    imports SUBSTITUTION

    syntax Val ::= Id
                 | "lambda" Id "." Exp  [binder]
    syntax Exp ::= Val
                 | Exp Exp              [left, strict]
                 | "(" Exp ")"          [bracket]
    syntax KVariable ::= Id
    syntax KResult ::= Val
    rule (lambda X:Id . E:Exp) V:Val => E[V / X]
    rule (lambda X:Id . E:Exp) V:Val => E[V / X]

    syntax Val ::= Int | Bool
    syntax Exp ::= Exp "*" Exp          [strict, left]
               | Exp "/" Exp          [strict]
               > Exp "+" Exp          [strict, left]
               > Exp "<=" Exp         [strict]
    rule I1 * I2 => I1 *Int I2
    rule I1 / I2 => I1 /Int I2  requires I2 =/=Int 0
    rule I1 + I2 => I1 +Int I2
    rule I1 <= I2 => I1 <=Int I2

//     syntax Exp ::= "if" Exp "then" Exp "else" Exp   [strict(1)]
//     rule if true  then E:Exp else _     => E
//     rule if false then _     else E:Exp => E
endmodule
