package Module::Build::FFI::Fortran;

use strict;
use warnings;
use base qw( Module::Build::FFI );

our $VERSION = '0.01';

=head1 NAME

Module::Build::FFI::Fortran - Build Perl extensions in Fortran with FFI

=head1 DESCRIPTION

L<Module::Build::FFI> variant for writing Perl extensions in Fortran with
FFI (sans XS).

=head1 BASE CLASS

All methods, properties and actions are inherited from:

L<Module::Build::FFI>

=head1 METHODS

=head2 ffi_have_compiler

 my $has_compiler = $mb->ffi_have_compiler;

Returns true if Fortran is available.

=cut

sub ffi_have_compiler
{
  my($self) = @_;
}

=head2 ffi_build_dynamic_lib

 my $dll_path = $mb->ffi_build_dynamic_lib($src_dir, $name, $target_dir);
 my $dll_path = $mb->ffi_build_dynamic_lib($src_dir, $name);

Works just like the version in the base class, except builds Fortran
sources.

=cut

sub ffi_build_dynamic_lib
{
  my($self, $src_dir, $name, $target_dir) = @_;
}

sub _f77_config
{
  require FFI::Platypus::Lang::Fortran::ConfigData;
  FFI::Platypus::Lang::Fortran::ConfigData->config('f77');
}

1;

__END__

=head1 EXAMPLES

TODO

=head1 SEE ALSO

=item L<FFI::Platypus>

The Core Platypus documentation.

=item L<Module::Build::FFI>

General MB class for FFI / Platypus.

=back

=head1 AUTHOR

Graham Ollis E<lt>plicease@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

