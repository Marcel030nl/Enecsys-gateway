# Enecsys-gateway
Retrieves data from your Enecsys (v1) gateway and posts them to PVoutput (optional to MySQL) using Perl.

Features
- retrieves data from (serveral) Enecsys v1 gateway's
  - you can set-up a single perl-enable linux system to gather data from several gateways, all with mutiple inverters.
- posts all data to a MySQL database
- posts all data to seperate PVoutput ID's

How to get started?
- Setup a MySQL database
  - Create a user for each gateway, for example:
    INSERT INTO `users` (`apikey`, `ajax_url`) VALUES
    ('aed33cd37ad773ab2d43e16fb0a46eb', 'asdf.leicher.nl:8080/ajax.xml');
  - Create for each panel a row in the table inverter, using the user_id from the previous step:
    INSERT INTO `inverters` (`inverter_id`, `user_id`, `pvo_system_id`) VALUES
    (100060629, 1, 26368),
    (110052018, 1, 26802);
- Copy the perl script to you home directory on a Linux perl-enabled system.
  - Insert your MySQL database details (host, database, username, password)
- Setup a crontab for the perl script
  */5 * * * *	/home/ubuntu/enecsys-with-mysql.pl
