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

=attr bundle_class

The class to inspect.

=cut

has bundle_class => (
  is         => 'ro',
  isa        => PackageName,
  required   => 1,
);

=attr bundle_method

The class method to call that returns the list of plugin specs.
Defaults to C<mvp_bundle_config>

=cut

has bundle_method => (
  is         => 'lazy',
  isa        => Identifier,
);

sub _build_bundle_method {
  'mvp_bundle_config'
}

=attr bundle_name

Passed to the class method in a hashref as the C<name> value.
Defaults to L</bundle_class>.

=cut

has bundle_name => (
  is         => 'lazy',
  isa        => Str,
);

sub _build_bundle_name {
  return $_[0]->bundle_class;
}

=attr plugin_specs

An arrayref of plugin specs returned from the L</bundle_class>.
A plugin spec is an array ref of:

  [ $name, $package, \%payload ]

=cut

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

=attr prereqs

A L<CPAN::Meta::Requirements> object representing the prerequisites
as determined from the plugin specs.

=cut

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

=attr ini_string

A string representing the bundle's contents in INI format.
Generated from the plugin specs by L<Config::MVP::Writer::INI>.

=cut

has ini_string => (
  is         => 'lazy',
  isa        => Str,
);

=attr ini_opts

Options to pass to L<Config::MVP::Writer::INI>.
Defaults to an empty hashref.

=cut

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

  my $inspector = Config::MVP::BundleInspector->new(
    bundle_class => 'SomeApp::PluginBundle::Stuff',
  );

  $inspector->prereqs;

=head1 DESCRIPTION

This module gathers info about the plugin specs from a L<Config::MVP> C<PluginBundle>.

=cut
