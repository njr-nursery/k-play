load '../t/test-lib'

@test "lambda callcc" {
    assert_function m_krun lambda k <<.
        (callcc (lambda k  . ((k 5) + 2))) + 10     ⇒ 15
        (callcc (lambda k  . (5 + 2)))     + 10     ⇒ 17
.
}

@test "lambda basic" {
    assert_function m_krun lambda k <<.
        lambda x . x                                ⇒ lambda x . x
        a (((lambda x.lambda y.x) y) z)             ⇒ a y
        (lambda z.(z z)) (lambda x.lambda y.(x y))  ⇒ lambda y . ( ( lambda x . lambda y . ( x y ) ) y )
.
}

@test "lambda arithmatic" {
    assert_function m_krun lambda k <<.
        2 + 3 * 2 * 2                               ⇒ 14
        2 <= 3 + 1                                  ⇒ true
        2 <= 1                                      ⇒ false
.
}

@test "lambda if then else" {
    assert_function m_krun lambda k <<.
        # if true  then lambda x. 2*x else 4 3      ⇒ 6
        # We'd expect this to work, but the parsing seems a bit too greedy.
        # So we use parens to work around.
        (if true  then lambda x. 2*x else 4) 3      ⇒ 6
        if false then lambda x. 2*x else 4          ⇒ 4
.
}

@test "let" {
    run m_krun lambda k '
        let f = lambda x . (
                (lambda t . lambda x . (t t x))
                (lambda f . lambda x . (if x <= 1 then 1 else (x * (f f (x + -1)))))
                x
              )
        in (f 10)
'
    assert_success
    assert_output '3628800'
}

@test "letrec" {
    run m_krun lambda k '
        letrec f x = if x <= 1 then 1 else (x * (f (x + -1)))
        in (f 10)
'
    assert_success
    assert_output '3628800'
}
