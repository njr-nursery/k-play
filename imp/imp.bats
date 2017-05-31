load '../t/test-lib'

setup() {
    test_lib_setup
    test_suite_scratch="$build_t_dir/$test_suite_name"
    [[ -e $test_suite_scratch/imp-kompiled/ ]] ||
        kompile "$BATS_TEST_DIRNAME/imp.k"  -d "$test_suite_scratch"
    m_krun() {
        # krun doesn't like process substitution?
        temp="$(mktemp)"
        echo "$1" > "$temp"
        krun -d "$test_suite_scratch" "$temp"
    }
}

@test "imp if" {
    run m_krun '
        int x, y;
        x = 3; y = x + 99;
        if (x >= y)
            x = 100;
        if (y <= x) {
            y = 2;
            x = 3;
        }
   '
   assert_success
   assert_output -p '<state> x |-> 3 y |-> 102 </state>'
}

@test "imp variables, arithmatic and assignemnts" {
    assert_function m_krun <<.
        int x; x = 2 + 3;               ⇒ <T> <k> . </k> <state> x |-> 5 </state> </T>
        int x, y; y = 2; x = 3 + y;     ⇒ <T> <k> . </k> <state> x |-> 5 y |-> 2 </state> </T>
.
}

@test "imp expressions" {
    skip
    assert_function m_krun <<.
        2 + 3 ⇒ <k> 5 </k>
        9 / 2 ⇒ <k> 4 </k>
        3 <= 2 ⇒ <k> false </k>
        3 >= 2 ⇒ <k> true </k>
        true && true ⇒ <k> true </k>
.

    # This shouldn't even parse
    run m_krun '2 + true'
    assert_failure
    assert_output -p 'Parse error'
}
