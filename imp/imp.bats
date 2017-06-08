load '../t/test-lib'

setup() {
    test_lib_setup
}

@test "imp while" {
    run m_krun imp state '
        int x;
        while (x <= 12) x = x +1;
    '
   assert_success
   assert_output 'x |-> 13'
}

@test "imp if" {
    run m_krun imp state '
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
   assert_output 'x |-> 3 y |-> 102'
}

@test "imp variables, arithmatic and assignemnts" {
    assert_function m_krun imp state <<.
        int x; x = 2 + 3;           ⇒ x |-> 5
        int x, y; y = 2; x = 3 + y; ⇒ x |-> 5 y |-> 2
.
}

@test "imp expressions" {
    assert_function m_krun exp k <<.
        2 + 3 ⇒ 5
        9 / 2 ⇒ 4
        3 <= 2 ⇒ false
        3 >= 2 ⇒ true
        true && true ⇒ true
.

    # This shouldn't even parse
    run m_krun exp k '2 + true'
    assert_failure
    assert_output -p 'Parse error'
}
