#!/usr/bin/perl

use DBI;
use Env qw($USER);

# bring in $passwd externally (db)
require("../authkeys-dbpasswd.pl");

# Connect to DB
$db = "authkeys";
$host = "localhost";
$userid = "authkeys";
$connectionInfo = "dbi:mysql:$db;$host";
$dbh = DBI->connect($connectionInfo,$userid,$passwd);

# Get list of allowed users
$query = "SELECT * FROM authusers WHERE username='$USER'";
$runq = $dbh->prepare($query);
$runq->execute();
$runq->bind_columns(\$allowed_username);
while($runq->fetch()) {
        push @allowed_username_keys $allowed_username;
}

foreach (@allowed_username_keys) {
    print $_ . "\n";
}
