#!/strawberry/perl/bin/perl -w
#!/usr/bin/perl -w

use CGI qw(:all);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use XML::LibXML;
use XML::LibXML::PrettyPrint;
use XML::LibXSLT;
use strict;
use Cwd;
use File::Path qw(make_path rmtree);
use File::Copy qw(copy move);
use File::Find::Rule;
use Encode 'encode', 'decode';
use Digest::MurmurHash3 qw( murmur128_x64 );
use JSON;
use XML::XML2JSON;
use Win32::Symlink;
use utf8;
#binmode(STDOUT, ":encoding(UTF-8)");
#my $dir = '/m8/ыыы';
#my $file = '/m8/ыыы/value.txt'
if (0 and param('make')){
	my $name = param('make');
	my $dir = '/m8/'.$name;
	my $file = $dir.'/value.txt';
	my $dir2 = Encode::encode('cp1251', Encode::decode('utf8', $dir));
	my $file2 = $dir2.'/value.txt';
	make_path $dir2;
	if (0){
	open (FILE, '>'.$file2)|| die "Error opening file $file2: $!\n";
			#print FILE Encode::decode('utf8', $text) if $text;
			print FILE $name;
			print FILE "\n";
			print FILE Encode::decode_utf8($name);
			print FILE "\n";
			print FILE Encode::decode('utf8', $name);
			print FILE "\n";
			print FILE Encode::encode('utf8', Encode::decode_utf8($name) );			
			print FILE "\n";
			print FILE Encode::encode('cp1251', Encode::decode('utf8', $name));
	close (FILE);
	}
	#&setFile( undef, '/m8/test.txt', $name );
	$name = Encode::decode_utf8($name);
	&setFile( undef, '/m8/test.txt', ( join "\n", ( undef, $name, 'я2', 'ss' ) ) );
	#my @text = &getFile ('/m8/test.txt');
	my @text = &getFile ('/m8/base/t3938350261774388780/value.txt');
	my %test;
	for (0..$#text){
		$test{$text[$_]}= Encode::decode_utf8($text[$_]);
	}
	#$test{'ss'} = $text;
	&setData (undef, '/m8/test', \%test);
	$name = &utfText($name);
		my $cgi = CGI->new();
		print $cgi->header(-type => 'text/html' );
		$cgi->charset('utf-8');
		print '<html><head><meta charset="utf-8"/></head><body>';
		print "@text";
		print '<br/>';
		print Encode::encode('utf8', $name );	
		print '<br/>';
		print Encode::decode_utf8($name);
		print '</body></html>';
}
elsif (param('del')){
	my $name = param('del');
	my $dir = '/m8/'.$name;
	$dir = Encode::encode('cp1251', Encode::decode('utf8', $dir));
	my $file = $dir.'/value.txt';
	open (FILE, $file)|| die "Error opening file $file: $!\n";
		my $sfile = <FILE>;
	close (FILE);
	$sfile = Encode::encode('cp1251', Encode::decode('utf8', $sfile));
	unlink $sfile
}
#$dir = Encode::encode('cp1251', Encode::decode('utf8', $dir));
#make_path $dir;

my $cgi = CGI->new();
		print $cgi->header(-type => 'text/html' );
		$cgi->charset('utf-8');
		print '<html><head><meta charset="utf-8"/></head><body>';
		print "ss";
		print '</body></html>';

sub setFile {
	my ( $unreal, $file, $text, $add)=@_;
	#&setWarn( "						sF @_" );
	#$dbg || $unreal || return;
	#return if $unreal == 2;
	#$file = Encode::encode('cp1251', $file);
	chomp $text;
	my @path = split '/', $file;
	my $fileName = pop @path;
		my $dir = join '/', @path;
		$dir = Encode::encode('cp1251', $dir);
		$fileName = Encode::encode('cp1251', $fileName);
		-d $dir || make_path $dir;
		my $mode = '>';
		$mode = '>'.$mode if $add;
		open (FILE, $mode, $dir.'/'.$fileName)|| die "Error opening file $dir/$fileName: $!\n";
			print FILE $text if $text;
			print FILE "\n" if $add;
		close (FILE);
	return $text; #обязательно нужно что-то возвращать, т.к. иногда функция вызывается в контексте and
}

sub getFile {
	#my $file = Encode::encode('cp1251', Encode::decode_utf8($_[0]));
	my $file = $_[0];
	-e $file || return;
	my @text;
	open (FILE, $file)|| die "Error opening file $file: $!\n"; 
		while (<FILE>){
			chomp;
			push @text, Encode::decode_utf8($_);
			#push @text, $_;
		}
	close (FILE);
	if ( $text[1] ){ return @text }
	else { 
		$text[0]=~s!^<c.*>(.+)</c>$!$1!;
		return $text[0]
	}
}
sub getFile2 {
	#my $file = Encode::encode('cp1251', Encode::decode_utf8($_[0]));
	my $file = $_[0];
	open (FILE, $file)|| die "Error opening file $file: $!\n";
		$_ = <FILE>;
		chomp;
	close (FILE);
	my $sfile = Encode::decode('utf8', $_);
	return $sfile;
}
sub utfText {
	my ( $value, $utf ) = @_;
	$value =~ tr/+/ /;
	$value =~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge;# if $utf
	#$value = Encode::decode ( 'UTF8', $value ) if $utf;
	#$value = Encode::decode_utf8($value) if $utf;
	return $value
}
sub setData {
	my ( $unreal, $file, $data ) = @_;
	#$data = Encode::decode_utf8($data);
	my $JSON = JSON->new->utf8->encode($data);
	#my $JSON = JSON->new->encode($data);
	#$JSON = Encode::decode('utf8', $JSON);
	#$JSON = &utfText($JSON);
	return &setFile( $unreal, $file.'.json', $JSON );
}