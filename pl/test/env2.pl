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
#use Win32::Symlink;
#use utf8;
#binmode(STDOUT, ":encoding(UTF-8)");
my @v =('m8', 	#0 - имя системы
'frame', 		#1 - базовый атрибут в r1/карте - определяет в контексте какого адреса пришел список (для запроса - некогда или пусто, для остальных - класс объектов)   
);
my $dbg = 1;
my $Disk = 'M:';
my $programs = '/$';
my $controlxslDir = '/$';
my $mapFrameAtr = 'frame';
my $avatars = '/a'; #убрали по новой модели 01.12.2015
my $defaultAvatar = 'lab';#communicator 'm8data'; #вообще его можно и лучше брать из SCRIPT_NAME 
my $defaultAuthor = 'guest';
my $admin = 'm8data';
my $pivatDir = '/m8/$/privat';
my $reportDir = $Disk.'/m8';
my $stepDir = $Disk.'/step';
my $textKey = '$t';
my $linkEl = 'a';
my $recordTime = 0;
my $lengthMult = 3;
my $viewEl = 'plan';
#my $revolutionInterval = 20;
my $lengthSession = 4; #длинна имени идентификатора сессии
my $nameRang = 100000; #длина PID #привязки к длинне в коде нигде нет кроме генерации титлов - туда идет последний знак из name2Rang
my $name2Rang = 1000; #длина sentence (цифр у дочернего айди в процессе)
my $name2 = '000'; #длина sentence (цифр у дочернего айди в процессе)
my $queryMiddle = '000';
my $busyDir = $Disk.'/m8/busy';
my $control = '/m8/control';
my $journal = '/m8/$/journal';
my $journal2 = '/m8/$/journal';
my $alfa = '/m8/alfa';
my $beta = $alfa.'/beta';
my %typeName = ('n1', 'triple', 'n0', 'mult', 'r1', 'map', 'r0', 'text');
my $reqnew;
my $currentTime = time;

my $time = time;
my $trashDir = '/m8/$';

my $errorLog = $Disk.'/error_log.txt';
my $logName = 'data_log.txt';
my $log = $Disk.'/'.$logName;
my $log1 = $Disk.'/control_log.txt';

my $qa = CGI->new();
print $qa->header( -type => 'text/html' ); 
print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'; 

print JSON->new->utf8->encode(\%ENV);

my $cgi;

exit;

#!!!!!!!!!!!!!!!!!! ФУНКЦИИ !!!!!!!!!!!!!!!!!!!!!




######### функции четвертого порядка ##########
sub setFile {
	my ( $unreal, $file, $text, $add)=@_;
	#&setWarn( "						sF @_" );
	#$dbg || $unreal || return;
	#return if $unreal == 2;
	if ( $unreal ){
		#&setWarn( "						sF  Логическая запись" );
		if ($add){ $$unreal{$file} .= $text.'\n' }
		else { $$unreal{$file} = $text }
	}
	else{		
		#&setWarn( "						sF  Физическая запись $$temp{'time'}" );
		my @path = split '/', $file;
		my $fileName = pop @path;
		my $dir = join '/', @path;
		-d $dir || make_path $dir;
		my $mode = '>';
		$mode .= '>' if $add;
		open (FILE, $mode.$file)|| die "Error opening file $file: $!\n";
			print FILE $text if $text;
			print FILE "\n" if $add;
		close (FILE);
		&setFile ( undef, $file.'.xml','<c>'.$time.'</c>' ) if $file=~/.txt$/ or $file=~/.json$/; 
	}
	return $text; #обязательно нужно что-то возвращать, т.к. иногда функция вызывается в контексте and
}

sub setWarn {
	$dbg || return;
	my ($text, $logFile)=@_;
	my @c = caller;
	#warn $text;
	if ($logFile){
		$log = $logFile;  #что бы записи отладки для контроля и другого шли в разные логи
		unlink $log if -e $log;
	}
	open (FILE, '>>'.$log)|| die "Ошибка при открытии файла: $!\n";
		print FILE $c[2],  $text, "\n";#"\t",
	close (FILE);
}
sub setM8 {
	my ($m8, $numb) = @_;
	$numb = '' if not $numb;
	&setFile($Disk.'/', JSON->new->utf8->encode($m8), 'm8-'.$numb.'.json');
}
sub endProc {
	my ($message) = @_;
	&setWarn( "								eP @_" );
	my %params;
	my $time = time;
	my $localtime = localtime($time);
	my $sourceXML;
	my %sometime;
	if ($message){
		&setWarn('  eP Отправка сообщения об ошибке.');
		$sourceXML = XML::LibXML->load_xml(location => '/m8/r1/'.$params{'frame'}.'/value.xml');
		&setFile ('/m8/r1/'.$params{'frame'}, '<c localtime="'.$localtime.'" message="'.$message.'">'.$time.'</c>', 'last.xml'); 
	}
	else{ 
		&setWarn('  eP Сохранение нового некогда.');	
		delete $params{'m8mode'} if defined $params{'m8mode'} and ( ( $params{'m8mode'} eq 'chk_avatar' and defined $params{'avatar'} and $params{'avatar'} ) or ( $params{'m8mode'} eq 'chk_author' and defined $params{'author'} and $params{'author'} ) );
		$params{'author'} = '' if not $ENV{HTTP_REFERER}; #$ENV{HTTP_REFERER};	
		if ($params{'frame'}){
			&setWarn('  Чтение прошлого некогда');
			my $index = decode_json(&getFile ('/m8/r1/'.$params{'frame'}, 'value.json'));
			if ( defined $params{'m8mode'} and $params{'m8mode'} eq 'reverse' ){	#включается режим инверсии - все что заказано на стирание пропускается, остальное нет
				&setWarn('   eP Работа инверсионного режима'); # от него лучше отказаться ориентируясь в блоке про проверку юзера на login.txt
				for my $key ( grep { s/@// and defined $params{$_} and not $params{$_} } keys %{$$index{'value'}{$viewEl}} ){
					&setWarn("    eP Пропускаем параметр $key, значение $$index{'value'}{$viewEl}{'@'.$key}");
					$sometime{$viewEl}{'@'.$key} = $$index{'value'}{$viewEl}{'@'.$key};
					delete $params{$key};
				}
				delete $params{'m8mode'};
			}
			else { %sometime = %{$$index{'value'}} }
			#delete $sometime{$viewEl}{'@m8mode'};
			#$sometime{$viewEl}{'@'.$mapFrameAtr} = $params{'frame'};
			#$author = $sometime{$viewEl}{'@author'} = $$index{'value'}{$viewEl}{'@author'} if defined $$index{'value'}{$viewEl}{'@author'};
			#delete $sometime{$viewEl}{'@user'} if defined $sometime{$viewEl}{'@user'} and $sometime{$viewEl}{'@user'} eq 'guest'; 
		}
		foreach my $key (keys %params) { 
			if ($params{$key}){	$sometime{$viewEl}{'@'.$key} = $params{$key} }
			else {delete $sometime{$viewEl}{'@'.$key} }# map { s/^@// } 
		}
		$ENV{REQUEST_URI}=~/^(\S+)\?$ENV{QUERY_STRING}/;
		my $viewValue = $1 || $ENV{REQUEST_URI};
		foreach my $pair ( sort {$a <=> $b} split(/&/, $ENV{QUERY_STRING}) ){ $viewValue .= '
'.$pair }
		my $sometimeName2;
		($params{'frame'}, $sometimeName2) = murmur128_x64($viewValue);
		if (-d '/m8/r1/'.$params{'frame'}){
			&setWarn("		eP  Проверка занятости $params{'frame'}"  ); #Здесь не получается применять getFile т.к. тот читает только одну строку
			my $oldVal = '';
			open (FILE,'/m8/r1/'.$params{'frame'}.'/value.txt')|| die 'Error opening file /m8/r1/'.$params{'frame'}.'/value.txt: '.$!.'\n'; 
				while (<FILE>) { $oldVal.=$_ }
			close (FILE);
			$params{'frame'} = $sometimeName2 if $viewValue ne $oldVal;
		}
		$sometime{'@id'} = '/m8/r1/'.$params{'frame'};
		$sometime{'@type'} = 'r1';
		$sometime{'@name'} = $params{'frame'};
		&setFile ($sometime{'@id'}, $viewValue, 'value.txt');	
		&setFile ($sometime{'@id'}, '<c localtime="'.$localtime.'">'.$time.'</c>', 'last.xml');
		$sometime{$viewEl}{'@request'} = $ENV{REQUEST_URI};
		&setFile ('/m8/r1/'.$params{'frame'}, $sometime{$viewEl}{'@avatar'}, 'avatar.txt') if defined $sometime{$viewEl}{'@avatar'};		
		&setFile ('/m8/r1/'.$params{'frame'}, $sometime{$viewEl}{'@author'}, 'author.txt') if defined $sometime{$viewEl}{'@author'}; 
		$sourceXML = &saveHash (\%sometime, 'value', $sometime{'@id'});
		&setFile ('/m8/$', $sourceXML, 'step.xml');
		if (defined $params{'last'}){
			&setWarn("		eP  Запись изменений в индексе"  );
			$time =~/(\d{5})(\d{5})/;
			my $journalDir = $Disk.$journal.'/'.$1.'/'.$2;
			-d $journalDir || make_path ($journalDir);
			open (FILE, '>>'.$journalDir.'/index.txt')|| die "Ошибка при открытии файла: $!\n";
				print FILE $$.'_'.$params{'mults'}.'?'.$ENV{QUERY_STRING}, "\n";
			close (FILE);
			
			my @query = split / /, &getFile( '/m8/r1/'.$params{'last'}, 'value.txt');
			my %m8;
			for my $s (1..$#query ){
				&setWarn(" eP Фиксация упоминаний трипла предложения $s ($query[$s]) из текущего запроса");
				my $null = 1;
				$null = 0 if -e '/m8/m8/'.$query[$s];
				&indexingTriple (\%m8, $query[$s], $null, $params{'time'});
			}
		}
		# здесь еще нужно проставить id некогда во все триплы
	}
	$sometime{$viewEl}{'@avatar'} = $defaultAvatar if not defined $sometime{$viewEl}{'@avatar'};
	my $xslFile = '/'.$sometime{$viewEl}{'@avatar'}.$avatars.'/'.$sometime{$viewEl}{'@avatar'}.'.xsl';
	my $locationType = &getFile ('', 'locationType.txt');
	if ( $ENV{QUERY_STRING}=~/passw/ and not $params{'m8mode'} ){ print $cgi->header(-location =>'/m8/r1/'.$params{'frame'}) } # если в QUERY_STRING виден пароль, то редирект для его сокрытия
	elsif ( $locationType eq 'html' ){
		print $cgi->header(); #HTTP_REFERER
		# вывод сервером -type => 'text/html',
		my $xslt = XML::LibXSLT->new();
		my $style_doc = XML::LibXML->load_xml(location=> $xslFile, no_cdata=>1);
		my $stylesheet = $xslt->parse_stylesheet($style_doc); 
		my $results = $stylesheet->transform($sourceXML);
		print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'; #нужно корректно указывать что бы не включился искусственный режим совместимости портящий шрифты и т.д.
		print $stylesheet->output_as_bytes($results);
	}
	else {
		print $cgi->header(-type=>'text/xml');
		my $xslHref = '<?xml-stylesheet href="'.'https://'.$ENV{HTTP_HOST}.$xslFile.'" type="text/xsl"?>
';
		$sourceXML=~s/<value/$xslHref<value/;
		print $sourceXML;
	}
	exit
}