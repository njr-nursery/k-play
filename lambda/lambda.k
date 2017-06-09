module LAMBDA-SYNTAX
    syntax Exp ::= Val | Id
                 | "lambda" Id "." Exp  [binder, latex(\lambda{#1}.{#2})]
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

    syntax Exp ::= "let" Id "=" Exp "in"  Exp
    syntax Exp ::= "letrec" Id Id "=" Exp "in" Exp
    syntax Exp ::= "mu" Id "." Exp [binder, latex(\mu{#1}.{#2})]
    syntax Exp ::= "callcc" Exp [strict]
endmodule

module LAMBDA
    imports LAMBDA-SYNTAX

    syntax Val ::= closure(Map,Id,Exp)
    rule <k> lambda X:Id . E => closure(Rho,X,E) ... </k>
         <env> Rho </env> [structural]
    rule <k> closure(Rho,X,E) V:Val => E ~>  Rho' ... </k>
         <env>  Rho' => Rho[X <- !N] </env>
         <store> ... .Map => (!N:Int |-> V) ... </store>
    rule <k> X => V ... </k>
         <env>   ... X |-> N ... </env>
         <store> ... N |-> V ... </store>
    rule <k> _:Val ~>  (Rho' => .) ... </k>
         <env>  _ => Rho' </env>

    rule <k> closure(Rho,X,E) V:Val => E ~> Rho' ...</k>
       <env> Rho' => Rho[X <- !N] </env>
       <store>... .Map => (!N:Int |-> V) ...</store>
    rule <k> X => V ...</k>
       <env>... X |-> N ...</env>
       <store>... N |-> V ...</store>

    rule I1 * I2 => I1 *Int I2
    rule I1 / I2 => I1 /Int I2  requires I2 =/=Int 0
    rule I1 + I2 => I1 +Int I2
    rule I1 <= I2 => I1 <=Int I2

    rule if true  then E:Exp else _     => E
    rule if false then _     else E:Exp => E

    rule let X = E in E':Exp => (lambda X . E') E   [macro]

    syntax Id ::= "$x" | "$y"
    rule letrec F:Id X:Id = E in E' => let F =
         (lambda $x . ((lambda F . lambda X . E) (lambda $y . ($x $x $y))))
         (lambda $x . ((lambda F . lambda X . E) (lambda $y . ($x $x $y))))
       in E'                                                           [macro]

//    rule mu X . E => E[(mu X . E) / X]

    syntax Val ::= cc(Map,K)
    rule <k> (callcc L:Val => L cc(Rho,K)) ~> K </k> <env> Rho </env>
    rule <k> cc(Rho,K) V ~> _ => V ~> K </k> <env> _ => Rho </env>

    configuration <t><k> $PGM:Exp </k>
                     <env> .Map </env>
                     <store> .Map </store>
                  </t>
endmodule
