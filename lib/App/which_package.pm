package App::which_package;

use strict;
use warnings;
use Alien::Packages;
use Path::Class qw( file dir );
use Text::Table;
use File::Which qw( which );

# ABSTRACT: Determine which package installed a file
our $VERSION = '0.05'; # VERSION

my $ap = Alien::Packages->new;

sub main
{
  my($class, @files) = @_;
  
  unless(@files > 0)
  {
    say STDERR "usage: which_package /path/to/file";
    return 1;
  }
  
  my $table = Text::Table->new(qw( file package type ));
  
  my %owners = $ap->list_fileowners(
    map { $_->absolute } 
    map { -d $_ ? dir($_) : file($_) } 
    map { -e $_ ? $_ : which($_) }
    @files
  );

  my $count = 0;
  
  foreach my $file (sort keys %owners)
  {
    foreach my $package (sort { $a->{Package} cmp $b->{Package} } @{ $owners{$file} })
    {
      $table->add($file, $package->{Package}, $package->{PkgType});
      $count++;
    }
  }
  
  if($count > 0)
  {
    print $table;
    return 0;
  }
  else
  {
    return 2;
  }
}

1;

__END__

=pod

=head1 NAME

App::which_package - Determine which package installed a file

=head1 VERSION

version 0.05

=head1 AUTHOR

Graham Ollis <plicease@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
