load '../t/test-lib'

setup() {
    test_lib_setup
    kompile "$BATS_TEST_DIRNAME/lambda.k"  -d "$test_scratch_dir"
    m_krun() {
        # krun doesn't like process substitution?
        temp="$(mktemp)"
        echo "$1" > "$temp"
        krun -d "$test_scratch_dir" "$temp"
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
