#!/usr/bin/perl

use DBI;
use Env qw($USER $HOME);
use Digest::MD5 qw(md5_hex);
use Digest::SHA1 qw(sha1_hex);

# Global configuration is in authkeys-config.pl
require("authkeys-config.pl");
# bring in $passwd externally (db)
require($pwfilelocation);

# Connect to DB
$dbh = DBI->connect($connectionInfo,$userid,$passwd);

# Easy check: Does our md5/sha1 hash of .ssh/authorized_keys
# match whats in the db? 
open SSHAUTHKEYS, "$HOME/.ssh/authorized_keys";
binmode SSHAUTHKEYS;
my @sshkeys = <SSHAUTHKEYS>;
close SSHAUTHKEYS;
$md5 = md5_hex(@sshkeys);
$sha1 = sha1_hex(@sshkeys);

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
    }
    if ($md5 =~ $db_md5 && $sha1 =~ $db_sha1) {
        # This executes if there's a hash match.
        exit 0;
    }
    $count++;
}

# If we've made it this far, the file has been tampered with. Alert the
# administrator...

print "Your administrator has installed AuthKeys to monitor your SSH\n";
print "authorized_keys file. This application has detected a security\n";
print "issue and your session will now end. Please contact your\n";
print "administrator for more information.\n";

open(MAIL, "|/usr/sbin/sendmail -t");
$host = `hostname`;
chomp($host);
print MAIL "To: $ADMIN_ADDR\n";
print MAIL "From: $FROM_ADDR\n";
print MAIL "Subject: SSH Auth Keys MISMATCH for $USER\n\n";
print MAIL "This is the AuthKeys application on $host. ";
print MAIL "At this time, user $USER has had a mismatched SSH authorized_keys file. ";
print MAIL "This could be serious, so please check /home/$USER/.ssh/authorized_keys\n";
close(MAIL);

if($< == 0) {
    system("sudo pkill -9 -u $USER");
}
