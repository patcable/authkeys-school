# Authkeys

A project for 4055.841 - Computer Forensics

Group 4 Members:
* Patrick Cable
* Akshad Pol
* Rich Rockelmann
* Kriti Sharma
* Peter Wilson

## What is Authkeys

Authkeys builds a .ssh authorized_keys file based on database entries.

buildauthkeys.pl can be invoked as a user to build the ssh authorized_keys file.
checkauthkeys.pl is part of a global login script to ensure that the ssh authorized_keys file is correct.

Upon any failure, an email is sent to $ADMIN_USER letting them know that something is fishy.

## Should I use Authkeys?

In production? Questionable.

As a thought experiment? Sure.

## How do I set it up?

1. Create a user that has sudo access
2. Install the scripts. Setuid the perl "checkauthkeys.pl" script to root. 
3. Create a database and import the mysql_database.sql file.
4. Edit authkeys-config.pl accordingly
5. use "adminauthkeys.pl" to add users and their keys as necessary
6. Have each user run "makeauthkeys.pl" 
7. Check that it works as intended by running "checkauthkeys.pl" as a particular user
8. Enable enforcement by adding "checkauthkeys.pl" to the system shell init script of all installed shells
