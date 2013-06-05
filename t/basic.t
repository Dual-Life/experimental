#! perl

use Test::More 0.89;

local $SIG{__WARN__} = sub { fail("Got unexpected warning"); diag($_[0]) };

if ($] >= 5.010001) {
	eval <<"END";
	use experimental 'smartmatch';
	sub bar { 1 };
	is(1 ~~ \&bar, 1, "is 1");
END
	if ($] >= 5.018) {
		eval <<"END";
		use experimental 'lexical_subs';
		my sub foo { 1 };
		is(foo(), 1, "foo is 1");
END
	}
}
else {
	fail("No experimental features available on perl $]");
}

done_testing;

