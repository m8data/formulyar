#!/usr/bin/perl -w

use strict;
use warnings;
use CGI qw(:all);
BEGIN {
   if ($^O eq 'MSWin32'){
      require Win32::Symlink;
      Win32::Symlink->import();
   }
}
my $disk = '';
$disk = "C:" if $^O eq 'MSWin32';
my @path = split '/', $ENV{'DOCUMENT_ROOT'};
my $path = join( '/', splice( @path, 1, -3 ) );
-d $ENV{'DOCUMENT_ROOT'}.'/formulyar' || symlink( $disk.'/'.$path.'/root/develop/formulyar' => $ENV{'DOCUMENT_ROOT'}.'/formulyar' );
print CGI->new()->header( -location => '/' );
#print CGI->new()->header(  );
#print $path;
#exit;