package Email::MIME::Attachment::Stripper;

use strict;
use warnings;

our $VERSION = '1.31';

use Email::MIME;
use Email::MIME::Modifier;
use Email::MIME::ContentType;
use Carp;

=head1 NAME

Email::MIME::Attachment::Stripper - Strip the attachments from a mail

=head1 SYNOPSIS

	my $stripper = Email::MIME::Attachment::Stripper->new($mail);

	my Email::MIME $msg = $stripper->message;
	my @attachments       = $stripper->attachments;

=head1 DESCRIPTION

Given a Email::MIME object, detach all attachments from the
message. These are then available separately.

=head1 METHODS

=head2 new 

	my $stripper = Email::MIME::Attachment::Stripper->new($mail, %args);

This should be instantiated with a Email::MIME object. Current arguments
supported:

=over 3

=item force_filename

Try harder to get a filename, making one up if necessary.

=back

=head2 message

	my Email::MIME $msg = $stripper->message;

This returns the message with all the attachments detached. This will
alter both the body and the header of the message.

=head2 attachments

	my @attachments = $stripper->attachments;

This returns a list of all the attachments we found in the message,
as a hash of { filename, content_type, payload }.

=head1 PERL EMAIL PROJECT

This module is maintained by the Perl Email Project

  L<http://emailproject.perl.org/wiki/Email::MIME::Attachment::Stripper>

=head1 AUTHOR

Casey West <casey@geeknest.com>

=head1 CREDITS AND LICENSE

This module is incredibly closely derived from Tony Bowden's
L<Mail::Message::Attachment::Stripper>; this derivation was done by
Simon Cozens (C<simon@cpan.org>), and you receive this under the same
terms as Tony's original module.

=cut

sub new {
	my ($class, $message, %attr) = @_;
	$message = Email::MIME->new($message) if !ref($message);

	croak "Need a message" unless ref($message) || do {
	    require Email::Abstract;
	    $message = Email::Abstract->cast($message, 'Email::MIME');
	};
	bless { message => $message, attr => \%attr }, $class;
}

sub message {
	my ($self) = @_;
	$self->_detach_all unless exists $self->{attach};
	return $self->{message};
}

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
          if $ct =~ m[text/plain] && $dp =~ /inline/;
        push @attach, $_;
        $self->_detach_all($_) if $_->parts > 1;
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
}

1;
