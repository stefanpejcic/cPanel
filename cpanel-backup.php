<?php

// PHP script to allow periodic cPanel backups automatically.
// v-nessa.net
// Permissions on this file should be 600 
// Place outside your public_html
// Crontab:  30 3 * * * /usr/local/bin/php /home/username/cpanel_backup.php

// ********* Configuration *********

// Info required for cPanel access
$cpuser = ""; // Username used to login to CPanel
$cppass = ""; // Password used to login to CPanel
$domain = ""; // Domain name where CPanel is run
$skin = "x3"; // Set to cPanel skin you use (script won't work if it doesn't match)

// Info required for FTP host
$ftpuser = ""; // Username for FTP account
$ftppass = ""; // Password for FTP account
$ftphost = "t"; // Full hostname or IP address for FTP host
$ftpmode = "passiveftp"; // FTP mode ("ftp" for active, "passiveftp" for passive)
$ftpport = "21"; // FTP port, usually 21
$ftpdir = "/backups"; // Path to folder where backups should be stored off of FTP root. Folder must exist.

// Notification information
$notifyemail = ""; // Email address to send results

// Secure or non-secure mode
$secure = 0; // Set to 1 for SSL (requires SSL support), otherwise will use standard HTTP

// Set to 1 to have web page result appear in your cron log
$debug = 1;

// *********** Don't Touch!! *********

if ($secure) {
   $url = "ssl://".$domain;
   $port = 2083;
} else {
   $url = $domain;
   $port = 2082;
}

$socket = fsockopen($url,$port);
if (!$socket) { echo "Failed to open socket connection... Bailing out!\n"; exit; }

// Encode authentication string
$authstr = $cpuser.":".$cppass;
$pass = base64_encode($authstr);

$params = "dest=$ftpmode&email=$notifyemail&server=$ftphost&user=$ftpuser&pass=$ftppass&port=$ftpport&rdir=$ftpdir&submit=Generate Backup";

// Make POST to cPanel
fputs($socket,"POST /frontend/".$skin."/backup/dofullbackup.html?".$params." HTTP/1.0\r\n");
fputs($socket,"Host: $domain\r\n");
fputs($socket,"Authorization: Basic $pass\r\n");
fputs($socket,"Connection: Close\r\n");
fputs($socket,"\r\n");

// Grab response even if we don't do anything with it.
while (!feof($socket)) {
  $response = fgets($socket,4096);
  if ($debug) echo $response;
}

fclose($socket);

?>
