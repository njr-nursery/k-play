load '../t/test-lib'

setup() {
    test_lib_setup
    test_suite_scratch="$build_t_dir/$test_suite_name"

    compile() {
        lang="$1"; shift
        [[ -e $test_suite_scratch/$lang/$lang-kompiled/ ]] || {
            kompile -d "$test_suite_scratch/$lang" "$BATS_TEST_DIRNAME/$lang.k"
        }
    }

    m_krun() {
        lang="$1"; shift
        input="$1"; shift
        compile "$lang"
        # krun doesn't like process substitution?
        temp="$(mktemp)"
        echo "$input" > "$temp"
        krun -d "$test_suite_scratch/$lang" "$temp"
    }
}

@test "imp while" {
    run m_krun imp '
        int x;
        while (x <= 12) x = x +1;
    '
   assert_success
   assert_output -p '<state> x |-> 13 </state>'
}

@test "imp if" {
    run m_krun imp '
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
    assert_function m_krun imp <<.
        int x; x = 2 + 3;           ⇒ <T> <k> . </k> <state> x |-> 5 </state> </T>
        int x, y; y = 2; x = 3 + y; ⇒ <T> <k> . </k> <state> x |-> 5 y |-> 2 </state> </T>
.
}

@test "imp expressions" {
    assert_function m_krun exp <<.
        2 + 3 ⇒ <k> 5 </k>
        9 / 2 ⇒ <k> 4 </k>
        3 <= 2 ⇒ <k> false </k>
        3 >= 2 ⇒ <k> true </k>
        true && true ⇒ <k> true </k>
.

    # This shouldn't even parse
    run m_krun exp '2 + true'
    assert_failure
    assert_output -p 'Parse error'
}
