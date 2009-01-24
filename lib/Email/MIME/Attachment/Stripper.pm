use strict;
use warnings;
package Email::MIME::Attachment::Stripper;

our $VERSION = '1.316';

use Email::MIME 1.861;
use Email::MIME::Modifier;
use Email::MIME::ContentType;
use Carp;

=head1 NAME

Email::MIME::Attachment::Stripper - strip the attachments from an email

=head1 VERSION

version 1.316

=head1 SYNOPSIS

	my $stripper = Email::MIME::Attachment::Stripper->new($mail);

	my $msg = $stripper->message;
	my @attachments = $stripper->attachments;

=head1 DESCRIPTION

Given a Email::MIME object, detach all attachments from the message and make
them available separately.

The message you're left with might still be multipart, but it should only be
multipart/alternative or multipart/related.

Given this message:

  + multipart/mixed
    - text/plain
    - application/pdf; disposition=attachment

The PDF will be stripped.  Whether the returned message is a single text/plain
part or a multipart/mixed message with only the text/plain part remaining in it
is not yet guaranteed one way or the other.

=head1 METHODS

=head2 new 

	my $stripper = Email::MIME::Attachment::Stripper->new($email, %args);

The constructor may be passed an Email::MIME object, a reference to a string,
or any other value that Email::Abstract (if available) can cast to an
Email::MIME object.

Valid arguments include:

  force_filename - try harder to get a filename, making one up if necessary

=cut

sub new {
	my ($class, $email, %attr) = @_;
	$email = Email::MIME->new($email) if (ref($email) || 'SCALAR') eq 'SCALAR';

	croak "Need a message" unless ref($email) || do {
	  require Email::Abstract;
	  $email = Email::Abstract->cast($email, 'Email::MIME');
	};

	bless { message => $email, attr => \%attr }, $class;
}

=head2 message

	my $email_mime = $stripper->message;

This returns the message with all the attachments detached. This will alter
both the body and the header of the message.

=cut

sub message {
	my ($self) = @_;
	$self->_detach_all unless exists $self->{attach};
	return $self->{message};
}

=head2 attachments

	my @attachments = $stripper->attachments;

This returns a list of all the attachments we found in the message, as a hash
of { filename, content_type, payload }.

This may contain parts that might not normally be considered attachments, like
text/html or multipart/alternative.

=cut

sub attachments {
	my $self = shift;
	$self->_detach_all unless exists $self->{attach};
	return $self->{attach} ? @{ $self->{attach} } : ();
}

sub _detach_all {
    my ($self, $part) = @_;
    $part ||= $self->{message};
    return if $part->parts == 1;
    
    my @attach = ();
    my @keep   = ();
    foreach ( $part->parts ) {
        my $ct = $_->content_type                  || 'text/plain';
        my $dp = $_->header('Content-Disposition') || 'inline';
        
        push(@keep, $_) and next
          if $ct =~ m[text/plain]i && $dp =~ /inline/i;
        push @attach, $_;
  if ($_->parts > 1) {
          my @kept=$self->_detach_all($_);
    push(@keep,@kept) if @kept;
        }
    }
    $part->parts_set(\@keep);
    push @{$self->{attach}}, map {
        my $content_type = parse_content_type($_->content_type);
        {
            content_type => join(
                                 '/', 
                                 @{$content_type}{qw[discrete composite]}
                                ),
            payload      => $_->body,
            filename     =>   $self->{attr}->{force_filename}
                            ? $_->filename(1)
                            : ($_->filename || ''),
        }
    } @attach;

    return @keep;
}

=head1 PERL EMAIL PROJECT

This module is maintained by the Perl Email Project

L<http://emailproject.perl.org/wiki/Email::MIME::Attachment::Stripper>

=head1 AUTHOR

Currently maintained by Ricardo SIGNES <rjbs@cpan.org>

Written by Casey West <casey@geeknest.com>

=head1 CREDITS AND LICENSE

This module is incredibly closely derived from Tony Bowden's
L<Mail::Message::Attachment::Stripper>; this derivation was done by Simon
Cozens (C<simon@cpan.org>), and you receive this under the same terms as Tony's
original module.

=cut

1;
