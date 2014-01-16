package experimental;

use strict;
use warnings;

use feature ();
use Carp qw/croak carp/;

my %warnings = map { $_ => 1 } grep { /^experimental::/ } keys %warnings::Offsets;
my %features = map { $_ => 1 } keys %feature::feature;

my %grandfathered = (
	autoderef     => 5.014000,
	smartmatch    => 5.010001,
	lexical_topic => 5.010000,
	array_base    => 5,
);

my %additional = (
	postderef  => ['postderef_qq'],
	switch     => ['smartmatch'],
);

sub _enable {
	my $pragma = shift;
	if ($warnings{"experimental::$pragma"}) {
		warnings->unimport("experimental::$pragma");
		feature->import($pragma) if exists $features{$pragma};
		_enable(@{ $additional{$pragma} }) if $additional{$pragma};
	}
	elsif ($features{$pragma}) {
		feature->import($pragma);
		_enable(@{ $additional{$pragma} }) if $additional{$pragma};
	}
	elsif (not $grandfathered{$pragma}) {
		croak "Can't enable unknown feature $pragma";
	}
	elsif ($grandfathered{$pragma} > $]) {
		croak "Need perl $grandfathered{$pragma} for feature $pragma";
	}
}

sub import {
	my ($self, @pragmas) = @_;

	for my $pragma (@pragmas) {
		_enable($pragma);
	}
	return;
}

sub _disable {
	my $pragma = shift;
	if ($warnings{"experimental::$pragma"}) {
		warnings->import("experimental::$pragma");
		feature->unimport($pragma) if exists $features{$pragma};
		_disable(@{ $additional{$pragma} }) if $additional{$pragma};
	}
	elsif ($features{$pragma}) {
		feature->unimport($pragma);
		_disable(@{ $additional{$pragma} }) if $additional{$pragma};
	}
	elsif (not $grandfathered{$pragma}) {
		carp "Can't disable unknown feature $pragma, ignoring";
	}
}

sub unimport {
	my ($self, @pragmas) = @_;

	for my $pragma (@pragmas) {
		_disable($pragma);
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

Because of the nature of the features it enables, forward compatibility can not be guaranteed in any way.

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

