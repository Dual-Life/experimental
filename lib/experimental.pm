package experimental;
use strict;
use warnings;
eval { require feature };

use Carp qw/croak carp/;

my %warnings = map { $_ => 1 } grep { /^experimental::/ } keys %warnings::Offsets;
my %features = map { $_ => 1 } do { no warnings 'once'; keys %feature::feature; };

my %grandfathered = ( smartmatch => 5.010001, array_base => 5);

sub import {
	my ($self, @pragmas) = @_;

	for my $pragma (@pragmas) {
		if ($warnings{"experimental::$pragma"}) {
			warnings->unimport("experimental::$pragma");
			feature->import($pragma) if $features{$pragma};
		}
		elsif ($features{$pragma}) {
			feature->import($pragma);
		}
		elsif ($grandfathered{$pragma} and $grandfathered{$pragma} > $]) {
			croak "Need perl $] for feature $pragma";
		}
		else {
			croak "Can't enable unknown feature $pragma";
		}
	}
	return;
}

sub unimport {
	my ($self, @pragmas) = @_;

	for my $pragma (@pragmas) {
		if ($warnings{"experimental::$pragma"}) {
			warnings->import("experimental::$pragma");
			feature->unimport($pragma) if $features{$pragma};
		}
		elsif ($features{$pragma}) {
			feature->unimport($pragma);
		}
		elsif (not $grandfathered{$pragma}) {
			carp "Can't disable unknown feature $pragma, ignoring";
		}
	}
	return;
}

1;

#ABSTRACT: Experimental features made easy

=head1 SYNOPSYS

 use experimental 'lexical_subs', 'smartmatch';
 my sub foo { $_[0] ~~ 1 }

=head1 DESCRIPTION

This pragma provides an easy and convenient way to enable or disable experimental features.

=head2 Disclaimer

Because of the nature of the features it enables, forward compatability can not be guaranteed in any way.

=head2 Use cases

=over 4

=item * smartmatch

This is effectively equivalent to

 no if $] >= 5.017011, warnings => 'experimental::smartmatch';

Except that on versions that do no support smartmatch, it will give an explicit error.

=item * lexical_subs

This is equivalent to

 use feature 'lexical_subs';
 no warnings 'experimental::lexical_subs';

=back

