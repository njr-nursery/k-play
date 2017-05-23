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

@test "lambda" {
    assert_function m_krun <<.
        lambda x . x                                ⇒ <k> lambda x . x </k>
        a (((lambda x.lambda y.x) y) z)             ⇒ <k> a y </k>
        (lambda z.(z z)) (lambda x.lambda y.(x y))  ⇒ <k> lambda y . ( ( lambda x . lambda y . ( x y ) ) y ) </k>
        2 + 3 * 2 * 2                               ⇒ <k> 14 </k>
        2 <= 3 + 1                                  ⇒ <k> true </k>
        2 <= 1                                      ⇒ <k> false </k>
.
}
