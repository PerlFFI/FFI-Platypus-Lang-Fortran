package FFI::Platypus::Lang::Fortran;

use strict;
use warnings;
use File::ShareDir::Dist qw( dist_config );

# ABSTRACT: FFI::Platypus::Lang::Fortran
# VERSION

my $config = dist_config 'FFI-Platypus-Lang-Fortran';

sub native_type_map
{
  $config->{'type'};
}

sub mangler
{
  my($class, @libs) = @_;

  $config->{'f77'}->{'trailing_underscore'}
  ? sub { return "$_[0]_" }
  : sub { $_[0] };
}

1;

=head1 SYNOPSIS

Fortran:

# EXAMPLE: examples/add.f

Perl:

# EXAMPLE: examples/add.pl

=head1 DESCRIPTION

This module provides native types and demangling for Fortran when used
with L<FFI::Platypus>.

This module is somewhat experimental.  It is also available for adoption
for anyone either sufficiently knowledgeable about Fortran or eager enough to
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

=head1 EXAMPLES

=head2 Passing and Returning Integers

=head3 Fortran

# EXAMPLE: examples/add.f

=head3 Perl

# EXAMPLE: examples/add.pl

=head3 Execute

 $ gfortran -shared add.f -o add.so
 $ perl add.pl
 3

=head3 Discussion

In Fortran 77 variables that start with the letter I are integers
unless declared otherwise.  Fortran is also pass by reference, which
means that under the covers Fortran passes its arguments as pointers
to the data, and you have to remember to pass in a reference to a
value from Perl.

Here we are building our own Fortran dynamic library using the GNU
Fortran compiler on a Unix like platform.  The exact incantation that
you will use to do this will unfortunately depend on your platform
and Fortran compiler.

=head2 Calling a subroutine

=head3 Fortran

# EXAMPLE: examples/sub.f

=head3 Perl

# EXAMPLE: examples/sub.pl

=head3 Execute

 $ gfortran -shared sub.f -o sub.so
 $ perl sub.pl 
 3

=head3 Discussion

A Fortran "subroutine" is just a function that doesn't return a value.
This example is similar to the previous and uses the same addition
operation, but it returns the value in an argument instead of as the
result of a function.

=head2 Call Fortran 90 / 95

Fortran:

 ! on Linux: gfortran -shared -fPIC -o libfib.so fib.f90
 
 recursive function fib(x) result(ret)
   integer, intent(in) :: x
   integer :: ret
 
   if (x == 1 .or. x == 2) then
     ret = 1
   else
     ret = fib(x-1) + fib(x-2)
   end if
 
 end function fib

Perl:

 use FFI::Platypus 2.00;
 
 my $ffi = FFI::Platypus->new( api => 2 );
 $ffi->lang('Fortran');
 $ffi->lib('./libfib.so');
 
 $ffi->attach( fib => ['integer*'] => 'integer' );
 
 for(1..10)
 {
   print fib(\$_), "\n";
 }

B<Discussion>: Fortran 90 has "advanced" features such as recursion and
pointers, which can now be used in Perl too.

=head2 Complex numbers

Fortran:

 ! on Linux: gfortran -shared -fPIC -o libcomplex.so complex.f90
 
 subroutine complex_decompose(c,r,i)
   implicit none
   complex*16 :: c
   real*8 :: r
   real*8 :: i
 
   r = real(c)
   i = aimag(c)
 
 end subroutine complex_decompose

Perl:

 use FFI::Platypus 2.00;
 use Math::Complex;
 
 my $ffi = FFI::Platypus->new( api => 2 );
 $ffi->lang('Fortran');
 $ffi->lib('./libcomplex.so');
 
 $ffi->attach(
   complex_decompose => ['real_8[2]','real_8*','real_8*'] => 'void',
   sub {
     # wrapper around the Fortran function complex_decompose
     # $decompose is a code ref to the real complex_decompose
     # and $complex is the first argument passed int othe Perl
     # function complex_decompose
     my($decompose, $complex) = @_;
     my $real;
     my $imaginary;
     # decompose the Perl complex number and pass it as a
     # Fortran complex number
     $decompose->([Re($complex),Im($complex)], \$real, \$imaginary);
     # The decomposed real and imaginary parts are returned from
     # Fortran.  We pass them back to the caller as a return value
     ($real, $imaginary);
   },
 );
 
 my($r,$i) = complex_decompose(1.5 + 2.5*i);
 
 print "${r} + ${i}i\n";

B<Discussion>: More recent versions of C<libffi> and L<FFI::Platypus>
support complex types, but not pointers to complex types, so they
aren't (yet) much use when calling Fortran, which is pass by reference.
There is a work  around, however, at least for complex types passes as
arguments.  They are really two just two C<real*4> or C<real*8> types
joined together like an array or record of two elements.  Thus we can
pass in a complex type to a Fortran subroutine as an array of two
floating points.  Take  care though, as this technique DOES NOT work
for return types.

From my research, some Fortran compilers pass in the return address of
the return value as the first argument for functions that return a
C<complex> type.  This is not the case for GNU Fortran, the compiler
that I have been testing with, but if your compiler does use this
convention you could pass in the "return value" as a two element array,
as we did in the above example.  I have not been able to test this
though.

=head2 Fixed length array

Fortran:

 ! on Linux: gfortran -shared -fPIC -o libfixed.so fixed.f90
 
 subroutine print_array10(a)
   implicit none
   integer, dimension(10) :: a
   integer :: i
   do i=1,10
     print *, a(i)
   end do
 end subroutine print_array10

Perl:

 use FFI::Platypus 2.00;
 
 my $ffi = FFI::Platypus->new( api => 2 );
 $ffi->lang('Fortran');
 $ffi->lib('./libfixed.so');
 
 $ffi->attach( print_array10  => ['integer[10]'] => 'void' );
 my $array = [5,10,15,20,25,30,35,40,45,50];
 print_array10($array);

Output:

            5
           10
           15
           20
           25
           30
           35
           40
           45
           50

B<Discussion>: In Fortran arrays are 1 indexed unlike Perl and C where
arrays are 0 indexed.  Perl arrays are passed in from Perl using
Platypus as a array reference.

=head2 Multidimensional arrays

Fortran:

 ! On Linux gfortran -shared -fPIC -o libfixed2.so fixed2.f90
 
 subroutine print_array2x5(a)
   implicit none
   integer, dimension(2,5) :: a
   integer :: i,n
 
   do i=1,5
     print *, a(1,i), a(2,i)
   end do
 end subroutine print_array2x5

Perl:

 use FFI::Platypus 2.00;
 
 my $ffi = FFI::Platypus->new( api => 2 );
 $ffi->lang('Fortran');
 $ffi->lib('./libfixed.so');
 
 $ffi->attach( print_array2x5 => ['integer[10]'] => 'void' );
 my $array = [5,10,15,20,25,30,35,40,45,50];
 print_array2x5($array);

Output:

            5          10
           15          20
           25          30
           35          40
           45          50

B<Discussion>: Perl does not generally support multi-dimensional arrays
(though they can be achieved using lists of references).  In Fortran,
multidimensional arrays are stored as a contiguous series of bytes, so
you can pass in a single dimensional array to a Fortran function or
subroutine assuming it has sufficient number of values.

Platypus updates any values that have been changed by Fortran when the
Fortran code returns.

One thing to keep in mind is that Fortran arrays are "column-first",
which is the opposite of C/C++, which could be termed "row-first".

=head2 Variable-length array

Fortran:

 ! On Linux gfortran -shared -fPIC -o libvar.so var.f90
 
 function sum_array(size,a) result(ret)
   implicit none
   integer :: size
   integer, dimension(size) :: a
   integer :: i
   integer :: ret
 
   ret = 0
 
   do i=1,size
     ret = ret + a(i)
   end do
 end function sum_array

Perl:

 use FFI::Platypus 2.00;
 
 my $ffi = FFI::Platypus->new( api => 2 );
 $ffi->lang("Fortran");
 $ffi->lib("./libvar_array.so");
 
 $ffi->attach( sum_array => ['integer*','integer[]'] => 'integer',
   sub {
     my $f = shift;
     my $size = scalar @_;
     $f->(\$size, \@_);
   },
 );
 
 my @a = (1..10);
 my @b = (25..30);
 
 print sum_array(1..10), "\n";
 print sum_array(25..30), "\n";

Output:

 55
 165

B<Discussion>: Fortran allows variable-length arrays.  To indicate a
variable length array use the C<[]> notation without a length.  Note
that this works for argument types, where Perl knows the length of an
array, but it will not work for return types, where Perl has no way of
determining the size of the returned array (you can probably fake it
with an C<opaque> type and a wrapper function though).

=head1 METHODS

Generally you will not use this class directly, instead interacting with
the L<FFI::Platypus> instance.  However, the public methods used by
Platypus are documented here.

=head2 native_type_map

 my $hashref = FFI::Platypus::Lang::Fortran->native_type_map;

This returns a hash reference containing the native aliases for
Fortran.  That is the keys are native Fortran types and the values
are libffi native types.

=head2 mangler

 my $mangler = FFI::Platypus::Lang::Fortran->mangler($ffi->libs);
 my $c_name = $mangler->($fortran_name);

Returns a subroutine reference that will "mangle" Fortran names.

=head1 SUPPORT

If something does not work as advertised, or the way that you think it
should, or if you have a feature request, please open an issue on this
project's GitHub issue tracker:

L<https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues>

=head1 CONTRIBUTING

If you have implemented a new feature or fixed a bug then you may make a
pull request on this project's GitHub repository:

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

=head1 CAVEATS

Fortran is pass by reference, which means that you need to pass pointers.
Confusingly Platypus uses a star (C<*>) suffix to indicate a pointer, and
Fortran uses a star to indicate the size of types.

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

The Core Platypus documentation.

=item L<FFI::Build> + L<FFI::Build::File::Fortran>

Bundle Fortran with your FFI / Perl extension.

=back

=cut
