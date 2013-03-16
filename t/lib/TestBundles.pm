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

1;
