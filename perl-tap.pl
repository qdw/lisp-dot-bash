#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

ok(1 == 1, "one is one");
is(2, 2, "two is two");

SKIP: {
    skip "skip to my lou", 1;
    ok "felt cute, might skip later";
}

is(2 + 2 , 5, "bad math");
