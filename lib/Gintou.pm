package Gintou;
use strict;
use warnings;
our $VERSION = '0.01';
use parent qw( Class::Accessor::Fast );
use Guard ();
use Cwd;
use File::Temp qw( tempdir );
use File::Spec;

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
    return `$command`;
}

sub clone {
    my $self = shift;
    my $guard = $self->into_workdir;
    return $self->do( 'clone', '--bare', $self->repository );
}

sub logs {
    my $self = shift;
    my $guard = $self->into_workdir;
    warn getcwd;
    return $self->do( 'log' );
}

1;
__END__

=head1 NAME

Gintou -

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
