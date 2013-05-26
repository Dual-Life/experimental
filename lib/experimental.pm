package experimental;
use strict;
use warnings;

use Carp qw/croak carp/;

my $has_feature = eval { require feature };
my %warnings = map { $_ => 1 } grep { /^experimental::/ } keys %warnings::Offsets;
my %features = map { $_ => 1 } $has_feature ? keys %feature::feature : ();
my %grandfathered = ( smartmatch => 5.010001 );

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
		elsif (not $grandfathered{$pragma} && $grandfathered{$pragma} < $] ) {
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
		elsif (not $grandfathered{$pragma} && $grandfathered{$pragma} < $] ) {
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

...

