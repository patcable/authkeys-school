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

# Easy check: Does our md5/sha1 hash of .ssh/authorized_keys
# match whats in the db? 
open SSHAUTHKEYS, "$HOME/.ssh/authorized_keys";
binmode SSHAUTHKEYS;
my $sshkeys = <SSHAUTHKEYS>;
close SSHAUTHKEYS;
$md5 = md5_hex($sshkeys);
$sha1 = sha1_hex($sshkeys);

if ($debug) {
    print "DEBUG: md5 - $md5 sha1 - $sha1\n";
}

$query = "SELECT md5,sha1 FROM authkeys_hashes WHERE user='$USER'";
$runq = $dbh->prepare($query);
$runq->execute();
$runq->bind_columns(\$db_md5, \$db_sha1);
while($runq->fetch()) {
    if ($debug) {
        print "DEBUG: db_md5 - $db_md5, db_sha1 - $db_sha1\n";
    }
    $count = 0;
    if ($md5 !~ $db_md5 || $sha1 !~ $db_sha1) {
        print "Danger! DB and File dont match. Script continuing...\n";
    }
    if ($md5 =~ $db_md5 && $sha1 =~ $db_sha1) {
        print "Files match. Quitting...";
        exit 0;
    }
    $count++;
}

# Get list of allowed users
$query = "SELECT authusers FROM authusers WHERE username='$USER'";
$runq = $dbh->prepare($query);
$runq->execute();
$runq->bind_columns(\$allowed_username);
while($runq->fetch()) {
        push(@allowed_usernames,$allowed_username);
}

if ($debug) {
    print "DEBUG: Allowed Usernames: ";
    foreach(@allowed_usernames) {
        print $_ . " ";
    }
    print "\n";
}

# Read in information from .ssh/authorized_keys
# format is ssh-keytype key identifier
# split based on \s and get identifier
