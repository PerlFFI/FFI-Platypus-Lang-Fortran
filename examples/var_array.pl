use strict;
use warnings;
use FFI::Platypus;

my $ffi = FFI::Platypus->new;
$ffi->lang("Fortran");
$ffi->lib("./libvar_array.so");

my @a = (1..10);
my @b = (25..30);

sub sum_array
{
  my $size = @_;
  $ffi->function( sum_array => ['integer*',"integer[$size]"] => 'integer' )->call(\$size, \@_);
}

print sum_array(@a), "\n";
print sum_array(@b), "\n";
