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
GetOptions( 'user' => \$priuser,
            'adduser' => \$adduser,
            'rmuser' => \$rmuser,
            'lsuser' => \$lsuser,
            'addcert' => \$addcert,
            'rmcert' => \$rmcert,
            'lscert' => \$lscert,
            'help' => \$help);

# debug mode - more verbose data
#$debug = TRUE;

# help - if user isnt specified, or theres no args, or -help

if($help || $user =~ //) {
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
