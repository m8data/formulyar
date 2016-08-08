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

#my $time = time;

#symlink ('M:/$/reg.pl' => 'M:/a/communicator/$/action');
&setWarn( "		Control proc !!! " , $log1);
&setFile (undef, '/m8/control.txt');
&setFile(undef, $Disk.'/m8/env.json', JSON->new->utf8->encode(\%ENV));
&setFile(undef, $Disk.'/m8/argv.txt', "@ARGV");
sleep 8;
unlink '/m8/control.txt';
unlink '/m8/control.txt.xml';
my $cgi;

exit;

#!!!!!!!!!!!!!!!!!! ФУНКЦИИ !!!!!!!!!!!!!!!!!!!!!



######### функции первого порядка ##########
sub parseRequest{
	my ( $time, $proc, $request)=@_;
	&setWarn( "		pR @_" );# на входе строка $request, на выходе в журнале txt-файл request и в r1 листинги активных квестов, а так же папки всех квестов с: листингом истории и xml-файлами quest и last
	my @request = split /\?/, $request;	
	my @pair = ($request[0]);
	#$pair[0] = $request[0] if $request[0] ne $request;
	push @pair, sort {$a <=> $b} split(/&/, $request[1]) if $request[1];
	my $questValue = join '\n', @pair;
	my ($questName, $questName2) = sprintf("%08x", murmur128_x64($questValue) );
	if (-d '/m8/r1/'.$questName){
		&setWarn("		pR  Проверка занятости $questName"  ); #Здесь не получается применять getFile т.к. тот читает только одну строку
		my $oldVal = '';
		open (FILE,'/m8/r1/'.$questName.'/quest.txt')|| die 'Error opening file /m8/r1/'.$questName.'/quest.txt: '.$!.'\n'; 
			while (<FILE>) { $oldVal.=$_ }
		close (FILE);
		$questName = $questName2 if $questValue ne $oldVal;
	}
	my $base = shift @pair; #$pair[0] = 'folder='.$pair[0];
	my %ask;
	for my $pair (@pair){
		my ($name, $value) = split(/=/, $pair);
		#$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$ask{'@'.$name} = $value;
	}
	my %quest = (	
		'@id'	=> '/m8/r1/'.$questName,
		'@type' => 'r1',
		'@name' => $questName
	);
	$quest{$viewEl}{'@request'} = $request;
	if ( $base=~m!^/m8/r1/(\S+)/! ){
		&setWarn('  pR Чтение прошлого некогда '.$1);
		$quest{$viewEl}{'@frame'} = $1;
		my $index = decode_json(&getFile ('/m8/r1/'.$quest{$viewEl}{'@frame'}, 'quest.json'));
		for my $key ( grep { /^@/ } keys %{$$index{'quest'}{$viewEl}} ){
			&setWarn('  pR   Передача параметра '.$key.'(значение: '.$$index{'quest'}{$viewEl}{$key}.')');
			$quest{$viewEl}{$key} = $$index{'quest'}{$viewEl}{$key} if not ( defined $ask{'@m8mode'} and $ask{'@m8mode'} eq 'reverse' ) or ( defined $ask{$key} and not $ask{$key} )
		}
		#delete $quest{$viewEl}{'@m8mode'};
		&setFile($Disk.'/', JSON->new->utf8->encode(\%quest), 'quest.json');
		my $message = &askRequest (\%quest, \%ask, @pair);
		$message =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		&setWarn('  pR Вернулась ошибка -'.$message.'-');
		$quest{$viewEl}{'@message'} = $message if $message;
	}	
	if ( not defined $quest{$viewEl}{'@message'} ){
		&setWarn('  pR Валидация не нашла ошибок. Пишем параметры ');	
		for my $key (keys %ask){
			if ($ask{$key}){ $quest{$viewEl}{$key} = $ask{$key} }
			else { delete $quest{$viewEl}{$key} }
		}	
		if ( $request=~/[a|z][1|2|3]=/ ){ 
			open (FILE, '>>'.'/m8/r1/index.txt')|| die "Ошибка при открытии файла: $!\n";
				print FILE $questName, "\n";#"\t",
			close (FILE);
		}
		else { 	$quest{$viewEl}{'@message'} = 'no save' }	
	}

	delete $quest{$viewEl}{'@m8mode'} if defined $quest{$viewEl}{'@m8mode'} and ( ( $quest{$viewEl}{'@m8mode'} eq 'chk_avatar' and defined $quest{$viewEl}{'@avatar'} and $quest{$viewEl}{'@avatar'} ) or ( $quest{$viewEl}{'@m8mode'} eq 'chk_author' and defined $quest{$viewEl}{'@author'} and $quest{$viewEl}{'@author'} ) );
	delete $quest{$viewEl}{'@author'} if defined $quest{$viewEl}{'@author'} and not $ENV{HTTP_REFERER}; #$ENV{HTTP_REFERER};

	my $sourceXML = &saveHash (\%quest, 'quest', $quest{'@id'});
	&setFile ($quest{'@id'}, $questValue,  'quest.txt');
	my $localtime = localtime($time);
	&setFile ($quest{'@id'}, '<c localtime="'.$localtime.'">'.$time.'</c>', 'last.xml');
	&setFile ('/m8/$', $sourceXML, 'step.xml');
	$quest{$viewEl}{'@avatar'} = $defaultAvatar if not defined $quest{$viewEl}{'@avatar'};
	return $questName, $sourceXML, $quest{$viewEl}{'@avatar'}, $quest{$viewEl}{'@message'}
}

sub askRequest {
	my ( $quest, $ask, @pair)=@_;
	&setWarn( "		aR @_" );	
	if (defined $$ask{'@m8mode'} and ($$ask{'@m8mode'} eq 'chk_author') and defined $$ask{'@author'} and $$ask{'author'} ){ #not -e '/m8/r1/'.$params{'frame'}.'/author.txt'
		&setWarn('  aR  Работа с предложением автора.');
		#if (not ( -e '/m8/r1/'.$params{'frame'}.'/author.txt' ) ){# or ($params{'author'} eq 'guest')
		#	&setWarn('  Обработка предложения автора.');
		my $authorDir = $pivatDir.'/user/'.$$ask{'@author'};
		if ( defined $$ask{'@passw'} ){		
			&setWarn('	aR   Вход ранее созданного пользователя');
			-d $authorDir  || return 'Такой пользователь не зарегистрирован';#-e $authorRuneDIR.'/mult/index.xml'
			my $password=&getFile($authorDir);
			$password eq $$ask{'@passw'} || return 'Пароль или имя пользователя указаны не верно';
			delete $$ask{'@passw'};
		}
		elsif ( defined $$ask{'@password_first'} and defined $$ask{'@retype'} ) {
			&setWarn('	aR   Создание автора');
			defined $$ask{'@retype'} || return 'Повторите пароль';
			return 'Такой пользователь уже существует' if -d $authorDir; #-e $authorRuneDIR.'/mult/index.xml';
			$$ask{'@password_first'} eq $$ask{'@retype'} || return 'Пароль не совпадает';
			$$ask{'@author'} =~/^\w+$/ || return 'В имени могут быть лишь буквы латинского алфавита и цифры.';
			34 >= length $$ask{'@author'} || return 'Имя не должно быть длиннее 34 символов.';
			&setFile($authorDir, '<c>'.$$ask{'@password_first'}.'</c>');
			delete $$ask{'@retype'};
			delete $$ask{'@password_first'};
		}
		else { return 'Укажите пароль' }
	}
	elsif (defined $$ask{'@m8mode'} and ($$ask{'@m8mode'} eq 'chk_avatar') and defined $$ask{'@avatar'} and $$ask{'@avatar'} ){
		&setWarn('	aR   Проверка аватара');
		-e '/'.$$ask{'@avatar'}.$avatars.'/'.$$ask{'@avatar'}.'.xsl' || return 'Нет такого аватара';
	}
	elsif ($$quest{$viewEl}{'@request'} =~/[a|z][1|2|3]=/){
		&setWarn('  aR  Запись в универс');
		defined $$quest{$viewEl}{'@author'} ||  return 'Для редактирования информации нужно войти в систему'; # and $ENV{HTTP_REFERER}
		 #не вводим в параметры, т.к. для целей идентификации вью не важно откуда к нему пришли
		my %plan;
		#&parseQuery(\%plan, $author, $ENV{QUERY_STRING} );#\%sometime
		&setFile($Disk.'/', JSON->new->utf8->encode(\%plan), 'plan.json');
	}
	return 0
}


sub parseQuery{
	my ( $plan, $author, $qstring, @premult)=@_;
	&setWarn( "		pQ @_" );
	my @mult;
	my @query = ('n1');	
	my @map; #не создать нельзя, т.к. второго может не быть
	my @sentence;	
	my @value; #массив для контроля повторяющихся значений внутри триплов
	my %params;	
	foreach my $pair (split(/&/, $qstring)){
		&setWarn( "		pQ  $pair: парсинг данной пары" );	
		my ($name, $value) = split(/=/, $pair);
		$name || &endProc("ERROR Плохое имя парамера - $name");
		delete $params{$name} if $name =~/[a|z][1|2|3]/;	
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value = 0 if not $value; ## Если значение параметра прямо не указано, или указывается пустым, то оно признается равным нулю
		#$name and $value || &endProc("ERROR Bad pair $pair: name - $name, value - $value");
		if ($name eq 'z3'){
			&setWarn("		pQ   $pair: монтирование трипла $value" );	
			$value=~m!(\w+)$!; #что бы указывать трипл на демонтаж можно было разными способами
			my $tripleName = $1;
			if ($params{'frame'}){
				&setWarn("		pQ    $pair: подготовка единовременного демонтирования" );	
				$tripleName || &endProc('ERROR Вы пытаетесь изменить статус не трипла "'.$value.'"');
				&endProc('ERROR Повторяющийся трипл на монтирование: '.$tripleName) if defined $value[0]{$tripleName};
				-d $value || &endProc('ERROR Трипла '.$tripleName.' никогда не было.');
				my @query = split / /, &getFile( '/m8/n1/'.$tripleName, 'query.txt');
				$author eq $query[3] || &endProc('ERROR Текущий пользователь '.$author.' не имеет права демонтировать трипл "'.$tripleName.'". Автор - '.$query[3]);
				unlink '/m8/m8/'.$tripleName;
			}
			delete $$plan{'/m8/m8/'.$tripleName};
			$value[0]{$tripleName} = 1;
			push @query, $tripleName;
		}
		elsif ($name=~/u[123]/){
			&setWarn("		pQ   $pair: проверка назначения авторства" );
			#не допускаем указания юзером юзер-мультов, только логины
			my %input;
			$name=~/u([123])/;
			$input{$1} = $value
		}
		elsif ($name=~/(\w+)([123])/){
			&setWarn("		pQ   $pair: проверка формирования трипла" );
			my ($s, $m) = ($1, $2);
			$s =~tr/a-i/1-9/;
			my $pre = $s - 1;
			&endProc('ERROR Формирование трипла "'.$s.'" идет после операций монтирования.') if $s == 1 and $query[1];
			$pre==0 || $sentence[$pre] || &endProc('ERROR Пропущено предложение "'.$pre.'".');
			&endProc('ERROR Повторяющееся значение в предложении "'.$s.'": '.$value) if $value and defined $value[$s]{$value};
			$m == 3 and ($value=~m!^/m8/n0/! or $value=~m!^/m8/r1/!) || &endProc('ERROR Несколько значений в предложении "'.$s.' для члена "'.$m.'".') if $sentence[$s]{$m};
			if ($value=~m!/m8/n0/(\w+)$!){
				&setWarn("		pQ    $pair: проверка мульта $1.");
				my $multName = $1;
				#-d $value and  $currentTime > &getFile($value, 'time.txt') || &endProc('ERROR Указанный в значении мульт "'.$value.'" не существует на момент формирования запроса');
				if ($m == 3){ 
					if ($map[$s][0]){ 
						$map[$s][0] eq 'n0' || &endProc('ERROR При создании карты-таблицы в предложении '.$s.' обнаружено включение мульта '.$value.'.');
						push $map[$s], $multName;
					}
					else {$map[$s][0] = 'n0'}
				}
			}
			elsif ($value=~m!/m8/n1/(\w)$!){
				&setWarn("		pQ    $pair: проверка и раскодирование ссылки.");
				my $f = $1;
				$f =~tr/a-i/1-9/;
				$s > $f || &endProc('ERROR Ccылка '.$value.' не указывает на какое-либо предыдущее предложение');		
				$value = '/m8/n1/'.$f
			}
			else {
				&setWarn("		pQ    $pair: проверка руны.");
				&endProc('ERROR Трипл '.$s.' ошибочно указывает руну подлежащим') if $m==1;
				if ($value=~m!/m8/r[01]/!) { 
					&setWarn("		pQ     $pair: проверка явного айди руны.");
					&endProc('ERROR Трипл '.$s.' ошибочно указывает сказуемым карту') if $m==2 and $value=~m!/m8/r1!;
					#$value=~m!/m8/r0/\w{1,15}$! || -d $value and $time > &getFile ($value, 'time.txt') || &endProc('ERROR Указанная в значении руна "'.$value.'" не существует на момент формирования запроса');
					if ($m == 3){ 
						if ($map[$s][0]){ 
							$map[$s][0] eq 'r1' || &endProc('ERROR При создании карты-списка в предложении '.$s.' обнаружено включение карты '.$value.'.'); 
							push $map[$s], $value;
						}
						else {$map[$s][0] = 'r1'}
					}
				}
			}
			$sentence[$s]{$m} = $value[$s]{$value} = $value;
		}
		#else {&endProc('ERROR Не корректное имя в паре "'.$pair.'"')}
	}
	if ($sentence[1]){
		&setWarn("		pQ  Процедура создания триплов");
		for my $s (1..$#sentence){
			&setWarn("		pQ  $s: работа с данным предложением");
			my @v = ('');
			for my $m (1..3){
				&setWarn("		pQ    $s#$m: обработка этой роли с значением $sentence[$s]{$m}");
				if (defined $sentence[$s]{$m}){
					&setWarn("		pQ     $s#$m: проверка на генерацию рун и подстановки");
					if ( $map[$s][1] ){	$sentence[$s]{$m} = join '/', &makeMatter ( $plan, 'r1', @{$map[$s]} ) }
					elsif ( $sentence[$s]{$m}=~m!/(\w+)/(\w+)/(\w+)! ){ $sentence[$s]{$m} = $sentence[$1]{$2} if $sentence[$s]{$m}=~m!/m8/(\d+)/([1|2|3])!	}
					elsif ( $sentence[$s]{$m}=~/\w\S+/ ){ $sentence[$s]{$m} = join '/', &makeMatter ( $plan, 'n0', $sentence[$s]{$m}) }
					else { $sentence[$s]{$m} = join '/', &makeMatter ( $plan, 'r0', $sentence[$s]{$m}) }					
				}
				else{
					&setWarn("		pQ     $s#$m: создание нечто");
					if ($m == 2){ $sentence[$s]{$m} = join '/', &makeMatter ( $plan, 'n0', '0') }
					else{ 
						my $newSubject = shift @premult;
						if (not $newSubject){
							my @num = (0..9);
							my $num = 1; #rand @num;
							my @chars = (0..9, 'a'..'z');
							$newSubject = join("", @chars[ map{ rand @chars}(1..$lengthMult)]);#$max
							while (-d '/m8/n0/'.$num.$newSubject){ $newSubject = join("", @chars[ map{ rand @chars}(1..$lengthMult)]) }
							$newSubject = $num.$newSubject;
						}
						push @mult, $newSubject;
						$sentence[$s]{$m} = join '/', &makeMatter ( $plan, 'n0', $newSubject) 
					}
				}
				push @v, $sentence[$s]{$m};
			}
			my @tripleID = &makeMatter($plan, 'n1', @v);
			push @query, $tripleID[3];
			$$plan{'/m8/m8/'.$tripleID[3]} = 1; #$time.' '.$proc.' '.$s.' '.$user;
			&setFile ('/m8/m8', '', $tripleID[3]) if $params{'frame'}; #&setFile ('/m8/n1/'.$tripleID[3], $time.' '.$proc.' '.$s.' '.$user, 'query.txt') && 
		}
	}
	my @queryID = &makeMatter($plan, 'r1', @query);
	$params{'last'} = $queryID[3];
	$params{'mult'} = join '-', @mult;
	return @mult; #не обязательно отправлять 
}

sub indexingTriple{
	my ($plan, $name, $null, $online) = @_; #val,  %value
	&setWarn("		iT Регистрация трипла $name в индексах обнулением-$null (online-$online)"  );
	my @val = split / /, &getFile( '/m8/n1/'.$name, 'value.txt');
	my %m8;
	foreach my $m (1..3){ ( $m8{$val[$m]}{'role'}, $m8{$val[$m]}{'where'}[0], $m8{$val[$m]}{'where'}[1], $m8{$val[$m]}{'who'}[0], $m8{$val[$m]}{'who'}[1]  ) = ( $m, &getName( $val[$m] ), 'n1', $name ) }
	my @map;
	@map = split / /, &getFile( $val[3], 'value.txt') if $val[3] =~ m!/m8/r1/!;
	foreach my $m (1..$#map){
		my $metterID = '/m8/'.$map[0].'/'.$map[$m];
		( $m8{$metterID}{'role'}, $m8{$metterID}{'where'}[0], $m8{$metterID}{'where'}[1], $m8{$metterID}{'who'}[0], $m8{$metterID}{'who'}[1], $m8{$metterID}{'position'} ) = ( 0, $map[0], $map[$m], &getName( $val[3] ), $m ) 
	}
	my $tripleID = '/m8/n1/'.$name;
	my ($time, $proc, $position, $user) = split / /, &getFile( '/m8/n1/'.$name, 'query.txt');
	( $m8{$tripleID}{'role'}, $m8{$tripleID}{'where'}[0], $m8{$tripleID}{'where'}[1], $m8{$tripleID}{'who'}[0], $m8{$tripleID}{'who'}[1], $m8{$tripleID}{'position'} ) = ( 0, 'n1', $name, 'r1', $time.$queryMiddle.$proc, $position);
	foreach my $id (keys %m8){	
		&setWarn("		iT  Регистрация в сущности $id" );
		my $whereID = '/m8'.$id;
		my $whoID = '/m8/'.$m8{$id}{'who'}[0].'/'.$m8{$id}{'who'}[1];
		my $e1;
		if (defined $$plan{$whereID}){
			for my $p (0..$#{$$plan{$whereID}} ){ $e1 = $p if $$plan{$whereID}{$linkEl}[$p]{$textKey} eq $whoID	}
			$e1 = @{$$plan{$whereID}{$linkEl}} if not defined $e1;	
		}
		else {$e1 = 0}
		if ($null){
			&setWarn("		iT   Удаление упоминания в $whereID" );
			splice ( @{$$plan{$whereID}{$linkEl}}, $e1, 1);
		}
		else {
			&setWarn("		iT   Создание упоминания в $whereID" );
			$$plan{$whereID}{'@id'} = $id;
			$$plan{$whereID}{'@type'} = $m8{$id}{'where'}[0];
			$$plan{$whereID}{'@name'} = $m8{$id}{'where'}[1];
			$$plan{$whereID}{$linkEl}[$e1]{$textKey} = $whoID;
			$$plan{$whereID}{$linkEl}[$e1]{'@type'} = $m8{$id}{'who'}[0];
			$$plan{$whereID}{$linkEl}[$e1]{'@name'} = $m8{$id}{'who'}[1];
			$$plan{$whereID}{$linkEl}[$e1]{'@role'} = $m8{$id}{'role'};
			$$plan{$whereID}{$linkEl}[$e1]{'@qtime'} = $time;
			$$plan{$whereID}{$linkEl}[$e1]{'@qproc'} = $proc;
			$$plan{$whereID}{$linkEl}[$e1]{'@qposition'} = $position;
			$$plan{$whereID}{$linkEl}[$e1]{'@quser'} = $user;
			$$plan{$whereID}{$linkEl}[$e1]{'@qlocaltime'} = localtime($time);
			#my @localtime = localtime($time);
			#for (0..$#localtime){ $index{$linkEl}[$exist]{'@t'.$_} = $localtime[$_] }
			if (defined $m8{$id}{'position'}) { $$plan{$whereID}{$linkEl}[$e1]{'@position'} = $m8{$id}{'position'} }
			else{
				#for my $m (1..3){ 
				#	$$plan{$whereID}{$linkEl}[$e1]{'@t'.$m} = $m8{$val[$m]}{'where'}[0];
				#	$$plan{$whereID}{$linkEl}[$e1]{'@n'.$m} = $m8{$val[$m]}{'where'}[1]
				#} 
			}
		}
		$online || next;
		my $exist;
		my %index;
		if (-d $whereID){
			&setWarn("		iT   Действия при наличии папки $whereID" );
			my $index = decode_json(&getFile ($whereID, 'index.json'));
			%index = %{$index};
			#&setWarn("		iT    $#{$index{$linkEl}}" );
			for my $p (0..$#{$index{'index'}{$linkEl}} ){ $exist = $p if $index{'index'}{$linkEl}[$p]{'@name'} eq $name	}
			$exist = @{$index{'index'}{$linkEl}} if not defined $exist;
		}
		else {
			&setWarn("		iT   Действия при отсутствии папки $whereID" );
			make_path $whereID;
			$index{'index'}{'@id'} = $id;
			$index{'index'}{'@type'} = $m8{$id}{'where'}[0];
			$index{'index'}{'@name'} = $m8{$id}{'where'}[1];
			$exist = 0
		}
		if ($null){
			&setWarn("		iT   Запись удаления из позиции $exist в базу" );
			if ( $#{$index{'index'}{$linkEl}} ){ 
				&setWarn("		iT    Редактирование хэша" );
				splice ( @{$index{'index'}{$linkEl}}, $exist, 1);
				&saveHash ( $index{'index'}, 'index', $whereID);				
			}
			else {
				&setWarn("		iT    Полное удаление папки" );
				rmtree $whereID;
				&delDir ($plan, '/m8/m8/'.$m8{$id}{'where'}[0]);
				&delDir ($plan, '/m8/m8');
			}
		}
		else {
			&setWarn("		iT   Запись добавления в позицию $exist в базу" );
			for my $key( keys %{$$plan{$whereID}{$linkEl}[$e1]} ){ $index{'index'}{$linkEl}[$exist]{$key} = $$plan{$whereID}{$linkEl}[$e1]{$key} }
			&saveHash ( $index{'index'}, 'index', $whereID);
		}
		&setFile ($id, $online, 'time.txt');
	}
}



######### функции второго порядка ##########
sub makeMatter{
	my ($plan, $type, @value) = @_;
	&setWarn("				mМ Создание файла сущности $type, c значением @value" );
	my $value = join ' ', @value;
	my $name = $value[0];
	if ($type ne 'n0'){
		my $name2;
		if ($type eq 'n1'){ ($name, $name2) = murmur128_x64($value) }
		else { ($name, $name2) = sprintf("%08x", murmur128_x64($value)) }
		$name = $name2 if -d '/m8/'.$type.'/'.$name and ($value ne &getFile('/m8/'.$type.'/'.$name, 'value.txt'));
	}
	my $matterID = '/m8/'.$type.'/'.$name;
	$$plan{$matterID} = 1;
	my %m8;
	if ($value[1]){ #вероятно здесь правильнее (понятнее) было бы смотреть не на значения, а на тип - r0 или нет
		my $typeVal = shift @value;
		for my $p (0..$#value){
			&setWarn("				mМ   Запись позиции $p с значением $value[$p]" );
			my @name = ( $typeVal, $value[$p] );
			if ($typeVal){ $value[$p] = '/m8/'.$typeVal.'/'.$value[$p] }
			else { @name = &getName ($value[$p])}
			#&setWarn("		mМ   values: @value" );
			$m8{$linkEl}[$p]{$textKey} = $value[$p];
			$m8{$linkEl}[$p]{'@type'} = $name[0];
			$m8{$linkEl}[$p]{'@name'} = $name[1];
		}
	}
	else { $m8{$textKey} = $name }	
	&setFile ($matterID, $value, 'value.txt');
	$m8{'@id'} = $matterID;
	$m8{'@name'} = $name;
	$m8{'@type'} = $type;
	&saveHash (\%m8, 'value', '/m8/'.$type.'/'.$name);
	#symlink ('M:/m8'.$matterID => 'M:'.$matterID.'/index'); #ссылки лучше делать так, а не динамически, иначе придется контролировать их наличие
	return ('', 'm8', $type, $name);
}

sub getFile {
	&setWarn( "				gF @_" );
	my ($dir, $file)=@_;
	$file = 'index.xml' if not $file;
	open (FILE, $dir.'/'.$file)|| die "Error opening file $dir/$file: $!\n"; 
		my $text=<FILE>;
	close (FILE);
	$text = $1 if $text=~m!^<c.*>(.+)</c>$!;
	return $text
}

sub getDir{
	my ($path)=@_;
	opendir (TEMP, $path) || die "Error open dir $path: $!";
	my @name = grep {!/\./} readdir TEMP;
	closedir(TEMP);
	return @name
}




######### функции третьего порядка ##########
sub saveHash {
	my ($hash, $root, $pathDir) = @_;
	&setWarn("						sH Запись хэша $hash (root $root) в путь $pathDir" );
	my %hash = ($root, $hash);
	my $JSON = JSON->new->utf8->encode(\%hash);
	&setFile($pathDir, $JSON, $root.'.json');
	my $XML2JSON = XML::XML2JSON->new(pretty => 'true');
	my $XML = $XML2JSON->json2xml($JSON);
	&setFile ($pathDir, $XML, $root.'.xml');	
	return $XML;
}
sub getName {
	&setWarn( "						gN @_" );
	my ($metterID)=@_;
	$metterID =~m!/m8/([r|n][0|1])/(\w{1,20})!; #r допускается, т.к. может быть карта-запрос
	return ($1, $2)
}

sub delDir {
	&setWarn( "						dD @_" );
	my ($plan, $dirname)=@_;
	my $del = 1;
	my $rootDir = $Disk.$dirname;
	-d $rootDir || return;
	opendir (TEMP, $rootDir) || die "Error open dir $rootDir: $!";
		while (readdir TEMP){ $del = 0 && last if !/\.$/ }
	closedir(TEMP);
	$del || return;
	#delete $$plan{$rootDir};
	return rmtree ($rootDir);
}

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