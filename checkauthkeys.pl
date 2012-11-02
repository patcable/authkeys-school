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
        # This is what executes if either of the hashes don't match
        # what's in the DB. 
        print "Danger! DB and File dont match. Script continuing...\n";
    }
    if ($md5 =~ $db_md5 && $sha1 =~ $db_sha1) {
        # This executes if there's a hash match.
        print "Files match. Quitting...\n";
        exit 0;
    }
    $count++;
}

# If we've made it this far, we've got some more checking to do.

# Get list of allowed users
$query = "SELECT authusers.authusers AND usercerts.cert FROM authusers,usercerts WHERE authusers.username='$USER' AND authusers.username = usercerts.user";
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

# Read in information from .ssh/authorized_keys
# format is ssh-keytype key identifier
# split based on \s and get identifier
