BEGIN {
  unless(eval q{ use 5.008001; 1 }) {
    print "Perl 5.008001 or better required\n";
    exit;
  }
}
use strict;
use warnings;
use lib 'inc';
use lib 'lib';
use My::ModuleBuild;

my $builder = My::ModuleBuild->new(
  module_name => 'FFI::Platypus::Lang::Fortran',
  dist_abstract => 'Documentation and tools for using Platypus with Fortran',
  dist_author => [ 'Graham Ollis <plicease@cpan.org>' ],
  license => 'perl',
  configure_requires => {
    'Module::Build' => 0.38,
    'File::Which'   => 0,
  },
  build_requires => {
    'Module::Build' => 0.38,
    'File::Which'   => 0,
  },
  test_requires => {
    'FFI::CheckLib' => 0,
    'File::Which'   => 0,
  },
  requires => {
    'perl'          => '5.008001',
    'FFI::Platypus' => '0.21',
    'File::Which'   => 0,
  },
);

$builder->add_to_cleanup(qw(
  *.bak
  examples/*.o
  examples/*.so
  examples/*.dylib
  examples/*.bundle
  libtest/*.o
  libtest/*.so
  libtest/*.dylib
  libtest/*.bundle
  FFI-Platypus-Lang-Fortran-*
  config.log
));

$builder->create_build_script;
