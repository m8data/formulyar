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
# hao@infostandart.com
my $poluchatel = 'hao@infostandart.com';

my $email = Email::Simple->create (
  header => [
    From    => param('email'),
    To      => $poluchatel,
    Subject => 'question from tn_landing',
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
      username => '',
      password => '',
    ]
});

$sender->send ($email);

print $q->header();
print '1';