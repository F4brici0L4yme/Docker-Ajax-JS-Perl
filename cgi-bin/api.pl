#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use DBI;

my $dsn      = "DBI:mysql:database=test_db;host=localhost";
my $username = "root";
my $password = "password";
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, PrintError => 0 });

my $cgi = CGI->new;
print $cgi->header('application/json');

if ($ENV{'REQUEST_METHOD'} eq 'GET') {
    my $id = $cgi->param('id');
    if ($id) {
        my $sth = $dbh->prepare("SELECT * FROM employees WHERE id = ?");
        $sth->execute($id);
        print to_json($sth->fetchrow_hashref);
    } else {
        my $sth = $dbh->prepare("SELECT * FROM employees");
        $sth->execute();
        print to_json($sth->fetchall_arrayref({}));
    }
} elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
    my $data = decode_json($cgi->param('POSTDATA'));
    if ($data->{id}) {
        $dbh->do("UPDATE employees SET name = ?, position = ?, salary = ? WHERE id = ?", undef,
            $data->{name}, $data->{position}, $data->{salary}, $data->{id});
    } else {
        $dbh->do("INSERT INTO employees (name, position, salary) VALUES (?, ?, ?)", undef,
            $data->{name}, $data->{position}, $data->{salary});
    }
    print to_json({ success => 1 });
} elsif ($ENV{'REQUEST_METHOD'} eq 'DELETE') {
    my $id = $cgi->param('id');
    $dbh->do("DELETE FROM employees WHERE id = ?", undef, $id);
    print to_json({ success => 1 });
}

$dbh->disconnect;
