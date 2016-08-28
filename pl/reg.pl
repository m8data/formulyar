#!/usr/bin/perl -w


#модули в составе ядра
use strict;
use warnings;
#no warnings 'layer';

use Cwd;
use POSIX qw(strftime);
use File::Path qw(make_path rmtree);
use File::Copy qw(copy move);
use File::Copy::Recursive qw(dircopy);
use File::Find::Rule;
use JSON; #Perl 5.14 been a core module

#инсталлируемые модули 	(perl -MCPAN -e shell)
#use Encode 'encode', 'decode'; #модуль указан как базовый, но ставить себя в 5.22.1.3 все равно просит
use CGI qw(:all); # модуль удален из базовой комплектации начиная с версии 5.22
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); #идет в составе CGI
use XML::LibXML;
use XML::LibXML::PrettyPrint;
use XML::LibXSLT; #идет в составе XML::LibXML
#нет в ubuntu
use Digest::MurmurHash3 qw( murmur128_x64 );
use XML::XML2JSON;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

use Time::HiRes qw( time gettimeofday );#gettimeofday

#установление возможности записывать файлы с правами 777
umask 0;

my $disk = '';
BEGIN {
   if ($^O eq 'MSWin32'){
      require Win32::Symlink;
      Win32::Symlink->import();
   }
}
$disk = "C:" if $^O eq 'MSWin32';

my $guestDaysDefault = 30;
my $userDaysDefault = 60;
my $passwordDefault = 'ryazan2016';
my $guestDaysFile = 'guest_days.txt';
my $userDaysFile = 'user_days.txt';
my $passwordFile = 'password.txt';
my $userConfigDir = 'user';
my $forceDBG = 0;
my $dbg = 0;
my $chmod = 0777;

my $stylesheetDir = 'xsl';
my $defaultAvatar = 'formulyar';
my $defaultAuthor = 'guest';
my $defaultFact = 'n';
my $admin = 'admin';
my $canonicalHomeAvatar = 'formulyar';	
my $tNode = '$t';
my @level = ( 'system', 'prefix', 'fact', 'author', 'quest' );
my @role = (	'triple', 	'role1', 	'role2', 		'role3', 	'author', 'quest', 'target' );
my @number = (	'name',		'subject', 	'predicate',	'object',	'author', 'quest', 'add' );
my @transaction = ( 'REMOTE_ADDR', 'HTTP_USER_AGENT', 'DOCUMENT_ROOT', 'REQUEST_URI', 'QUERY_STRING', 'HTTP_COOKIE', 'REQUEST_METHOD', 'HTTP_X_REQUESTED_WITH' );#, 'HTTP_USER_AGENT', 'HTTP_ACCEPT_LANGUAGE', 'REMOTE_ADDR' $$transaction{'QUERY_STRING'}
my @mainTriple = ( 'n', 'r', 'i' );
my %formatDir = ( '_doc', 1, '_json', 1, '_pdf', 1, '_avatar', 1 );
my @superrole = ( 'triple', 'role', 'role', 'role', 'author', 'quest', 'subject', 'predicate', 'object' );
my @superfile = ( undef, 'port', 'dock', 'terminal' ); 
my $type = 'xml';

my $logDir = '../log';
my $authorPath = 'm8/author';
my $configDir = 'config';
my $sessionDir = $configDir.'/temp_name';
#my $defaultNumberPath = 'guest/tsv/d/n';
my $tempfsFolder = '/mnt/tmpfs/';

my $errorLog = $logDir.'/error_log.txt';
my $logName = 'data_log.txt';
my $log = $logDir.'/'.$logName;
my $log1 = $logDir.'/control_log.txt';
my $guest_log = $logDir.'/guest_log.txt';

my $rootFolder = '/var/www/';
my $rootDir = 'public_html';
my $userDir = 'u';
my $auraDir = 'a';
my $planDir = 'p';
my $indexDir = 'm8';


my $trashPath = $logDir.'/trash';
my $universePath = $configDir.'/universe';

my $ROOT_DIR;
	
my %temp;

my %universe;
%universe = &getHash( $universePath.'.json' ) if -e $universePath.'.json';

my $JSON = JSON->new->utf8;
my $XML2JSON = XML::XML2JSON->new(pretty => 'true');


if ( $ARGV[0] ){
	my $aName = $ARGV[0];
	$ROOT_DIR = $rootFolder.$aName.'/'.$rootDir.'/';
	chdir $ROOT_DIR;
	&setWarn (' Ответ на запрос с локалхоста', $log1);
	
	-d $logDir || make_path( $logDir, { chmod => $chmod } );
	-e $configDir.'/'.$guestDaysFile || &setFile( $configDir.'/'.$guestDaysFile, $guestDaysDefault );
	-e $configDir.'/'.$userDaysFile || &setFile( $configDir.'/'.$userDaysFile, $userDaysDefault );
	#if (not -d $planDir.'/guest/tsv'){
	#	warn '		Make defaultTriple  ';
	-e $planDir.'/guest/tsv/d/n/time.txt' || &setFile( $planDir.'/guest/tsv/d/n/time.txt', '1.1' );
	-e $planDir.'/guest/tsv/d/value.tsv' || &setFile( $planDir.'/guest/tsv/d/value.tsv', ( join "\t", @mainTriple ) );
	-e $planDir.'/guest/tsv/i/value.tsv' || &setFile( $planDir.'/guest/tsv/i/value.tsv' );
	#}
	#-d $defaultNumberPath || make_path( $defaultNumberPath, { chmod => $chmod } );
	if ( not -d 'm8' ){
		warn 'check $tempfsFolder.$aName';
		if ( -d $tempfsFolder.'m8/'.$ARGV[0] ){
			warn 'add '.$tempfsFolder.'m8/'.$ARGV[0];
			make_path( $tempfsFolder.'m8/'.$ARGV[0], { chmod => $chmod } );
			symlink( $disk.$tempfsFolder.'m8/'.$ARGV[0] => $disk.$ROOT_DIR.'m8' )
		}
		else {
			warn 'add '.$ROOT_DIR.'m8';
			make_path( $ROOT_DIR.'m8', { chmod => $chmod } )
		}
	}
	&startProc;
	-d $auraDir || make_path( $auraDir, { chmod => $chmod } );
	-d $auraDir.'/m8' || symlink( $disk.$ROOT_DIR.'m8' => $disk.$ROOT_DIR.$auraDir.'/m8' );
	my @ava = &getDir( $planDir, 1 );
	for my $ava ( @ava ){
		-d $auraDir.'/'.$ava || make_path( $auraDir.'/'.$ava, { chmod => $chmod } );
		-d $auraDir.'/'.$ava.'/m8' || symlink( $disk.$ROOT_DIR.'m8' => $disk.$ROOT_DIR.$auraDir.'/'.$ava.'/m8' );
		-e $userDir.'/'.$ava.'/'.$passwordFile || &setFile( $userDir.'/'.$ava.'/'.$passwordFile, $passwordDefault );
	}	
	for my $format ( keys %formatDir ){
		-d $format || symlink( $disk.$ROOT_DIR.$auraDir => $disk.$ROOT_DIR.$format );
	}
	-d $defaultAvatar || symlink( $disk.$ROOT_DIR.$planDir.'/'.$defaultAvatar => $disk.$ROOT_DIR.$defaultAvatar ); #для возможности авторизации указанием в корне formulyar
	if (0){
	my $tsvPath = $configDir.'/tsv';
	for my $tsvName ( &getDir ( $tsvPath, 1 ) ){ 
		warn '		tsv  '.$tsvName;
		next if $tsvName=~/^u/ or $tsvName=~/^i/;
		my @div = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$tsvName.'/value.tsv' );
		my @val = split "\t", $div[0];
		unshift @val, $tsvName;
		for my $authorName ( &getDir( $tsvPath.'/'.$tsvName, 1 ) ){
			for my $questName ( &getDir( $tsvPath.'/'.$tsvName.'/'.$authorName, 1 ) ){
				print REINDEX "    Исследование квеста $questName \n";
				my ( $timeProc ) = &getFile( $tsvPath.'/'.$tsvName.'/'.$authorName.'/'.$questName.'/time.txt' );
				make_path( $authorName.'/tsv/'.$tsvName.'/'.$questName );
				&setFile ( $authorName.'/tsv/'.$tsvName.'/'.$questName.'/time.txt', $timeProc ); #ss
				copy( $tsvPath.'/'.$tsvName.'/value.tsv', $authorName.'/tsv/'.$tsvName.'/value.tsv' );
				for my $m (1..3){
					next if not $val[$m]=~/i/;
					-d $authorName.'/tsv/'.$val[$m] || make_path( $authorName.'/tsv/'.$val[$m] );
					copy( $tsvPath.'/'.$val[$m].'/value.tsv', $authorName.'/tsv/'.$val[$m].'/value.tsv' )
				}
			}
		}
	}
	}
	if ($ARGV[1]){
		&dryProc2( $ARGV[1] )
	}
	
}
else{
	chdir $ENV{DOCUMENT_ROOT};
	$ROOT_DIR = $ENV{DOCUMENT_ROOT}.'/';
	my $adminMode = $dbg = 1 if $forceDBG or cookie('debug') ne '';
	$temp{'adminMode'} = "true" if $adminMode;
	if (not $adminMode and $ENV{'QUERY_STRING'} ){
		open (FILE, '>>'.$guest_log)|| die "Ошибка при открытии файла $guest_log: $!\n";
			print FILE localtime(time).'	'.$ENV{'REMOTE_ADDR'}.'	'.$ENV{'HTTP_FORWARDED'}.'	'.$ENV{'REQUEST_URI'},  "\n";
		close (FILE);
	}
	&setFile( $logDir.'/env.json', $JSON->encode(\%ENV) ) if $dbg;

	my %cookie;
	my $q = CGI->new();
	if ( $ENV{'REQUEST_URI'} =~m!^/_(pdf)/(\w+)/! or $ENV{'REQUEST_URI'} =~m!^/_(doc)/(\w+)/! or $ENV{'REQUEST_URI'} =~m!^/_(avatar)/(\w+)/! ){
		my ( $format, $value ) = ( $1, $2 ); 
		&setWarn( "  Найден запрос $ENV{'REQUEST_URI'} вывода в особом формате $1 (папка: $2)", $log.'_special.txt' );#	
		my $req = $ENV{'REQUEST_URI'};
		$req =~s!/_$format!!;
		my @request_uri = split /\?/, $req;
		&setWarn( "  перевод на $request_uri[0] (формат: $format)" );#
		$request_uri[0] =~s!^/!!;
		if ( $format eq 'avatar' ){
			if ( $value eq cookie('avatar') ){
				#$value = $q->cookie('debug');
				if ( not cookie('debug') or $q->cookie('debug') eq '' ){ $value = time }
				else { $value = '' }
				$format = 'debug';
			}
			my $cookie = $q->cookie( -name => $format, -expires => '+1y', -value => $value );
			print $q->header( -location => $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.'/'.$auraDir.'/'.$request_uri[0], -cookie => $cookie );
		
		}
		else {		
			if ( $format eq 'pdf' ){
				&setWarn( "   Формирование pdf-файла запросом $ENV{HTTP_HOST}$req&proc=wkhtmltopdf" );#
				system ( 'wkhtmltopdf '.$ENV{HTTP_HOST}.$req.' '.$ROOT_DIR.$request_uri[0].'/report.pdf'.' 2>'.$ROOT_DIR.$logDir.'/wkhtmltopdf.txt' );
				#system ( 'wkhtmltopdf localhost'.$req.' '.$request_uri[0].'/report.pdf'.' 2>/_log/wkhtmltopdf.txt' );
				$temp{'format'} = 'pdf';
			}
			elsif ( $format eq 'doc' ){
				&setWarn( "   Формирование doc-файла" );#
				&initProc( \%temp, \%cookie );
				$temp{'format'} = 'doc';
				
				rmtree $request_uri[0].'/report' if -d $request_uri[0].'/report'; 
				dircopy $value.'/template/report', $request_uri[0].'/report';
				-e $request_uri[0].'/report/_rels/.rels' || copy( $value.'/template/report/_rels/.rels', $request_uri[0].'/report/_rels/.rels' ) || die "Copy for Windows failed: $!";
				my $xmlFile = $ROOT_DIR.$request_uri[0].'temp.xml';
				&setFile( $xmlFile, &getDoc( \%temp ) );
				$temp{'avatar'} = $temp{'tempAvatar'} if defined $temp{'tempAvatar'};
				my $xslFile = $ROOT_DIR.$planDir.'/'.$temp{'avatar'}.'/'.$stylesheetDir.'/'.$temp{'avatar'}.'.xsl';
				my $documentFile = $ROOT_DIR.$request_uri[0].'/report/word/document.xml';
				my $status = system ( 'xsltproc -o '.$documentFile.' '.$xslFile.' '.$xmlFile.' 2>'.$ROOT_DIR.$logDir.'/xsltproc_doc.txt' );#
				&setWarn( "   documntXML: $status" );#
				unlink $request_uri[0].'report.docx' if -e $request_uri[0].'report.docx';
				my $zip = Archive::Zip->new();
				$zip->addTree( $request_uri[0].'/report/' );
				unless ( $zip->writeToFileNamed($request_uri[0].'report.docx') == AZ_OK ) {
					die 'write error';
				}
				$format = 'docx';
			}
			if ($adminMode and 0){
				&setWarn( '   редирект на '.$request_uri[0].'report.'.$format );
				print $q->header(-location => '/'.$request_uri[0].'report.'.$format );
			}
			else {
				&setWarn( '   редирект на '.$ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.'/'.$auraDir.'/'.$request_uri[0].'report.'.$format );
				print $q->header(-location => $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.'/'.$auraDir.'/'.$request_uri[0].'report.'.$format );
			}
		}
	}
	else{
		&setWarn( " Обработка запроса $ENV{REQUEST_URI} для DOCUMENT_ROOT: >$ROOT_DIR< ", $log);#		
		&initProc( \%temp, \%cookie );
		&washProc( \%temp, \%cookie ) if $temp{'REQUEST_METHOD'} eq 'POST' or $temp{'QUERY_STRING'};
		$temp{'fact'} = $temp{'quest'} = $defaultFact if not defined $temp{'fact'};		
		my @cookie;
		for (keys %cookie){	
			&setWarn( "   Добавление куки $_: $cookie{$_}");#		
			push @cookie, $q->cookie( -name => $_, -expires => '+1y', -value => $cookie{$_} ) 
		}	
		if ( 1 and ( not $temp{'QUERY_STRING'} or ( not $temp{'record'} and not defined $temp{'message'} ) or defined $temp{'ajax'} or defined $temp{'wkhtmltopdf'} ) ){ 	#$temp{'QUERY_STRING'} $temp{'record'} or $temp{'QUERY_STRING'}=~/^n1464273764-4704-1/ $ENV{'HTTP_HOST'} eq 'localhost'$ENV{'REMOTE_ADDR'} eq "127.0.0.1" 
			&setWarn('   Вывод в web без редиректа '.$temp{'record'});		
			my $doc = $JSON->encode(\%temp);
			&setFile( $logDir.'/temp.json', $doc ) if $dbg;
			$q->charset('utf-8');
			print $q->header( 
				-type 			=> 'text/'.$temp{'format'}, 
				-cookie 		=> [@cookie],
				-expires		=> 'Sat, 26 Jul 1997 05:00:00 GMT',
				# always modified
				-Last_Modified	=> strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
				# HTTP/1.0
				-Pragma			=> 'no-cache',
				-Note 			=> 'CACHING IS DISABLED IN SCRIPT REG.PL',
				# HTTP/1.1 + IE-specific (pre|post)-check
				-Cache_Control => join(', ', qw(
					private
					no-cache
					no-store
					must-revalidate
					max-age=0
					pre-check=0
					post-check=0
				)),
			);
			if ( $temp{'format'} ne 'json' ){
				&setWarn ('    Вывод в xml-варианте');
				$doc = &getDoc( \%temp );
				if ( $temp{'format'} eq 'html' ){
					&setWarn("     Вывод temp-а под аватаром: $temp{'tempAvatar'}");
					$temp{'avatar'} = $temp{'tempAvatar'} if defined $temp{'tempAvatar'};
					my $xslFile = $planDir.'/'.$temp{'avatar'}.'/'.$stylesheetDir.'/'.$temp{'avatar'}.'.xsl';
					if ( 1 or defined $universe{'serverTranslate'} ){
						&setWarn('      Преобразование на сервере');
						if (0){
							my $xslt = XML::LibXSLT->new();
							my $style_doc = XML::LibXML->load_xml(location=> $xslFile, no_cdata=>1);
							my $stylesheet = $xslt->parse_stylesheet($style_doc); 
							$doc = $stylesheet->transform($doc);
						}
						else {				
							$temp{'time'} =~/(\d\d)$/;
							my $trashTempFile = $logDir.'/trash/'.$1.'.xml';
							&setFile( $trashTempFile, $doc );
							$doc = system ( 'xsltproc '.$ROOT_DIR.$xslFile.' '.$ROOT_DIR.$trashTempFile.' 2>'.$ROOT_DIR.$logDir.'/out.txt' );#
							$doc =~s/(\d*)$//;
							print $1 if $adminMode and $1
						}
					}
				}	
			}
			print $doc;
		}
		else {
			&setWarn( '   Вывод в web c редиректом' );
			copy( $log, $log.'.txt' ) or die "Copy failed: $!" if $dbg; #копировать лог не ниже, т.е. не после возможного редиректа
			my $location = $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST};
			if ( defined $temp{'message'} and $temp{'message'} ne 'OK' ){ $location .= '/'.$auraDir.'/'.$temp{'ctrl'}.'/m8/?error='.$temp{'message'} }
			else { $location .= &m8req( \%temp ).'/' }
			print $q->header( -location => $location, -cookie => [@cookie] )# -status => '201 Created' #куки нужны исключительно для случая указания автора		
		}
		
	}
	
}

exit;

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ФУНКЦИИ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

######### функции первого порядка ##########
sub initProc{
	my ( $temp, $cookie )=@_; 
	&setWarn( "		iP @_" );
	$$temp{'time'} = time;
	( $$temp{'seconds'}, $$temp{'microseconds'} ) = gettimeofday;
	$$temp{'record'} = 0;
	$$temp{'version'} = &getFile( $planDir.'/'.$defaultAvatar.'/version.txt' ) || 'v0';
	for my $param ( @transaction ){	
		&setWarn('		iP  ENV '.$param.': '.$ENV{$param});
		$$temp{$param} = $ENV{$param} 
	}
	foreach my $itm ( split '; ', $$temp{'HTTP_COOKIE'} ){
		&setWarn('		iP  Прием куки '.$itm);
		my ( $name, $value ) = split( '=', $itm );
		if ( $name eq 'user'){
			$$temp{'tempkey'} = $value;
			if ( -e $sessionDir.'/'.$value.'/value.txt' ){ $$temp{'user'} = &getFile( $sessionDir.'/'.$value.'/value.txt' ) }
			else { $$cookie{'user'} = $defaultAuthor }
		}
		elsif ( $name eq 'avatar' ){ 
			if ( -d $value ){ $$temp{$name} = $value }
			else { $$cookie{'avatar'} = &startProc }
		}
		elsif ( $name eq 'debug' ){ $$temp{$name} = $value }
	}
	if ( $$temp{'user'} ){ $$temp{'author'} = $$temp{'user'} }
	else { $$temp{'author'} = $$temp{'user'} = $defaultAuthor }
	if ( $$temp{'avatar'} ){ $$temp{'ctrl'} = $$temp{'avatar'} }
	else { $$cookie{'avatar'} = $$temp{'ctrl'} = $$temp{'avatar'} = &startProc }
	$$temp{'format'} = 'html';
	$$temp{'ajax'} = $$temp{'HTTP_X_REQUESTED_WITH'} if $$temp{'HTTP_X_REQUESTED_WITH'}; 
	$$temp{'wkhtmltopdf'} = 'true' if $temp{'HTTP_USER_AGENT'}=~/ wkhtmltopdf/ or $temp{'HTTP_USER_AGENT'}=~m!Qt/4.6.1!;
	my @request_uri = split /\?/, $$temp{'REQUEST_URI'};
	chop $request_uri[0] if $request_uri[0]=~m!/$!;
	$request_uri[0]=~s!^/!!;
	-d $request_uri[0] || return;
	
	&setWarn( "		iP В пожелании $$temp{'REQUEST_URI'} директория $request_uri[0] действительна. Идет детектирование автора/аватара/квеста" );# стирка 	
	$$temp{'path'} = '/'.$request_uri[0];
	my @path = split '/', $request_uri[0];
	if ( @path == 1 and $path[0] ne 'm8' ){ 
		&setWarn( "		iP  Найден запрос системной операции" );#
		$$temp{'quest'} = &utfText($path[1]);
		if ( $$temp{'QUERY_STRING'} =~/^avatar=$/ ){
			&setWarn( "		iP   Смена аватара текущего аватара" );
			if ( -e $planDir.'/'.$$temp{'quest'}.'/'.$stylesheetDir.'/'.$$temp{'quest'}.'.xsl' and -e $planDir.'/'.$$temp{'quest'}.'/'.$stylesheetDir.'/title.txt' ){ $$cookie{'group'} = $$temp{'ctrl'} =  $$temp{'avatar'} = $$temp{'quest'} }
			else {
				&setWarn( "		iP    Обнуление текущего аватара " );
				&startProc;
				$$cookie{'group'} = ''; #$$temp{'avatar'} = 			
			}
		}
		elsif ( -e $planDir.'/'.$$temp{'quest'}.'/'.$stylesheetDir.'/'.$$temp{'quest'}.'.xsl' ){ $$temp{'ctrl'} = $$temp{'tempAvatar'} = $$temp{'quest'} }
		else {$$temp{'ctrl'} =  $$temp{'tempAvatar'} = $canonicalHomeAvatar }
	}
	else{
		&setWarn( "		iP  Не системный запрос" );#
		if ( $path[0] ne 'm8' ){
			$$temp{'format'} = shift @path;
			$$temp{'format'} = 'html' if $$temp{'format'} eq $auraDir;
			$$temp{'ctrl'} = $$temp{'tempAvatar'} = shift @path if $path[0] ne 'm8'; 
		}
		$$temp{'fact'} = $$temp{'quest'} = &utfText($path[2]) if $path[2];
		$$temp{'author'} = $path[3] if $path[3];	
		$$temp{'quest'} = $path[4] if $path[4]
	}
	#$$transaction{'REQUEST_METHOD'} eq 'POST' || $$transaction{'QUERY_STRING'} || return;
	#&setWarn( "		wP Имеется запрос. Идет обработка" );# стирка	
}
	
sub washProc{
	my ( $temp, $cookie ) = @_;
	&setWarn( "		wP @_" );
	my @num;
	if ( $$temp{'REQUEST_METHOD'} eq 'POST' ){
		&setWarn( "		wP  Запись файла" );# 
		my $req = new CGI; 
		my $DownFile = $req->param('file'); 
		$DownFile =~/tsv$/ || $DownFile =~/txt$/ || $DownFile =~/csv$/ || return;
		my @text;			
		while ( <$DownFile> ) { 
			s/\s+\z//;
			push @text, Encode::decode_utf8( $_ )
		}
		$$temp{'fact'} = $defaultFact if not defined $$temp{'fact'};
		$$temp{'quest'} = $defaultFact if not defined $$temp{'quest'};
		my $iName = &setName( 'i', $$temp{'user'}, @text );
		my $trName =  &setName( 'd', $$temp{'user'}, $$temp{'fact'}, 'n', $iName );
		my @val = ( $trName, $$temp{'fact'}, 'n', $iName, $$temp{'user'}, $$temp{'quest'}, 1 );
		push @num, \@val;
	}
	else {
		&setWarn( "		wP  Имеется строка запроса $$temp{'QUERY_STRING'}. Идет идет ее парсинг" );# 
		my %param;
		for my $pair ( split( /&/, $$temp{'QUERY_STRING'}  ) ){
			&setWarn( "		wP   Анализ пары $pair" );	
			my ($name, $value) = split( /=/, $pair );
			next if $name eq 'user';
			$param{$name} = &utfText($value);
			if ( $name eq 'logout' ){ delete $$temp{'user'} }
			elsif ( $name =~/^\w[\d_\-]*$/ ){
				&setWarn( "		wP     Детектирован элемент создания номера" );
				$$temp{'record'} = $$temp{'record'} + 1;
			}
			elsif ( $name =~/^\w+$/ ) { 
				&setWarn( "		wP     Детектирован простой корневой параметр" );
				$$temp{$name} = $param{$name} 
			}
		}	
		#keys %param || return;
		if ( not $$temp{'user'} ){
			&setWarn( "		wP   Найден запрос смены автора" );# 
			#$avatar = $$cookie{'avatar'} = $$temp{'avatar'} = $canonicalHomeAvatar;
			if ( defined $$temp{'login'} or defined $$temp{'new_author'} ){
				&setWarn( "		wP    Процедура авторизации" );# 		
				my %pass;
				for my $pass ( grep { defined $param{$_} } ( 'password', 'new_password', 'new_password2' ) ){ $pass{$pass} = $param{$pass} 	}
				$$temp{'message'} = &parseNew ( $temp, \%pass );
				return if $$temp{'message'};
				$$temp{'fact'} = $$temp{'quest'} = $defaultFact;
				if ( defined $$temp{'new_author'} ){
					&setWarn('		wP    фиксация создания автора '); 
					$$temp{'user'} = $pass{'new_password'};
					$$temp{'author'} = $$temp{'user'} = $$temp{'new_author'};
					my @value = ( 'd', @mainTriple, $$temp{'user'}, $$temp{'quest'}, 1 );
					push @num, \@value;
					my $data = join "\t", @mainTriple;
					&setFile( $$temp{'user'}.'/tsv/d/value.tsv', $data );
					&rinseProc ( 'd', $data)
				}
				else { 
					$$temp{'user'} = $$temp{'author'} = $$temp{'login'} 
				
				}
				my $tempName = 'u';
				$tempName .= murmur128_x64(rand(10000000));
				my %tempkey = &getHash( $configDir.'/'.$$temp{'user'}.'.json' );
				$tempkey{$tempName} = $$temp{'time'};
				&setFile( $configDir.'/'.$$temp{'user'}.'.json', $JSON->encode(\%tempkey) );
				&setFile( $sessionDir.'/'.$tempName.'/value.txt', $$temp{'user'} );
				$$cookie{'user'} = $tempName;
			}
			else { 
				&setWarn( "		wP    Процедура разлогирования" );#
				my $tempKeysFile = $configDir.'/'.$$temp{'author'}.'.json';
				if ( -e $tempKeysFile ){
					&setWarn( "		wP     Удаление временного ключа" );#
					my %tempkey = &getHash( $tempKeysFile );	
					delete $tempkey{$$temp{'tempkey'}};
					if ( keys %tempkey ){ &setFile( $tempKeysFile, $JSON->encode(\%tempkey) ) }
					else { unlink $tempKeysFile } 
				}
				rmtree $sessionDir.'/'.$$temp{'tempkey'} if -d $sessionDir.'/'.$$temp{'tempkey'};
				$$cookie{'user'} = $defaultAuthor 
			}
			$$temp{'message'} = 'OK';
		}
		elsif ( defined $param{'z0'} and $param{'z0'} eq 'd' ){
			&setWarn( "		wP   Найден запрос удаления автора" );
			my @value = ( 'd' );
			push @num, \@value;
			$$cookie{'user'} = $$temp{'author'} = $defaultAuthor
		}
		elsif ( defined $$temp{'control'} ){
			&setWarn ('		wP   Контроль');
			if ( $$temp{'author'} ne $admin ){
				$$temp{'message'} = 'Требуются админские полномочия';
				return
			}
			if ( defined $$temp{'del'} ){
				&setWarn ('		wP    Системное удаление директорий');
				for my $m8subdir ( &getDir( 'm8', 1 ) ){
					&setWarn ("		wP     Анализ директории $m8subdir");
					if ( $$temp{'del'} < 3 ){ 
						&setWarn ("		wP      Анализ базовых директорий");
						if ( $$temp{'del'} > 1 ){
							#for my $dir ( grep { $_ ne 'd' } &getDir ( $tsvPath, 1 ) ){ rmtree( $tsvPath.'/'.$dir ) }
						}
					}
					else { 
						&setWarn ("		wP      Удаление директории $m8subdir");
						if ( $$temp{'del'} == 3 ){ $$cookie{'user'} = $defaultAuthor; $$cookie{'group'} = '' }
					} 
				}
			}
			elsif ( $$temp{'control'} eq 'start'){
				&startProc;
			}
			else {
				&setWarn ('		wP    Работа с глобальными параметрами');
				if ( defined $$temp{'serverTranslate'} ){
					&setWarn ('	  wP   Работа с параметром serverTranslate');
					if ( $$temp{'serverTranslate'} eq '' ){ delete $universe{'serverTranslate'} }
					else { $universe{'serverTranslate'} = 1 }
				}
				if ( defined $$temp{'emulationControl'} ){
					&setWarn ('	  wP   Работа с параметром emulationControl');
					if ( $$temp{'emulationControl'} eq '' ){ delete $universe{'emulationControl'} }
					else { $universe{'emulationControl'} = 1 }
				}
				if ( keys %universe ){
					&setWarn ('		wP   Работа с хэшем universe');
					&setFile( $universePath.'.json', $JSON->encode(\%universe) );
				}			
				elsif (-e $universePath.'.json') {
					unlink $universePath.'.json';
					&getDir ($configDir) || rmdir $configDir
				}
			}
			for (keys %universe){ $$temp{$_} = 1 }
			#$temp{'control'} = param('control');
			#$temp{'avatar'} = 'control' if not param('out');
		}
		elsif ( $$temp{'record'} ) {	
			&setWarn( "		wP   Поиск и проверка номеров в строке запроса $$temp{'QUERY_STRING'}" );# стирка 
			my @value; #массив для контроля повторяющихся значений внутри триплов
			my %table; #таблица перевода с буквы предлложения на номер позиции в процессе
			for my $pair ( split( /&/, $$temp{'QUERY_STRING'}  ) ){
				&setWarn('		wP  парсинг пары >'.$pair.'<');
				my ($name, $value) = split(/=/, $pair);
				next if $name eq 'user' or defined $$temp{$name};
				#$value =~ s/%([a-fA-F0-9]{2})/pack("C", hex($1))/eg;
				my $n = "\n";
				$value =~ s/%0D%0A/$n/eg; #без этой обработки на выходе получаем двойной возврат каретки помимо перевода строки если данные идут из textarea
				#$value =~ s/\s+\z//;
				$value = &utfText($value);
				$value = Encode::decode_utf8($value);# 
				
				
				
				if ( not $value and $value ne '0' ){ 
					&setWarn('		wP     присвоение пустого значения');
					$value = 'r' 
				} #0 - тоже значение
				elsif ( $value=~m!^/m8/(\w)/([1-5])$! and defined $table{$1} and $num[$table{$1}][$2]  ){
					&setWarn('		wP     присвоение значения по ссылке');
					$value = $num[$table{$1}][$2] 
				}
				elsif ( $value=~/^-{0,1}\d{1,15}[,\.]*\d{0,8}$/ ){ 
					&setWarn('		wP     присвоение цифрового значения');
					$value=~tr/[,\.]/_/;
					$value = 'r'.$value 
				}
				elsif ( $value=~m!^/m8/[dirn]/([dirn][\d_\-]*)$! or $value=~m!^([dirn][\d_\-]*)$!  ){ #or ( ( $name =~/^[a-z]+[0-2]$/ or $name eq 'r' ) and $value=~m!^([dirn])$!)
					&setWarn('		wP     оставление значения '.$value.' как есть ('.$1.')');
					$value =  $1 
				}
				else {
					&setWarn('		wP     запрос карты');
					&setWarn('		wP: '.$value );
					my @value = split "\n", $value;
					$value = &setName( 'i', $$temp{'user'}, @value );
					if ( $value[1] and $value[1]=~/^xsd:(\w+)$/ ){
						&setWarn('		wP      запрос создания именнованой карты');
						#здесь еще нужно исключить указание одному имени разных типов
						my $authorTypeFile = $authorPath.'/'.$$temp{'author'}; #вообще не верно здесь работать с именованными индексами, т.к. автор может прийти из а4
						my %type = &getJSON( $authorTypeFile, 'type' );
						$type{$value}[0]{'name'} = $value[0];
						&setXML ( $authorTypeFile, 'type', \%type );
						&rinseProc2 ( $$temp{'author'}, %type )
					}
				} 
				if ( $name =~/^([a-z]+)([0-5]*)$/ and not $name =~/^[dirn]/ ){
					&setWarn('		wP     Формирование номера в расширенном режиме. Член - '.$name.' Значение - '.$value);
					my ( $s, $m ) = ( $1, $2 );	
					if ( defined $table{$s} ){ $s = $table{$s} }
					else {
						&setWarn("			wP      $pair: новый номер $s" );
						$s = $table{$s} = @num;
						$num[$s][6] = 1 
					}
					if ( $m ){
						&setWarn("			wP      $pair: подготовка номера частью $m" );
						$value = $num[$s][3]."\n".$value if $m == 3 and $num[$s][3];
						$num[$s][$m] = $value[$s]{$value} = $value;
					}
					elsif ( $m eq '0' ){
						&setWarn("			wP      $pair: демонтаж" );
						next if defined $value[0]{$value};
						$num[$s][0] = $value;
						$num[$s][6] = undef;
						$value[0]{$value} = 1;
					}
					else{
						&setWarn("			wP      $pair: создание новой сущности" );
						$num[$s][1] = 'n'.$$temp{'seconds'}.'-'.$$temp{'microseconds'}.'-'.$s; 
						$num[$s][3] = $value;
						if ( $name eq 'a' ){
							&setWarn("			wP       $pair: подготовка редиректа" );
							$$temp{'fact'} = $num[$s][1] if not defined $param{'fact'};
							$$temp{'quest'} = $num[$s][1] if not defined $param{'quest'};
						}
						elsif ( not $num[$s][5] ) { $num[$s][5] = $num[$s][1] }
					}
				}
				else{ 
					&setWarn('		wP     Формирование номера в простом режиме. Предикат - '.$name);
					my @triple = ( undef, undef, $name, $value, undef, undef, 1 );
					push @num, \@triple;
				}
			}
			if ( @num and 1 ){
				&setWarn( "		wP    Найдены номера @num. Идет их обогащение удаление старого." );
				for my $s ( 0..$#num ){
					&setWarn("		wP     Замена пустого в номере $s");
					if ( $num[$s][0] ){			
						&setWarn("		wP      на удаление");
						my @span = &getTriple( $$temp{'user'}, $num[$s][0] );
						$span[4] = $num[$s][4] if $num[$s][4];
						$span[5] = $num[$s][5] if $num[$s][5];
						$num[$s] = \@span
					}
					else{
						&setWarn("		wP      на добавление");
						for my $m ( grep { not ( defined $num[$s][$_] and $num[$s][$_] ) } 1..3){
							&setWarn("		wP       Замена пустого члена $m ");
							if ( $m == 1 ){		$num[$s][1] = $$temp{'fact'}	}
							elsif ( $m == 2 ){	$num[$s][2] = 'r' 				}
							else { 				$num[$s][3] = 'r'	}
						}
						$num[$s][0] = &setName( 'd', $$temp{'user'}, $num[$s][1], $num[$s][2], $num[$s][3] );
					}
					$num[$s][4] = $$temp{'user'};
					$num[$s][5] = $$temp{'quest'} if not $num[$s][5];
				} 
			}
		}
	}
	@num || return;
	
	&setWarn( "		wP ## Имеются номера. Идет запись." );
	for my $s ( grep { $num[$_] } 0..$#num ){
		&setWarn("		wP  Проверка номера $s ");
		for my $key ( 0..6 ){ 
			$$temp{'number'}[$s]{$number[$key]} = $num[$s][$key] if $num[$s][$key];
		}	
		if ( grep { $s != $_ and $num[$_] and ( $num[$s][0] eq $num[$_][0] ) } 0..$#num ) { 
			&setWarn("		wP   Номер запрашивает повтор трипла в запросе");
			$$temp{'povtor'}[$s] = 1;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор трипла в запросе';
			next;
		}
		if ( &spinProc( $num[$s], $$temp{'time'} ) ){
			&setWarn("		wP   Номер запрашивает повтор трипла в базе.");
			$$temp{'povtor'}[$s] = 2;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор установления значения';
		}
	}
	return if 1 or -e $configDir.'/control' or not grep { $$temp{'number'}[$_] eq 'OK' } @{$$temp{'number'}};
	
	&setWarn('   Обнаружены физические записи. Запуск процесса сушки');
	eval{ system( 'perl.exe M:\system\reg.pl dry >/dev/null 2>M:\_log\error_dry.txt' ); }	
}



sub rinseProc {
	my ( $name, @div )=@_;
	&setWarn("		rP @_"  );
	my %value;
	if ( ( $div[0] and $div[0] ne '' ) or $div[1]  ){ 
		&setWarn("		rP  Раскладка @div по строкам"  );
		for my $s (0..$#div){
			&setWarn("		rP   Строка $s: $div[$s]"  );
			#$div[$s] = Encode::decode_utf8($div[$s]) if $div[$s];
			my @span = split "\t", $div[$s];
			for my $m (0..$#span){ $value{'div'}[$s]{'span'}[$m]{$tNode} = $span[$m] } 
		}
	}
	else { $value{'div'}[0]{'span'}[0]{$tNode} = undef }
	&setXML ( &m8dir( $name ), 'value', \%value );		
}

sub rinseProc2 {
	my ( $author, %type )=@_;
	&setWarn("		rP2 @_"  );
	-d $author || return;
	my %xsl_stylesheet;
	$xsl_stylesheet{'xsl:stylesheet'}{'version'} = '1.0';
	$xsl_stylesheet{'xsl:stylesheet'}{'xmlns:xsl'} = 'http://www.w3.org/1999/XSL/Transform';
	$xsl_stylesheet{'xsl:stylesheet'}{'xmlns:m8'} = 'http://m8data.com';
	my $x = 0;
	for my $mapName ( grep { $type{$_} =~/ARRAY/ } keys %type){
		$xsl_stylesheet{'xsl:stylesheet'}{'xsl:param'}[$x]{'name'} = $type{$mapName}[0]{'name'};
		$xsl_stylesheet{'xsl:stylesheet'}{'xsl:param'}[$x]{'select'} = "name( m8:path( '$mapName', 'role3' )/$author/* )";
		$x++
	}
	my $XML = $XML2JSON->json2xml( $JSON->encode(\%xsl_stylesheet) );
	&setFile( $authorPath.'/'.$author.'/type.xsl', $XML );
}

sub spinProc {
	my ( $val, $time )=@_;
	&setWarn("
		sP @_"  );
	for my $key ( 0..6 ){ 
		&setWarn("		sP  Значение на сушку $key: $$val[$key]"  );
	}	
	my ( $name, $subject, $predicate, $object, $author, $quest, $add ) = ( $$val[0], $$val[1], $$val[2], $$val[3], $$val[4], $$val[5], $$val[6] );
	my $mainDir = &m8dir( $subject, $author, $quest );
	
	my %port = &getJSON( $mainDir, 'port' );
	my $good;
	if ( $add ){
		&setWarn("		sP  Поиск старого значения в порту директории $mainDir"  );
		if ( defined $port{$predicate} ){
			&setWarn("		sP   Анализ старого значения"  );
			my @oldObject = keys %{$port{$predicate}[0]};
			my $oldObject = $oldObject[0];
			my @oldTriple = keys %{$port{$predicate}[0]{$oldObject}[0]};
			my $oldTriple = $oldTriple[0];
			my $oldTime = $port{$predicate}[0]{$oldObject}[0]{$oldTriple}[0]{'time'};
			if ( $time < $oldTime ){ $add = undef }
			elsif ( $oldObject eq $object ){ $good = 1 }
			else{
				&setWarn("		sP    Удаление старого значения"  );
				my @triple = ( $oldTriple, $subject, $predicate, $oldObject, $author, $quest );
				&spinProc ( \@triple, $time );
			}
		}
	}
	elsif ( not defined $port{$predicate} or not defined $port{$predicate}[0]{$object} ){ $good = 1 }
	my @value = ( $name, $subject, $predicate, $object, $author, $quest );
	if (not $good){
	push @value, ( $subject, $predicate, $object ) if $predicate=~/^r\d*$/;
	for my $mN ( grep { $value[$_] } 0..$#value ){
		&setWarn("		sP  Обработка упоминания cущности $mN: $value[$mN]"  );
		my $addC = $add || 0; #заводим отдельный регистр, т.к. $add должен оставаться с значением до цикла
		my $metter = &getID($value[$mN]);
		my $type = $superrole[$mN];
		my ( $role, $file, $first, $second );
		
		if ( $mN == 0 ){	( $role, $file, $first, $second ) = ( 'activate',	'activate'				, $author,	$quest ) }
		elsif ( $mN < 4 ) {	( $role, $file, $first, $second ) = ( 'role'.$mN,	'role'.$mN 				, $author,	$quest ) }
		elsif ( $mN == 4 ){ ( $role, $file, $first, $second ) = ( 'author',		'author'				, $name, 	$quest ) }
		elsif ( $mN == 5 ){ ( $role, $file, $first, $second ) = ( 'quest',		'quest'					, $author,	$subject ) }#вероятнее всего, здесь subject нужно поменять на name
		elsif ( $mN == 6 ){ ( $role, $file, $first, $second ) = ( $predicate,	'subject_'.$predicate	, $author,	$quest ) }
		elsif ( $mN == 7 ){	( $role, $file, $first, $second ) = ( $object,		'predicate_'.$object	, $author,	$quest ) }
		elsif ( $mN == 8 ){	( $role, $file, $first, $second ) = ( $subject, 	'object_'.$subject		, $author,	$quest ) } 
		
		if ( $mN == 1 or $mN == 2 or $mN == 3  ){
			&setWarn("		sP   Формирование порта/дока/терминала"  );
			my ( $master, $slave, $file2 );
			if ( $mN == 1 )		{ ( $master, $slave ) = ( $predicate, 	$object 	) }
			elsif ( $mN == 2 )	{ ( $master, $slave ) = ( $subject, 	$object 	) }
			elsif ( $mN == 3 ) 	{ ( $master, $slave ) = ( $subject, 	$predicate 	) }
			my %role = &getJSON( $metter.'/'.$author.'/'.$quest, $superfile[$mN] );
			if ( $addC ){
				&setWarn("		sP    Операции при добавлении значения"  );
				$role{$master}[0]{$slave}[0]{$name}[0]{'time'} = $time;
			}
			else { 
				&setWarn("		sP    Операции при удалении значения. Удаление ключа $master"  );
				delete $role{$master} ; 
				$addC = 1 if keys %role; 
			} 
			&setXML ( $metter.'/'.$author.'/'.$quest, $superfile[$mN], \%role );
		}
		my %role1 = &getJSON( $metter, $file );
		if ( $addC == 1 ) {
			&setWarn("		sP   Счетчик упоминаний не пустой - дополняем/обновляем индекс-файл роли"  );
			$role1{$first}[0]{'time'} = $time;		
			$role1{$first}[0]{$second}[0]{'time'} = $time;
			$role1{$first}[0]{$second}[0]{'triple'} = $name;
		}
		else {
			&setWarn("		sP   Счетчик упоминаний пустой - сокращаем индекс-файл роли"  );
			delete $role1{$first}[0]{$second};
			if ( not grep {$_ ne 'time'} keys %{$role1{$first}[0]} ){
				delete $role1{$first};		
			}			
		}
		&setXML ( $metter, $file, \%role1 ); 	

		my %index = &getJSON( $metter, 'index' );
		if (keys %role1){
			&setWarn("		sP    Добавление/обновление упоминания роли"  );
			$index{$type}[0]{$role}[0]{'time'} = $time;
			$index{$type}[0]{$role}[0]{'file'} = $file;
			$index{$type}[0]{$role}[0]{'superfile'} = $superfile[$mN] if $mN and $mN < 4
		}
		else { 
			&setWarn("		sP    Удаление упоминания роли"  );
			delete $index{$type}[0]{$role};
			delete $index{$type} if not keys %{$index{$type}[0]};
		}
		&setXML ( $metter, 'index', \%index );
	}
	}
	#my $metterDir = $tsvPath.'/'.$name;
	#my $authorDir = $metterDir.'/'.$author;
	#my $questDir = $authorDir.'/'.$quest;
	my $questDir = $planDir.'/'.$author.'/tsv/'.$name.'/'.$quest;
	if ( $add ){
		&setWarn("		wP   Добавление директории $questDir в базу");
		#&setFile( $questDir.'/time.txt', $time );
		&setFile ( $planDir.'/'.$author.'/tsv/'.$name.'/'.$quest.'/time.txt', $time ); #ss
	}
	else{
		&setWarn("		wP   Удаление директории $questDir из базы");
		rmtree $questDir;
		if ( not &getDir ( $planDir.'/'.$author.'/tsv/'.$name, 1 ) ){
			rmtree $planDir.'/'.$author.'/tsv/'.$name;
			if ( not &getDir( $planDir.'/'.$author.'/tsv', 1 ) ){
				&setXML( 'm8/d/'.$value[0], 'value' );
				rmtree $planDir.'/'.$author.'/tsv';
			}
			if ( $value[3]=~/^i\d+$/ ){
				&setWarn("		dN    Проверка на идентификатор");
				my $authorTypeDir = $authorPath.'/'.$value[4];
				if ( -e $authorTypeDir.'/type.json' ){
					my %type = &getJSON( $authorTypeDir, 'type' );
					if ( defined $type{$value[3]} ){ 
						delete $type{$value[3]};
						&setXML( $authorTypeDir, 'type', \%type );
						&rinseProc2( $value[4], %type )
					}
				}
			}
		}
	}
	return 0;
	&setWarn("		sP @_ (END)
	"  );	
}

sub dryProc2 {
	my ( $mode )=@_; #$param
	#&setWarn("		dP 2 @_" );
	
	#mode1 - удаляется и переиндексируется все
	#mode2 - только удаляется мусор (в штатном режиме имеет смысл только для доудаления гостевых триплов)
	#@user - Если указаны то только они будут сохранены
	#chdir "W:";
	my %stat;
	$dbg = 0;
	
	rmtree $logDir if -d $logDir;
	make_path( $logDir, { chmod => $chmod } );
	open (REINDEX, '>'.$logDir.'/reindex.txt')|| die "Ошибка при открытии файла reindex.txt: $!\n";
	warn '		DRY BEGIN ';
	my $guestDays = 0;# = &getFile( $configDir.'/guest_days.txt' ) || return;\
	my $userDays = 0;
	if ( -e $configDir.'/guest_days.txt' ){
		$guestDays = &getFile( $configDir.'/guest_days.txt' )
	}
	if ( -e $configDir.'/user_days.txt' ){
		$userDays = &getFile( $configDir.'/user_days.txt' )
	}
	warn '		guestDays: '.$guestDays;	
	my $guestTime = time - $guestDays * 24 * 60 * 60;
	my $userTime = time - $userDays * 24 * 60 * 60;
	if ( $mode == 2 or 0 ){
		warn '		delete all index';
		for my $d ( &getDir( 'm8' ) ){
			if ( -d 'm8/'.$d ){ rmtree 'm8/'.$d }
			else { unlink 'm8/'.$d }
		}
	}
	my %dry;
	my %authorType;
	my $count1 = 0;
	my $n_delG = 0;
	my $n_delR = 0;
	my $n_delN = 0;
	my $all = 0;
	my $triple = 0;
	my $clean = 0; 
	my $DL_map = 0;
	my $cookie = 0;
	my $DL_cookie = 0;

	for my $sessionName ( &getDir( $sessionDir, 1 ) ){ 
		print REINDEX "sessionName	$sessionName \n";
		warn '		sessionName  '.$sessionName;
		$cookie++;
		my $cAuthor = &getFile( $sessionDir.'/'.$sessionName.'/value.txt' );
		my $tempKeysFile = $configDir.'/'.$cAuthor.'.json';
		if ( -e $tempKeysFile ){
			my %tempkey = &getHash( $tempKeysFile );
			if ( not defined $tempkey{$sessionName} or $tempkey{$sessionName} < $userTime ){
				rmtree $sessionDir.'/'.$sessionName;
				$DL_cookie++
			}
		}
		else {
			rmtree $sessionDir.'/'.$sessionName;
			$DL_cookie++
		}		
	}
	my $time1 = time;
	my $time2;		
	for my $authorName ( grep { -d $planDir.'/'.$_.'/tsv' } &getDir( $planDir, 1 ) ){ 
		print REINDEX "authorName	$authorName \n";
		warn '		authorName  '.$authorName;
		
		my $tsvPath = $planDir.'/'.$authorName.'/tsv';
		if ( not defined $stat{$authorName} ){
			for ( 'add', 'n_delR', 'n_delN' ){ $stat{$authorName}{$_} = 0 }
		}
		for my $tsvName ( &getDir( $tsvPath, 1 ) ){
			print REINDEX "   Исследование aвтора $tsvName \n";
			warn '		tsv  '.$tsvName;
			$all++;
			my @div = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$tsvName.'/value.tsv' );
			&rinseProc( $tsvName, @div );
			next if $tsvName=~/^i/;	
			my @val = split "\t", $div[0];
			unshift @val, $tsvName;
			$val[4] = $authorName;
			$triple++;
			if ( $val[3] =~/^i\d+$/ ){
				my @map = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$val[3].'/value.tsv' );
				$authorType{$authorName}{$val[3]} = $map[0] if $map[1] and $map[1]=~/^xsd:\w+$/;
			}
			if (1){
			for my $questName ( &getDir( $tsvPath.'/'.$tsvName, 1 ) ){
				print REINDEX "    Исследование квеста $questName \n";
				$val[5] = $questName;
				my ( $timeProc ) = &getFile( $tsvPath.'/'.$tsvName.'/'.$val[5].'/time.txt' );
				if ( $authorName eq 'guest' and $tsvName ne 'd' and $timeProc and $timeProc < $guestTime ){ 
					print REINDEX "     Удаление старого гостевого трипла '.$div[0].' \n";
					$n_delG++
				}
				else {
					print REINDEX "     Реиндексация значений '$div[0]' \n";
					$val[6] = 1;
					$stat{$authorName}{'add'}++;
				}
				&spinProc( \@val, $timeProc );
				#make_path( $authorName.'/tsv/'.$tsvName.'/'.$questName );
				#&setFile ( $authorName.'/tsv/'.$tsvName.'/'.$questName.'/time.txt', $timeProc ); #ss
				#copy( $tsvPath.'/'.$tsvName.'/value.tsv', $authorName.'/tsv/'.$tsvName.'/value.tsv' );
				#for my $m (1..3){
				#	next if not $val[$m]=~/i/;
				#	-d $authorName.'/tsv/'.$val[$m] || make_path( $authorName.'/tsv/'.$val[$m] );
				#	copy( $tsvPath.'/'.$val[$m].'/value.tsv', $authorName.'/tsv/'.$val[$m].'/value.tsv' )
				#}
			}
			}
		}
	#}
		$time2 = time;
	#	my $real2 = 1;
	#if(1){
	#for my $authorName ( grep { -d $planDir.'/'.$_.'/tsv' } &getDir( $planDir, 1 ) ){ 
	#	warn '		author2  '.$authorName;
	#	print REINDEX "author2	$authorName \n";
	#	my $tsvPath = $planDir.'/'.$authorName.'/tsv';
		for my $tsvName ( &getDir( $tsvPath, 1 ) ){ 
			warn '		tsv2  '.$tsvName;
			print REINDEX "tsv2	$tsvName \n";
			if ( $tsvName=~/^i/ ){
				if ( not -e &m8path( $tsvName, 'index' ) and $tsvName ne 'i' ){
					rmtree $tsvPath.'/'.$tsvName;
					rmtree &m8dir( $tsvName );
					$DL_map++
				}
			}
			elsif ( $tsvName=~/^d/ ){
				my @val = map{ Encode::decode_utf8($_) } &getTriple( $authorName, $tsvName );
				my $parent = $val[1];
				$val[4] = $authorName;
				for my $questName ( &getDir( $tsvPath.'/'.$tsvName, 1 ) ){
					$val[5] = $questName;
					if ( $val[2]=~/^r/ ){
						next if $val[1] eq $val[5];
						$parent = $val[5];
					}
					my %index = &getJSON( &m8dir( $parent ), 'index' );
					next if defined $index{'subject'};
					my ( $timeProc ) = &getFile( $tsvPath.'/'.$tsvName.'/'.$val[5].'/time.txt' );
					if ( $val[3] =~/^i\d+$/ ){
						my @map = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$val[3].'/value.tsv' );
						delete $authorType{$val[4]}{$val[3]} if $map[1]=~/^xsd:\w+$/;
					}
					&spinProc( \@val, $timeProc );
					if ( $val[2]=~/^r/ ){ $stat{$authorName}{'n_delR'}++ }
					else { $stat{$authorName}{'n_delN'}++ }
				}
			}
		}
	#}
	}
	my $time3 = time+1;
	for my $authorName ( keys %authorType ){
		my %type;
		#здесь еще нужно исключить указание одному имени разных типов
		my $authorTypeDir = $authorPath.'/'.$authorName; #не верно здесь работать с именованными индексами, т.к. автор может прийти из а4
		for my $tsvName ( keys %{$authorType{$authorName}} ){
			$type{$tsvName}[0]{'name'} = $authorType{$authorName}{$tsvName};
		}
		&setXML( $authorTypeDir, 'type', \%type );
		&rinseProc2( $authorName, %type )
	}

	my $second1 = int( $time2 - $time1 ) +1;
	my $second2 = int( $time3 - $time2 ) +1;
	my $s1 = int( $all / $second1 );
	my $s2 = int( $all / $second2 );
	my $map = $all - $triple;
	my $list = '
	guestDays: 	'.$guestDays.'
	guestTime:	'.$guestTime.'
	N_DL-G:	'.$n_delG.'
	
	ALL: 	'.$all.'
	MAP:	'.$map.'
	DL_map: '.$DL_map.'
	
	TRIPLE:	'.$triple.'
	';
	for my $auth ( keys %stat ){
		$list .= $auth.':		'.$stat{$auth}{'add'}.'	'.$stat{$auth}{'n_delR'}.'	'.$stat{$auth}{'n_delN'}.'
	';
	}
	$list .= '
	
	cookie:		'.$cookie.'
	DL_cookie:	'.$DL_cookie.'
	
	TIME1:		'.$second1.'	/	'.$s1.'
	TIME2:		'.$second2.'	/	'.$s2.'
	
	';
	warn $list;
	print REINDEX $list;
	close (REINDEX);
}

sub startProc {
	my %avatar;
	my $count = 0;
	for my $avatarName ( grep { -e $planDir.'/'.$_.'/'.$stylesheetDir.'/title.txt'} &getDir( $planDir, 1 ) ){
		&setWarn ("		startProc   Найден аватар $avatarName");
		$avatar{'unit'}[$count]{'id'} = $avatarName;
		$avatar{'unit'}[$count]{'title'} = Encode::decode_utf8( &getFile( $planDir.'/'.$avatarName.'/'.$stylesheetDir.'/title.txt' ) );
		$count++
	}
	&setXML ( '.', 'avatar', \%avatar );
	return $avatar{'unit'}[0]{'id'} if $count == 1;
}



sub parseNew {
	my ( $temp, $pass )=@_;
	&setWarn( "			pN @_" );	
	if ( defined $$temp{'login'} ){ 
		&setWarn('			pN   Вход ранее созданного пользователя');
		if ($$temp{'login'} ne 'guest'){
			defined $$pass{'password'} and $$pass{'password'} || return 'no_password';
			my $userFile = $userDir.'/'.$$temp{'login'}.'/'.$passwordFile;
			-e $userFile || return 'no_user';
			my $password = &getFile( $userFile );
			$password eq $$pass{'password'} || return 'bad_password';
		}
	}
	elsif ( defined $$temp{'new_author'} ){
		&setWarn('			pN   Создание автора');
		$$temp{'new_author'} =~/^\w+$/ || return 'В имени могут быть лишь буквы латинского алфавита и цифры.';
		34 >= length $$temp{'new_author'} || return 'Имя не должно быть длиннее 34 символов.';
		return 'Такой пользователь уже существует' if -d $userDir.'/'.$$temp{'new_author'}; #-e $authorRuneDIR.'/mult/index.xml';
		defined $$pass{'new_password'} and $$pass{'new_password'} || return 'Введите пароль';
		defined $$pass{'new_password2'} and $$pass{'new_password2'} || return 'Введите пароль с повтором';		
		$$pass{'new_password'} eq $$pass{'new_password2'} || return 'Пароль повторен не верно';
	}	
	return 0
}




######### функции второго порядка ##########
sub m8path {
	my ( $level1, $level2, $level3, $level4 ) = @_;
	my $path;
	if ( $level2 ){
		$path = 'm8/'.substr($level1,0,1).'/'.$level1.'/'.$level2;
		if ( $level4 ){ 	$path .= '/'.$level3.'/'.$level4 }
		elsif ( $level3 ){	$path .= '/'.$level1.'/'.$level3 }
	}
	else { $path = $authorPath.'/'.$level1.'/type' }
	return $path.'.xml'
}
sub m8dir {
	my ( $fact, $author, $quest ) = @_;
	my $dir = 'm8/'.substr($fact,0,1).'/'.$fact;
	if ( $quest ){ 	$dir .= '/'.$author.'/'.$quest }
	elsif ( $author ){	$dir .= '/'.$author.'/'.$fact }
	return $dir
}
sub m8req {
	my ( $temp ) = @_;
	my $dir = '/'.$auraDir.'/'.$$temp{'ctrl'}.'/m8/'.substr($$temp{'fact'},0,1).'/'.$$temp{'fact'};
	if ( $$temp{'quest'} ne $$temp{'fact'} ){ $dir .= '/'.$$temp{'author'}.'/'.$$temp{'quest'} }
	elsif ( $$temp{'author'} and $$temp{'author'} ne $$temp{'ctrl'} ){ $dir .= '/'.$$temp{'author'} }
	return $dir;
}
sub getID {
	my ( $name )=@_;
#	&setWarn("						gI  @_" );
	if ($name=~m!^/m8/[dirn]/[dirn][\d_\-]*$! or $name=~m!^/m8/author/[a-z]{2}[\w\d]*$!){ $name=~s!^/!!; return $name }
	elsif ($name=~m!^([dirn])[\d_\-]*$!){ return 'm8/'.$1.'/'.$name }
	else { return $authorPath.'/'.$name }
}

sub setFile {
	my ( $file, $text, $add )=@_;
	#&setWarn( "						sF @_" );
	chomp $text;
	#warn $file.': '.$text;
	my @path = split '/', $file;
	my $fileName = pop @path;
	my $dir = join '/', @path;
	-d $dir || make_path( $dir, { chmod => $chmod } );
	my $mode = '>';#>:encoding(UTF-8)
	$mode = '>'.$mode if $add;
	open (FILE, $mode, $dir.'/'.$fileName)|| die "Error opening file $dir/$fileName: $!\n";
		print FILE $text if $text ne ''; #на входе может быть '0' поэтому не просто "if $text"
		print FILE "\n" if $add;
	close (FILE);
	if ( $dbg and $file=~/.xml$/ or 1 ){
		-d $trashPath || make_path( $trashPath, { chmod => $chmod } );
		my $file = $trashPath.'/'.$path[$#path].'_'.$fileName;
		open (FILE, $mode, $file )|| die "Error opening file $file: $!\n";#$path[2].'-'.
			print FILE $text if $text;
			print FILE "\n" if $add;
		close (FILE);
	}
	return $text; #обязательно нужно что-то возвращать, т.к. иногда функция вызывается в контексте and
}
sub setXML {
	my ( $pathDir, $root, $hash ) = @_;
	&setWarn("						sX @_" );
	my @keys = keys %{$hash};
	if ( $keys[0] ){
		#&setWarn("						sX  Add xml" );
		my %hash = ( $root => $hash );
		&setFile( $pathDir.'/'.$root.'.json', $JSON->encode(\%hash) );
		if ( $pathDir ){
			my @path = split '/', $pathDir;
			for ( 0..$#path ){	$hash{$root}{$level[$_]} = $path[$_] }
		}
		my $XML = $XML2JSON->json2xml( $JSON->encode(\%hash) );
		&setFile( $pathDir.'/'.$root.'.xml', $XML );
		return $XML;
	}
	else{
		#&setWarn("						sX  Удаление xml-файла" );
		unlink $pathDir.'/'.$root.'.xml';
		unlink $pathDir.'/'.$root.'.json';
	}
}
sub setName {
	my ( $type, $author, @value )=@_;
	&setWarn( "					sN @_" );
	my $name;
	my $tsvPath = $planDir.'/'.$author.'/tsv';
	if (@value){
		@value = ( join( "\t", @value ) ) if $type eq 'd'; 
		my $value = join "\n", @value;
		my @name = murmur128_x64($value);
		( $name[0], $name[1] ) = ( $type.$name[0], $type.$name[1] );
		for my $n ( grep { -e $tsvPath.'/'.$name[$_].'/value.tsv' } ( 0, 1 ) ){
			&setWarn( "					sN  проверка варианта $n - $name[$n]" );
			my $old = join "\n", &getFile( $tsvPath.'/'.$name[$n].'/value.tsv' );
			$old = Encode::decode_utf8($old);#читает и так нормально, но проверку на эквивалетность без флага не пройдет
			if ( $value eq $old ){ $name = $name[$n] }
			else { $name[$n] = undef }
		}
		if (not $name ){
			&setWarn( "					sN  присвоение первого попавшегося имени из двух: @name" );
			( $name ) = grep { $_ } @name;
			&setFile( $tsvPath.'/'.$name.'/value.tsv', $value );
			&rinseProc( $name, @value )
		}	
	}
	else{
		$name = 'i';
		&rinseProc( 'i', '' )
	}
	return $name
}
sub setWarn {
	$dbg || return;
	my ( $text, $logFile )=@_;
	-d $logDir || mkdir $logDir;
	my @c = caller;
	if ($logFile){
		$log = $logFile;  #что бы записи отладки для контроля и другого шли в разные логи
		unlink $log if -e $log;
	}
	my $time = time;
	#$text = Encode::decode_utf8($text);
	open( FILE, ">>", $log ) || die "Ошибка при открытии файла $log: $!\n"; #:utf8 без :utf8 выдает ошибку "wide character..."
		$text = Encode::decode_utf8($c[2].' '.$text);
		print FILE $text, "\n";#  $c[3], ' ' - секунда
	close (FILE);
}

sub setMessage {
	open (REINDEX, '>>reindex.txt')|| die "Ошибка при открытии файла reindex.txt: $!\n";
		print REINDEX $_[0]."\n";#  $c[3], ' ' - секунда
	close (REINDEX);
}

sub getFile {
	&setWarn( "						gF @_" );
	my $file = $_[0];
	-e $file || return;
	my @text;
	open (FILE, $file)|| die "Error opening file $file: $!\n"; #'encoding(UTF-8)', "<:utf8", 
		while (<FILE>){
			s/\s+\z//;
			push @text, $_;
		}
	close (FILE);
	if ( @text > 1 ){	return @text 	}	#elsif ( $text[0] ){ return $text[0]	}
	elsif (@text) 	{	return $text[0]	}
	else { 				return '' 		}
}
sub getDir{
	my ( $dir, $dir_only )=@_;
#	&setWarn("						gD  @_" );
	-d $dir.'/' || return; #используется в начале стирки при детектировании автора
	opendir (TEMP, $dir.'/') || die "Error open dir $dir: $!";
		my @name = grep {!/^\./} readdir TEMP;
	closedir(TEMP);
	if ( $dir_only ){ 
		@name = grep { -d $dir.'/'.$_ } @name;
		if ($dir_only == 1) { return @name }
		elsif ($dir_only == 2) { return $name[0] }
	}
	else { return @name } #возвращает имена файлов включая имена директорий
}
sub getHash {
	-e $_[0] || return;
	my $hash = decode_json( &getFile( $_[0] ) );	
	return %{$hash};
}
sub getJSON {
	my ( $pathDir, $root ) = @_;
#	&setWarn("						gJ Получение JSON @_" );
	-d $pathDir || return; #иначе скрипт прежде чем проверить наличие файла в папке будет еще 2 секунды искать саму папку
	-e $pathDir.'/'.$root.'.json' || return;
	my %hash = &getHash( $pathDir.'/'.$root.'.json' );
	return %{$hash{$root}}
}


sub getDoc {
	my ( $temp, $adminMode, $xslFile )=@_;
	my $doc = XML::LibXML::Document->new( "1.0", "UTF-8" );
	my $rootElement = $doc->createElement($$temp{'fact'});
	$doc->addChild($rootElement);
	if ( defined $$temp{'number'} ){
		&setWarn('     Идет выдача отладочной информации '.$temp{'number'} );
		foreach my $s ( 0..$#{$temp{'number'}} ){
			&setWarn("      Передача в темп-файл информации о созданном номере $s");
			my $tripleElement = $doc->createElement('number');
			foreach my $key ( keys %{$temp{'number'}[$s]} ){
				$tripleElement->setAttribute($key, $$temp{'number'}[$s]{$key});
			}
			$tripleElement->appendText($s);
			$rootElement->addChild($tripleElement);
		}
		delete $$temp{'number'}
	}
	$rootElement->appendText('_');
	for my $param ( grep {$temp{$_}} keys %temp ) {	$rootElement->setAttribute( $param, $$temp{$param} ) }
	my $localtime = localtime($temp{'time'}); 
	$rootElement->setAttribute( 'localtime', $localtime );
	if ($xslFile){
		&setWarn('      Подготовка преобразования на клиенте');
		my $pi = $doc->createProcessingInstruction("xml-stylesheet"); #нельзя добавлять в конце поэтому добавляем вручную
		$pi->setData(type=>'text/xsl', href => $xslFile);
		$doc->insertBefore($pi, $rootElement);
	}
	my $pp = XML::LibXML::PrettyPrint->new();
	$pp->pretty_print($rootElement);
	my $tempFile = $logDir.'/temp.xml';
	copy( $tempFile, $tempFile.'.xml' ) if -e $tempFile and $adminMode;
	&setFile( $tempFile, $doc );
	return $doc
}
sub getTriple {
	&setWarn("		gT @_");
	my ( $user, $name )=@_;
	my $val = &getFile( $planDir.'/'.$user.'/tsv/'.$name.'/value.tsv' );
	&setWarn("		gT val: $val");
	my @value = ( split "\t", $val );
	unshift @value, $name;
	&setWarn("		gT return: @value");
	return @value 
}
sub delDir {
	#&setWarn( "						dD @_" );
	my ( $dirname, $subdir)=@_;
	-d $dirname || return;
	my $count = 0;
	for my $file ( &getDir( $dirname ) ){
		if ( -d $dirname.'/'.$file ){ $count += &delDir( $dirname.'/'.$file ) }
		else {
#			&setWarn("						dD   Удаление файла $dirname/$file" );
			unlink  $dirname.'/'.$file;
			$count++
		}	
	}
	rmdir $dirname;
	if ( $subdir ){
		&setWarn("						dD  Удаление поддиректорий" );
		my @dir = split '/', $dirname;
		pop @dir;
		while (@dir > $subdir){
#			&setWarn("						dD   Удаление поддиректории @dir" );		
			my $dir = join '/', @dir;
			if ( &getDir( $dir, 1 ) ){ @dir = () }
			else { &delDir( $dir ) }
			pop @dir
		}
	}
	return $count
}
sub utfText {
	my ( $value ) = @_;
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9]{2})/pack("C", hex($1))/eg;
	return $value
}