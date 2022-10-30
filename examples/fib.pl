use strict;
use warnings;
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new( api => 2 );
$ffi->lang('Fortran');
$ffi->lib('./fib.so');

$ffi->attach( fib => ['integer*'] => 'integer' );

for(1..10)
{
  print fib(\$_), "\n";
}
