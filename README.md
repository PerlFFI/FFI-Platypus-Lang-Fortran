# FFI::Platypus::Lang::Fortran ![static](https://github.com/PerlFFI/FFI-Platypus-Lang-Fortran/workflows/static/badge.svg) ![linux](https://github.com/PerlFFI/FFI-Platypus-Lang-Fortran/workflows/linux/badge.svg)

FFI::Platypus::Lang::Fortran

# SYNOPSIS

Fortran:

```
   FUNCTION ADD(IA, IB)
       ADD = IA + IB
   END
```

Perl:

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => './add.so',
);

$ffi->attach( add => ['integer*','integer*'] => 'integer');

print add(\1,\2), "\n";
```

# DESCRIPTION

This module provides native types and demangling for Fortran when used
with [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus).

This module is somewhat experimental.  It is also available for adoption
for anyone either sufficiently knowledgeable about Fortran or eager enough to
learn enough about Fortran.  If you are interested, please send me a pull
request or two on the project's GitHub.

For types, `_` is used instead of `*`, so use `integer_4` instead of
`integer*4`.

- byte, character
- integer, integer\_1, integer\_2, integer\_4, integer\_8
- unsigned, unsigned\_1, unsigned\_2, unsigned\_4, unsigned\_8
- logical, logical\_1, logical\_2, logical\_4, logical\_8
- real, real\_4, real\_8, double precision

# EXAMPLES

## Passing and Returning Integers

### Fortran

```
   FUNCTION ADD(IA, IB)
       ADD = IA + IB
   END
```

### Perl

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => './add.so',
);

$ffi->attach( add => ['integer*','integer*'] => 'integer');

print add(\1,\2), "\n";
```

### Execute

```
$ gfortran -shared add.f -o add.so
$ perl add.pl
3
```

### Discussion

In Fortran 77 variables that start with the letter I are integers
unless declared otherwise.  Fortran is also pass by reference, which
means that under the covers Fortran passes its arguments as pointers
to the data, and you have to remember to pass in a reference to a
value from Perl.

Here we are building our own Fortran dynamic library using the GNU
Fortran compiler on a Unix like platform.  The exact incantation that
you will use to do this will unfortunately depend on your platform
and Fortran compiler.

## Calling a subroutine

### Fortran

```
   SUBROUTINE ADD(IRESULT, IA, IB)
       IRESULT = IA + IB
   END
```

### Perl

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => './sub.so',
);

$ffi->attach( add => ['integer*','integer*','integer*'] );

my $value = 0;
add(\$value, \1, \2);

print "$value\n";
```

### Execute

```perl
$ gfortran -shared sub.f -o sub.so
$ perl sub.pl
3
```

### Discussion

A Fortran "subroutine" is just a function that doesn't return a value.
This example is similar to the previous and uses the same addition
operation, but it returns the value in an argument instead of as the
result of a function.

## Calling recursive Fortran 90 / 95 Functions

### Fortran

```
recursive function fib(x) result(ret)
  integer, intent(in) :: x
  integer :: ret
  
  if (x == 1 .or. x == 2) then
    ret = 1
  else
    ret = fib(x-1) + fib(x-2)
  end if

end function fib
```

### Perl

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang =>'Fortran',
  lib  => './fib.so',
);

$ffi->attach( fib => ['integer*'] => 'integer' );

for(1..10)
{
  print fib(\$_), "\n";
}
```

### Execute

```
$ gfortran -shared fib.f90 -o fib.so
$ perl fib.pl
1
1
2
3
5
8
13
21
34
55
```

### Discussion

If you have a newer Fortran compiler that understands Fortran 90 or 95,
you can take advantage of its advanced features like recursion and
pointers.  In this example we compute 10 Fibonacci numbers.

## Complex numbers

### Fortran

```perl
subroutine complex_decompose(c, r, i) 
  implicit none
  complex*16, intent(in) :: c
  real*8, intent(out):: r
  real*8, intent(out) :: i
  
  r = real(c)
  i = aimag(c)
end subroutine complex_decompose
```

### Perl

```perl
use FFI::Platypus 2.00;
use Math::Complex;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => './complex.so',
);

$ffi->attach( complex_decompose => ['complex_16*','real_8*','real_8*'] );

complex_decompose( \(1.5 + 2.5*i), \my $r, \my $i);

print "${r} + ${i}i\n";
```

### Execute

```
$gfortran -shared complex.f90 -o complex.so
$ perl complex.pl
1.5 + 2.5i
```

### Discussion

Platypus now supports complex types of various sizes.  This means that
you can transparently use complex arguments and arrays of complex types.

## Arrays

### Fortran

```perl
subroutine print_array10(a)
  implicit none
  integer, dimension(10) :: a
  integer :: i
  
  do i=1,10
    print *, a(i)
  end do
  
end subroutine print_array10
```

### Perl

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => 'array.so',
);

$ffi->attach( print_array10  => ['integer[10]'] => 'void' );

my $array = [5,10,15,20,25,30,35,40,45,50];

print_array10($array);
```

### Execute

```
$ gfortran -shared array.f90 -o array.so
$ perl array.pl
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
```

### Discussion

In Fortran arrays are 1 indexed unlike Perl and C where arrays are 0 indexed.
Perl arrays are passed in from Perl using Platypus as a array reference.

## Multidimensional Arrays

### Fortran

```perl
subroutine print_array2x5(a)
  implicit none
  integer, dimension(2,5) :: a
  integer :: i,n
  
  do i=1,5
    print *, a(1,i), a(2,i)
  end do

end subroutine print_array2x5
```

### Perl

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => 'array2d.so',
);

$ffi->attach( print_array2x5 => ['integer[10]'] => 'void' );

my $array = [5,10,15,20,25,30,35,40,45,50];

print_array2x5($array);
```

### Execute

```
$ gfortran -shared array2d.f90 -o array2d.so
$ perl array2d.pl
           5          10
          15          20
          25          30
          35          40
          45          50
```

### Discussion

Perl does not generally support multi-dimensional arrays (though they
can be achieved using lists of references).  In Fortran, multidimensional
arrays are stored as a contiguous series of bytes, so you can pass in a
single dimensional array to a Fortran function or subroutine assuming
it has sufficient number of values.

Platypus updates any values that have been changed by Fortran when the
Fortran code returns.

One thing to keep in mind is that Fortran arrays are "column-first",
which is the opposite of C/C++, which could be termed "row-first".

## Variable-length array

### Fortran

```
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
```

### Perl

```perl
use FFI::Platypus 2.00;

my $ffi = FFI::Platypus->new(
  api  => 2,
  lang => 'Fortran',
  lib  => './var_array.so',
);

$ffi->attach( sum_array => ['integer*','integer[]'] => 'integer',
  sub {
    my $f = shift;
    my $size = scalar @_;
    $f->(\$size, \@_);
  }
);

my @a = (1..10);
my @b = (25..30);

print sum_array(@a), "\n";
print sum_array(@b), "\n";
```

### Execute

```
$ gfortran -shared var_array.f90 -o var_array.so
$ perl var_array.pl
55
165
```

### Discussion

Fortran allows variable-length arrays.  To indicate a variable length
array use the `[]` notation without a length.  Note that this works
for argument types, where Perl knows the length of an array, but it
will not work for return types, where Perl has no way of determining
the size of the returned array (you can probably fake it with an
`opaque` type and a wrapper function though).

# METHODS

Generally you will not use this class directly, instead interacting with
the [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) instance.  However, the public methods used by
Platypus are documented here.

## native\_type\_map

```perl
my $hashref = FFI::Platypus::Lang::Fortran->native_type_map;
```

This returns a hash reference containing the native aliases for
Fortran.  That is the keys are native Fortran types and the values
are libffi native types.

## mangler

```perl
my $mangler = FFI::Platypus::Lang::Fortran->mangler($ffi->libs);
my $c_name = $mangler->($fortran_name);
```

Returns a subroutine reference that will "mangle" Fortran names.

# SUPPORT

If something does not work as advertised, or the way that you think it
should, or if you have a feature request, please open an issue on this
project's GitHub issue tracker:

[https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues](https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues)

# CONTRIBUTING

If you have implemented a new feature or fixed a bug then you may make a
pull request on this project's GitHub repository:

[https://github.com/plicease/FFI-Platypus-Lang-Fortran/pulls](https://github.com/plicease/FFI-Platypus-Lang-Fortran/pulls)

Also Feel free to use the issue tracker:

[https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues](https://github.com/plicease/FFI-Platypus-Lang-Fortran/issues)

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

# CAVEATS

Fortran is pass by reference, which means that you need to pass pointers.
Confusingly Platypus uses a star (`*`) suffix to indicate a pointer, and
Fortran uses a star to indicate the size of types.

# SEE ALSO

- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)

    The Core Platypus documentation.

- [FFI::Build](https://metacpan.org/pod/FFI::Build) + [FFI::Build::File::Fortran](https://metacpan.org/pod/FFI::Build::File::Fortran)

    Bundle Fortran with your FFI / Perl extension.

# AUTHOR

Author: Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015-2022 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
