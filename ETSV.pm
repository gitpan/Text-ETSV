package Text::ETSV;

use 5.008;
use strict;
use warnings;
# use Carp;

our $VERSION = '0.01'; # 2005-09-26 (since 2005-09-26)

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(
    etsv_encode etsv_decode
);
our @EXPORT_OK = qw(
    etsv_escape etsv_unescape
);

=head1 NAME

Text::ETSV - Manipulate ETSV (Enhanced Tab Separated Values).

=head1 SYNOPSIS

 use Text::ETSV;
 
 my %param = (
    name    => 'Masanori HATA'           ,
    mail    => 'lovewing@dream.big.or.jp',
    sex     => 'male'                    ,
    birth   => '2005-09-26'              ,
    nation  => 'Japan'                   ,
    pref    => 'Saitama'                 ,
    city    => 'Kawaguchi'               ,
    tel     => '+81-48-2XX-XXXX'         ,
    fax     => '+81-48-2XX-XXXX'         ,
    job     => 'student'                 ,
    role    => 'president'               ,
    hobby   => 'exaggeration'            ,
 );
 
 my $encoded = etsv_encode(%param);
 
 my %decoded = estv_decode($encoded);

=head1 DESCRIPTION

This module provides functions to manipulate ETSV. ETSV (Enhanced Tab Separated Values) is a data table format which I originated. This enhancement to TSV format has two features.

=over

=item 1. escaped characters

Only five kind of charaters are escaped. Those are [TAB] (for the column separater), [CR] or [LF] (for the line separater), '=' (for the name-value separater) and '%' (for the token of escaped string).

=item 2. object oriented values

All of values are coupled with its name. So all of values know their name by themselvs. It is like an object oriented way. Besides of a few size of overhead, it is very useful for the human usability and flexibility.

=back

For example, a ETSV data table is like below:

 name1=value1[TAB]name2=value2[TAB]name3=value3[TAB]...[LF]
 name1=value1[TAB]name2=value2[TAB]name3=value3[TAB]...[LF]
 (...)

=head1 FUNCTIONS

=over

=item etsv_encode(%param)

This function encode some hash (%) parameters to a line (table row).

=cut

# Enhanced TSV (Tab Separated Values) functions
# 1. CR or LF is escaped. (for the line separater)
# 2. Tab is escaped. (for the column separater)
# 3. '=' is escaped. (for the name-value separater)
# 4. '%' is escaped. (for the token of escaped string)

# Enhanced TSV encode/escape
sub etsv_encode {
	my @param = @_;
	
	my @column;
	for (my $i = 0; $i < $#param; $i += 2) {
		my $name  = &etsv_escape( $param[$i    ] );
		my $value = &etsv_escape( $param[$i + 1] );
		push @column, "$name=$value";
	}
	
	my $line = join "\t", @column;
	
	return $line;
}
sub etsv_escape {
	my $string = shift;
	
	my $reserved = "\x0D\x0A\t=%";
	my %escaped = (
		"\x0D" => '%0D',
		"\x0A" => '%0A',
		"\t"   => '%09',
		'='    => '%3D',
		'%'    => '%25',
	);
	
	$string =~ s/([$reserved])/$escaped{$1}/og;
	
	return $string;
}

=item etsv_decode($row)

This function decode a ETSV encoded row to hash (%) parameters.

=back

=cut

# Enhanced TSV decode/unescape
sub etsv_decode {
	my $line = shift;
	
	my @column = split /\t/, $line;
	
	my %data;
	foreach my $column (@column) {
		my($name, $value) = split /=/, $column;
		
		$name  = &etsv_unescape($name );
		$value = &etsv_unescape($value);
		
		$data{$name} = $value;
	}
	
	return %data;
}
sub etsv_unescape {
	my $string = shift;
	
	my $escaped = "%0D|%0A|%09|%3D|%25";
	my %unescaped = (
		'%0D' => "\x0D",
		'%0A' => "\x0A",
		'%09' => "\t"  ,
		'%3D' => '='   ,
		'%25' => '%'   ,
	);
	
	$string =~ s/$escaped/$unescaped{$&}/og;
	
	return $string;
}
########################################################################
1;
__END__

=head1 TSV vs CSV

I prefer to use TSV rather than CSV. Because, [TAB] is the control character just for the purpose, isn't it? Comma is not a control character and it is used also for human language purpose. Need for escaping comma in CSV would happen oftenly while that for escaping [TAB] in TSV would rarely.

=head1 AUTHOR

Masanori HATA E<lt>lovewing@dream.big.or.jpE<gt> (Saitama, JAPAN)

=head1 COPYRIGHT

Copyright (c) 2005 Masanori HATA. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

