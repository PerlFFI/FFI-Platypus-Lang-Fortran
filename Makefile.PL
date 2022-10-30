use strict;
use warnings;
use lib 'inc';

BEGIN {
  unless(eval q{ use 5.008004; 1 }) {
    print "Perl 5.008004 or better required\n";
    exit;
  }
}

use ExtUtils::MakeMaker 6.64;

require './inc/config.pl';

my %WriteMakefileArgs = (
  NAME               => 'FFI::Platypus::Lang::Fortran',
  DISTNAME           => 'FFI-Platypus-Lang-Fortran',
  AUTHOR             => "Graham Ollis <plicease\@cpan.org>",
  VERSION_FROM       => 'lib/FFI/Platypus/Lang/Fortran.pm',
  ABSTRACT_FROM      => 'lib/FFI/Platypus/Lang/Fortran.pm',
  LICENSE            => 'perl',
  MIN_PERL_VERSION   => '5.008004',
  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker'           => '6.64',
    'FFI::Platypus'                 => '2.00',
    'File::Which'                   => '0',
    'ExtUtils::F77'                 => '1.24',
    'File::ShareDir::Dist::Install' => '0.07',
  },
  BUILD_REQUIRES => {
    'File::ShareDir::Dist' => 0,
    'FFI::Build::MM'       => 0,
  },
  TEST_REQUIRES => {
    'Test::More' => '0.98',
    'Test2::V0'  => '0',
  },
  PREREQ_PM => {
    'FFI::Platypus' => '2.00',
    'File::Which'   => '0',
    'FFI::Build'    => '1.00',
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      bugtracker => {
        web => 'https://github.com/PerlFFI/FFI-Platypus-Lang-Fortran/issues',
      },
      repository => {
        type => 'git',
        url => 'https://github.com/PerlFFI/FFI-Platypus-Lang-Fortran.git',
        web => 'https://github.com/PerlFFI/FFI-Platypus-Lang-Fortran',
      },
      x_IRC => 'irc://irc.perl.org/#native',
    },
    no_index => {
      directory => [ 'examples' ],
    },
  },
  clean => {
    FILES => join(' ', qq(
      *.bak
      examples/*.o
      examples/*.obj
      examples/*.so
      examples/*.dylib
      examples/*.bundle
      t/ffi/*.so
      t/ffi/*.dylib
      t/ffi/*.bundle
      t/ffi/_build
      FFI-Platypus-Lang-Fortran-*
      config.log
    ))
  },
);

WriteMakefile(%WriteMakefileArgs);
