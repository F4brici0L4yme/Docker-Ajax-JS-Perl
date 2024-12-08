#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

my $cgi = CGI->new;

# Configurar las cabeceras para JSON
print $cgi->header(-type => 'application/json', -charset => 'UTF-8');

# Configuración de la base de datos
my $dsn      = "DBI:mysql:database=menagerie;host=127.0.0.1";
my $username = "root";
my $password = "";

# Conexión a la base de datos
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, PrintError => 0 });

# Determinar la acción solicitada
my $action = $cgi->param('action') || '';
my $response = { status => 'error', message => 'Invalid action' };

if ($action eq 'insert') {
    # Insertar un nuevo registro
    my $name    = $cgi->param('name');
    my $owner   = $cgi->param('owner');
    my $species = $cgi->param('species');
    my $sex     = $cgi->param('sex');
    my $birth   = $cgi->param('birth');
    my $death   = $cgi->param('death') || undef;

    eval {
        $dbh->do(
            "INSERT INTO pets (name, owner, species, sex, birth, death) VALUES (?, ?, ?, ?, ?, ?)",
            undef, $name, $owner, $species, $sex, $birth, $death
        );
        $response = { status => 'success', message => 'Record inserted successfully' };
    };
    if ($@) {
        $response = { status => 'error', message => 'Failed to insert record: ' . $@ };
    }

} elsif ($action eq 'delete') {
    # Eliminar un registro
    my $name = $cgi->param('name');

    eval {
        $dbh->do("DELETE FROM pets WHERE name = ?", undef, $name);
        $response = { status => 'success', message => 'Record deleted successfully' };
    };
    if ($@) {
        $response = { status => 'error', message => 'Failed to delete record: ' . $@ };
    }

} elsif ($action eq 'update') {
    # Actualizar un registro existente
    my $old_name = $cgi->param('old_name');
    my $name     = $cgi->param('name');
    my $owner    = $cgi->param('owner');
    my $species  = $cgi->param('species');
    my $sex      = $cgi->param('sex');
    my $birth    = $cgi->param('birth');
    my $death    = $cgi->param('death') || undef;

    eval {
        $dbh->do(
            "UPDATE pets SET name = ?, owner = ?, species = ?, sex = ?, birth = ?, death = ? WHERE name = ?",
            undef, $name, $owner, $species, $sex, $birth, $death, $old_name
        );
        $response = { status => 'success', message => 'Record updated successfully' };
    };
    if ($@) {
        $response = { status => 'error', message => 'Failed to update record: ' . $@ };
    }

} elsif ($action eq 'fetch') {
    # Obtener todos los registros de la tabla
    my $sth = $dbh->prepare("SELECT * FROM pets");
    $sth->execute();
    my @pets;

    while (my $row = $sth->fetchrow_hashref) {
        push @pets, $row;
    }

    $response = { status => 'success', data => \@pets };
} else {
    $response = { status => 'error', message => 'Unknown action' };
}

# Enviar la respuesta en formato JSON
print encode_json($response);

# Desconectar la base de datos
$dbh->disconnect;
