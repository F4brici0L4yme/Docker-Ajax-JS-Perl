#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use DBI;

my $cgi = CGI->new;
print $cgi->header(-type => 'text/html', -charset => 'UTF-8');

my $dsn      = "DBI:mysql:database=menagerie;host=127.0.0.1";
my $username = "root";
my $password = "";

my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, PrintError => 0 });

my $action = $cgi->param('action') || '';
if ($action eq 'insert') {
    my $name    = $cgi->param('name');
    my $owner   = $cgi->param('owner');
    my $species = $cgi->param('species');
    my $sex     = $cgi->param('sex');
    my $birth   = $cgi->param('birth');
    my $death   = $cgi->param('death') || undef;

    $dbh->do("INSERT INTO pets (name, owner, species, sex, birth, death) VALUES (?, ?, ?, ?, ?, ?)",
             undef, $name, $owner, $species, $sex, $birth, $death);
} elsif ($action eq 'delete') {
    my $name = $cgi->param('name');
    $dbh->do("DELETE FROM pets WHERE name = ?", undef, $name);
} elsif ($action eq 'update') {
    my $old_name = $cgi->param('old_name');
    my $name     = $cgi->param('name');
    my $owner    = $cgi->param('owner');
    my $species  = $cgi->param('species');
    my $sex      = $cgi->param('sex');
    my $birth    = $cgi->param('birth');
    my $death    = $cgi->param('death') || undef;

    $dbh->do("UPDATE pets SET name = ?, owner = ?, species = ?, sex = ?, birth = ?, death = ? WHERE name = ?",
             undef, $name, $owner, $species, $sex, $birth, $death, $old_name);
}

my $sth = $dbh->prepare("SELECT * FROM pets");
$sth->execute();

print <<'HTML';
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRUD Example</title>
</head>
<body>
    <h1>CRUD Example with Pets Table</h1>
    <form method="post">
        <input type="hidden" name="action" value="insert">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required>
        <label for="owner">Owner:</label>
        <input type="text" id="owner" name="owner" required>
        <label for="species">Species:</label>
        <input type="text" id="species" name="species" required>
        <label for="sex">Sex:</label>
        <select id="sex" name="sex" required>
            <option value="m">Male</option>
            <option value="f">Female</option>
        </select>
        <label for="birth">Birth Date:</label>
        <input type="date" id="birth" name="birth" required>
        <label for="death">Death Date:</label>
        <input type="date" id="death" name="death">
        <button type="submit">Add</button>
    </form>
    <hr>
    <table border="1">
        <tr>
            <th>Name</th>
            <th>Owner</th>
            <th>Species</th>
            <th>Sex</th>
            <th>Birth Date</th>
            <th>Death Date</th>
            <th>Actions</th>
        </tr>
HTML

while (my $row = $sth->fetchrow_hashref) {
    print qq{
        <tr>
            <form method="post">
                <td><input type="text" name="name" value="$row->{name}" required></td>
                <td><input type="text" name="owner" value="$row->{owner}" required></td>
                <td><input type="text" name="species" value="$row->{species}" required></td>
                <td>
                    <select name="sex" required>
                        <option value="m" @{[$row->{sex} eq 'm' ? 'selected' : '']}>Male</option>
                        <option value="f" @{[$row->{sex} eq 'f' ? 'selected' : '']}>Female</option>
                    </select>
                </td>
                <td><input type="date" name="birth" value="$row->{birth}" required></td>
                <td><input type="date" name="death" value="@{[$row->{death} // '']}"></td>
                <td>
                    <input type="hidden" name="old_name" value="$row->{name}">
                    <button type="submit" name="action" value="update">Update</button>
                    <button type="submit" name="action" value="delete">Delete</button>
                </td>
            </form>
        </tr>
    };
}

print <<'HTML';
    </table>
</body>
</html>
HTML

$sth->finish;
$dbh->disconnect;
