package stable;

use strict;
use warnings;
use version ();

use experimental ();
use Carp qw/croak carp/;

my %allow_at = (
	bitwise       => 5.022000,
	isa           => 5.032000,
	lexical_subs  => 5.022000,
	postderef     => 5.020000,
);

sub import {
	my ($self, @pragmas) = @_;

	for my $pragma (@pragmas) {
		my $min_ver = $allow_at{$pragma};
		croak "unknown stablized experiment $pragma" unless defined $min_ver;
		croak "requested stablized experiment $pragma, which is stable at $min_ver but this is $]"
			unless $] >= $min_ver;
	}

	experimental->import(@pragmas);
	return;
}

sub unimport {
	my ($self, @pragmas) = @_;

	# Look, we could say "You can't unimport stable experiment 'bitwise' on
	# 5.20" but it just seems weird. -- rjbs, 2022-03-05
	experimental->unimport(@pragmas);
	return;
}

1;

#ABSTRACT: Experimental features made easy, once we know they're stable

=head1 SYNOPSIS

	use stable 'lexical_subs', 'bitwise';
	my sub is_odd($value) { $value & 1 }

=head1 DESCRIPTION

The L<experimental> pragma makes it easy to turn on experimental while turning
off associated warnings.  You should read about it, if you don't already know
what it does.

Seeing C<use experimental> in code might be scary.  In fact, it probably should
be!  Code that uses experimental features might break in the future if the perl
development team decides that the experiment needs to be altered.  When
experiments become stable, because the developers decide they're a success, the
warnings associated with them go away.  When that happens, they can generally
be turned on with C<use feature>.

This is great, if you are using a version of perl where the feature you want is
already stable.  If you're using an older perl, though, it might be the case
that you want to use an experimental feature that still warns, even though
there's no risk in using it, because subsequent versions of perl have that
feature unchanged and now stable.

Here's an example:  The C<postderef> feature was added in perl 5.20.0.  In perl
5.24.0, it was marked stable.  Using it would no longer trigger a warning.  The
behavior of the feature didn't change between 5.20.0 and 5.24.0.  That means
that it's perfectly safe to use the feature on 5.20 or 5.22, even though
there's a warning.

In that case, you could very justifiably add C<use experimental 'postderef'>
but the casual reader may still be worried at seeing that.  The C<stable>
pragma exists to turn on experimental features only when it's known that
their behavior in the running perl is their stable behavior.

If you try to use an experimental feature that isn't stable or available on
the running version of perl, an exception will be thrown.

At present there are only a few "stable" features:

=over 4

=item * C<bitwise> - stable as of 5.22

=item * C<isa> - stable as of 5.32

=item * C<lexical_subs> - stable as of 5.22

Lexical subroutines were actually added in 5.18, and their design did not
change, but significant bugs makes them unsafe to use before 5.22.

=item * C<postderef> - stable as of 5.20

=back

=head1 SEE ALSO

L<perlexperiment|perlexperiment> contains more information about experimental features.

=cut
