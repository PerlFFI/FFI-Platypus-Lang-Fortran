use strict;
use warnings;
use Test::More;
use FFI::CheckLib qw( find_lib );
use FFI::Platypus;

my $libtest = find_lib lib => 'test', libpath => 'libtest';
plan skip_all => 'test requires Fortran'
  unless $libtest;

plan tests => 1;

my $ffi = FFI::Platypus->new;
$ffi->lang('Fortran');
$ffi->lib($libtest);

subtest lib => sub {
  $ffi->attach( add => ['integer*', 'integer*'] => 'integer');
  is add(\1,\2), 3, 'add(\1,\2) = 3';
};
