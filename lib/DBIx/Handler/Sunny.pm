package DBIx::Handler::Sunny;
use strict;
use warnings;

# cpan
use parent qw(DBIx::Handler);

sub _do_selectrow { # see DBI::_do_selectrow
    my ($self, $method, @args) = @_;
    my $sth = $self->query(@args)
        or return undef;
    my $row = $sth->$method()
        and $sth->finish;
    return $row;
}

sub select_one {
    my ($self, @args) = @_;
    my $row = $self->_do_selectrow('fetchrow_arrayref', @args);
    return undef unless $row;
    return $row->[0];
}

sub select_row {
    my ($self, @args) = @_;
    my $row = $self->_do_selectrow('fetchrow_hashref', @args);
    return unless $row;
    return $row;
}

sub select_all {
    my ($self, @args) = @_;
    my $sth = $self->query(@args)
        or return [];
    return $sth->fetchall_arrayref({});
}

sub last_insert_id {
    my $self = shift;
    my $dsn = $self->{_connect_info}->[0];
    if ($dsn =~ /^(?i:dbi):SQLite\b/) {
        return $self->dbh->func('last_insert_rowid');
    }
    elsif ( $dsn =~ /^(?i:dbi):mysql\b/) {
        return $self->dbh->{mysql_insertid};
    }
    $self->dbh->last_insert_id(@_);
}

1;
__END__
