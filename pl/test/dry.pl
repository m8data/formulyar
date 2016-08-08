#!/strawberry/perl/bin/perl

use CGI qw(:all);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

my $comand = 'perl.exe M:\system\reg.pl scontrol  2>m:\_log\error.txt';
my $file = "M:/_log/sec.txt";
#my $tempFile = '/m8/system/temp.xml';
my $sec = 1;
if ( param('sec') !=0 ){
	while (-e $file){
		open (FILE, $file)|| die "Error opening file $file: $!\n"; 
			$sec = <FILE>;
		close (FILE);
		system ( $comand );	
		sleep $sec;
	}
}
else{
	system ( $comand );#>/dev/null
	sleep $sec;
}


my $cgi = CGI->new();
$cgi->charset('utf-8');
print $cgi->header( -type => 'text/xml');
print '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="/control/a/control.xsl" type="text/xsl"?>
<temp/>';

#open (FILE, $tempFile )|| die "Error opening file $tempFile: $!\n"; 
#	while (<FILE>){
#		print $_;
#	}
#close (FILE);

#print '<body>OK</body>';
#print $cgi->header( -location => $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.'/m8/system/temp.xml' ); #
exit;