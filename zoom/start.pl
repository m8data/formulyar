#!/usr/bin/perl -w

use strict;
use warnings;
use CGI qw(:all);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); #идет в составе CGI
BEGIN {
   if ($^O eq 'MSWin32'){
      require Win32::Symlink;
      Win32::Symlink->import();
   }
}
my $disk = '';
$disk = "C:" if $^O eq 'MSWin32';
my @path = split '/', $ENV{'DOCUMENT_ROOT'};
my @work = splice( @path, 1, -3 );
my $path = join '/', @work;

my $target = param('u');
#my $planeRoot = $disk.'/'.$path.'/.public/'.$target.'/zoom';
my $from = $disk.'/'.$path.'/.public/'.$target.'/zoom/formulyar';
my $to = $disk.'/'.$path.'/.public/'.$path[2];

#-d $planeRoot || mkdir $planeRoot;
-d $from || symlink( $to => $from );
#
if (1){
	print CGI->new()->header( -location => 'http://'.$target.'.m8data.'.param('d') );
}
else {
	print CGI->new()->header(  );
	print $from;
	print '<br/>';
	print $to
}
#exit;