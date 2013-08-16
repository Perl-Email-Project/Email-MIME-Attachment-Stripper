use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
	AUTHOR        => 'Ricardo SIGNES <rjbs@cpan.org>',
	NAME          => "Email::MIME::Attachment::Stripper",
	ABSTRACT_FROM => 'lib/Email/MIME/Attachment/Stripper.pm',
	VERSION_FROM  => 'lib/Email/MIME/Attachment/Stripper.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    'Email::MIME'              => '1.861', # new(\$str)
    'Email::MIME::ContentType' => '1.0',
    'Email::MIME::Modifier'    => '1.442', # otherwise, scalar deref bug
  },
	dist => {
		COMPRESS     => 'gzip -9',
		SUFFIX       => '.gz',
		DIST_DEFAULT => 'all tardist',
	},
  (eval { ExtUtils::MakeMaker->VERSION(6.46) }
    ? (META_MERGE => {
        resources => {
          repository => 'http://github.com/rjbs/email-mime-attachment-stripper'
        }
      })
    : ()
  ),
);
