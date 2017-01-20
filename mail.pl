#!/usr/bin/perl

use warnings;
use strict;
use Email::Send;
use Email::Send::Gmail;
use Email::Simple::Creator;

use CGI 'param','header'; # модуль удален из базовой комплектации начиная с версии 5.22
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); #идет в составе CGI

 my $q = CGI->new;
#http://stackoverflow.com/questions/23704058/perl-emailsendgmail-cannot-connect-to-gmail-account-on-windows-7
my @account;

open (FILE, $ENV{DOCUMENT_ROOT}.'/mail.conf' )|| die "Error opening file $ENV{DOCUMENT_ROOT}/mail.conf: $!\n"; 
		while (<FILE>){
			s/\s+\z//;
			push @account, $_;
		}
	close (FILE);

my $email = Email::Simple->create (
  header => [
    From    => param('email'),
    To      => $account[0],
    Subject => 'question from '.$ENV{SERVER_NAME},
  ],

  body => 'Имя: '.param('name').'
Email: '.param('email').'
Телефон: '.param('phone').'
Вопрос: '.param('question')
);

my $sender = Email::Send->new 
({
  mailer      => 'Gmail',
  mailer_args => 
    [
      username => $account[1],
      password => $account[2],
    ]
});

$sender->send ($email);

print $q->header();
print '1';