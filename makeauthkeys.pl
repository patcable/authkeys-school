#!/usr/bin/perl

use DBI;
use Env qw($USER $HOME);
use Digest::MD5 qw(md5_hex);
use Digest::SHA1 qw(sha1_hex);

# debug mode - more verbose data
$debug = TRUE;

# bring in $passwd externally (db)
require("../authkeys-dbpasswd.pl");

# Connect to DB
$db = "authkeys";
$host = "localhost";
$userid = "authkeys";
$connectionInfo = "dbi:mysql:$db;$host";
$dbh = DBI->connect($connectionInfo,$userid,$passwd);

# Get list of allowed users
$query = "SELECT authusers.authusers,usercerts.cert FROM authusers,usercerts WHERE authusers.username='$USER' AND authusers.authusers = usercerts.user";
$runq = $dbh->prepare($query);
$runq->execute();
$runq->bind_columns(\$allowed_username, \$allowed_cert);
while($runq->fetch()) {
        push(@allowed_usernames,$allowed_username);
        push(@allowed_certs,$allowed_cert);
}

if ($debug) {
    print "DEBUG: Allowed Usernames: ";
    foreach(@allowed_usernames) {
        print $_ . " ";
    }
    print "\n";

    foreach(@allowed_certs) {
        print $_ . " ";
    }
    print "\n";
}

foreach(@allowed_usernames) {
    $count = 0;
    print $allowed_certs[$count] . " " . $_ . "\n";
    $count++;
}
