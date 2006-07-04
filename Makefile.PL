use ExtUtils::MakeMaker;

use strict;
use warnings;

my $PACKAGE = "Email::MIME::Attachment::Stripper";
my $LOCN    = "lib/Email/MIME/Attachment/Stripper.pm";

WriteMakefile(
	AUTHOR        => 'Casey West <casey@geeknest.com>',
	NAME          => $PACKAGE,
	ABSTRACT_FROM => $LOCN,
	VERSION_FROM  => $LOCN,
    PREREQ_PM     => {
                      'Email::MIME' => '1.82',
                      'Email::MIME::ContentType' => '1.0',
                      'Email::MIME::Modifier' => '1.41',
                     },
	dist => {
		COMPRESS     => 'gzip -9',
		SUFFIX       => '.gz',
		DIST_DEFAULT => 'all tardist',
	},

);
