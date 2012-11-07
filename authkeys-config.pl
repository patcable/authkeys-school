# Configuration File for AuthKeys
# 

# $debug - if set to TRUE, will print some extra output to make 
#          troubleshooting easier. If not enabled, leave commented.
#$debug = TRUE;

# $FROM_ADDR - The address that warnings from the script are sent from
$FROM_ADDR = 'root@pcable.net';

# $ADMIN_ADDR - The address that notifications should be sent to
$ADMIN_ADDR = 'pc@pcable.net';

# $db - Database Name
$db = "authkeys";

# $host - Database host
$host = "localhost";

# $userid - Database UserID
$userid = "authkeys";

# PASSWORD INFO
# This file should be restricted access to either the service
# account that the check script runs as.

$pwfilelocation = "../authkeys-dbpasswd.pl";

# The MySQL dbi string
$connectionInfo = "dbi:mysql:$db;$host";
