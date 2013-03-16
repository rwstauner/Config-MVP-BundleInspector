# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;

package Config::MVP::BundleInspector;
# ABSTRACT: Determine prereqs and INI string from PluginBundles

use Class::Load ();

use Moose;
use MooseX::AttributeShortcuts;
use MooseX::Types::Moose qw( Str ArrayRef HashRef );
use MooseX::Types::Perl qw( PackageName Identifier );
use namespace::autoclean;

# lots of lazy builders for subclasses

has bundle_class => (
  is         => 'ro',
  isa        => PackageName,
  required   => 1,
);

has bundle_method => (
  is         => 'lazy',
  isa        => Identifier,
);

sub _build_bundle_method {
  'mvp_bundle_config'
}

has bundle_name => (
  is         => 'lazy',
  isa        => Str,
);

sub _build_bundle_name {
  $_[0]->bundle_class
}

has plugin_specs => (
  is         => 'lazy',
  isa        => ArrayRef,
);

sub _build_plugin_specs {
  my ($self) = @_;
  my $class = $self->bundle_class;
  my $method = $self->bundle_method;

  Class::Load::load_class($class);

  return $self->_plugin_specs_from_bundle_method($class, $method);
}

sub _plugin_specs_from_bundle_method {
  my ($self, $class, $method) = @_;
  return [
    $class->$method({
      name    => $self->bundle_name,
      payload => {},
    })
  ];
}

has prereqs => (
  is         => 'lazy',
  isa        => 'CPAN::Meta::Requirements',
);

sub _build_prereqs {
  my ($self) = @_;

  require CPAN::Meta::Requirements;
  my $prereqs = CPAN::Meta::Requirements->new;
  foreach my $spec ( @{ $self->plugin_specs } ){
    my ($name, $class, $payload) = @$spec;
    $payload ||= {};
    $prereqs->add_minimum($class => $payload->{':version'} || 0)
  }

  return $prereqs;
}

has ini_string => (
  is         => 'lazy',
  isa        => Str,
);

has ini_opts => (
  is         => 'lazy',
  isa        => HashRef,
);

sub _build_ini_opts {
  return {};
}

sub _build_ini_string {
  my ($self) = @_;

  require Config::MVP::Writer::INI;
  my $string = Config::MVP::Writer::INI->new($self->ini_opts)
    ->ini_string($self->plugin_specs);

  return $string;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut
