#!/usr/bin/perl

#if(getlogin() !~ /root/) {
#    print "Sorry, this app must be run as root.\n";
#    exit 1;
#}


use DBI;
use Env qw($USER $HOME);
use Digest::MD5 qw(md5_hex);
use Digest::SHA1 qw(sha1_hex);
use Getopt::Long;

my($priuser, $adduser, $rmuser, $lsuser,
   $addcert, $rmcert, $lscert, $help);
GetOptions( 'user=s' => \$priuser,
            'adduser=s' => \$adduser,
            'rmuser=s' => \$rmuser,
            'lsuser' => \$lsuser,
            'addcert=s' => \$addcert,
            'rmcert' => \$rmcert,
            'lscert' => \$lscert,
            'help' => \$help);

# debug mode - more verbose data
#$debug = TRUE;
if($debug) {
    print "DEBUG: vars:\n";
    print "       user $priuser\n";
    print "       addu $adduser\n";
    print "       remu $rmuser\n";
    print "       lsur $lsuser\n";
    print "       addc $addcert\n";
    print "       remc $rmcert\n";
    print "       lsct $lscert\n";
    print "       help $help\n";
    print "\n";
}


# help - if user isnt specified, or theres no args, or -help
if($help || !$priuser) {
    print "Authkeys - a basic ssh authorized_keys manager\n";
    print "Options:\n";
    print "  --user USERNAME    specify user to perform action on\n";
    print "  --adduser NEWUSER  adds NEWUSER to USERNAME's authorized_keys\n";
    print "  --rmuser DELUSER   deletes DELUSER to USERNAME's authorized_keys list\n";
    print "  --lsuser           lists users allowed to log on as USERNAME with\n";
    print "                     SSH keys\n";
    print "  --addcert PATH     adds a cert to the database for USERNAME. PATH is a\n";
    print "                     the id_rsa.pub\n";
    print "  --delcert          removes USERNAME's certificate\n";
    print "  --lscert           print's USERNAME's certificate to STDOUT\n";
    print "  --help             this screen\n";
    exit 1;
}

# Connect to DB
require("../authkeys-dbpasswd.pl");
$db = "authkeys";
$host = "localhost";
$userid = "authkeys";
$connectionInfo = "dbi:mysql:$db;$host";
$dbh = DBI->connect($connectionInfo,$userid,$passwd);

if ($adduser) {
    print "adding $adduser to $priuser ... ";
    $query = "INSERT INTO authusers VALUES ('$priuser', '$adduser')";
    $runq = $dbh->prepare($query);
    $runq->execute();
    print "Done!\n";
    exit 0;
}

if ($rmuser) {
    print "removing $rmuser from $priuser ... ";
    $query = "DELETE FROM authusers WHERE username = '$priuser' AND authusers = '$rmuser' LIMIT 1";
    $runq = $dbh->prepare($query);
    $runq->execute();
    print "Done!\n";
    exit 0;
}

if ($lsuser) {
    $query = "SELECT * FROM authusers WHERE username = '$priuser'";
    $runq = $dbh->prepare($query);
    $runq->execute();
    my($returned_user,$returned_authuser);
    $runq->bind_columns(\$returned_user, \$returned_authuser);
    print "USERNAME\tAUTHORIZED USER\n";
    while($runq->fetch()) {
        print "$returned_user\t$returned_authuser\n"
    }
    exit 0;
}

if ($addcert) {
    print "adding cert at $addcert to $priuser ... ";
    open CERT, "$addcert";
    @cert = <CERT>;
    $lines = 0;
    foreach (@cert) {
        $lines++;
        last if ($lines > 1);
    }
    if ($lines > 1) {
        print "File too long.\n";
        exit 1;
    }
    $key = $cert[0];
    if ($key !~ /^ssh-(dsa|rsa)/) {
        print "Not a key file.\n";
        exit 1;
    }
    chomp($key);
    @fullkey = split(/\s/, $key);
    $query = "INSERT INTO usercerts VALUES('$priuser', '$fullkey[0] $fullkey[1]')";
    $runq = $dbh->prepare($query);
    $runq->execute();
    print "Done!\n";
    exit 0;
}

if ($rmcert) {
    print "Deleting cert for $priuser ... ";
    $query = "DELETE FROM usercerts WHERE user = '$priuser' LIMIT 1";
    $runq = $dbh->prepare($query);
    $runq->execute();
    print "Done!\n";
}

if ($lscert) {
    $query = "SELECT cert FROM usercerts WHERE user = '$priuser'";
    $runq = $dbh->prepare($query);
    $runq->execute();
    my($returned_cert);
    $runq->bind_columns(\$returned_cert);
    $count = 0;
    while($runq->fetch()) {
        print "user $priuser has the certificate:\n";
        print "($count) $returned_cert\n";
        $count++;
    }
    exit 0;
}
