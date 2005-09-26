use 5.008;
use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'         => 'Text::ETSV',
	'VERSION_FROM' => 'ETSV.pm',
	'PREREQ_PM'    => {
		'Exporter' => '5.58',
	},
	($] >= 5.005 ? (
		'ABSTRACT' => 'Manipulate ETSV (Enhanced Tab Separated Values)',
		'AUTHOR'   => 'Masanori HATA <lovewing@dream.big.or.jp>',
	) : ()),
);
