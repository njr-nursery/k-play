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

    syntax Val ::= Int
    syntax Exp ::= IntExp
    syntax IntExp ::= Int
    syntax IntExp ::= IntExp "*" IntExp         [strict]
                    > IntExp "+" IntExp         [strict]
                    | "(" IntExp ")"          [bracket]

    rule M:Int * N:Int => M *Int N
    rule M:Int + N:Int => M +Int N
endmodule
