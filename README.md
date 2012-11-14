# Authkeys

A project for 4055.841 - Computer Forensics

Group 4 Members:
* Patrick Cable
* Akshad Pol
* Rich Rockelmann
* Kriti Sharma
* Peter Wilson

## What is Authkeys

For this project we have chosen to develop a SSH Authorized Keys Validation Tool ("AuthKeys") that would verify a particular user's ability to access keys to a particular account on a specific machine. If the keys do not match an email will be sent to that Administrator of the system notifying them of a change in the file. Our motivation for the tool was to use concepts introduced in Advanced Computer Forensics, specifically hashing, in a tool geared towards System Administrators to enhance IT security and further knowledge.

## Background and Tool Use
OpenSSH is a utility built on OpenSSL that allows users to securely connect to remote servers and get a command prompt, or shell. OpenSSH has a variety of authentication methods - one could use one-time passwords, regular passwords, public key authentication, Kerberos, among others. This tool focuses specifically on public key authentication, and a specific problem: many times an individual - not a company or business unit - has physical access over the file that controls access to their account, and could use this access for malicious reasons.

In more detail, a user's "authorized_keys" file can be used to give - depending on how the private key was created - access to a system without a password. As a result, It is important to monitor this file for changes and analysis each time a user logs in, as changes to the file could allow a malicious to access a machine. We implement SHA and MD5 hashing to ensure that a user's authorized_keys file remains untouched by the end user - and alert the administrator 

For example, let's imagine a particular service account on a particular machine has no password (and thus does not accept password-based login attempts), but requires a group of authorized users to have access to it. For this example, let's assume the account is used to run a Human Resources Information System that stores information about employee reviews and salaries. The account is setup to accept PKI-based logins from Alice, Bob, and Charlie. However, Charlie decides to add his friend Eve in Accounting to the system - simply by editing the "authorized_keys" file. 

Had the file not have a mechanism of monitoring, the system would honor the request. However, the business would most certainly not have wished for Eve to have access. If Eve did have a need to know, then it's likely that Charlie would not have the authorization to perform such an action. This tool allows for an administrator to know that a change happened, and be able to perform more detailed forensic analysis.

## How do I set it up?

To implement AuthKeys, one must:
1. Check out the current version of AuthKeys using git (git clone https://github.com/patcable/authkeys)
2. Copy the files into a globally accessible directory
   a. It is key to ensure that no one can read the password file. 
3. Create a MySQL user and database to store the authkeys data
4. Import the MySQL Database (mysql -u user -p databasename < mysql_database.sql)
5. Store the password for the database in a file you define in authkeys-config.pl.
6. Add the appropriate keys to the database with adminauthkeys.pl
   For each user, run: 
   adminauthkeys.pl --user [username] --addcert [path to public key]
7. Link accounts to their authorized users
   For each user, run:
   adminauthkeys.pl --user [username] --adduser [other user to access acct.]
8. Create the appropriate authorized users file for each user
   For each user, run:
   su -c user - makeauthkeys.pl
9. Test accordingly
   1. Ensure a user can ssh to the other user
   2. Ensure that when you change the $HOME/.ssh/authorized_keys file, the you can not log in.
10. Implement system-wide
    Add the checkauthkeys.pl file to all installed shell's system-wide shell init files.

## More Information

More Information is available in the final report PDF in this project.
