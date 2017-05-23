load '../t/test-lib'

setup() {
    test_lib_setup
    kompile "$BATS_TEST_DIRNAME/lambda.k"  -d "$test_scratch_dir"
    check_krun() {
        # krun doesn't like process substitution?
        temp="$(mktemp)"
        echo "$1" > "$temp"
        run krun -d "$test_scratch_dir" "$temp" 
        assert_output "<k> $2 </k>"
    }
}

@test "identity" {
    check_krun 'lambda x . x' 'lambda x . x'
}

@test "lambda2" {
    check_krun 'lambda x . x' 'lambda x .'
}
