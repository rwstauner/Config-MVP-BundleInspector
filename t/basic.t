use strict;
use warnings;
use Test::More 0.96;
use lib 't/lib';
use TestBundles;
use Test::Differences;

my $mod = 'Config::MVP::BundleInspector';
eval "require $mod" or die $@;

subtest mvp_bundle_config => sub {
  my $bundle = 'TestBundles::RoundHere';
  my $bi = new_ok($mod, [
    bundle => $bundle,
  ]);

  local *pkg  = sub { $bundle . '::' . $_[0] };
  eq_or_diff $bi->plugin_specs, [
    [Omaha   => pkg('Jones'),         { salutation => 'mr' }],
    [Perfect => pkg('BlueBuildings'), { ':version' => '0.003' }],

  ], 'plugin_specs';

  eq_or_diff $bi->prereqs, {
    $bundle . '::Jones'         => 0,
    $bundle . '::BlueBuildings' => '0.003',
  }, 'simplified prereqs with version';
};


