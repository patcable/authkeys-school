#!/usr/bin/perl

use DBI;
use Env qw($USER $HOME);
use Digest::MD5 qw(md5_hex);
use Digest::SHA1 qw(sha1_hex);

# bring in global settings
require("authkeys-config.pl");
# bring in $passwd externally (db)
require($pwfilelocation);

# Connect to DB
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

# Remove existing .ssh/authorized_keys
unlink("$HOME/.ssh/authorized_keys");
open SSHAUTHKEYS, "+>", "$HOME/.ssh/authorized_keys" or die $!;

# Write new .ssh/authorized_keys
$count = 0;
foreach(@allowed_usernames) {
    print SSHAUTHKEYS $allowed_certs[$count] . " " . $_ . "\n";
    $count++;
}

# Hash new .ssh/authorized_keys
seek SSHAUTHKEYS,0,0;
$SSHAUTHKEYS = <SSHAUTHKEYS>;
$md5 = md5_hex($SSHAUTHKEYS);
$sha1 = sha1_hex($SSHAUTHKEYS);

# Update DB. We do a delete than an insert (rather than an update)
# because it's possible this user doesn't have an entry, yet.
$query = "DELETE FROM authkeys_hashes WHERE user='$USER' LIMIT 1";
$runq = $dbh->prepare($query);
$runq->execute();
$query = "INSERT INTO authkeys_hashes VALUES('$USER', '$md5', '$sha1')";
$runq = $dbh->prepare($query);
$runq->execute();

