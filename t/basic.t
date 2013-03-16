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

  eq_or_diff $bi->prereqs->as_string_hash, {
    $bundle . '::Jones'         => 0,
    $bundle . '::BlueBuildings' => '0.003',
  }, 'simplified prereqs with version';
};

subtest bundle_config => sub {
  my $bundle = 'TestBundles::AnnaBegins';
  my $bi = new_ok($mod, [
    bundle => $bundle,
  ]);

  local *pkg  = sub { $bundle . '::' . $_[0] };
  eq_or_diff $bi->plugin_specs, [
    [Time      => pkg('Time'), {':version' => '1.2', needs_feature => 'b',}],
    [TimeAgain => pkg('Time'), {':version' => '1.1', only_needs => ['feature', 'a'] }],
    [Rain      => pkg('King')],

  ], 'plugin_specs';

  eq_or_diff $bi->prereqs->as_string_hash, {
    $bundle . '::Time' => '1.2',
    $bundle . '::King' => 0,
  }, 'prereqs with latest version';
};

done_testing;
