load '../t/test-lib'

setup() {
    test_lib_setup
    test_suite_scratch="$build_t_dir/$test_suite_name"
    [[ -e $test_suite_scratch/lambda-kompiled/ ]] ||
        kompile "$BATS_TEST_DIRNAME/lambda.k"  -d "$test_suite_scratch"
    m_krun() {
        # krun doesn't like process substitution?
        temp="$(mktemp)"
        echo "$1" > "$temp"
        krun -d "$test_suite_scratch" "$temp"
    }
}

@test "lambda basic" {
    assert_function m_krun <<.
        lambda x . x                                ⇒ <k> lambda x . x </k>
        a (((lambda x.lambda y.x) y) z)             ⇒ <k> a y </k>
        (lambda z.(z z)) (lambda x.lambda y.(x y))  ⇒ <k> lambda y . ( ( lambda x . lambda y . ( x y ) ) y ) </k>
.
}

@test "lambda arithmatic" {
    assert_function m_krun <<.
        2 + 3 * 2 * 2                               ⇒ <k> 14 </k>
        2 <= 3 + 1                                  ⇒ <k> true </k>
        2 <= 1                                      ⇒ <k> false </k>
.
}

@test "lambda if then else" {
    assert_function m_krun <<.
        # if true  then lambda x. 2*x else 4 3      ⇒ <k> 6 </k>
        # We'd expect this to work, but the parsing seems a bit too greedy.
        # So we use parens to work around.
        (if true  then lambda x. 2*x else 4) 3      ⇒ <k> 6 </k>
        if false then lambda x. 2*x else 4          ⇒ <k> 4 </k>
.
}

@test "let" {
    run m_krun '
        let f = lambda x . (
                (lambda t . lambda x . (t t x))
                (lambda f . lambda x . (if x <= 1 then 1 else (x * (f f (x + -1)))))
                x
              )
        in (f 10)
'
    assert_success
    assert_output '<k> 3628800 </k>'
}

@test "letrec" {
    run m_krun '
        letrec f x = if x <= 1 then 1 else (x * (f (x + -1)))
        in (f 10)
'
    assert_success
    assert_output '<k> 3628800 </k>'
}

