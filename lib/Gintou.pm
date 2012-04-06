package Gintou;
use strict;
use warnings;
our $VERSION = '0.01';
use parent qw( Class::Accessor::Fast );
use Guard ();
use Cwd;
use File::Temp qw( tempdir );
use File::Spec;
use utf8;

__PACKAGE__->mk_accessors( qw( repository workdir binary cleanup ) );

sub new {
    my ( $class, %args ) = @_;
    my $workdir = File::Spec->catfile( tempdir() );
    $args{workdir} ||= $workdir;
    $args{binary} ||= '/usr/bin/env git';
    my $self = $class->SUPER::new( { %args } );
    $self->cleanup( Guard::guard {
        `rm -rf $workdir`;
    } );
    $self->clone;
    return $self;
}

sub guard {
    my $self = shift;
    my $cwd = getcwd();
    return Guard::guard {
        chdir $cwd;
    };
}

sub into_workdir {
    my $self = shift;
    my $guard = $self->guard;
    chdir $self->workdir;
    return $guard;
}

sub do {
    my ( $self, @cmd ) = @_;
    my $git = $self->binary;
    my $command = join ' ', $git, @cmd;
    warn $command;
    return scalar `$command`;
}

sub clone {
    my $self = shift;
    return $self->do( 'clone', '--bare', $self->repository, $self->workdir );
}

sub log {
    my ( $self, @options ) = @_;
    my $guard = $self->into_workdir;
    my $raw = $self->do( 'log', @options );
    my @logs = $raw =~ /commit\s([0-9a-f]{40})\nAuthor:\s(.+?)\nDate:\s+(.+?)\n\n\s+(.+?)\n/msg;
    my @rtn;
    while ( @logs ) {
        my $log = {
            commit => shift @logs,
            author => shift @logs,
            date => shift @logs,
            message => shift @logs,
        };
        push @rtn, $log;
    }
    return @rtn;
}

sub show {
    my ( $self, $commit ) = @_;
    my $guard = $self->into_workdir;
    my $raw = $self->do( 'show', $commit );
    my $rtn = {};
    ( $rtn->{commit}, $rtn->{author}, 
      $rtn->{date}, $rtn->{message}, 
      $rtn->{differ} 
    ) = $raw =~ /commit\s([0-9a-f]{40})\nAuthor:\s(.+?)\nDate:\s+(.+?)\n\n\s+(.+?)\n\n(.+)/msg;
    $rtn->{differ} = [ map { 'diff --git '.$_ } split /diff --git /, $rtn->{differ} ];
    shift @{$rtn->{differ}};
    for my $diff ( @{$rtn->{differ}} ) {
        $diff = { 
            code => $diff, 
            file => undef,
        };
        ( $diff->{file} ) = $diff->{code} =~ /diff --git a\/(.+?)\s/;
    }
    return $rtn;
}

1;
__END__

=head1 NAME

Gintou - Git repository explorer class

=head1 SYNOPSIS

  use Gintou;

=head1 DESCRIPTION

Gintou is

=head1 AUTHOR

satoshi azuma E<lt>ytnobody at gmail dot comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
