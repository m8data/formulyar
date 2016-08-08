#!/usr/bin/perl -w
#!/strawberry/perl/bin/perl 

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

use Time::HiRes qw(gettimeofday);


#use utf8;
#binmode(STDOUT,':utf8');

#use utf8;
#use open ':encoding(utf8)';
#use Encode qw(encode_utf8);

#u; se LWP::Simple;# qw(!head)-w приводит к морганию dos-окном в windows
umask 0;
#my $cgi = CGI->new();
#		print $cgi->header(-type => 'text/html' );
#		$cgi->charset('utf-8');
#		print '<html><head><meta charset="utf-8"/></head><body>';	
#		print "ss";
#		print '</body></html>';

#use Win32::Symlink;
BEGIN {
   if ($^O eq 'MSWin32'){
      require Win32::Symlink;
      Win32::Symlink->import();
   }
}


#binmode(STDOUT, ":encoding(UTF-8)");

#my @v =('m8', 	#0 - имя системы
#	'frame', 		#1 - базовый атрибут в r1/карте - определяет в контексте какого адреса пришел список (для запроса - некогда или пусто, для остальных - класс объектов)   
#);
my $chmod = 0777;
my $dbg = 1;
my $avatars = '/a';#'/a'; #убрали по новой модели 01.12.2015
my $defaultAvatar = 'system'; #вообще его можно и лучше брать из SCRIPT_NAME 
my $defaultAuthor = 'guest';
my $defaultFact = 'n';
my $admin = 'admin';
my $canonicalHomeAvatar = 'system';	
my $tNode = '$t';
my @level = ( 'system', 'prefix', 'fact', 'author', 'quest' );
my @role = (	'triple', 	'role1', 	'role2', 		'role3', 	'author', 'quest', 'target' );#$tNode
my @number = (	'name',		'subject', 	'predicate',	'object',	'author', 'quest', 'add' );#$tNode
#my @param = ( 'time', 'process' ); #, 'number' 'avatar', 
my @clientENV = ();#'HTTP_USER_AGENT', 'HTTP_ACCEPT_LANGUAGE', 'REMOTE_ADDR'
my @transaction = ( 'REMOTE_ADDR', 'HTTP_USER_AGENT', 'DOCUMENT_ROOT', 'REQUEST_URI', 'QUERY_STRING', 'HTTP_COOKIE', 'REQUEST_METHOD', 'HTTP_X_REQUESTED_WITH', @clientENV );#, 'HTTP_USER_AGENT', 'HTTP_ACCEPT_LANGUAGE', 'REMOTE_ADDR' $$transaction{'QUERY_STRING'}
#my $reqnew;
my @mainTriple = ( 'n', 'r', 'i' );
my %formatDir = ( '_doc', 1, '_json', 1, '_pdf', 1 );
my $type = 'xml';
#my $time = time;
my ($time, $microseconds) = gettimeofday;
my $localtime = localtime($time);

my $logDir = '../log';
my $userDir = 'm8/author';
my $baseDir = 'base';

my $errorLog = $logDir.'/error_log.txt';
my $logName = 'data_log.txt';
my $log = $logDir.'/'.$logName;
my $log1 = $logDir.'/control_log.txt';
my $guest_log = $logDir.'/guest_log.txt';


my $trashDir = $logDir.'/trash'; #$systemDir.'/$'$baseDir.
#my $universeDir = $baseDir;
my $universePath = $baseDir.'/universe';

my $ROOT_DIR;
#my $comand = 'perl.exe M:\system\reg.pl scontrol  2>m:\_log\error.txt';
#my $file = "M:/_log/sec.txt";
#my $fileSystem = 'cp1251';
#my $fileSystem = 'UTF-16';

	
my %temp;

#chdir $Disk;
#rmtree( $trashDir ) if $dbg;
 
my %universe;
%universe = &getHash ( $universePath.'.json' ) if -e $universePath.'.json';

#my $req = new CGI; 
my $JSON = JSON->new->utf8;
my $XML2JSON = XML::XML2JSON->new(pretty => 'true');
#my $DownFile = $req->param('file2'); 


if ( $ARGV[0]   ){#or $ENV{'SERVER_NAME'}=~/^w2./
	chdir $ARGV[0];
	$ROOT_DIR = $ARGV[0].'/';
	#my $proc = $ROOT_DIR=~s!//$!/!;
	&setWarn (' Ответ на запрос с локалхоста', $log1);#здесь вероятно е
	-d 'm8' || make_path( 'm8', { chmod => $chmod });
	-d $logDir || make_path( $logDir, { chmod => $chmod } );
	my @ava = grep { $_ ne $baseDir and $_ ne 'm8' and not defined $formatDir{$_} } &getDir( '.', 1 );
	for my $ava ( @ava ){
		-d $ROOT_DIR.$ava.'/m8' || symlink( $ROOT_DIR.'m8' => $ROOT_DIR.$ava.'/m8' );
	}	
	for my $format ( keys %formatDir ){
		-d $format || make_path( $format, { chmod => $chmod } );
		-d $ROOT_DIR.$format.'/m8' || symlink( $ROOT_DIR.'m8' => $ROOT_DIR.$format.'/m8' );
		for my $ava ( @ava ){
			-d $ROOT_DIR.$format.'/'.$ava || symlink( $ROOT_DIR.$ava => $ROOT_DIR.$format.'/'.$ava );
		}
	}
	#warn "@ARGV";
	if ($ARGV[1]){
		&dryProc2( $ARGV[1] )
	}
	
}
else{
	chdir $ENV{DOCUMENT_ROOT};
	$ROOT_DIR = $ENV{DOCUMENT_ROOT}.'/';
	my $adminMode = $dbg = 1 if 0 or $ENV{'REMOTE_ADDR'} eq "192.168.0.129" or $ENV{'REMOTE_ADDR'} eq "192.168.0.127" or $ENV{'REMOTE_ADDR'} eq "192.168.0.112" or $ENV{'REMOTE_ADDR'} eq "192.168.0.91" or $ENV{'REMOTE_ADDR'} eq "127.0.0.1";
	$temp{'adminMode'} = "true" if $adminMode;
	if (not $adminMode and $ENV{'QUERY_STRING'} and $ENV{'HTTP_FORWARDED'} ne 'for=213.87.144.149'){
		open (FILE, '>>'.$guest_log)|| die "Ошибка при открытии файла $guest_log: $!\n";
			print FILE localtime($time).'	'.$ENV{'REMOTE_ADDR'}.'	'.$ENV{'HTTP_FORWARDED'}.'	'.$ENV{'REQUEST_URI'},  "\n";#  $c[3], ' ' - секунда
		close (FILE);
	}	
	&setFile( $logDir.'/env.json', $JSON->encode(\%ENV) ) if $dbg;
	#&setWarn ( ' Time: '.$localtime );

	my %cookie;
	my $q = CGI->new();
	#print $q->header();
	if ( $ENV{'REQUEST_URI'} =~m!^/_(pdf)/(\w+)/! or $ENV{'REQUEST_URI'} =~m!^/_(doc)/(\w+)/! ){
		my ( $format, $folder ) = ( $1, $2 ); 
		&setWarn( "  Найден запрос $ENV{'REQUEST_URI'} вывода в особом формате $1 (папка: $2)", $log.'_special.txt' );#	
		my $req = $ENV{'REQUEST_URI'};
		$req =~s!/_$format!!;
		
		my @request_uri = split /\?/, $req;
		&setWarn( "  перевод на $request_uri[0] (формат: $format)" );#
		#copy( $log, $log.'.txt' ) or die "Copy failed: $!" if $dbg;
		#copy( $log, $log.'.txt' ) or die "Copy failed: $!" if $dbg;
		#&setWarn( " Отправка в веб-кит запроса $ENV{HTTP_HOST}.$req.' '.$request_uri[0]" );#
		$request_uri[0] =~s!^/!!;
		if ( $format eq 'pdf' ){
			&setWarn( "   Формирование pdf-файла запросом $ENV{HTTP_HOST}$req" );#
			system ( 'wkhtmltopdf '.$ENV{HTTP_HOST}.$req.' '.$ROOT_DIR.$request_uri[0].'/report.pdf'.' 2>'.$ROOT_DIR.$logDir.'/wkhtmltopdf.txt' );
			#system ( 'wkhtmltopdf localhost'.$req.' '.$request_uri[0].'/report.pdf'.' 2>/_log/wkhtmltopdf.txt' );
		}
		elsif ( $format eq 'doc' ){
			&setWarn( "   Формирование doc-файла" );#
			&initProc( \%temp, \%cookie, $time, $microseconds );
			$temp{'format'} = 'doc';
			
			rmtree $request_uri[0].'/report' if -d $request_uri[0].'/report'; 
			dircopy $folder.'/template/report', $request_uri[0].'/report';
			-e $request_uri[0].'/report/_rels/.rels' || copy( $folder.'/template/report/_rels/.rels', $request_uri[0].'/report/_rels/.rels' ) || die "Copy failed: $!";
			my $xmlFile = $ROOT_DIR.$request_uri[0].'temp.xml';
			&setFile( $xmlFile, &getDoc (%temp) );
			$temp{'avatar'} = $temp{'tempAvatar'} if defined $temp{'tempAvatar'};
			my $xslFile = $ROOT_DIR.$temp{'avatar'}.$avatars.'/'.$temp{'avatar'}.'.xsl';
			#&setWarn( "   xslFile: $xslFile" );#
			#&setWarn( "   xmlFile: $xmlFile" );#
			my $documentFile = $ROOT_DIR.$request_uri[0].'/report/word/document.xml';
			#unlink $documentFile if -e $documentFile;
			my $status = system ( 'xsltproc -o '.$documentFile.' '.$xslFile.' '.$xmlFile.' 2>'.$ROOT_DIR.$logDir.'/xsltproc_doc.txt' );#
			&setWarn( "   documntXML: $status" );#
			#&setFile( $request_uri[0].'/report/word/document.xml', $documntXML );
			unlink $request_uri[0].'report.docx' if -e $request_uri[0].'report.docx';
			my $zip = Archive::Zip->new();
			#my $dir_member = $zip->addDirectory( $request_uri[0].'/report/' );
			$zip->addTree( $request_uri[0].'/report/' );
			unless ( $zip->writeToFileNamed($request_uri[0].'report.docx') == AZ_OK ) {
				die 'write error';
			}
			$format = 'docx';
		}
		#$request_uri[0] = $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$request_uri[0]; #для основного использования - с предложением расширения при сохранении
		#
		if ($adminMode and 0){
			&setWarn( '   редирект на '.$request_uri[0].'report.'.$format );
			print $q->header(-location => $request_uri[0].'report.'.$format );
		}
		else {
			&setWarn( '   редирект на '.$ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.'/'.$request_uri[0].'report.'.$format );
			print $q->header(-location => $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.'/'.$request_uri[0].'report.'.$format );
			#print $q->header;
			#print $q->redirect($ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.$request_uri[0].'report.'.$format);
			#print "Content-Type: application/x-download\n";
			#print "Content-Disposition: attachment; filename=report.$format\n\n";
		}
	}
	else{
		&setWarn( " Обработка запроса $ENV{REQUEST_URI} для DOCUMENT_ROOT: >$ROOT_DIR< (time: $time)", $log);#		
		#&setWarn (" Ответ на запрос из Web-а $ENV{REQUEST_URI} (adminmode: $adminMode)", $log);#
		#&setWarn ('  Вывод не в особых форматах pdf и doc');
		#my %transaction;
		&initProc( \%temp, \%cookie, $time, $microseconds );
		&washProc( \%temp, \%cookie, $$ ) if $temp{'REQUEST_METHOD'} eq 'POST' or $temp{'QUERY_STRING'};
		
		my @cookie;
		for (keys %cookie){	push @cookie, $q->cookie( -name => $_, -expires => '+1y', -value => $cookie{$_} ) }	
		if ( 1 and ( defined $temp{'ajax'} or not $temp{'parts'} ) ){ 	# or $temp{'QUERY_STRING'}=~/^n1464273764-4704-1/ $ENV{'HTTP_HOST'} eq 'localhost'$ENV{'REMOTE_ADDR'} eq "127.0.0.1" 
			&setWarn('   Вывод в web без редиректа '.$temp{'parts'});		
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
				$doc = &getDoc(%temp);
				#$temp{'tempAvatar'} = $temp{'avatar'} if not defined $temp{'tempAvatar'} or $temp{'tempAvatar'} eq '';
				if ( $temp{'format'} eq 'html' ){
					&setWarn("     Вывод temp-а под аватаром: $temp{'tempAvatar'}");
					$temp{'avatar'} = $temp{'tempAvatar'} if defined $temp{'tempAvatar'};
					my $xslFile = $temp{'avatar'}.$avatars.'/'.$temp{'avatar'}.'.xsl';
					if ( 1 or defined $universe{'serverTranslate'} ){
						&setWarn('      Преобразование на сервере');
						if (0){
							my $xslt = XML::LibXSLT->new();
							#$xslt->output_encoding('windows-1251');
							my $style_doc = XML::LibXML->load_xml(location=> $xslFile, no_cdata=>1);
							my $stylesheet = $xslt->parse_stylesheet($style_doc); 
							$doc = $stylesheet->transform($doc);
						}
						else {				
							$time =~/(\d\d)$/;
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
			copy( $log, $log.'.txt' ) or die "Copy failed: $!" if $dbg; #бессмысленно копировать лог ниже, т.е. после возможного редиректа
			my $location = $ENV{REQUEST_SCHEME}.'://'.$ENV{HTTP_HOST}.&m8req( \%temp ).'/';
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
	my ( $temp, $cookie, $time, $microseconds )=@_; #$time, $proc, $request, $referer 
	&setWarn( "		iP @_" );# стирка 
	$$temp{'time'} = $time;
	$$temp{'microseconds'} = $microseconds;
	$$temp{'parts'} = 0;
	for my $param ( @transaction ){	
		&setWarn('		iP  ENV '.$param.': '.$ENV{$param});
		$$temp{$param} = $ENV{$param} 
	}
	#$$temp{'process'};
	#for my $key ( @clientENV ){
	#	&setWarn( "		wP  $key: $$transaction{$key}" );
	#	$$temp{$key} = $$transaction{$key} 
	#}
	#my %cookie;
	foreach my $itm ( split '; ', $$temp{'HTTP_COOKIE'} ){
		&setWarn('		iP  Прием куки '.$itm);
		my ( $name, $value ) = split( '=', $itm );
		$$temp{$name} = $value if $value;
	}
	if ( $$temp{'user'} ){ $$temp{'author'} = $$temp{'user'} }
	else { $$temp{'author'} = $$temp{'user'} = $$cookie{'user'} = $defaultAuthor }
	$$temp{'ctrl'} = $$temp{'avatar'} = $$temp{'group'} || &startProc ||  $$temp{'author'}; # $defaultAvatar;
	$$temp{'format'} = 'html';
	$$temp{'ajax'} = $$temp{'HTTP_X_REQUESTED_WITH'} if $$temp{'HTTP_X_REQUESTED_WITH'}; 
	my @request_uri = split /\?/, $$temp{'REQUEST_URI'};
	chop $request_uri[0] if $request_uri[0]=~m!/$!;
	$request_uri[0]=~s!^/!!;
	-d $request_uri[0] || return;
	
	&setWarn( "		iP В пожелании $$temp{'REQUEST_URI'} директория $request_uri[0] действительна. Идет детектирование автора/аватара/квеста" );# стирка 	
	#my $pdfout;
	my @path = split '/', $request_uri[0];
	if ( @path == 1 and $path[0] ne 'm8' ){ 
		&setWarn( "		iP  Найден запрос системной операции" );#
		#return 1 if $temp{'new_avatar'} eq 'null';
		$$temp{'quest'} = &utfText($path[1]);
		if ( $$temp{'QUERY_STRING'} =~/^avatar=$/ ){
			&setWarn( "		iP   Смена аватара текущего аватара" );
			if ( -e $$temp{'quest'}.$avatars.'/'.$$temp{'quest'}.'.xsl' and -e $$temp{'quest'}.$avatars.'/title.txt' ){ $$cookie{'group'} = $$temp{'ctrl'} =  $$temp{'avatar'} = $$temp{'quest'} }
			else {
				&setWarn( "		iP    Обнуление текущего аватара " );
				&startProc;
				$$cookie{'group'} = ''; #$$temp{'avatar'} = 			
			}
		}
		elsif ( -e $$temp{'quest'}.$avatars.'/'.$$temp{'quest'}.'.xsl' ){ $$temp{'ctrl'} = $$temp{'tempAvatar'} = $$temp{'quest'} }
		else {$$temp{'ctrl'} =  $$temp{'tempAvatar'} = $canonicalHomeAvatar }
	}
	else{
		&setWarn( "		iP  Не системный запрос" );#
		$temp{'format'} = shift @path if $path[0] =~m!^_!;
		$$temp{'ctrl'} = $$temp{'tempAvatar'} = shift @path if $path[0] ne 'm8'; 
		$$temp{'fact'} = $$temp{'quest'} = &utfText($path[2]) if $path[2];
		$$temp{'author'} = $path[3] if $path[3];	
		$$temp{'quest'} = $path[4] if $path[4]
	}
	#$$transaction{'REQUEST_METHOD'} eq 'POST' || $$transaction{'QUERY_STRING'} || return;
	#&setWarn( "		wP Имеется запрос. Идет обработка" );# стирка	
}
	
sub washProc{
	my ( $temp, $cookie ) = @_; #$time, $proc, $request, $referer 
	&setWarn( "		wP @_" );# стирка 	
	#&setWarn( "		wP Имеется информация для записи в квест $$temp{'quest'}. Идет поиск и обработка номеров" );# стирка 
	my @num;
	if ( $$temp{'REQUEST_METHOD'} eq 'POST' ){
		&setWarn( "		wP  Запись файла" );# 
		my $req = new CGI; 
		my $DownFile = $req->param('file'); 
		#my $fileName = $DownFile;
		#$fileName =~ s!^.*(\|/)!!;
		$DownFile =~/tsv$/ || $DownFile =~/txt$/ || $DownFile =~/csv$/ || return;
		my @text;			
		while ( <$DownFile> ) { 
			#chomp;
			#my $r = "\r";
			#s/$r//; #иначе остается лишний знак перевода каретки
			s/\s+\z//;
			push @text, Encode::decode_utf8( $_ )
		}
		$$temp{'fact'} = $defaultFact if not defined $$temp{'fact'};
		$$temp{'quest'} = $defaultFact if not defined $$temp{'quest'};
		#$$temp{'fact'} = $defaultFact if not d;$$temp{'quest'} = $defaultFact;
		my $iName = &setName( 'i', @text );
		my $trName =  &setName( 'd', $$temp{'fact'}, 'n', $iName ); # было вместо факта почему-то $quest
		my @val = ( $trName, $$temp{'fact'}, 'n', $iName, $$temp{'author'}, $$temp{'quest'}, 1 ); # было вместо факта почему-то $quest
		push @num, \@val;
	}
	else {
		&setWarn( "		wP  Имеется строка запроса $$temp{'QUERY_STRING'}. Идет идет ее парсинг" );# 
		#$$temp{'QUERY_STRING'} = &utfText( $$temp{'QUERY_STRING'} );	
		my %param;
		for my $pair ( split( /&/, $$temp{'QUERY_STRING'}  ) ){
			&setWarn( "		wP   Анализ пары $pair" );	
			my ($name, $value) = split( /=/, $pair );
			$param{$name} = &utfText($value);
			if ( $name =~/^\w[\d_\-]*$/ ){
				&setWarn( "		wP     Детектирован элемент создания номера" );
				$$temp{'parts'} = $$temp{'parts'} + 1;
				if ( 0 and $name =~/^\w$/ and not $name =~/^[dirn]/ ){
					&setWarn( "		wP     Подготовка создания нового нечто в простом режиме" );
					$$temp{'fact'} = 'n'.$time.'-'.$microseconds;#.'-0'
					$$temp{'quest'} = $$temp{'fact'} if not defined $param{'quest'};
				}
			}
			elsif ( $name =~/^\w+$/ ) { $$temp{$name} = $param{$name} }
			#elsif ( grep { $name eq $_ } ( 'format', 'ctrl', 'fact', 'author', 'quest', 'user', 'ajax', 'login', 'new_author', 'tempAuthor', 'tempAvatar', 'message', 'control', 'del', 'serverTranslate', 'emulationControl' ) ){ $$temp{$name} = $param{$name} }
		}	
		#keys %param || return;
		if (not $$temp{'author'}){
			&setWarn( "		wP   Найден запрос смены автора" );# 
			#$avatar = $$cookie{'avatar'} = $$temp{'avatar'} = $canonicalHomeAvatar;
			if ( defined $$temp{'login'} or defined $$temp{'new_author'} ){
				&setWarn( "		wP    Процедура авторизации" );# 		
				my %pass;
				for my $pass ( grep { defined $param{$_} } ( 'password', 'new_password', 'new_password2' ) ){ $pass{$pass} = $param{$pass} 	}
				$$temp{'message'} = &parseNew ( $temp, \%pass );
				return if $$temp{'message'};
				if ( defined $$temp{'new_author'} ){
					&setWarn('		wP    фиксация создания автора '); 
					#$avatar = $$cookie{'avatar'} = $$temp{'avatar'} = $defaultAvatar; 
					#$avatar = $canonicalHomeAvatar; # при этом $temp{'avatar'} остается с старым значением и идет в темп
					#$$temp{'quest'} = 'n'.$time.'-'.$process.'-0'; #$$temp{'someone'} = 
					$$temp{'fact'} = $$temp{'quest'} = $defaultFact;
					$$temp{'user'} = $pass{'new_password'};
					$$temp{'author'} = $$temp{'new_author'};
					#my @value = ( &setName( 'd' ), undef, undef, undef, 1, $pass{'new_password'} );
					my @value = ( 'd', @mainTriple, $$temp{'author'}, $$temp{'quest'}, 1 ); #$pass{'new_password'}
					push @num, \@value;
					my $data = join "\t", @mainTriple;
					&setFile( $baseDir.'/d/value.tsv', $data );
					&rinseProc ( 'd', $data)
				}
				else { $$temp{'author'} = $$temp{'login'} }
				$$cookie{'user'} = $$temp{'author'};
			}
			else { $$cookie{'user'} = $defaultAuthor }#( $$temp{'tempAvatar'}, 
		} #my $someone = $$temp{'someone'} = &getFile( $baseDir.'/'.$author.'/value.tsv' );
		elsif ( defined $param{'z0'} and $param{'z0'} eq 'd' ){
			&setWarn( "		wP   Найден запрос удаления автора" );
			my @value = ( 'd' );
			push @num, \@value;
			$$cookie{'user'} = $$temp{'author'} = $defaultAuthor
		}
		elsif ( defined $$temp{'control'} ){
			&setWarn ('		wP   Контроль');
			#$$temp{'tempAvatar'} = $canonicalHomeAvatar if not defined $$temp{'tempAvatar'};
			if ( $$temp{'author'} ne $admin ){
				$$temp{'message'} = 'Требуются админские полномочия'; # $$temp{'number'}[0]=
				return
			}
			if ( defined $$temp{'del'} ){
				&setWarn ('		wP    Системное удаление директорий');
				for my $m8subdir ( &getDir( 'm8', 1 ) ){
					&setWarn ("		wP     Анализ директории $m8subdir");
					if ( $$temp{'del'} < 3 ){ # or $m8subdir eq 'n1'
						&setWarn ("		wP      Анализ базовых директорий");
						if ( $$temp{'del'} > 1 ){
							for my $dir ( grep { $_ ne 'd' } &getDir ( $baseDir, 1 ) ){ rmtree( $baseDir.'/'.$dir ) }
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
					&getDir ($baseDir) || rmdir $baseDir
				}
			}
			for (keys %universe){ $$temp{$_} = 1 }
			#$temp{'control'} = param('control');
			#$temp{'avatar'} = 'control' if not param('out');
		}
		elsif ( $$temp{'parts'} ) {	
			&setWarn( "		wP   Поиск и проверка номеров в строке запроса $$temp{'QUERY_STRING'}" );# стирка 
			my @value; #массив для контроля повторяющихся значений внутри триплов
			my %table; #таблица перевода с буквы предлложения на номер позиции в процессе
			#&setWarn("		!!!>$$temp{'QUERY_STRING'}<");
			
			for my $pair ( split( /&/, $$temp{'QUERY_STRING'}  ) ){
				&setWarn('		wP  парсинг пары >'.$pair.'<');
				my ($name, $value) = split(/=/, $pair);
				#$value =~ s/%([a-fA-F0-9]{2})/pack("C", hex($1))/eg;
				my $n = "\n";
				$value =~ s/%0D%0A/$n/eg; #без этой обработки на выходе получаем двойной возврат каретки помимо перевода строки если данные идут из textarea
				$value = &utfText($value);
				$value = Encode::decode_utf8($value);# 
				#&setWarn('		wP    в текущем виде '.$value);
				#&setWarn('		wP  значение >'.$value.'<');
				#$value = Encode::decode_utf8($value);# 
				#&setWarn("		wP   Предикат $name системный!!!") if defined $$temp{$name};
				next if defined $$temp{$name};
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
				}#здесь нужно дать возможность указывать в значении d|i|r|n как буквы		
				else {
					&setWarn('		wP     запрос карты');
					my @value = split "\n", $value;
					$value = &setName( 'i', @value );
					if ( $value[1] and $value[1]=~/^xsd:(\w+)$/ ){
						&setWarn('		wP      запрос создания именнованой карты');
						#my $type = $1;
						#$value = &setName( $value, 'i' );
						
						
						#здесь еще нужно исключить указание одному имени разных типов
						my $authorTypeFile = $userDir.'/'.$$temp{'author'}; #вообще не верно здесь работать с именованными индексами, т.к. автор может прийти из а4
						my %type = &getJSON( $authorTypeFile, 'type' );
						$type{$value}[0]{'name'} = $value[0];
						&setXML ( $authorTypeFile, 'type', \%type );
						&rinseProc2 ( $$temp{'author'}, %type )
						#my $authorTypeFile = '/m8/user/'.$$temp{'author'}.'/type.json';
						#my %userType = &getHash( $authorTypeFile );
						#$value = &setName( $value, 'i' );
						#if ( defined $userType{$value} and $userType{$value} ne $typeName) { $value = 'r' }
						#else {
						#	$userType{$value} = $typeName;
						#	&setFile( $authorTypeFile, JSON->new->utf8->encode(\%userType) );
						#	&rinseProc2 ( $$temp{'author'}, %userType )
						#}
					}
				} 
				#&setWarn("			wP    !!!!!!!! >>>>$name<<<" );
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
						$num[$s][1] = 'n'.$time.'-'.$microseconds.'-'.$s; 
						$num[$s][3] = $value;
						# if ;
						if ( $name eq 'a' ){
							&setWarn("			wP       $pair: подготовка редиректа" );
							$$temp{'fact'} = $num[$s][1] if not defined $param{'fact'};
							$$temp{'quest'} = $num[$s][1] if not defined $param{'quest'};
						}
						elsif ( not $num[$s][5] ) { $num[$s][5] = $num[$s][1] }
					}
				} #elsif ($name =~/^\d+$/){ $del{$name} = $value }
				else{ 
					&setWarn('		wP     Формирование номера в простом режиме. Предикат - '.$name);
					my @triple = ( undef, undef, $name, $value, undef, undef, 1 );
					push @num, \@triple;
				}
			}
			if ( @num and 1 ){
				&setWarn( "		wP    Найдены номера @num. Идет их обогащение удаление старого." );
				#unshift @num, 0;	
				for my $s ( 0..$#num ){
					&setWarn("		wP     Замена пустого в номере $s");
					if ( $num[$s][0] ){			
						&setWarn("		wP      на удаление");
						my @span = &getTriple( $num[$s][0] );
						$span[4] = $num[$s][4] if $num[$s][4];
						$span[5] = $num[$s][5] if $num[$s][5];
						$num[$s] = \@span
					}
					else{
						&setWarn("		wP      на добавление");
						for my $m ( grep { not ( defined $num[$s][$_] and $num[$s][$_] ) } 1..3){
							&setWarn("		wP       Замена пустого члена $m ");
							if ( $m == 1 ){		$num[$s][1] = $$temp{'fact'}	}
							elsif ( $m == 2 ){	$num[$s][2] = 'r' 				} #elsif ( $m == 2 ) '/m8/r1/0' 
							else { 				$num[$s][3] = 'r'	}#'/m8/n0/n'.$time.'-'.$process.'-'.$s #'/m8/r0/null'
						}
						$num[$s][0] = &setName( 'd', $num[$s][1], $num[$s][2], $num[$s][3] );
					}
					$num[$s][4] = $$temp{'author'} if not $num[$s][4];
					$num[$s][5] = $$temp{'quest'} if not $num[$s][5];
				} 
			}
		}
	}
	$$temp{'fact'} = $defaultFact if not defined $$temp{'fact'};
	$$temp{'quest'} = $defaultFact if not defined $$temp{'quest'};
	@num || return;
	
	&setWarn( "		wP ## Имеются номера. Идет запись." );
	#return; /base/d13632387581185099314/teplotn/teplotn/n1459416563-6716-1
	for my $s ( grep { $num[$_] } 0..$#num ){
		&setWarn("		wP  Проверка номера $s ");
		for my $key ( 0..6 ){ 
			#&setWarn("		wP   Значение на сушку $key: $num[$s][$key]"  );
			$$temp{'number'}[$s]{$number[$key]} = $num[$s][$key] if $num[$s][$key];
		}	
		if ( grep { $s != $_ and $num[$_] and ( $num[$s][0] eq $num[$_][0] ) } 0..$#num ) { 
			&setWarn("		wP   Номер запрашивает повтор трипла в запросе");
			#$$temp{'number'}[$s]= 'Повтор трипла в запросе'	;
			$$temp{'povtor'}[$s] = 1;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор трипла в запросе';
			next;
		}
		#elsif ( 0 and -d $questDir == $num[$s][6] ) {  #0 and временно коментим для исключения накопившихся расхождений
		#	&setWarn("		wP   Номер запрашивает повтор трипла в базе. Смотрим в порт.");
		#	my %port = &getJSON( &m8dir( $num[$s][1], $num[$s][4], $num[$s][5] ), 'port' );
		#	if ( ( defined $port{$num[$s][2]} == $num[$s][6] ) and ( defined $port{$num[$s][2]}[0]{$num[$s][3]} == $num[$s][6] ) ){# and $port{$num[$s][2]}[0]{'time'} < $time
		#		&setWarn("		wP    Трипл отражен и в порту. Отмена индексации.");
		#		$$temp{'povtor'}[$s] = 2;
		#		$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор установления значения';
		#		next;
		#	}
		#}
		if ( &spinProc ( $num[$s], $$temp{'time'}, $$temp{'user'} ) ){
			&setWarn("		wP   Номер запрашивает повтор трипла в базе.");
			$$temp{'povtor'}[$s] = 2;
			$$temp{'number'}[$s]{'message'} = 'Номер запрашивает повтор установления значения';
		}

		#производим изменения  в индексе до записей в базе, т.к. ошибки в индексе искажают итоговую картину	
		
		#else { &delNumber ( $$temp{'time'}, $$temp{'user'}, @{$num[$s]} )	}
		#}	
	}
	return if 1 or -e $baseDir.'/control' or not grep { $$temp{'number'}[$_] eq 'OK' } @{$$temp{'number'}};
	
	&setWarn('   Обнаружены физические записи. Запуск процесса сушки');
	eval{ system( 'perl.exe M:\system\reg.pl dry >/dev/null 2>M:\_log\error_dry.txt' ); }	
}



sub rinseProc {
	my ( $name, @div )=@_;
	&setWarn("		rP @_"  );
	my %value;
	if ( $div[0] ne '' or $div[1] ){ 
		&setWarn("		rP  Раскладка @div по строкам"  );
		for my $s (0..$#div){
			&setWarn("		rP   Строка $s: $div[$s]"  );
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
	#my %xsl_stylesheet = decode_json( &getFile($baseDir.'/'.$author.'.json') );	
	$xsl_stylesheet{'xsl:stylesheet'}{'version'} = '1.0';
	$xsl_stylesheet{'xsl:stylesheet'}{'xmlns:xsl'} = 'http://www.w3.org/1999/XSL/Transform';
	$xsl_stylesheet{'xsl:stylesheet'}{'xmlns:m8'} = 'http://m8data.com';
	my $x = 0;
	for my $mapName ( grep { $type{$_} =~/ARRAY/ } keys %type){
		$xsl_stylesheet{'xsl:stylesheet'}{'xsl:param'}[$x]{'name'} = $type{$mapName}[0]{'name'};
		$xsl_stylesheet{'xsl:stylesheet'}{'xsl:param'}[$x]{'select'} = "name( m8:path( '$mapName', 'role3' )/$author/* )";
		$x++
	}
	#my $XML2JSON = XML::XML2JSON->new(pretty => 'true');
	my $XML = $XML2JSON->json2xml( $JSON->encode(\%xsl_stylesheet) );
	&setFile( $userDir.'/'.$author.'/type.xsl', $XML );
}

sub spinProc {
	my ( $val, $time, $user )=@_; #$param
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
				&spinProc ( \@triple, $time, $user );
			}
		}
	}
	elsif ( not defined $port{$predicate} or not defined $port{$predicate}[0]{$object} ){ $good = 1 }
	my @value = ( $name, $subject, $predicate, $object, $author, $quest );
	if (not $good){
	push @value, ( $subject, $predicate, $object ) if $predicate=~/^r\d*$/;
	for my $mN ( grep { $value[$_] } 0..$#value ){
		&setWarn("		sP  Обработка упоминания cущности $mN: $value[$mN]"  );
		#next if ( $mN == 1 or $mN == 2 ) and $add == 2;
		my $addC = $add || 0; #заводим отдельный регистр, т.к. $add должен оставаться с значением до цикла
		my $metter = &getID($value[$mN]);
		#$metter =~s!^/!!;
		my ( $type, $role, $file, $first, $second );
		if ( $mN == 0 ){	( $type, $role, $file, $first, $second ) = ( 'triple', 		'activate',	'activate'				, $author,	$quest ) }
		elsif ( $mN < 4 ) {	( $type, $role, $file, $first, $second ) = ( 'role', 		'role'.$mN,	'role'.$mN 				, $author,	$quest ) }
		elsif ( $mN == 4 ){ ( $type, $role, $file, $first, $second ) = ( 'author', 		'author',	'author'				, $name, 	$quest ) }
		elsif ( $mN == 5 ){ ( $type, $role, $file, $first, $second ) = ( 'quest', 		'quest',	'quest'					, $author,	$subject ) }#вероятнее всего, здесь subject нужно поменять на name
		elsif ( $mN == 6 ){ ( $type, $role, $file, $first, $second ) = ( 'subject', 	$predicate,	'subject_'.$predicate	, $author,	$quest ) }
		elsif ( $mN == 7 ){	( $type, $role, $file, $first, $second ) = ( 'predicate',	$object,	'predicate_'.$object	, $author,	$quest ) }
		elsif ( $mN == 8 ){	( $type, $role, $file, $first, $second ) = ( 'object', 		$subject, 	'object_'.$subject		, $author,	$quest ) } #'num'.	
		
		if ( $mN == 1 or $mN == 2 or $mN == 3  ){
			&setWarn("		sP   Формирование порта/дока/терминала"  );
			my ( $master, $slave, $file2 );
			if ( $mN == 1 )		{ ( $master, $slave, $file2 ) = ( $predicate, 	$object, 	'port' 		) }
			elsif ( $mN == 2 )	{ ( $master, $slave, $file2 ) = ( $subject, 	$object, 	'dock' 		) }
			elsif ( $mN == 3 ) 	{ ( $master, $slave, $file2 ) = ( $subject, 	$predicate, 'terminal' 	) }
			my %role = &getJSON( $metter.'/'.$author.'/'.$quest, $file2 );
			if ( $addC ){
				&setWarn("		sP    Операции при добавлении значения"  );
				$role{$master}[0]{$slave}[0]{$name}[0]{'user'} = $user;
				$role{$master}[0]{$slave}[0]{$name}[0]{'time'} = $time;
			}
			else { 
				&setWarn("		sP    Операции при удалении значения. Удаление ключа $master"  );
				delete $role{$master} ; 
				$addC = 1 if keys %role; 
			} 
			&setXML ( $metter.'/'.$author.'/'.$quest, $file2, \%role ); #.'/'.$metter{$metter}$count
		}
		#&setWarn("		sP   ADD $add"  );
		
		my %role1 = &getJSON( $metter, $file );
		if ( $addC == 1 ) {
			&setWarn("		sP   Счетчик упоминаний не пустой - дополняем/обновляем индекс-файл роли"  );
			$role1{$first}[0]{'time'} = $time;		
			$role1{$first}[0]{$second}[0]{'time'} = $time;
			$role1{$first}[0]{$second}[0]{'user'} = $user;
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
			$index{$type}[0]{$role}[0]{'file'} = $file
		}
		else { 
			&setWarn("		sP    Удаление упоминания роли"  );
			delete $index{$type}[0]{$role};
			delete $index{$type} if not keys %{$index{$type}[0]};
		}
		&setXML ( $metter, 'index', \%index ); #grep {$index{$_}=~/^ARRAY/} 
	}
	#if ( $predicate eq 'd' ){
	#	my @val = map{ Encode::decode_utf8($_) } &getFile( $baseDir.'/'.$object.'/value.tsv' );
	#	if (@val==2 and $val[1]=~/^xsd:/){	
	}
	my $metterDir = $baseDir.'/'.$name;
	my $authorDir = $metterDir.'/'.$author;
	my $questDir = $authorDir.'/'.$quest;
	if ( $add ){
		&setWarn("		wP   Добавление директории $questDir в базу");
		make_path( $questDir.'/'.$time.'/'.$user, { chmod => $chmod } );
		make_path( $baseDir.'/'.$object.'/'.$name, { chmod => $chmod } ) if $object =~/^i\d+$/;
	}
	else{
		&setWarn("		wP   Удаление директории $questDir из базы");
		rmtree $questDir;
		if ( not &getDir ( $authorDir ) ){
			rmtree $authorDir;
			if ( not &getDir( $metterDir, 1 ) ){
				&setXML ( 'm8/d/'.$value[0], 'value' );
				rmtree $metterDir;
				foreach my $m ( grep { $value[$_] =~/^i\d+$/ } 1..3 ){
					&setWarn("		dN    Удаление линка в литерале $value[$m]");
					rmdir $baseDir.'/'.$value[$m].'/'.$value[0];
					if ( not &getDir ( $baseDir.'/'.$value[$m], 1 ) ){
						&setWarn("		dN     Удаление всего литерала");
						&delDir ( $baseDir.'/'.$value[$m], 2 );
						&setXML ( &getID($value[$m]), 'value' );
					}
				}
				if ( $value[3]=~/^i\d+$/ ){
					&setWarn("		dN    Проверка на идентификатор");
					my $authorTypeDir = $userDir.'/'.$value[4];
					if ( -e $authorTypeDir.'/type.json' ){
						my %type = &getJSON( $authorTypeDir, 'type' );
						if ( defined $type{$value[3]} ){ 
							delete $type{$value[3]};
							&setXML ( $authorTypeDir, 'type', \%type );
							&rinseProc2 ( $value[4], %type )
						}
					}
				}
			}
		}
	}
		
	#	}
	#}
	#my %xsl_stylesheet = decode_json( &getFile($baseDir.'/'.$author.'.json') );	
	#$xsl_stylesheet{'xsl:stylesheet'}{'version'} = '1.0';
	#$xsl_stylesheet{'xsl:stylesheet'}{'xmlns:xsl'} = 'http://www.w3.org/1999/XSL/Transform';
	
	#my %xsl_stylesheet = &getJSON( $base, 'xsl_stylesheet' );
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
	#-d $baseDir || return;
	my %stat;
	$dbg = 0;
	my $guestDays;# = &getFile( $baseDir.'/guest_days.txt' ) || return;
	open (REINDEX, '>reindex.txt')|| die "Ошибка при открытии файла reindex.txt: $!\n";
	
	if (not -d $baseDir){
		&setWarn ("		sP   MakeBase");
		make_path( $baseDir.'/d/admin/n0000000000-0-0/0/a', { chmod => $chmod } );
		&setFile( $baseDir.'/d/value.tsv', ( join "\t", @mainTriple ) );
		&setFile( $baseDir.'/i/value.tsv' );
		&startProc;
	}
	elsif ( -e $baseDir.'/guest_days.txt' ){
		$guestDays = &getFile( $baseDir.'/guest_days.txt' )
	}
	else { return }
	my $guestTime = $guestDays * 24 * 60 * 60;
	
	&setWarn("		dP 2 guestDays/guestTime: $guestDays/$guestTime" );
	#print REINDEX "guestDays/guestTime: $guestDays/$guestTime \n";
	#warn "guestDays/guestTime: $guestDays/$guestTime";
	if ( $mode == 2 or 0 ){
		for my $d ( &getDir ( 'm8' ) ){
			if ( -d 'm8/'.$d ){ rmtree 'm8/'.$d }
			else { unlink 'm8/'.$d }
		}
	}
	#rmtree '/m8';
	rmtree $logDir;
	#&setFile ( $systemDir.'/control');
	my $cutoff = $time;
	my %dry;
	my %userType;
	my $count1 = 0;
	
	my $n_delG = 0;
	#my $n_delV = 0;
	
	my $n_delR = 0;
	my $n_delN = 0;
	
	my $all = 0;
	my $triple = 0;
	my $clean = 0; #not defined $universe{'emulationControl'};
	#my %base;
	
	for my $tsvName ( &getDir ( $baseDir, 1 ) ){ 
		print REINDEX "tsv	$tsvName \n";
		warn '		tsv  '.$tsvName;
		$all++;
		if (0){
		if ( not -e $baseDir.'/'.$tsvName.'/value.tsv' ){
			dircopy $baseDir.'/'.$tsvName, $logDir.'/'.$baseDir.'/'.$time.'/'.$tsvName;
			rmtree $baseDir.'/'.$tsvName;
			next
		}
		}
		my @div = map{ Encode::decode_utf8($_) } &getFile( $baseDir.'/'.$tsvName.'/value.tsv' );
		&rinseProc ( $tsvName, @div );
	
		next if $tsvName=~/^i/;	
		my @val = split "\t", $div[0];
		#$val[0] eq 'n1469044299-55492' || next;
		unshift @val, $tsvName;
		$triple++;
		
		for my $authorName ( &getDir ( $baseDir.'/'.$tsvName, 1 ) ){
			print REINDEX "   Исследование aвтора $authorName \n";
			$val[4] = $authorName;
			if ( not defined $stat{$authorName} ){
				for ( 'add', 'n_delR', 'n_delN' ){ $stat{$authorName}{$_} = 0 }
			}
			if ( $val[3] =~/^i\d+$/ ){
				my @map = map{ Encode::decode_utf8($_) } &getFile( $baseDir.'/'.$val[3].'/value.tsv' );
				$userType{$authorName}{$val[3]} = $map[0] if $map[1] and $map[1]=~/^xsd:\w+$/;
			}
			if (1){
			for my $questName ( &getDir ( $baseDir.'/'.$tsvName.'/'.$authorName, 1 ) ){
				print REINDEX "    Исследование квеста $questName \n";
				$val[5] = $questName;
				my ( $timeProc ) = &getDir ( $baseDir.'/'.$tsvName.'/'.$authorName.'/'.$questName, 1 );
				my ( $userProc ) = &getDir ( $baseDir.'/'.$tsvName.'/'.$authorName.'/'.$questName.'/'.$timeProc, 1 );
				if ( $authorName ne 'teplotn' and ( $time - $guestTime ) > $timeProc ){ #and $val[2]=~/^r/
					print REINDEX "     Удаление старого гостевого трипла '.$div[0].' \n";
					$n_delG++
				}
				else {
					print REINDEX "     Реиндексация значений '$div[0]' \n";
					$val[6] = 1;
					$stat{$authorName}{'add'}++;
				}
				&spinProc ( \@val, $timeProc, $userProc );
			}
			}
		}
	}
	#&setXML ( $baseDir, 'base', \%base );	
	
	my $time1 = time;
	my $real2 = 1;
	if(1){
	for my $tsvName ( &getDir ( $baseDir, 1 ) ){ 
		warn '		tsv2  '.$tsvName;
		print REINDEX "tsv2	$tsvName \n";
		next if $tsvName=~/^i/;	
		my @val = map{ Encode::decode_utf8($_) } &getTriple( $tsvName );
		my $parent = $val[1];
		for my $authorName ( &getDir ( $baseDir.'/'.$tsvName, 1 ) ){
			$val[4] = $authorName;
			for my $questName ( &getDir( $baseDir.'/'.$tsvName.'/'.$val[4], 1 ) ){
				$val[5] = $questName;
				if ( $val[2]=~/^r/ ){
					next if $val[1] eq $val[5];
					$parent = $val[5];
				}
				my %index = &getJSON( &m8dir( $parent ), 'index' );
				next if defined $index{'subject'};
				my ( $timeProc ) = &getDir( $baseDir.'/'.$tsvName.'/'.$val[4].'/'.$val[5], 1 );
				my ( $userProc ) = &getDir( $baseDir.'/'.$tsvName.'/'.$val[4].'/'.$val[5].'/'.$timeProc, 1 );
				if ( $val[3] =~/^i\d+$/ ){
					my @map = map{ Encode::decode_utf8($_) } &getFile( $baseDir.'/'.$val[3].'/value.tsv' );
					delete $userType{$val[4]}{$val[3]} if $map[1]=~/^xsd:\w+$/;
				}
				&spinProc ( \@val, $timeProc, $userProc );
				if ( $val[2]=~/^r/ ){ $stat{$authorName}{'n_delR'}++ }
				else { $stat{$authorName}{'n_delN'}++ }
			}
		}
	}
	}
	my $time2 = time+1;
	for my $authorName ( keys %userType ){
		#$value = &setName( $value, 'i' );
		my %type;
		#здесь еще нужно исключить указание одному имени разных типов
		my $authorTypeDir = $userDir.'/'.$authorName; #вообще не верно здесь работать с именованными индексами, т.к. автор может прийти из а4
		for my $tsvName ( keys %{$userType{$authorName}} ){
			$type{$tsvName}[0]{'name'} = $userType{$authorName}{$tsvName};
		}
		&setXML ( $authorTypeDir, 'type', \%type );
		&rinseProc2 ( $authorName, %type )
	}

	my $t1 = $time1 - $cutoff;
	my $t2 = $time2 - $time1;
	my $s1 = $count1 / $t1;
	my $s2 = ( $n_delR + $n_delN ) / $t2;
	my $list = '
	guestDays: 	'.$guestDays.'
	guestTime:	'.$guestTime.'
	N_DL-G:	'.$n_delG.'
	
	ALL: 	'.$all.'
	TRIPLE:	'.$triple.'
	
	';
	for my $auth ( keys %stat ){
		$list .= $auth.':		'.$stat{$auth}{'add'}.'	'.$stat{$auth}{'n_delR'}.'	'.$stat{$auth}{'n_delN'}.'
	';
	}
	$list .= '
	TIME1:		'.$t1.' ('.$s1.')
	TIME2:		'.$t2.' ('.$s2.')
	
	';
	warn $list;
	print REINDEX $list;
	close (REINDEX);
	return;
	my $goodFile = 0;
	my $goodDir = 0;
	if ( 1 ){ # keys %unreal
		&setWarn ("		dP  Проверка наличия необходимых файлов");
		my @file = grep { $_ ne '/m8' } File::Find::Rule->in( '/m8' );
		@file = map { $_ } @file;
		
		for my $file (@file){
			&setWarn ("		dP   Сушка физического файла $file");
			if ( $file=~m!(.*)/(.+\..+).tmp$! ){
				&setWarn ("		dP    Обследование метки времени");
				#delete $unreal{$file};	
				my ($maindir, $mainfile) = (  $1, $2 );
				$file = $file;
				if ( $clean and  $cutoff > &getFile( $file ) and not -e $maindir.'/'.$mainfile ) { 
					&setWarn ("		dP      Физическое удаление.");
					unlink $file;
					&getDir($maindir) || &delDir( $maindir , 2 )
				}
				#if ( &getFile( $file ) >= $cutoff ){ 
				#	&setWarn ("		dP     Файл находится в процессе редактирования. Удаление его логического отображения");
				#	next
				#}
				#elsif ( not -e $maindir.'/'.$mainfile ){
				#	&setWarn ("		dP     Файл не редактируется и не нужен. Удаление вместе с подпапками.");

				#} #та самая сушка 
			}
			else{
				&setWarn ("		dP    Обследование не метки времени");
				my @path = split '/', $file;
				my $fileName = pop @path;
				my %file = ('name', $file); #, 'dir', (join '/', @path)
				-d $file || &getFile( $file ) < $cutoff || next;
				if ( ( $#path == 3 or $#path == 6 ) and ( $fileName=~m!^\w+\.xml$! or $fileName=~m!^\w+\.json$! or $fileName=~m!^\w+\.txt$! ) ) {
					&setWarn ("		dP     Файл форматный");
					next if &getFile( $file.'.tmp' ) > $cutoff;
					if ( 0 ){ #defined $unreal{$file}
						&setWarn ("		dP      Файл санкционирован. Проверка на схождение.");
						#if (not $fileName=~m!^\w+\.json$!){
						my $content = join "\t", &getFile( $file );
						&setWarn ("		dP       Правильный вариант - .");#$unreal{$file}
						if ( $content ne 1 ){ #$unreal{$file}
							&setWarn ("		dP        Контент не верный. Перезапись.");
							$file{'unreal'}[0]{$tNode} = 0; #$unreal{$file};
							$file{'real'}[0]{$tNode} = $content;
							push @{$dry{'difference'}[0]{'file'}}, \%file;
							#&setFile ( $file, $unreal{$file} ) if $clean;
						}
						else { 
							$goodFile++;
							push @{$dry{'exactly'}[0]{'file'}}, \%file;
						}
						#}
						#delete $unreal{$file};
					}
					else { 
						&setWarn ("		dP      Файл не санкционирован. Удаление.");
						push @{$dry{'unnecessary'}[0]{'file'}}, \%file;
						if ( $clean ){
							if ( -d $file ){ rmdir $file }
							else { unlink $file }
						}
					}
				}
				elsif ( -d $file and $#path < 7 and ( $fileName =~/^[rn][01]$/ or $#path != 1) ) { 
					&setWarn ("		dP     Обследование форматной директории");
					#if (defined $unreal{$file}){ 
					#	delete $unreal{$file};
					#	$goodDir++;
					#	push @{$dry{'exactly'}[0]{'file'}}, \%file;
					#}
					#else {
					#	&setWarn ("		dP      Удаление лишней директории");
					#	push @{$dry{'unnecessary'}[0]{'file'}}, \%file;
					#	rmdir $file if $clean;
					#}
				}
				else {
					&setWarn ("		dP     Удаление не форматного файла");
					push @{$dry{'unformat'}[0]{'file'}}, \%file;
					if ( $clean ){
						if ( -d $file ){ rmdir $file }
						else { unlink $file }
					}
				}
			}
		}
		#for my $file ( sort keys %unreal){#{$a <=> $b}
		#	&setWarn ("		dP   Воссоздание пропавшего файла $file ");
		#	if ( $clean ){
		#		&setWarn ("		dP   Физическая восстановка с значением $unreal{$file} ");
		#		if ( $unreal{$file} ){  &setFile( $file, $unreal{$file} ) } #&setWarn ("		dP    Создание директории");
		#		else { 
		#			mkdir $file;
		#		} #make_path
		#	}
		#	my %file = ('name', $file );
		#	push @{$dry{'lose'}[0]{'file'}}, \%file;
		#}
	}
	elsif ($clean) {
		for my $dir ( grep { $_ ne 'base' } &getDir ( 'm8', 1 ) ){ rmtree( 'm8/'.$dir ) }
	}
	#sleep 6;
	$dry{'exactly'}[0]{'sfile'} = $goodFile;
	$dry{'exactly'}[0]{'dir'} = $goodDir;
	$dry{'localtime'} = localtime(time);
	unlink $baseDir.'/control';
	&setXML( $logDir, 'dry', \%dry );
}

sub startProc {
	my %avatar;
	my $count = 0;
	for my $avatarName( grep { -e $_.$avatars.'/'.$_.'.xsl' and -e $_.$avatars.'/title.txt'} &getDir ( '.', 1 ) ){
		&setWarn ("		sP   Найден аватар $avatarName");
		$avatar{'unit'}[$count]{'id'} = $avatarName;
		$avatar{'unit'}[$count]{'title'} = &getFile( $avatarName.$avatars.'/title.txt' );
		$count++
	}
	&setXML ( '.', 'avatar', \%avatar );
	return $avatar{'unit'}[0]{'id'} if $count == 1;
}



sub parseNew {
	my ( $temp, $pass )=@_;
	&setWarn( "			pN @_" );	
	if ( defined $$temp{'login'} ){ #not -e '/m8/r1/'.$params{'frame'}.'/author.txt'
		&setWarn('			pN   Вход ранее созданного пользователя');
		if ($$temp{'login'} ne 'guest'){
			defined $$pass{'password'} and $$pass{'password'} || return 'Укажите пароль';
			my $userDir = $baseDir.'/d/'.$$temp{'login'}; #$canonicalHomeAvatar;
			-d $userDir || return 'Такой пользователь не зарегистрирован';#-e
			#my $someone = &getDir( $userDir, 2 );
			my $timeproc = &getDir( $userDir.'/n', 2 );
			my $password = &getDir( $userDir.'/n/'.$timeproc, 2 );
			$password eq $$pass{'password'} || return 'Пароль указан не верно';
		}
	}
	elsif ( defined $$temp{'new_author'} ){# and defined $$temp{'auth'}
		&setWarn('			pN   Создание автора');
		$$temp{'new_author'} =~/^\w+$/ || return 'В имени могут быть лишь буквы латинского алфавита и цифры.';
		34 >= length $$temp{'new_author'} || return 'Имя не должно быть длиннее 34 символов.';
		return 'Такой пользователь уже существует' if -e $baseDir.'/'.$$temp{'new_author'}.'/value.tsv'; #-e $authorRuneDIR.'/mult/index.xml';
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
	else { $path = $userDir.'/'.$level1.'/type' }
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
	my $dir = '/'.$$temp{'ctrl'}.'/m8/'.substr($$temp{'fact'},0,1).'/'.$$temp{'fact'};
	$dir .= '/'.$$temp{'author'};
	$dir .= '/'.$$temp{'quest'} if $$temp{'quest'} ne $$temp{'fact'};
	return $dir
}
sub getID {
	my ( $name )=@_;
#	&setWarn("						gI  @_" );
	if ($name=~m!^/m8/[dirn]/[dirn][\d_\-]*$! or $name=~m!^/m8/author/[a-z]{2}[\w\d]*$!){ $name=~s!^/!!; return $name }
	elsif ($name=~m!^([dirn])[\d_\-]*$!){ return 'm8/'.$1.'/'.$name }
	else { return $userDir.'/'.$name }
}

sub setFile {
	my ( $file, $text, $add )=@_;
	#&setWarn( "						sF @_" );
	chomp $text;
	my @path = split '/', $file;
	my $fileName = pop @path;
	my $dir = join '/', @path;
	-d $dir || make_path( $dir, { chmod => $chmod } );
	my $mode = '>';#>:encoding(UTF-8)
	$mode = '>'.$mode if $add;
	open (FILE, $mode, $dir.'/'.$fileName)|| die "Error opening file $dir/$fileName: $!\n";
		print FILE $text if $text;
		print FILE "\n" if $add;
	close (FILE);
#	&setFile ( $file.'.tmp','<c>'.$time.'</c>' ) if $file=~/.txt$/ or $file=~/.xml$/; 
	if ( $dbg and $file=~/.xml$/ or 1 ){
		-d $trashDir || make_path( $trashDir, { chmod => $chmod } );
		my $file = $trashDir.'/'.$path[$#path].'_'.$fileName;
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
	#&setWarn("						sX !!!! @keys" );
	#&setWarn("						sX ###### " ) if $keys[0];
	if ( $keys[0] ){
		#&setWarn("	###" );
		#&setWarn("						sX  Add xml" );
		my %hash = ( $root => $hash );
		#$hash{$root} = $hash;
		&setFile( $pathDir.'/'.$root.'.json', $JSON->encode(\%hash) );
		if ( $pathDir ){
			#$hash{$root}{'id'} = $pathDir;#'@
			my @path = split '/', $pathDir;
			for ( 0..$#path ){	$hash{$root}{$level[$_]} = $path[$_] }
		}
		#my $XML2JSON = XML::XML2JSON->new(pretty => 'true');
		my $XML = $XML2JSON->json2xml( $JSON->encode(\%hash) );
		&setFile( $pathDir.'/'.$root.'.xml', $XML );
		#&setFile( '/m8/$/'.$1.'.xml', $XML ) if $pathDir=~m!m8/(\w+)!;
		return $XML;
	}
	else{
		#&setWarn("						sX  Удаление xml-файла" );
		unlink $pathDir.'/'.$root.'.xml';
		unlink $pathDir.'/'.$root.'.json';
		#&setFile ( $pathDir.'/'.$root.'.xml.tmp', $time );  #время берется из глобальной переменной - не айс
	}
}
sub setName {
	my ( $type, @value )=@_;
	&setWarn( "					sN @_" );
	my $name;
	if (@value){
		@value = ( join( "\t", @value ) ) if $type eq 'd'; 
		my $value = join "\n", @value;
		my @name = murmur128_x64($value);
		( $name[0], $name[1] ) = ( $type.$name[0], $type.$name[1] );
		for my $n ( grep { -e $baseDir.'/'.$name[$_].'/value.tsv' } ( 0, 1 ) ){
			&setWarn( "					sN  проверка варианта $n - $name[$n]" );
			my $old = join "\n", &getFile( $baseDir.'/'.$name[$n].'/value.tsv');# )
			$old = Encode::decode_utf8($old);#читает и так нормально, но проверку на эквивалетность без флага не пройдет
			if ( $value eq $old ){ $name = $name[$n] }
			else { $name[$n] = undef }
		}
		if (not $name ){
			&setWarn( "					sN  присвоение первого попавшегося имени из двух: @name" );
			( $name ) = grep { $_ } @name;
			&setFile( $baseDir.'/'.$name.'/value.tsv', $value );
			#&setFile( $baseDir.'/'.$name.'/value2.tsv', $value );
			&rinseProc ( $name, @value )
		}	
	}
	else{
		$name = 'i';
		&rinseProc ( 'i', '' )
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
	#open( FILE, '>>'.$log )|| die "Ошибка при открытии файла $log: $!\n";
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
			#chomp;
			#s/\r$//;
			s/\s+\z//;
			push @text, $_;
		}
	close (FILE);
	#return @text;
	if ( $text[1] ){ 	return @text 	}	#elsif ( $text[0] ){ return $text[0]	}
	else {
		$text[0] = '' if not $text[0];
		return $text[0]
	}
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
	my %hash = &getHash(  $pathDir.'/'.$root.'.json' );
	return %{$hash{$root}}
}


sub getDoc {
	my ( %temp, $adminMode, $xslFile )=@_;
	my $doc = XML::LibXML::Document->new( "1.0", "UTF-8" );
	my $rootElement = $doc->createElement($temp{'fact'});
	$doc->addChild($rootElement);
	if ( defined $temp{'number'} ){
		&setWarn('     Идет выдача отладочной информации '.$temp{'number'} );
		foreach my $s ( 0..$#{$temp{'number'}} ){
			&setWarn("      Передача в темп-файл информации о созданном номере $s");
			my $tripleElement = $doc->createElement('number');
			foreach my $key ( keys %{$temp{'number'}[$s]} ){
				$tripleElement->setAttribute($key, $temp{'number'}[$s]{$key});
			}
			$tripleElement->appendText($s);
			$rootElement->addChild($tripleElement);
		}
		delete $temp{'number'}
	}
	$rootElement->appendText('_');
	#$temp{'tepmAuthor'} = $temp{'author'} if not defined $temp{'tempAuthor'};
	for my $param ( grep {$temp{$_}} keys %temp ) {	$rootElement->setAttribute( $param, $temp{$param} ) }
	my $localtime = localtime($temp{'time'}); #$temp{'time'}
	$rootElement->setAttribute( 'localtime', $localtime );
	#$rootElement->setAttribute( 'REQUEST_URI', $ENV{'REQUEST_URI'} );
	
	if ($xslFile){
		&setWarn('      Подготовка преобразования на клиенте');
		my $pi = $doc->createProcessingInstruction("xml-stylesheet"); #нельзя добавлять в конце поэтому добавляем вручную
		$pi->setData(type=>'text/xsl', href => $xslFile);
		$doc->insertBefore($pi, $rootElement);
	}
	my $pp = XML::LibXML::PrettyPrint->new();
	$pp->pretty_print($rootElement); # modified in-place
	
	&setFile( $logDir.'/temp.xml', $doc );
	return $doc
}
sub getTriple {
	&setWarn("		gT @_");
	my $name = $_[0];
	my $val = &getFile( $baseDir.'/'.$name.'/value.tsv' );
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
	for my $file ( &getDir($dirname) ){
		if ( -d $dirname.'/'.$file ){ $count += &delDir ( $dirname.'/'.$file ) }
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
			if ( &getDir ( $dir, 1 ) ){ @dir = () }
			else { &delDir ( $dir ) }
			pop @dir
		}
	}
	return $count
}
sub utfText {
	my ( $value ) = @_;
	$value =~ tr/+/ /;
	#$value =~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge;# if $utf
	#my $n = "\n";
	#$value =~ s/%0D%0A/$n/eg; #без этой обработки на выходе получаем двойной возврат каретки помимо перевода строки
	$value =~ s/%([a-fA-F0-9]{2})/pack("C", hex($1))/eg;
	return $value
}