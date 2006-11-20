use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
	AUTHOR        => 'Casey West <casey@geeknest.com>',
	NAME          => "Email::MIME::Attachment::Stripper",
	ABSTRACT_FROM => 'lib/Email/MIME/Attachment/Stripper.pm',
	VERSION_FROM  => 'lib/Email/MIME/Attachment/Stripper.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
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
