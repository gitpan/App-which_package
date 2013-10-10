use strict;
use warnings;
use Alien::Packages;
use Test::More;
use App::which_package;
use File::Temp qw( tempdir );
use Capture::Tiny qw( capture );
use Path::Class qw( file dir );

BEGIN {
  my %perl = Alien::Packages->new->list_fileowners("/usr/bin/perl");
  if($perl{"/usr/bin/perl"})
  { plan tests => 4 }
  else
  { plan skip_all => "requires perl system package" }
};

my $out = capture sub {
  is(App::which_package->main("/usr/bin/perl"), 0, "found package for /usr/bin/perl");
};

like $out, qr{/usr/bin/perl}, "/usr/bin/perl in output";

note $out;

my $dir = dir( tempdir( CLEANUP => 1 ) );

$dir->file("bogus.txt")->spew("hi there");

$out = capture sub {
  is(App::which_package->main($dir->file("bogus.txt")), 2, "no package");
};

is $out, '', "empty output";
note $out;
