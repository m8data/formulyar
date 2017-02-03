#!/usr/bin/perl -w

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

my $maddress = &utfText( param('email') );
my $body = '';  
for my $pair ( split( /&/, &utfText( $ENV{'QUERY_STRING'} ) ) ){
	my ($name, $value) = split(/=/, $pair);
	next if $name eq '_';
	$body .= ucfirst($name).': '.$value."\n";
}  
  
my $email = Email::Simple->create (
  header => [
    From    => $maddress,
    To      => $account[0],
    Subject => 'mail from '.$ENV{SERVER_NAME},
  ],
  body => $body
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

sub utfText {
	my $value = shift;
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9]{2})/pack("C", hex($1))/eg;
# $value = Encode::decode_utf8( $value );
	return $value
}