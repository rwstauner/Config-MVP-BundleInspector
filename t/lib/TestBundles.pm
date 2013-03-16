use strict;
use warnings;

package # no_index
  TestBundles;

package
  TestBundles::RoundHere;

sub pkg { __PACKAGE__ . '::' . $_[0] }

sub mvp_bundle_config {
  return (
    [Omaha   => pkg('Jones'),         { salutation => 'mr' }],
    [Perfect => pkg('BlueBuildings'), { ':version' => '0.003' }],
  );
}

package
  TestBundles::AnnaBegins;

sub pkg { __PACKAGE__ . '::' . $_[0] }

sub bundle_config {
  return (
    # in prereqs version should be 1.2
    [Time      => pkg('Time'), {':version' => '1.2', needs_feature => 'b',}],
    [TimeAgain => pkg('Time'), {':version' => '1.1', only_needs => ['feature', 'a'] }],
    [Rain      => pkg('King')],
  );
}

1;
