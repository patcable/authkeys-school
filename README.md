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
