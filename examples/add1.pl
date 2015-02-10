use strict;
use warnings;
use FFI::Platypus;

my $ffi = FFI::Platypus->new;
$ffi->lang('Fortran');
$ffi->lib('./libadd1.so');

$ffi->attach( add => ['integer*','integer*'] => 'integer');

print add(\1,\2), "\n";
