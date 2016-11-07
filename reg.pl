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
#нет в ubuntu
use Digest::MurmurHash3 qw( murmur128_x64 );
use XML::XML2JSON;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
#use FindBin qw($Bin);

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

my %setting = (
	'guestDays' 	=> 30,
	'userDays'		=> 60,
	'userPassword'	=> 'example',
	'forceDbg'		=> 0,
	'chMod'			=> '0777',
	'platformLevel'	=> 3,
	'tempfsFolder'	=> '/mnt/tmpfs'
);
my $passwordFile = 'password.txt';
my $sessionFile = 'session.json';
my $stylesheetDir = 'xsl';
my $defaultAvatar = 'formulyar';
my $startAvatar = 'start';
my $defaultUser = 'guest';
my $defaultFact = 'n';
my $defaultQuest = 'n';
my $admin = 'admin';
my $canonicalHomeAvatar = 'formulyar';	
my $tNode = '$t';
my @sentence = ( undef, 'subject', 	'predicate',	'object',	'modifier' );
my @matrix = ( undef, $defaultFact, $defaultFact, $defaultQuest );
my @level = ( 'system', 'prefix', 'fact', 'quest' );
my @number = (	'name',		'subject', 	'predicate',	'object',	'modifier', 'add' );
my @transaction = ( 'DOCUMENT_ROOT', 'REMOTE_ADDR', 'HTTP_USER_AGENT', 'REQUEST_URI', 'QUERY_STRING', 'HTTP_COOKIE', 'REQUEST_METHOD', 'HTTP_X_REQUESTED_WITH' );#, 'HTTP_USER_AGENT', 'HTTP_ACCEPT_LANGUAGE', 'REMOTE_ADDR' $$transaction{'QUERY_STRING'}
my @mainTriple = ( 'n', 'r', 'i' );
my %formatDir = ( '_doc', 1, '_json', 1, '_pdf', 1, '_xml', 1 );
my @superrole = ( 'triple', 'role', 'role', 'role', 'quest', 'author', 'subject', 'predicate', 'object', 'director' );
my @superfile = ( undef, 'port', 'dock', 'terminal' ); 

my $type = 'xml';

my $userDir = 'u';
my $auraDir = 'a';
my $planeDir = '.plane';
my $planeDir_link = 'p';
my $indexDir = 'm8';

my $logPath = $defaultAvatar.'/log'; #'../log';$userDir.'/'.
my $userPath = $indexDir.'/author';
my $configDir = 'config';
my $configPath = $userDir.'/'.$defaultAvatar.'/'.$configDir; #'../'.$configDir;
my $sessionPath = $configPath.'/temp_name';

my $errorLog = $logPath.'/error_log.txt';
my $logFile = 'data_log.txt';
my $log = $logPath.'/'.$logFile;
my $log1 = $logPath.'/control_log.txt';
my $guest_log = $logPath.'/guest_log.txt';
my $trashPath = $logPath.'/trash';
my $platformGit = '/home/git/_master/gitolite-admin/.git/refs/heads/master';
my $typesDir = 'm8';
my $typesFile = 'type.xml';

my $JSON = JSON->new->utf8;
my $XML2JSON = XML::XML2JSON->new(pretty => 'true');

warn 'script: '.$0;
my @bin = split '/', $0;
if ($bin[0]){
	if ( $bin[0]=~/:$/ ){ $disk = $bin[0] }
	else { 
		warn ' Not absolute path of script!!'; 
		exit 
	}
}
$bin[4] || warn ' Wrong absolute path!!' && exit;

my @planePath = splice( @bin, 1, -3 );
my $planePath = join '/', @planePath;
my $planeRoot = $disk.'/'.$planePath.'/';

chdir $planeRoot;
#my @head = split '/', &getFile ( '.plane/'.$univer.'/formulyar/.git/HEAD' );
#my $univer = $planePath[$#planePath];
#my $branche = $planePath[$#planePath-1];

#if ( $branche eq '.public' ){
$planePath[$#planePath]=~/^(\w+)-*(.*)$/;
my $univer = $1;
my $branche = $2 || 'master';
#}

my $chmod = $setting{'chMod'};
$chmod = &getSetting('chMod');
my $dbg = &getSetting('forceDbg');
my $prefix = '/';

my $platformLevel = &getSetting('platformLevel');
if ( defined $ENV{DOCUMENT_ROOT} ){
	my @dr = split '/', $ENV{DOCUMENT_ROOT};
	$dr[$#dr] || pop @dr;
	$platformLevel = $#dr;
}
for my $n ( $platformLevel..$#planePath ){ $prefix .= $planePath[$n].'/' }
my $multiRoot = join '/', splice( @planePath, 0, -2 );
$multiRoot = $disk.'/'.$multiRoot.'/';
warn 'prefix: '.$prefix;

if ( defined $ENV{DOCUMENT_ROOT} ){	
	warn 'WEB TEMP out!!';
	my $cookiePrefix = '';#$prefix; #&utfText(  );
	#$cookiePrefix =~ s!^/(.*).public/$!$1!;
	#$cookiePrefix =~ tr!/!.!;
	$dbg = 1 if 0 or cookie($cookiePrefix.'debug') ne '';
	copy( $log, $log.'.txt' ) or die "Copy failed: $!" if -e $log and $dbg; #копировать лог не ниже, т.е. не после возможного редиректа
	&setWarn( " Обработка запроса в сайте $ENV{DOCUMENT_ROOT}", $log);#	
	copy( $logPath.'/env.json', $logPath.'/env.json.json' ) or die "Copy failed: $!" if -e $logPath.'/env.json' and $dbg; #копировать лог не ниже, т.е. не после возможного
	&setFile( $logPath.'/env.json', $JSON->encode(\%ENV) ) if $dbg;
	my $dry;
	my $head;
	if ( -d '.plane/'.$univer ){
		&setWarn( "  Проверка необходимости сушки индекса после коммита");#	
		#if ( $^O ne 'MSWin32' ){ #and -d '/home/git'
		#	&setWarn( "   Обнаружена работа на сервере");#	
		if(0){
			for my $userName ( grep{ not $dry and not /^_/ and -d $planeDir.'/'.$_.'/.git' and -e $planeDir.'/'.$_.'/.git/refs/heads/'.$branche } &getDir( $planeDir, 1 ) ){ 
				&setWarn( "    Проверка коммитов в репозитории $userName");#	
				$head = &getFile( $planeDir.'/'.$userName.'/.git/refs/heads/'.$branche );
				$dry = 1 if not -e $userDir.'/'.$userName.'/'.$branche or &getFile( $userDir.'/'.$userName.'/'.$branche ) ne $head;
			}
		}
		#}
	}
	else { $dry = 1 }
	&dryProc2( 1 ) if $dry;
	my %temp = (
		'time'		=>	time,
		'univer'	=>	$univer,
		'planeRoot'	=>	$planeRoot,
		'prefix'	=>	$prefix,
		'record'	=>	0,
		'adminMode'	=> 	$dbg,
		'branche'	=>	$branche,
		'dry'		=>	$dry,
		'head'		=>	$head,
		'multiRoot' =>	$multiRoot,
		'fact'		=>	'n',
		'quest'		=>	'n',
	);
	#$temp{'adminMode'} = "true" if $dbg;
	for my $param ( @transaction ){	
		&setWarn('  ENV '.$param.': '.$ENV{$param});
		$temp{$param} = $ENV{$param} 
	}
	( $temp{'seconds'}, $temp{'microseconds'} ) = gettimeofday;
	$temp{'version'} = &getFile( $planeDir.'/'.$defaultAvatar.'/version.txt' ) || 'v0';
	foreach my $itm ( split '; ', $temp{'HTTP_COOKIE'} ){
		&setWarn('  Прием куки '.$itm);
		my ( $name, $value ) = split( '=', $itm );
		if ( $name eq $cookiePrefix.'user' ){
			$temp{'tempkey'} = $value;
			if ( $value eq 'guest' ){ $temp{'user'} = 'guest' }
			else { $temp{'user'} = &getFile( $sessionPath.'/'.$value.'/value.txt' ) if -e $sessionPath.'/'.$value.'/value.txt' }
		}
		elsif ( $name eq $cookiePrefix.'debug' ){		$temp{'debug'} = $value if $value	}
	}
	$temp{'user'} = $defaultUser if not defined $temp{'user'} or not $temp{'user'};
	$temp{'avatar'} = $temp{'ctrl'} = $univer;
	$temp{'mission'} = $temp{'format'} = 'html';
	$temp{'ajax'} = $temp{'HTTP_X_REQUESTED_WITH'} if $temp{'HTTP_X_REQUESTED_WITH'}; 
	$temp{'wkhtmltopdf'} = 'true' if $temp{'HTTP_USER_AGENT'}=~/ wkhtmltopdf/ or $temp{'HTTP_USER_AGENT'}=~m!Qt/4.6.1!;
	&setWarn( " Завершение инициализации процесса");#	
	
	my @request_uri = split /\?/, $temp{'REQUEST_URI'};
	$request_uri[0]=~s!^$temp{'prefix'}!!;	
	my $q = CGI->new();
	$q->charset('utf-8');

	if ( $request_uri[0] ne '' && -d $request_uri[0]) { 
		&setWarn( "  В пожелании $temp{'REQUEST_URI'} директория $request_uri[0] действительна. Идет прием факта/квеста" );# стирка 	
		$temp{'workpath'} = $request_uri[0];
		my @path = split '/', $temp{'workpath'};
		if ( $path[0] ne 'm8' ){
			&setWarn( "  Обнаружен регистр миссии $path[0]" );
			$temp{'mission'} = $temp{'format'} = shift @path;
			if ( $temp{'format'} eq $auraDir or $temp{'format'} eq $defaultAvatar ){ 	$temp{'format'} = 'html'	}
			else {									$temp{'format'} =~s/^_//	}
		}
		if ( @path ){
			if ( $path[0] ne 'm8' ){
				$temp{'ctrl'} = shift @path;
			}
		}		
		elsif ( $temp{'mission'} eq $defaultAvatar and $temp{'user'} eq $defaultUser ) {	$temp{'ctrl'} = $defaultAvatar } #Это указание не дает выйти на текущие контроллеры при переходе на страницу авторизации }
		if ( @path ){
			$temp{'m8path'} = join '/', @path;
			if ( $path[2] ){
				$temp{'fact'} = $path[2];
				if ( $path[3] ){
					$temp{'quest'} = $path[3];
					#( $matrix[1], $matrix[4] ) = ( $temp{'fact'}, $temp{'quest'} );
				}
				#else { $matrix[3] = $matrix[4] = $temp{'fact'} }
			}
		}
	}
	&setWarn( " Завершение разбора рабочего пути");#	
	#if ( $ENV{'QUERY_STRING'} =~ /^modifier=([\w\-\d]+)$/ and -d 'm8/n/'.$1 ){ $temp{'modifier'} = $1 }
	#else { $temp{'modifier'} = 'n' }
	if ( $ENV{'QUERY_STRING'} =~ /^reindex=(\d)$/ ){
		&dryProc2( $1 );
		print $q->header( -location => $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$temp{'prefix'}.$auraDir.'/'.$temp{'ctrl'} )
	}
	elsif ( $temp{'format'} eq 'pdf' or $temp{'format'} eq 'doc' ){
		&setWarn( "  Выдача не текстовой информации (pdf, docx)" );#	
		my $extensiton = $temp{'format'};	
		if ( $temp{'format'} eq 'pdf' ){
			&setWarn( "   Формирование pdf-файла запросом $ENV{HTTP_HOST}/$auraDir/$temp{'ctrl'}/$temp{'m8path'}" );#
			my $req = $ENV{HTTP_HOST}.$temp{'prefix'}.$auraDir.'/'.$temp{'ctrl'}.'/'.$temp{'m8path'};
			$req .= '/?'.$temp{'QUERY_STRING'};
			system ( 'wkhtmltopdf '.$req.' '.$planeRoot.$temp{'m8path'}.'/report.pdf'.' 2>'.$planeRoot.$logPath.'/wkhtmltopdf.txt' ); #здесь нужно перевести в папку юзера
		}
		elsif ( $temp{'format'} eq 'doc' ){
			&setWarn( "   Формирование doc-файла" );#
			rmtree $temp{'m8path'}.'/report' if -d $temp{'m8path'}.'/report'; 
			dircopy $planeDir.'/'.$temp{'ctrl'}.'/template/report', $temp{'m8path'}.'/report';
			-e $temp{'m8path'}.'/report/_rels/.rels' || copy( $planeDir.'/'.$temp{'ctrl'}.'/template/report/_rels/.rels', $temp{'m8path'}.'/report/_rels/.rels' ) || die "Copy for Windows failed: $!";
			my $xmlFile = $planeRoot.$temp{'m8path'}.'/temp.xml';
			&setFile( $xmlFile, &getDoc( \%temp ) );
			my $xslFile = $planeRoot.$planeDir.'/'.$temp{'ctrl'}.'/'.$stylesheetDir.'/'.$temp{'ctrl'}.'.xsl';
			my $documentFile = $planeRoot.$temp{'m8path'}.'/report/word/document.xml';
			my $status = system ( 'xsltproc -o '.$documentFile.' '.$xslFile.' '.$xmlFile.' 2>'.$planeRoot.$logPath.'/xsltproc_generate_docx.txt' );#
			&setWarn( "   documntXML: $status" );#
			unlink $temp{'m8path'}.'/report.docx' if -e $temp{'m8path'}.'/report.docx';
			my $zip = Archive::Zip->new();
			$zip->addTree( $temp{'m8path'}.'/report/' );
			unless ( $zip->writeToFileNamed($temp{'m8path'}.'/report.docx') == AZ_OK ) {
				die 'write error';
			}
			$extensiton = 'docx';
		}
		if ( $temp{'format'} eq 'pdf' and 1 ){
			&setWarn( '   редирект на '.$temp{'prefix'}.$temp{'m8path'}.'/report.'.$extensiton );
			print $q->header(-location => $temp{'prefix'}.$temp{'m8path'}.'/report.'.$extensiton );
		}
		else {
			&setWarn( '   редирект на '.$ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$temp{'prefix'}.$auraDir.'/'.$temp{'ctrl'}.'/'.$temp{'m8path'}.'/report.'.$extensiton );
			print $q->header(-location => $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$temp{'prefix'}.$auraDir.'/'.$temp{'ctrl'}.'/'.$temp{'m8path'}.'/report.'.$extensiton );
		}
	}
	else{
		&setWarn( "  Выдача текстовой информации" );
		my %cookie;
		$temp{'user'} = $cookie{'user'} = $defaultUser if not -d $planeDir.'/'.$temp{'user'}; 
		&washProc( \%temp, \%cookie ) if $temp{'REQUEST_METHOD'} eq 'POST' or $temp{'QUERY_STRING'};# and $temp{'QUERY_STRING'}=~/&/ or {'QUERY_STRING'} eq 'a=');
		$temp{'modifier'} = 'n' if not defined $temp{'modifier'};	
		$temp{'fact'} = $temp{'quest'} = $defaultFact if not defined $temp{'fact'};	
		$temp{'ctrl'} = $defaultAvatar if $temp{'mission'} eq $defaultAvatar;	
		my @cookie;
		for (keys %cookie){	
			&setWarn( "   Добавление куки $cookiePrefix.$_: $cookie{$_}");#		
			push @cookie, $q->cookie( -name => $cookiePrefix.$_, -expires => '+1y', -value => $cookie{$_} ) 
		}
		if ( 0 and ( $temp{'mission'} eq $defaultAvatar and $temp{'user'} eq 'guest' ) ){
			my $location = $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$temp{'prefix'};
			if ( defined $temp{'message'} and $temp{'message'} eq 'OK' ){ $location .= &m8req( \%temp ).'/'}
			else { $location .= $defaultAvatar.'/?error='.$temp{'message'} }
			print $q->header( -location => $location, -cookie => [@cookie] )
		
		}
		elsif ( 0 ) {
			&setWarn( '   Вывод в web c редиректом' );
			#copy( $log, $log.'.txt' ) or die "Copy failed: $!" if $dbg; #копировать лог не ниже, т.е. не после возможного редиректа
			my $location = $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$temp{'prefix'};
			if ( defined $temp{'message'} and $temp{'message'} ne 'OK' ){ $location .= $defaultAvatar.'/?error='.$temp{'message'} }
			else { $location .= &m8req( \%temp ) }
			print $q->header( -location => $location, -cookie => [@cookie] )# -status => '201 Created' #куки нужны исключительно для случая указания автора		
		}		
		elsif ( ( $temp{'mission'} ne $defaultAvatar or $temp{'user'} eq 'guest' ) and ( not $temp{'QUERY_STRING'} or ( not $temp{'record'} and not defined $temp{'message'} ) or defined $temp{'ajax'} or defined $temp{'wkhtmltopdf'} ) ) { 	#$temp{'QUERY_STRING'} $temp{'record'} or $temp{'QUERY_STRING'}=~/^n1464273764-4704-1/ $ENV{'HTTP_HOST'} eq 'localhost'$ENV{'REMOTE_ADDR'} eq "127.0.0.1" 
		#elsif (1) {
			&setWarn( '   Вывод в web без редиректа (номеров: '.$temp{'record'}.')' );		
			my $doc;
			print $q->header( 
				-type 			=> 'text/'.$temp{'format'}, 
				-cookie 		=> [@cookie]
				#-expires		=> 'Sat, 26 Jul 1997 05:00:00 GMT',
				#-charset		=> 'utf-8',
				# always modified
				# -Last_Modified	=> strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
				# HTTP/1.0
				# -Pragma			=> 'no-cache',
				# -Note 			=> 'CACHING IS DISABLED IN SCRIPT REG.PL',
				# HTTP/1.1 + IE-specific (pre|post)-check
				#-Cache_Control => join(', ', qw(
				#	private
				#	no-cache
				#	no-store
				#	must-revalidate
				#	max-age=0
				#	pre-check=0
				#	post-check=0
				#)),
			);
			if ( $temp{'format'} eq 'json' ){
				&setWarn ('    Вывод в json-варианте');
				$doc = $JSON->encode(\%temp);
				&setFile( $logPath.'/temp.json', $doc ) if $dbg;
			}
			else {
				&setWarn ('    Вывод в xml-варианте');
				$doc = &getDoc( \%temp );
				if ( $temp{'format'} eq 'html' ){
					&setWarn("     Вывод temp-а под аватаром: $temp{'ctrl'}");	
					my $xslFile = $planeDir.'/'.$temp{'ctrl'}.'/'.$stylesheetDir.'/'.$temp{'ctrl'}.'.xsl';
					my $tempFile = int( rand( 999 ) );						
					if (1) { 
						my $stl = '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="'.$planeRoot.$xslFile.'"/>
</xsl:stylesheet>';#<xsl:include href="'.$planeRoot.'m8/type.xsl"/>
						$xslFile = $logPath.'/trash/'.$tempFile.'.xsl';
						&setFile( $xslFile, $stl );
						
					}
					my $trashTempFile = $logPath.'/trash/'.$tempFile.'.xml';
					&setFile( $trashTempFile, $doc );
					copy( $planeRoot.$logPath.'/out.txt', $planeRoot.$logPath.'/out.txt.txt' ) or die "Copy failed: $!" if -e $log and -e $logPath.'/out.txt' and $dbg;
					$doc = system ( 'xsltproc '.$planeRoot.$xslFile.' '.$planeRoot.$trashTempFile.' 2>'.$planeRoot.$logPath.'/out.txt' );#
					$doc =~s/(\d*)$//;
					print $1 if $dbg and $1
				}	
			}
			print $doc;
		}
		else {
			&setWarn( '   Вывод в web c редиректом' );
			#copy( $log, $log.'.txt' ) or die "Copy failed: $!" if $dbg; #копировать лог не ниже, т.е. не после возможного редиректа
			my $location = $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$temp{'prefix'};
			if ( defined $temp{'message'} and $temp{'message'} ne 'OK' ){ $location .= $defaultAvatar.'/?error='.$temp{'message'} }
			else { $location .= &m8req( \%temp ) }
			print $q->header( -location => $location, -cookie => [@cookie] )# -status => '201 Created' #куки нужны исключительно для случая указания автора		
		}			
	}
}
else {
	&setWarn (' Ответ на запрос с локалхоста', $log1);
	&dryProc2( @ARGV );	
	if ( 0 and &getSetting('forceDbg') ){
		my $zip = Archive::Zip->new();
		$zip->addTree( $planeRoot );
		unless ( $zip->writeToFileNamed( '../formulyar.zip') == AZ_OK ) {
			die 'write error';
		}
	
	}
}

exit;

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ФУНКЦИИ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

######### функции первого порядка ##########
sub washProc{
	my ( $temp, $cookie ) = @_;
	&setWarn( "		wP @_" );
	my @num;
	if ( $$temp{'REQUEST_METHOD'} eq 'POST' ){
		&setWarn( "		wP  Запись файла" );# 
		my $req = new CGI; 
		my $DownFile = $req->param('file'); 
		$DownFile =~/tsv$/ || $DownFile =~/txt$/ || $DownFile =~/csv$/ || $DownFile =~/svg$/ || return;
		my @text;			
		while ( <$DownFile> ) { 
			s/\s+\z//;
			if ( $DownFile =~/svg$/ ){
				s/\t/ /g;
				$text[0] .= $_;
			}
			else { push @text, Encode::decode_utf8( $_ ) }
		}
		$text[0] =~ s/^.*(<svg .+)$/$1/ if $DownFile =~/svg$/;
		$$temp{'fact'} = $defaultFact if not defined $$temp{'fact'};
		$$temp{'quest'} = $defaultQuest if not defined $$temp{'quest'};
		my $iName = &setName( 'i', $$temp{'user'}, @text );
		my $trName =  &setName( 'd', $$temp{'user'}, $$temp{'fact'}, 'n', $iName );
		my @val = ( $trName, $$temp{'fact'}, 'n', $iName, $$temp{'quest'}, 1 );
		push @num, \@val;
	}
	else {
		&setWarn( "		wP  Имеется строка запроса $$temp{'QUERY_STRING'}. Идет идет ее парсинг" );# 
		my %param;
		$$temp{'QUERY_STRING'} =~ s/%0D//eg; #Оставляем LA(ака 0A или \n), но убираем CR(0D). Без этой обработки на выходе получаем двойной возврат каретки помимо перевода строки если данные идут из textarea
		$$temp{'QUERY_STRING'} = &utfText($$temp{'QUERY_STRING'});
		$$temp{'QUERY_STRING'} = Encode::decode_utf8($$temp{'QUERY_STRING'});
		my %types = &getJSON( $typesDir, 'type' );		
		for my $pair ( split( /&/, $$temp{'QUERY_STRING'}  ) ){
			&setWarn( "		wP   Прием пары $pair" );	
			my ($name, $value) = split( /=/, $pair );
			next if $name eq 'user';
			$param{$name} = $value; #&utfText($value);
			if ( $name eq 'logout' ){ $$temp{'logout'} = delete $$temp{'user'} }
			elsif ( $name eq 'debug' ){ 
				&setWarn( "		wP    Переключение режима отладки" );	
				$$temp{'message'} = 'OK';
				if ( $$temp{'debug'} ){ $$cookie{'debug'} = '' }
				else { $$temp{'debug'} = $$cookie{'debug'} = time }
			}			
			elsif ( $name =~/^\w\D+$/ ) { 
				&setWarn( "		wP     Детектирован простой корневой параметр" );
				if ( defined $types{$name} ){ $$temp{'record'} = $$temp{'record'} + 1 }
				else { $$temp{$name} = $param{$name} } 
			}
			elsif ( $name =~/^\w[\d_\w\-]*$/ ){ # здесь должно быть $name =~/^\w[\d_\-]*$/ но пока есть именованные юзеры все сложно
				&setWarn( "		wP     Детектирован элемент создания номера" );
				$$temp{'record'} = $$temp{'record'} + 1;
			}

		}
		
		#весь блок работы с матрицей нужно уводить в работу с пустотой, т.к. может быть и не 'а', а 'b' и 'с' и 'd'.
		#&setWarn( "		wP  Имеется строка запроса $$temp{'QUERY_STRING'}. Идет идет ее парсинг" );
		if ( defined $param{'a'} ){
			$$temp{'modifier'} = $$temp{'fact'} if not defined $$temp{'modifier'};
			$matrix[3] = $$temp{'fact'};
		}
		else{
			$$temp{'modifier'} = 'n' if not defined $$temp{'modifier'} or not -d 'm8/n/'.$$temp{'modifier'} or $$temp{'modifier'} eq $$temp{'fact'};
			$matrix[1] = $$temp{'fact'};
		}
		for my $ps ( 1..3 ){
			$matrix[$ps] = $$temp{$sentence[$ps]} if defined $$temp{$sentence[$ps]} 
		}
		#keys %param || return;
		if ( not $$temp{'user'} ){
			&setWarn( "		wP   Найден запрос смены автора" );# 
			if ( defined $$temp{'login'} or defined $$temp{'new_author'} ){
				&setWarn( "		wP    Процедура авторизации" );# 		
				my %pass;
				for my $pass ( grep { defined $param{$_} } ( 'password', 'new_password', 'new_password2' ) ){ $pass{$pass} = $param{$pass} 	}
				$$temp{'message'} = &parseNew ( $temp, \%pass );
				return if $$temp{'message'};
				
				if ( defined $$temp{'new_author'} ){
					&setWarn('		wP    фиксация создания автора '); 
					$$temp{'fact'} = $$temp{'quest'} = $defaultFact;
					$$temp{'user'} = $pass{'new_password'};
					$$temp{'user'} = $$temp{'new_author'};
					my @value = ( 'd', @mainTriple, $$temp{'user'}, $$temp{'quest'}, 1 );
					push @num, \@value;
					my $data = join "\t", @mainTriple;
					&setFile( $$temp{'user'}.'/tsv/d/value.tsv', $data );
					&rinseProc ( 'd', $data)
				}
				else { $$temp{'user'} = $$temp{'login'}	}
				my $sessionListFile = $userDir.'/'.$$temp{'user'}.'/'.$sessionFile;
				my $tempName = 'u';
				$tempName .= murmur128_x64(rand(10000000));
				my %tempkey = &getHash( $sessionListFile );
				$tempkey{$tempName} = $$temp{'time'};
				&setFile( $sessionListFile, $JSON->encode(\%tempkey) );
				&setFile( $sessionPath.'/'.$tempName.'/value.txt', $$temp{'user'} );
				$$cookie{'user'} = $tempName;
			}
			else { 
				&setWarn( "		wP    Процедура разлогирования" );#
				my $sessionListFile = $userDir.'/'.$$temp{'logout'}.'/'.$sessionFile;
				if ( -e $sessionListFile ){
					&setWarn( "		wP     Удаление временного ключа $$temp{'tempkey'}" );#
					my %tempkey = &getHash( $sessionListFile );	
					delete $tempkey{$$temp{'tempkey'}};
					if ( keys %tempkey ){ &setFile( $sessionListFile, $JSON->encode(\%tempkey) ) }
					else { unlink $sessionListFile } 
				}
				rmtree $sessionPath.'/'.$$temp{'tempkey'} if -d $sessionPath.'/'.$$temp{'tempkey'};
				$$cookie{'user'} = $defaultUser 
			}
			$$temp{'message'} = 'OK';
		}
		elsif ( defined $param{'z0'} and $param{'z0'} eq 'd' ){
			&setWarn( "		wP   Найден запрос удаления автора" );
			my @value = ( 'd' );
			push @num, \@value;
			$$cookie{'user'} = $defaultUser
		}
		elsif ( defined $$temp{'control'} ){
			&setWarn ('		wP   Контроль');
			if ( $$temp{'user'} ne $admin ){
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
						if ( $$temp{'del'} == 3 ){ $$cookie{'user'} = $defaultUser; $$cookie{'group'} = '' }
					} 
				}
			}
			elsif ( $$temp{'control'} eq 'start'){
				&getAvatar(1);
			}
		}
		elsif ( $$temp{'record'} ) {	
			&setWarn( "		wP   Поиск и проверка номеров в строке запроса $$temp{'QUERY_STRING'}" );# стирка 
			my @value; #массив для контроля повторяющихся значений внутри триплов
			my %table; #таблица перевода с буквы предлложения на номер позиции в процессе

			for my $pair ( split( /&/, $$temp{'QUERY_STRING'}  ) ){
				&setWarn('		wP  парсинг пары >'.$pair.'<');
				my ($name, $value) = split(/=/, $pair);
				next if $name eq '_'; #пара с именем '_' добавляется только для того что бы избежать кэширования запроса.
				$name = $types{$name} if defined $types{$name};
				next if $name eq 'user' or defined $$temp{$name};
				$value =~ s/^\s+//;
				$value =~ s/\s+$//;
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
				elsif ( $value=~m!^/m8/[dirn]/([dirn][\d\w_\-]*)$! or $value=~m!^([dirn][\d\w_\-]*)$!  ){ #or ( ( $name =~/^[a-z]+[0-2]$/ or $name eq 'r' ) and $value=~m!^([dirn])$!)
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
					
						
						$types{$value[0]} = $$temp{'fact'};
						#&setXML ( $typesDir, 'type', \%types );
						&rinseProc3 ( %types )
					}
				} 
				if ( $name =~/^([a-z]+)([0-5]*)$/ and not $name =~/^[dirn]/ ){
					&setWarn('		wP     Формирование номера в расширенном режиме. Член - '.$name.' Значение - '.$value);
					my ( $s, $m ) = ( $1, $2 );	
					if ( defined $table{$s} ){ $s = $table{$s} }
					else {
						&setWarn("			wP      $pair: новый номер $s" );
						$s = $table{$s} = @num;
						$num[$s][5] = 1 
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
						$num[$s][5] = undef;
						$value[0]{$value} = 1;
					}
					else{
						&setWarn("			wP      $pair: создание новой сущности" );
						$num[$s][1] = 'n'.$$temp{'seconds'}.'-'.$$temp{'microseconds'}.'-'.$s; # $$temp{'user'}.'-'.
						$num[$s][2] = $value;
						$num[$s][5] = 2;
						$$temp{'fact'} = $$temp{'quest'} = $num[$s][1] if $name eq 'a'; # подготовка редиректа
					}
				}
				else{ 
					&setWarn('		wP     Формирование номера в простом режиме. Предикат - '.$name);
					my @triple = ( undef, undef, $name, $value, undef, 1 );
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
						if ($num[$s][4]){ $span[4] = $num[$s][4] }
						else{
							if ( $span[2]=~/^r/ ){
								( $span[4] ) = &getDir( $planeDir.'/'.$$temp{'user'}.'/tsv/'.$num[$s][0], 1 );
								&setWarn("		wP       присвоение модификатора $span[4]");
							}
							else {	$span[4] = $$temp{'modifier'} }
						}
	
						#$span[5] = $num[$s][5] if $num[$s][5];
						$num[$s] = \@span
					}
					else{
						&setWarn("		wP      на добавление");
						for my $m ( grep { not ( defined $num[$s][$_] and $num[$s][$_] ) } 1..3){
							&setWarn("		wP       Замена пустого члена $m ");
							$num[$s][$m] = $matrix[$m]
							#if ( $m == 1 ){		$num[$s][1] = $$temp{'fact'}	}
							#elsif ( $m == 2 ){	$num[$s][2] = 'r'				}
							#else { 				$num[$s][3] = $$temp{'quest'}	}
						}
						$num[$s][0] = &setName( 'd', $$temp{'user'}, $num[$s][1], $num[$s][2], $num[$s][3] );
					}
					#$num[$s][4] = $$temp{'user'};
					#$num[$s][4] = $matrix[4] if not $num[$s][4];
					if ( $num[$s][4] ){ &setWarn("		wP      имеется обстоятельство - $num[$s][4] ") }
					if ( not $num[$s][4] ){
						&setWarn("		wP      присвоение номеру обстоятельства - $$temp{'modifier'} ");
						$num[$s][4] = $$temp{'modifier'} 
					}
				}
				$$temp{'modifier'} = 'n' if $num[0][2] eq 'r';
			}
			
		}
	}
	@num || return;
	
	&setWarn( "		wP ## Имеются номера. Идет запись." );
	for my $s ( grep { $num[$_] } 0..$#num ){
		&setWarn("		wP  Проверка номера $s ");
		my $miss;
		if ( $num[$s][5] != 2 and not defined $$temp{'wkhtmltopdf'}  ){#wkhtmltopdf - это костыль, потом нужно убрать инструкции на запись для wkhtmltopdf
			&setWarn("		wP   Проверка собственности при изменениях");
			if ( $num[$s][4] eq 'n' or $num[$s][2] eq 'r' ){ #r - нужен для контроля удаления, в обстоятельствах там может быть что угодно и для этого нельзя проверять or not(num[$s][5]) т.к. удаляться может и параметр в обстоятельствах
				&setWarn("		wP    Проверка подлежащего");
				my $holder = &m8holder( $num[$s][1] );
				if ( $holder ne $$temp{'user'}){
					&setWarn("		wP     Номер запрашивает действие над  подлежащим пользователя $holder");
					$$temp{'povtor'}[$s] = 4;
					$$temp{'number'}[$s]{'message'} = "Номер запрашивает действие над подлежащим пользователя $holder";
					next
				}
			}
			else {
				&setWarn("		wP    Проверка обстоятельства");
				my $holder = &m8holder( $num[$s][4] );
				if ( $holder ne $$temp{'user'} ){
					&setWarn("		wP     Номер запрашивает действие в обстоятельствах пользователя $holder");
					$$temp{'povtor'}[$s] = 4;
					$$temp{'number'}[$s]{'message'} = "Номер запрашивает действие в обстоятельствах пользователя $holder";
					next
				}
			}
		}
		for my $key ( 0..5 ){ 
			if ( $num[$s][$key] ){ 
				&setWarn("		wP   Элемент $key:  $num[$s][$key]");
				$$temp{'number'}[$s]{$number[$key]} = $num[$s][$key] 
			}
			elsif ( $key != 5 ){ 
				$miss = $key;
				&setWarn("		wP   Не найден элемент номера $miss");
			}	
		}
		if ( $miss ){
			$$temp{'povtor'}[$s] = 4;
			$$temp{'number'}[$s]{'message'} = "Не найден элемент номера $miss";
			next
		}
		if ( grep { $s != $_ and $num[$_] and ( $num[$s][0] eq $num[$_][0] ) } 0..$#num ) { 
			&setWarn("		wP   Номер запрашивает повтор трипла в запросе");
			$$temp{'povtor'}[$s] = 1;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор трипла в запросе';
			next;
		}
		if ( $num[$s][0] ne 'd' and $num[$s][1] eq $num[$s][4] ) { 
			&setWarn("		wP   Номер запрашивает нарушение правила иерархии");
			$$temp{'povtor'}[$s] = 3;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает нарушение правила иерархии';
			next;
		}
		if ( $num[$s][2]=~/^r/ and -d 'm8/n/'.$num[$s][1] ){
			&setWarn("		wP   Проверка изменения статуса имеющегося нечто.");
			#my $holder = &m8holder( $num[$s][1] );
			#if ( $holder ne $$temp{'user'} ){
			#	&setWarn("		wP    Номер запрашивает действие над чужим нечто");
			#	$$temp{'povtor'}[$s] = 4;
			#	$$temp{'number'}[$s]{'message'} = 'Номер запрашивает действие над чужим нечто';
			#	next
			#}
			if ( -d $planeDir.'/'.$$temp{'user'}.'/tsv/'.$num[$s][0] ){
				&setWarn("		wP    Проверка трипла $num[$s][0].");	#вероятно всю эту операцию нужно делать в сушке	
				if ( 0 and not $num[$s][5] ){# удалять начальников можно, но в стилях нужно избежать показа их подчиненных
					my %index = &getJSON( &m8dir( $num[$s][1] ), 'index' ); #Нельзя удалять объект имеющий подчиненных
					if ( defined $index{'director'} ){
						$$temp{'povtor'}[$s] = 3;
						$$temp{'number'}[$s]{'message'} = 'Номер запрашивает удаление директора';
						next
					}
					if ( defined $index{'object'} ){
						$$temp{'povtor'}[$s] = 3;
						$$temp{'number'}[$s]{'message'} = 'Номер запрашивает удаление лидера';
						next
					}
				}
				my ( $oldDirector ) = &getDir( $planeDir.'/'.$$temp{'user'}.'/tsv/'.$num[$s][0], 1 );
				if ( $oldDirector ){
					&setWarn("		wP     Удаление старой связи состава $num[$s][0].");	
					my @triple = ( $num[$s][0], $num[$s][1], $num[$s][2], $num[$s][3], $oldDirector );
					#push @num, \@triple;
					&spinProc( \@triple, $$temp{'user'}, $$temp{'time'}, 713 );
					if ( defined $$temp{'object'} ){
						&setWarn("		wP      Добавление к новой связи состава указания такого же типа.");
						$num[$s][3] = $num[$s][4];#$$temp{'object'};
						$num[$s][0] = &setName( 'd', $$temp{'user'}, $num[$s][1], $num[$s][2], $num[$s][3] );
					}			
				
				}
			}
		}
		if ( &spinProc( $num[$s], $$temp{'user'}, $$temp{'time'}, 723 ) ){
			&setWarn("		wP   Номер запрашивает повтор трипла в базе.");
			$$temp{'povtor'}[$s] = 2;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор установления значения';
		}
	}
	return if 1 or -e $configPath.'/control' or not grep { $$temp{'number'}[$_] eq 'OK' } @{$$temp{'number'}};
	
	&setWarn('   Обнаружены физические записи. Запуск процесса сушки');
	eval{ system( 'perl.exe M:\system\reg.pl dry >/dev/null 2>M:\_log\error_dry.txt' ); }	
}



sub rinseProc {
	my ( $name, @div )=@_;
	&setWarn("		rP @_"  );
	if ($div[0]=~/^\<svg/){
		&setWarn("		rP  запись xml-файла напрямую"  );
		&setFile( &m8dir( $name ).'/value.xml', '<?xml version="1.0" encoding="UTF-8"?><value id="'.$name.'">'.$div[0].'</value>' );
	}
	else{
		&setWarn("		rP  формировани xml-файла"  );
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

}

sub rinseProc3 {
	my ( %type )=@_;
	&setWarn("		rP2 @_"  );
	my %xsl_stylesheet;
	$xsl_stylesheet{'xsl:stylesheet'}{'version'} = '1.0';
	$xsl_stylesheet{'xsl:stylesheet'}{'xmlns:xsl'} = 'http://www.w3.org/1999/XSL/Transform';
	my $x = 0;
	for my $typeName ( keys %type ){
		$xsl_stylesheet{'xsl:stylesheet'}{'xsl:param'}[$x]{'name'} = $typeName;
		$xsl_stylesheet{'xsl:stylesheet'}{'xsl:param'}[$x]{'select'} = "'$type{$typeName}'";
		$x++
	}
	my $XML = $XML2JSON->json2xml( $JSON->encode(\%xsl_stylesheet) );
	&setFile( $typesDir.'/type.xsl', $XML );
	&setXML( $typesDir, 'type', \%type );
}

sub spinProc {
	my ( $val, $user, $time, $dry )=@_;
	&setWarn("
		sP @_"  );
	#if ( $$val[] ){
	if ( $$val[5] ){
		for my $key ( 0..5 ){ 
			&setWarn("		sP  Значение на сушку $key: $$val[$key]"  )
			#else { warn "delete $key - $$val[$key]"
		}	
	}
	else{ warn " DEL ($time / $dry): @{$val}" }
	my ( $name, $subject, $predicate, $object, $modifier, $add ) = ( $$val[0], $$val[1], $$val[2], $$val[3], $$val[4], $$val[5] );
	#$add = 1 if $add;
	my @value = ( $name, $subject, $predicate, $object, $modifier, $user );
	my $quest = $modifier;
	if ( $predicate eq 'r' ){
		$value[4] = $quest = 'n';
		push @value, ( $subject, $predicate, $object, $modifier )
	}
	my $mainDir = &m8dir( $subject, $quest );
	my $good;
	#if (-d $mainDir){
	my %port = &getJSON( $mainDir, 'port' );
	if ( $add ){
		&setWarn("		sP  Поиск такого же значения в порту директории $mainDir"  );
		if ( defined $port{$predicate} ){
			&setWarn("		sP   Анализ значения"  );
			my @oldObject = keys %{$port{$predicate}[0]};
			my $oldObject = $oldObject[0];
			my @oldTriple = keys %{$port{$predicate}[0]{$oldObject}[0]};
			my $oldTriple = $oldTriple[0];
			my $oldTime = $port{$predicate}[0]{$oldObject}[0]{$oldTriple}[0]{'time'};
			if ( $time < $oldTime ){ 
				warn " DELETE OLD ( $time < $oldTime ): @{$val} \n";
				$add = undef;
				$good = 1;
				#warn " DELETE OLD $planeDir/$user/tsv/$name/$modifier"
			} #имеющееся значение новее текущего
			elsif ( $oldObject eq $object ){ 
				#warn " REPET RECORD ($time): @{$val} \n";
				$good = 1 } # or $$val[2] = 'r' повтор, пропускаем реиндексацию, но (излишне?) перезаписываем базу
			else{
				&setWarn("		sP    Удаление старого значения"  );
				my $oldModifier = $modifier;
				$oldModifier = &m8director( $subject ) if $predicate eq 'r';
				my @triple = ( $oldTriple, $subject, $predicate, $oldObject, $oldModifier );
				warn " NEW VALUE ($time): @{$val} \n";
				&spinProc ( \@triple, $user, $oldTime, 809 );
			}
		}
	}
	elsif ( not defined $port{$predicate} or not defined $port{$predicate}[0]{$object} ){ $good = 1 }
	#return 0 if $dry eq 809;
	#}
	#my @value = ( $name, $subject, $predicate, $object, $modifier, $user );
	if (not $good){
	#push @value, ( $subject, $predicate, $object ) if $predicate=~/^r\d*$/;
	for my $mN ( grep { $value[$_] } 0..$#value ){
		&setWarn("		
		sP  Обработка упоминания cущности $mN: $value[$mN] (user: $user)"  );
		my $addC = $add || 0; #заводим отдельный регистр, т.к. $add должен оставаться с значением до цикла
		my $metter = &getID($value[$mN]);
		#&setLink( $planeRoot.'m8',	$planeRoot.$auraDir.'/m8'			);
		#&setLink( $planeRoot.'m8/n', 	$metter.'/q' ) if $value[$mN]=~/^n/ and $add;
		my $type = $superrole[$mN];
		my ( $role, $file, $first );
		if ( $mN == 0 ){	( $role, $file, $first ) = ( 'activate',	'activate'				, $quest ) }
		elsif ( $mN < 4 ) {	( $role, $file, $first ) = ( 'role'.$mN,	'role'.$mN 				, $quest ) }
		elsif ( $mN == 4 ){ ( $role, $file, $first ) = ( 'quest',		'quest'					, $subject ) }#вероятнее всего, здесь subject нужно поменять на name		
		elsif ( $mN == 5 ){ ( $role, $file, $first ) = ( 'author',		'author'				, $quest ) }
		elsif ( $mN == 6 ){ ( $role, $file, $first ) = ( $predicate,	'subject_'.$predicate	, $quest ) }
		elsif ( $mN == 7 ){	( $role, $file, $first ) = ( $object,		'predicate_'.$object	, $quest ) }
		elsif ( $mN == 8 ){	( $role, $file, $first ) = ( $subject, 		'object_'.$subject		, $quest ) } 
		elsif ( $mN == 9 ){	( $role, $file, $first ) = ( $subject, 		'director_'.$subject	, $quest ) } 
		
		if ( $mN == 1 or $mN == 2 or $mN == 3  ){
			&setWarn("		sP   Формирование порта/дока/терминала $role ($file, $first).  User: $user"  );
			
			my ( $master, $slave );
			if ( $mN == 1 )		{ ( $master, $slave ) = ( $predicate, 	$object 	) }
			elsif ( $mN == 2 )	{ ( $master, $slave ) = ( $subject, 	$object 	) }
			elsif ( $mN == 3 ) 	{ ( $master, $slave ) = ( $subject, 	$predicate 	) }
			my %role = &getJSON( $metter.'/'.$quest, $superfile[$mN] );
			if ( $addC ){
				&setWarn("		sP    Операции при добавлении значения в индекс $metter/$quest  ($master, $slave)"  );
				$role{$master}[0]{$slave}[0]{$name}[0]{'time'} = $time;
			}
			else { 
				&setWarn("		sP    Операции при удалении значения. Удаление ключа $master"  );
				delete $role{$master} ; 
				$addC = 1 if keys %role; 
			} 
			&setXML ( $metter.'/'.$quest, $superfile[$mN], \%role );
		}
		my %role1 = &getJSON( $metter, $file );
		if ( $addC ) {#==1
			&setWarn("		sP   Счетчик упоминаний не пустой - дополняем/обновляем индекс-файл роли $role ($file, $first)"  );
			$role1{$first}[0]{'time'} = $time;
			$role1{$first}[0]{'triple'} = $name;
			if ( $mN == 6 ){
				$role1{$first}[0]{'holder'} = $user;
				$role1{$first}[0]{'director'} = $modifier;# if $modifier ne 'n';
			}
		}
		else {
			&setWarn("		sP   Счетчик упоминаний пустой - сокращаем индекс-файл роли"  );
			delete $role1{$first};
			#if ( not grep {$_ ne 'time'} keys %{$role1{$first}[0]} ){
			#	delete $role1{$first};		
			#}			
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
	my $questDir = $planeDir.'/'.$user.'/tsv/'.$name.'/'.$modifier;
	if ( $add ){
		&setWarn("		sP   Добавление директории $questDir в базу");
		&setFile ( $questDir.'/time.txt', $time ); #ss
	}
	else{
		&setWarn("		sP   Удаление директории $questDir из базы");
		rmtree $questDir;
		if ( not &getDir ( $planeDir.'/'.$user.'/tsv/'.$name, 1 ) ){
			rmtree $planeDir.'/'.$user.'/tsv/'.$name;
			if ( not &getDir( $planeDir.'/'.$user.'/tsv', 1 ) ){
				&setXML( 'm8/d/'.$value[0], 'value' );
				rmtree $planeDir.'/'.$user.'/tsv';
			}
			if ( -e $typesDir.'/'.$typesFile and $value[3]=~/^i/ ){ #Эту проверку нужно делать в сушке, т.к. она нужна и при замене старого значения
				&setWarn("		sP    Проверка на идентификатор-тип");
				my @val = &getFile( $planeDir.'/'.$user.'/tsv/'.$value[3].'/value.tsv' );
				my %types = &getJSON( $typesDir, 'type' );
				if ( $val[1] and $val[1]=~/^xsd:/ ){
					delete $types{$val[0]};
					&setXML( $typesDir, 'type', \%types );
					&rinseProc3( %types )
				}
			}
		}
	}
	return 0;
	&setWarn("		sP @_ (END)
	"  );	
}

sub dryProc2 {
	my ( $reindex )=@_; #$param
	#&setWarn("		dP 2 @_" );
	$dbg = 0;
	#rmtree $logPath if -d $logPath;
	#:: емкости и резервуары n1477307416-546366-pgstn-0
	#:: огнезащита воздуховода n1477308145-515249-pgstn-0
	-d $logPath || make_path( $logPath, { chmod => $chmod } );
	#make_path( $logPath, { chmod => $chmod } );
	open (REINDEX, '>'.$logPath.'/reindex.txt')|| die "Ошибка при открытии файла $logPath/reindex.txt: $!\n";
	warn '		DRY BEGIN ';	
	#mode1 - удаляется и переиндексируется все
	#mode2 - только удаляется мусор (в штатном режиме имеет смысл только для доудаления гостевых триплов)
	#@user - Если указаны то только они будут сохранены
	#chdir "W:";
	if ( -e $platformGit and 0 ){
		print REINDEX "  Check platform \n";
		copy $platformGit, '/var/www/m8data.com/master';
	}
	if ( not -d 'm8' and 0 ){ #опция отключена 2016-10-05
		warn 'check tempfsFolder';
		my $tempfsFolder = &getSetting('tempfsFolder');
		if ( -d $tempfsFolder.'/m8'.$prefix ){
			warn 'link from '.$disk.$tempfsFolder.'/m8'.$prefix;
			&setLink( $disk.$tempfsFolder.'/m8'.$prefix, 	$planeRoot.'m8' )
		}
		else {
			warn 'add '.$planeRoot.'m8';
			make_path( $planeRoot.'m8', { chmod => $chmod } )
		}
	}
	else { make_path( $planeRoot.'m8', { chmod => $chmod } ) }
	#&setFile( '.htaccess', 'DirectoryIndex '.$prefix.'formulyar/reg.pl' );
	
	-d $auraDir || make_path( $auraDir, { chmod => $chmod } );
	-d 'formulyar' || make_path( 'formulyar', { chmod => $chmod } );
	-d $planeDir.'/'.$defaultUser || make_path( $planeDir.'/'.$defaultUser, { chmod => $chmod } );
	&setLink( $planeRoot.'m8',					$planeRoot.$auraDir.'/m8'			);
	&setLink( $planeRoot.$planeDir, 			$planeRoot.$planeDir_link 			);
	#&setLink( $planeRoot.'formulyar', 			$planeRoot.$planeDir.'/formulyar' 	);
	&setLink( $multiRoot.$branche.'/'.$univer, 	$planeRoot.$planeDir.'/'.$univer 	);
	if ( -e $planeDir.'/'.$univer.'/formulyar.conf' ){
		warn ('  Reed formulyar.conf');
		for my $site ( &getFile( $planeDir.'/'.$univer.'/formulyar.conf' ) ){
			$site=~/^(\w+)-*(.*)$/;
			my $univer_depend = $1;
			my $branch_depend = $2 || 'master';
			&setLink( $multiRoot.$branch_depend.'/'.$univer_depend, 	$planeRoot.$planeDir.'/'.$univer_depend );
		}
	}
	my @ava = &getDir( $planeDir, 1 );
	my %controller;
	for my $ava ( @ava ){
		$controller{$ava} = 1 if -e $planeDir.'/'.$ava.'/xsl/'.$ava.'.xsl';
		-d $auraDir.'/'.$ava || make_path( $auraDir.'/'.$ava, { chmod => $chmod } );
		&setLink( $planeRoot.'m8', $planeRoot.$auraDir.'/'.$ava.'/m8' );
		-e $userDir.'/'.$ava.'/'.$passwordFile || &setFile( $userDir.'/'.$ava.'/'.$passwordFile );
	}
	&setXML( $planeDir, 'controller', \%controller );
	for my $format ( keys %formatDir ){
		&setLink( $planeRoot.$auraDir, $planeRoot.$format );
	}
	$reindex || return;
	my %stat;

	my $guestDays = &getSetting('guestDays');
	my $userDays = &getSetting('userDays');
	my $guestTime = time - $guestDays * 24 * 60 * 60;
	my $userTime = time - $userDays * 24 * 60 * 60;
	if ( $reindex == 2 or 0 ){
		warn '		delete all index';
		for my $d ( &getDir( 'm8' ) ){
			if ( -d 'm8/'.$d ){ 
				
				rmtree 'm8/'.$d 
			}
			else { unlink 'm8/'.$d }
		}
	}
	my %dry;
	my %userType;
	my %types;
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

	for my $sessionName ( &getDir( $sessionPath, 1 ) ){ 
		print REINDEX "sessionName	$sessionName \n";
		warn '		sessionName  '.$sessionName;
		$cookie++;
		my $cUser = &getFile( $sessionPath.'/'.$sessionName.'/value.txt' );
		my $tempKeysFile = $userDir.'/'.$cUser.'/'.$sessionFile;
		if ( -e $tempKeysFile ){
			my %tempkey = &getHash( $tempKeysFile );
			if ( not defined $tempkey{$sessionName} or $tempkey{$sessionName} < $userTime ){
				rmtree $sessionPath.'/'.$sessionName;
				$DL_cookie++
			}
		}
		else {
			rmtree $sessionPath.'/'.$sessionName;
			$DL_cookie++
		}		
	}	
	print REINDEX "\n Круг1 \n";
	warn "		\n==== Round 1 ====\n  ";
	my $time1 = time;
	for my $userName ( grep{ not /^_/ and $_ ne 'formulyar' } &getDir( $planeDir, 1 ) ){  # 
		print REINDEX "\n userName	$userName \n";
		warn "		\n userName  $userName";
		if ( -e $planeDir.'/'.$userName.'/.git/refs/heads/'.$branche ){
			print REINDEX "    Копирование указателя состояния ветки $branche";
			warn '	Copy of branche head  ';
			copy $planeDir.'/'.$userName.'/.git/refs/heads/'.$branche, $userDir.'/'.$userName.'/'.$branche;
		}
		#next if $userName eq $defaultAvatar;
		
		my $tsvPath = $planeDir.'/'.$userName.'/tsv';
		&setFile( $tsvPath.'/d/n/time.txt', '0.1' );
		&setFile( $tsvPath.'/d/value.tsv', ( join "\t", @mainTriple ) );
		&setFile( $tsvPath.'/i/value.tsv' );
		
		if ( not defined $stat{$userName} ){
			for ( 'add', 'n_delR', 'n_delN' ){ $stat{$userName}{$_} = 0 }
		}
		for my $tsvName ( &getDir( $tsvPath, 1 ) ){
			print REINDEX "   Исследование tsv-шки $tsvName \n";
			warn '	tsv  '.$tsvName;
			if ( not -e $tsvPath.'/'.$tsvName.'/value.tsv' ){
				warn 'Error: no value.tsv file';
				print REINDEX "   Error: no $tsvPath/$tsvName/value.tsv file \n";
				rmtree $tsvPath.'/'.$tsvName;
				next;
			}
			$all++;
			my @div = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$tsvName.'/value.tsv' );
			&rinseProc( $tsvName, @div );
			next if $tsvName=~/^i/;	
			my @val = split "\t", $div[0];
			unshift @val, $tsvName;
			$val[4] = $userName;
			$triple++;
			if ( $val[3] =~/^i\d+$/ ){
				my @map = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$val[3].'/value.tsv' );
				$userType{$userName}{$val[3]} = $map[0] if $map[1] and $map[1]=~/^xsd:\w+$/;
				$types{$map[0]} = $val[1] if $map[1] and $map[1]=~/^xsd:\w+$/;
			}
			if (1){
			for my $questName ( &getDir( $tsvPath.'/'.$tsvName, 1 ) ){
				print REINDEX "    Исследование квеста $questName \n";
				$val[4] = $questName;
				my ( $timeProc ) = &getFile( $tsvPath.'/'.$tsvName.'/'.$val[4].'/time.txt' );
				if ( $val[0] ne 'd' and $val[1] eq $val[4] ){
					#корректировка формата данных 2016-10-07
					warn "	!!! refresh: @val";
					rmtree $tsvPath.'/'.$tsvName.'/'.$val[4];
					if ( $val[2] eq 'r' ){ $val[4] = $val[3]; }
					else { $val[4] = 'n'}
					&setFile( $tsvPath.'/'.$tsvName.'/'.$val[4].'/time.txt', $timeProc )
				}
				if ( $userName eq 'guest' and $tsvName ne 'd' and $timeProc and $timeProc < $guestTime ){ 
					print REINDEX "     Удаление старого гостевого трипла '.$div[0].' \n";
					$n_delG++
				}
				else {
					$val[5] = 1;
					print REINDEX "     Реиндексация значений @val \n"; # d1341061753575729161 d14757079324734822550
					$stat{$userName}{'add'}++;
				}
				&spinProc( \@val, $userName, $timeProc, 1094 );
			}
			}
		}
	}
	print REINDEX "\n Круг2 \n";
	warn "		\n==== Round 2 ====\n  ";
	my $time2 = time;
	if (1){
	for my $userName ( grep{ not /^_/ and $_ ne 'formulyar' } &getDir( $planeDir, 1 ) ){ 
		print REINDEX "userName2	$userName \n";
		warn "\n		userName2  $userName \n";
		my $tsvPath = $planeDir.'/'.$userName.'/tsv';
		for my $tsvName ( &getDir( $tsvPath, 1 ) ){ 
			warn '	tsv2  '.$tsvName;
			print REINDEX "  tsv2	$tsvName \n";
			if ( $tsvName=~/^i/ ){
				if ( not -e &m8path( $tsvName, 'index' ) and $tsvName ne 'i' ){
					rmtree $tsvPath.'/'.$tsvName;
					rmtree &m8dir( $tsvName );
					$DL_map++
				}
			}
			elsif ( $tsvName=~/^d/ ){
				print REINDEX "    Исследование трипла $tsvName \n";			
				my @val = map{ Encode::decode_utf8($_) } &getTriple( $userName, $tsvName );
				my $parent = $val[1];
				#$val[4] = $userName;
				for my $questName ( &getDir( $tsvPath.'/'.$tsvName, 1 ) ){
					print REINDEX "     Исследование квеста $questName \n";
					$val[4] = $questName;
					#if(0){
					#	if ( $val[2]=~/^r/ ){
					#		next if $val[1] eq $val[5];
					#		$parent = $val[5];
					#	}
					#	my %indexParent = &getJSON( &m8dir( $parent ), 'index' );
					#	my %indexQuest = &getJSON( &m8dir( $questName ), 'index' );
					#	next if defined $indexParent{'subject'} and defined $indexQuest{'subject'};
					#}
					#else{
						my $good = 1;
						for my $n ( grep { $val[$_]=~/^n/ and $good } 1..4 ){
							next if $n == 1 and $questName ne 'n'; #подлежащее имеет право быть удаленным, если оно мульт
							my $dirr = &m8dir( $val[$n] );
							print REINDEX "      Исследование роли $n: $val[$n] в папке $dirr \n";
							my %index = &getJSON( &m8dir( $val[$n] ), 'index' );
							if ( not defined $index{'subject'} ){
								$good = 0; 
								print REINDEX "       Cущность удалена. Номер испорчен. \n";
								warn "  No find $val[$n]. Delete nechto"
								#for my $key ( %index ){
								#	print REINDEX "       key: $key => $index{$key} \n";
								#}
							}
						}
						next if $good;
					#}
					my ( $timeProc ) = &getFile( $tsvPath.'/'.$tsvName.'/'.$val[4].'/time.txt' );
					if ( $val[3] =~/^i\d+$/ ){
						my @map = map{ Encode::decode_utf8($_) } &getFile( $tsvPath.'/'.$val[3].'/value.tsv' );
						delete $userType{$userName}{$val[3]} if $map[1]=~/^xsd:\w+$/;
						delete $types{$map[0]} if $map[1]=~/^xsd:\w+$/;
					}
					&spinProc( \@val, $userName, $timeProc, 1156 );
					if ( $val[2]=~/^r/ ){ $stat{$userName}{'n_delR'}++ }
					else { $stat{$userName}{'n_delN'}++ }
				}
			}
		}

	#}
	}
	}
	my $time3 = time+1;
	&rinseProc3( %types );# if keys %types;

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




sub parseNew {
	my ( $temp, $pass )=@_;
	&setWarn( "			pN @_" );	
	if ( defined $$temp{'login'} ){ 
		&setWarn('			pN   Вход ранее созданного пользователя');
		if ($$temp{'login'} ne 'guest'){
			defined $$pass{'password'} and $$pass{'password'} || return 'no_password';
			my $userPath = $userDir.'/'.$$temp{'login'};
			-d $userPath && -d $planeDir.'/'.$$temp{'login'} || return 'no_user';
			my $password = &getFile( $userPath.'/'.$passwordFile );
			$password = &getSetting('userPassword') if $password eq '';
			$password eq $$pass{'password'} || return 'bad_password';
		}
	}
	elsif ( defined $$temp{'new_author'} ){
		&setWarn('			pN   Создание автора');
		$$temp{'new_author'} =~/^\w+$/ || return 'В имени могут быть лишь буквы латинского алфавита и цифры.';
		34 >= length $$temp{'new_author'} || return 'Имя не должно быть длиннее 34 символов.';
		return 'Такой пользователь уже существует' if -d $userDir.'/'.$$temp{'new_author'};
		defined $$pass{'new_password'} and $$pass{'new_password'} || return 'Введите пароль';
		defined $$pass{'new_password2'} and $$pass{'new_password2'} || return 'Введите пароль с повтором';		
		$$pass{'new_password'} eq $$pass{'new_password2'} || return 'Пароль повторен не верно';
	}	
	return 0
}




######### функции второго порядка ##########
sub m8path {
	my @level = @_;
	my $path = 'm8/';
	if ( @level ){
		$path .= substr( $level[0], 0, 1 ).'/';
		$path .= join '/', @level
	}
	#if ( $level2 ){
	#	$path = 'm8/'.substr($level1,0,1).'/'.$level1.'/'.$level2;
		#if ( $level4 ){ 	$path .= '/'.$level3.'/'.$level4 }
	#	if ( $level3 ){	$path .= '/'.$level3 }
	#}
	#else { $path = $userPath.'/'.$level1.'/type' }
	return $path.'.xml'
}
sub m8dir {
	my ( $fact, $quest ) = @_;
	my $dir = 'm8/'.substr($fact,0,1).'/'.$fact;
	$dir .= '/'.$quest if $quest; 
	return $dir
}
sub m8req {
	my ( $temp ) = @_;
	my $dir = $auraDir.'/'.$$temp{'ctrl'}.'/m8/'.substr($$temp{'fact'},0,1).'/'.$$temp{'fact'}.'/';
	if ( defined $$temp{'number'} ){
		$dir .= '?';
		$dir .= 'modifier='.$$temp{'modifier'} if $$temp{'modifier'} ne 'n';
		$dir .= '&error='.$$temp{'number'}[0]{'message'} if defined $$temp{'number'}[0]{'message'};
	}
	return $dir;
}
sub m8holder {
	&setWarn( "			m8holder @_" );	
	my ( $fact ) = @_;
	my %subject = &getJSON( &m8dir( $fact ), 'subject_r' );
	return $subject{'n'}[0]{'holder'}
}
sub m8director {
	&setWarn( "			m8director @_" );	
	my ( $fact ) = @_;
	my %subject = &getJSON( &m8dir( $fact ), 'subject_r' );
	return $subject{'n'}[0]{'director'}
}



sub setFile {
	my ( $file, $text, $add )=@_;
	#&setWarn( "						sF @_" );
	
	my @path = split '/', $file;
	my $fileName = pop @path;
	if ( @path ){
		my $dir = join '/', @path;
		-d $dir || make_path( $dir, { chmod => $chmod } );
	}
	my $mode = '>';#>:encoding(UTF-8)
	if ( $add ){ $mode = '>'.$mode }
	elsif ( -e $file  ){
		#my @result = ;
		my $result = join '\n', &getFile( $file );
		if ( not $text and not $result ){ return }
		elsif ( $text and $result and ( $result eq $text ) ){ return $text }
		else { unlink $file }
	}
	open (FILE, $mode, $file )|| die "Error opening file $file: $!\n";
		if ($text){
			chomp $text;
			print FILE $text; #на входе может быть '0' поэтому не просто "if $text"
			print FILE "\n" if $add;
		}
	close (FILE);
	if ( $dbg and $file=~/.xml$/ ){
		-d $trashPath || make_path( $trashPath, { chmod => $chmod } );
		#my $file = $trashPath.'/'.$path[$#path].'_'.$fileName;
		copy $file, $trashPath.'/'.$path[$#path].'_'.$fileName;
		#open (FILE, $mode, $file )|| die "Error opening file $file: $!\n";#$path[2].'-'.
		#	print FILE $text if $text;
		#	print FILE "\n" if $add;
		#close (FILE);
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
			for ( 1..$#path ){	$hash{$root}{$level[$_]} = $path[$_] }
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
	my ( $type, $user, @value )=@_;
	&setWarn( "					sN @_" );
	my $name;
	my $tsvPath = $planeDir.'/'.$user.'/tsv';
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
	-d $logPath || mkdir $logPath;
	my @c = caller;
	if ($logFile){
		$log = $logFile;  #что бы записи отладки для контроля и другого шли в разные логи
		unlink $log if -e $log;
	}
	my $time = time;
	#$text = Encode::decode_utf8($text);
	open( FILE, ">>", $log ) || die "Ошибка при открытии файла $log: $!\n"; #:utf8 без :utf8 выдает ошибку "wide character..."
		#$text = Encode::decode_utf8($c[2].' '.$text);
		print FILE $text, "\n";#  $c[3], ' ' - секунда
	close (FILE);
}
sub setMessage {
	open (REINDEX, '>>reindex.txt')|| die "Ошибка при открытии файла reindex.txt: $!\n";
		print REINDEX $_[0]."\n";#  $c[3], ' ' - секунда
	close (REINDEX);
}
sub setLink {
	my ( $fromPhysic, $toLink )=@_;
	if ( -d $toLink ){
		if ( readlink( $toLink ) ne $fromPhysic ){
			rmdir $toLink;
			symlink( $fromPhysic => $toLink )
		}
	}
	else{ symlink( $fromPhysic => $toLink ) }
}


sub getID {
	my ( $name )=@_;
#	&setWarn("						gI  @_" );
	if ( $name=~m!^/m8/[dirn]/[dirn][\d\w_\-]*$! or $name=~m!^/m8/author/[a-z]{2}[\w\d]*$! ){ $name=~s!^/!!; return $name }
	elsif( $name=~m!^([dirn])[\w\d_\-]*$! ){ return 'm8/'.$1.'/'.$name }
	else{ return $userPath.'/'.$name }
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
sub getSetting {
	my ( $key ) = @_;
	&setWarn("						getSetting  @_" );	
	if ( -e $configPath.'/'.$key.'.txt' ){ $setting{$key} = &getFile( $configPath.'/'.$key.'.txt' ) }
	else { &setFile( $configPath.'/'.$key.'.txt', $setting{$key} ) }
	return $setting{$key}
}
sub getDoc {
	my ( $temp, $adminMode, $xslFile )=@_;
	my $doc = XML::LibXML::Document->new( "1.0", "UTF-8" );
	$$temp{'quest'} = $$temp{'modifier'} if defined $$temp{'modifier'};
	my $rootElement = $doc->createElement($$temp{'fact'});
	$doc->addChild($rootElement);
	if ( defined $$temp{'number'} ){
		&setWarn('     Идет выдача отладочной информации '.$$temp{'number'} );
		foreach my $s ( 0..$#{$$temp{'number'}} ){
			&setWarn("      Передача в темп-файл информации о созданном номере $s");
			my $tripleElement = $doc->createElement('number');
			foreach my $key ( keys %{$$temp{'number'}[$s]} ){
				$tripleElement->setAttribute($key, $$temp{'number'}[$s]{$key});
			}
			$tripleElement->appendText($s);
			$rootElement->addChild($tripleElement);
		}
		delete $$temp{'number'}
	}
	$rootElement->appendText('_');
	for my $param ( grep {$$temp{$_}} keys %{$temp} ) {	$rootElement->setAttribute( $param, $$temp{$param} ) }
	my $localtime = localtime($$temp{'time'}); 
	$rootElement->setAttribute( 'localtime', $localtime );
	if ($xslFile){
		&setWarn('      Подготовка преобразования на клиенте');
		my $pi = $doc->createProcessingInstruction("xml-stylesheet"); #нельзя добавлять в конце поэтому добавляем вручную
		$pi->setData(type=>'text/xsl', href => $xslFile);
		$doc->insertBefore($pi, $rootElement);
	}
	my $pp = XML::LibXML::PrettyPrint->new();
	$pp->pretty_print($rootElement);
	
	my $tempFile = $logPath.'/temp.xml';
	copy( $tempFile, $tempFile.'.xml' ) or die "Copy failed: $!" if -e $tempFile;
	#copy( $tempFile, $tempFile.'.xml' ) if -e $tempFile and $adminMode;
	&setFile( $tempFile, $doc );
	return $doc
}
sub getAvatar {
	&setWarn("		gA @_");
	my $setxml = $_[0];
	my %avatar;
	my $count = 0;
	my $ava;
	for my $avatarName ( grep { not /^_/ and -e $planeDir.'/'.$_.'/'.$stylesheetDir.'/title.txt' } &getDir( $planeDir, 1 ) ){
		&setWarn ("		getAvatar   Найден аватар $avatarName");
		$avatar{'unit'}[$count]{'id'} = $avatarName;
		$avatar{'unit'}[$count]{'title'} = Encode::decode_utf8( &getFile( $planeDir.'/'.$avatarName.'/'.$stylesheetDir.'/title.txt' ) );
		$ava = $avatarName if $avatarName ne $startAvatar;
		$count++;
	}
	&setXML ( 'm8', 'avatar', \%avatar ) if $setxml;
	return $ava;
}
sub getTriple {
	&setWarn("		gT @_");
	my ( $user, $name )=@_;
	my $val = &getFile( $planeDir.'/'.$user.'/tsv/'.$name.'/value.tsv' );
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