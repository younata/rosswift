#!/usr/bin/env bats

function in_test_env {
    pushd "$BATS_TEST_DIRNAME/.." >/dev/null 2>/dev/null
}

function exit_test_env {
    popd >/dev/null 2>/dev/null
}

@test "MessageGenerator Works in the simple case" {
    cat > $BATS_TMPDIR/Test.msg << EOF
int32 a
string b
EOF
    in_test_env

    run swift run MessageGenerator -e . $BATS_TMPDIR/Test.msg

    exit_test_env

    expectedMessage=$(cat <<EOF
struct Test: RosMessage {
    var a: Int32
    var b: String
}

EOF
)

    [ "$status" -eq 0 ]
    [ "$output" = "$expectedMessage" ]
}
