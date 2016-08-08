#!/usr/bin/perl -w

use PDF::FromHTML;

my $pdf = PDF::FromHTML->new( encoding => 'utf-8' );
    $pdf->load_file('page.html');
    $pdf->convert;
    $pdf->write_file('target.pdf');
    
    print "Content-type: text/html\n\n";
    print "done";
 
# my $pdf = PDF::FromHTML->new( encoding => 'utf-8' );
#    $pdf->load_file('R:/page.html');
#    $pdf->convert(
        #Font => '/path/to/font.ttf',
#        LineHeight => 10,
#        Landscape => 1,
 #   );
#    $pdf->write_file('R:/target.pdf');