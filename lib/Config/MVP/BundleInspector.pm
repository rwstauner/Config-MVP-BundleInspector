# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;

package Config::MVP::BundleInspector;
# ABSTRACT: Determine prereqs and INI string from PluginBundles

use Moose;
use MooseX::Types::Moose qw( Str ArrayRef );
use MooseX::Types::Perl qw( PackageName );

has bundle => (
  is         => 'ro',
  isa        => PackageName,
  required   => 1,
);

has plugin_specs => (
  is         => 'ro',
  isa        => ArrayRef,
  lazy       => 1,
  builder    => '_build_plugin_specs',
);

sub _build_plugin_specs {
  my ($self) = @_;
  my $class = $self->bundle;

  Class::Load::load_class($class);

  # HACK: this is hardly sufficient
  my $method = $class->can('bundle_config')
    ? 'bundle_config'
    : 'mvp_bundle_config';

  return $self->_plugin_specs_from_bundle_method($class, $method);
}

sub _plugin_specs_from_bundle_method {
  my ($self, $class, $method) = @_;

  # HACK: this is the convention for dz and pw... any others?
  (my $bundle_name = $class) =~ s/.+PluginBundle::/\@/;

  return [ $class->$method({ name => $bundle_name, payload => { expand_bundles => 0 } }) ];
}

has prereqs => (
  is         => 'ro',
  isa        => 'CPAN::Meta::Requirements',
  lazy       => 1,
  builder    => '_build_prereqs',
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

__PACKAGE__->meta->make_immutable;
1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut
