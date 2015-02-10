package FFI::Platypus::Lang::Fortran;

use strict;
use warnings;
use FFI::Platypus::Lang::Fortran::ConfigData;

our $VERSION = '0.01';

=head1 NAME

FFI::Platypus::Lang::Fortran - Documentation and tools for using Platypus with
Fortran

=head1 SYNOPSIS

Fortran:

 C Fortran function that adds two number together
 C On Linux create a .so with: gfortran -shared -o libadd.so add.f
       FUNCTION ADD(IA, IB)
           ADD = IA + IB
       END

Perl:

 use FFI::Platypus;
 $ffi->lang('Fortran');
 $ffi->lib('./libadd.so'); # or add.dll on Windows
 
 # Fortran is pass by reference, so use pointers
 $ffi->attach( add => [ 'integer*', 'integer*' ] => 'integer' );
 
 # Use a reference to an integer to pass
 # a pointer to an integer
 print add(\1,\2), "\n";  # prints 3

=head1 DESCRIPTION

This module provides native types and demangling for Fortran when
used with L<FFI::Platypus>.

This module is somewhat experimental.  It is also available for adoption
for anyone either sufficiently knowledgable about Fortran or eager enough to
learn enough about Fortran.  If you are interested, please send me a pull
request or two on the project's GitHub.

For types, C<_> is used instead of C<*>, so use C<integer_4> instead of
C<integer*4>.

=over 4

=item byte, character

=item integer, integer_1, integer_2, integer_4, integer_8

=item unsigned, unsigned_1, unsigned_2, unsigned_4, unsigned_8

=item logical, logical_1, logical_2, logical_4, logical_8

=item real, real_4, real_8, double precision

=back

=head1 CAVEATS

Fortran is pass by reference, which means that you need to pass pointers.
Confusingly Platypus uses a star (C<*>) suffix to indicate a pointer, and
Fortran uses a star to indicate the size of types.

Right now this module depends on L<ExtUtils::F77>, which has a less than
stellar record on cpantesters, and is Fortran 77 centric, although it
should work with Fortran 90+ on platforms where both Fortran 77 and
newer Fortrans are invoked with the same command, such as those that use
Gnu Fortran.

=head1 METHODS

Generally you will not use this class directly, instead interacting with
the L<FFI::Platypus> instance.  However, the public methods used by
Platypus are documented here.

=head2 native_type_map

 my $hashref = FFI::Platypus::Lang::Fortran->native_type_map;

This returns a hash reference containing the native aliases for
Fortran.  That is the keys are native Fortran types and the values
are libffi native types.

=cut

sub native_type_map
{
  FFI::Platypus::Lang::Fortran::ConfigData->config('type');
}

=head2 mangler

 my $mangler = FFI::Platypus::Lang::Fortran->mangler($ffi->libs);
 my $c_name = $mangler->($fortran_name);

Returns a subroutine reference that will "mangle" Fortran names.

=cut

sub mangler
{
  my($class, @libs) = @_;
  
  FFI::Platypus::Lang::Fortran::ConfigData->config('f77')->{'trailing_underscore'}
  ? sub { return "$_[0]_" }
  : sub { $_[0] };
}

=head1 EXAMPLES

TODO

=head1 SUPPORT

If something does not work as advertised, or the way that you think it
should, or if you have a feature request, please open an issue on this
project's GitHub issue tracker:

L<https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues>

=head1 CONTRIBUTING

If you have implemented a new feature or fixed a bug then you may make a
pull reequest on this project's GitHub repository:

L<https://github.com/plicease/FFI-Platypus-Lang-Fortran/pulls>

Also Feel free to use the issue tracker:

L<https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues>

This project's GitHub issue tracker listed above is not Write-Only.  If
you want to contribute then feel free to browse through the existing
issues and see if there is something you feel you might be good at and
take a whack at the problem.  I frequently open issues myself that I
hope will be accomplished by someone in the future but do not have time
to immediately implement myself.

Another good area to help out in is documentation.  I try to make sure
that there is good document coverage, that is there should be
documentation describing all the public features and warnings about
common pitfalls, but an outsider's or alternate view point on such
things would be welcome; if you see something confusing or lacks
sufficient detail I encourage documentation only pull requests to
improve things.

Caution: if you do this too frequently I may nominate you as the new
maintainer.  Extreme caution: if you like that sort of thing.

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

The Core Platypus documentation.

=item L<Module::Build::FFI::Fortran>

Bundle Fortran with your FFI / Perl extension.

=back

=head1 AUTHOR

Graham Ollis E<lt>plicease@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

