#!/usr/bin/perl
#
# FILL ALL #### FIELDS TO GET STARTED.
# Code based on 2012 Martijn van Duijn code.
# Edited by Marcel Leicher, 2015
# support or questions: @marcel030nl or marcel@leicher.nl.

use HTTP::Request::Common qw(POST GET);
use LWP::UserAgent;
use Math::BaseCnv;
use Math::BaseCnv dig; # enable the dig option
use XML::Simple;
use LWP::Simple;
use DateTime;
dig('url'); # select the right alphabet for the base64
use DBI; 

####### VAR ######
my $pvoutput_sysid;
my $NetFlag = 1;
# set to 1 for runtime debugging messages
my $debug = 0;
my $payload;
my $y = 19; #aantal pogingen

####### GET STARTED ######
my $ua = LWP::UserAgent->new;
my $pvoutput_url="http://pvoutput.org/service/r2/addstatus.jsp";
my $error;

####### MySQL ######
$dbh = DBI->connect('dbi:mysql:enecsys','enecsys_user','####') or die "Connection Error: $DBI::errstr\n";

# $payload = "Script started. Running for " .($y+1) . " rounds at 2s interval.";
# 			$sth = $dbh->prepare("INSERT INTO logging
# 	                			(payload)
# 	                        		values
# 	                      			('$payload')");
# $sth->execute() or die $DBI::errstr;
# $sth->finish();

$sqlselect = "SELECT user_id,apikey,ajax_url FROM users";
$sth1 = $dbh->prepare($sqlselect);
$sth1->execute() or die $DBI::errstr;

while (my @row = $sth1->fetchrow_array()) {
  	my ($user_id, $apikey, $ajax_url ) = @row;
  	my $url;
  	$url = "http://" . $ajax_url;
  	my $pvoutput_apikey = $apikey;
 	print "Rondje voor user_id=".$user_id.", URL = ".$url."\n" if $debug;
 
	for ($i=0; $i<$y; $i++)  #This defines the number of reading loops.
	{
		# Set up time & date
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900;
		$mon += 1;
		my $date = sprintf("%d%.2d%d", $year, $mon, $mday);
		#my $time = $hour . ":" . sprintf(%02d:%02d,$hour.$min);
		my $time = sprintf("%02d:%02d",$hour,$min);

		my $parser = new XML::Simple;
		my $content = get $url or die "Unable to get $url\n";
		my $data = $parser->XMLin($content);
		$Zigbee=$data->{zigbeeData}; #pick out the zigbee field
		$Zigbee =~ s/\r//g;	#Remove lifefeed and CR from the string
		$Zigbee =~ s/\n//g;	#Usually chomp is used for that, but there are issues between platforms with that

		# $Zigbee = "WS=skKPBgCaxjQAAPIgIQEAAAIfFDADiAAAjgCGA68yAOYgAL8BXwAA71";

		if ($Zigbee =~ /^WS/  && length($Zigbee)==57  ) #Normal inverter strings are parsed 
		{
			dig('url');
			$DecZigbee = cnv('A'.substr($Zigbee,3,54),64,10); #decimal representation of whole Zigbee string
			dig('HEX'); #the url alphabet messes up de dec hex conversions, so change to HEX
			$HexZigbee = cnv($DecZigbee,10,16); #Hex representation of zigbeestring
			if (length($HexZigbee) ==80) # if we have a leading 0 it gets chopped off, this is a fix for that.
				{
				$HexZigbee="0".$HexZigbee;
				}
			$HexID = substr($HexZigbee,0,8); #Device ID in hex
			$IDEndian = unpack("H*", pack("V*", unpack("N*", pack("H*", $HexID)))); # some magic to convert from little to big endian
			$IDDec = cnv($IDEndian,16,10); #Device ID in decimal numbers. Should match Enecsys monitor site
			$HexTime1 = cnv(substr($HexZigbee,18,4),16,10);
			$HexTime2 = cnv(substr($HexZigbee,30,6),16,10);
			$HexDCCurrent = 0.025*cnv(substr($HexZigbee,46,4),16,10); #25 mA units?
			$HexDCPower = cnv(substr($HexZigbee,50,4),16,10);
			$HexEfficiency = 0.001*cnv(substr($HexZigbee,54,4),16,10);#expressed as fraction
			$HexACFreq = cnv(substr($HexZigbee,58,2),16,10);
			$HexACVolt = cnv(substr($HexZigbee,60,4),16,10);
			$HexTemperature = cnv(substr($HexZigbee,64,2),16,10);
			$HexWh = cnv(substr($HexZigbee,66,4),16,10);
			print "HexWh = ", $HexWh, "\n" if $debug;
			$HexkWh = cnv(substr($HexZigbee,70,4),16,10);
			print "HexkWh = ", $HexkWh, "\n" if $debug;
			$LifekWh = $HexWh+(1000*$HexkWh);
			print "LifekWh = ", $LifekWh, "\n" if $debug;
			$ACpower = $HexDCPower * $HexEfficiency;
			$HexDCVolt = sprintf("%0.2f",$HexDCPower / $HexDCCurrent); 
			
			$sql = "SELECT pvo_system_id FROM inverters WHERE inverter_id='$IDDec'"; 
			$sth = $dbh->prepare($sql); 
			$sth->execute;
			if ($sth->rows==1) {
				@result = $sth->fetchrow_array();
				$pvoutput_sysid = $result[0];
				$ua->default_header(
				      	"X-Pvoutput-Apikey" => $pvoutput_apikey,
						"X-Pvoutput-SystemId" => $pvoutput_sysid,
				        "Content-Type" => "application/x-www-form-urlencoded");
				my $request = POST $pvoutput_url,
						[ d => $date, t => $time, v1 => $LifekWh, v2 => $HexDCPower, v5 => $HexTemperature, v6 => $HexDCVolt, c1 => $NetFlag ];
				my $res = $ua->request($request);
				if (! $res->is_success) {
					$error = "Failed pvoutput.org: " . $res->status_line;
				} else {
					$error = "Succes pvoutput.org: 200 OK";
				}
			} else {
				$pvoutput_sysid = 999999999;
				$error = "Valid string but failed because pvoutput system id was not found our database.";
			}
			$sth->finish();

			$payload = $HexDCPower . "W " . $LifekWh . "Wh " . $HexDCVolt . "V(DC) ". $HexTemperature . "C " . $error;
			$sth = $dbh->prepare("INSERT INTO logging
	                			(inverter_id, payload)
	                        		values
	                      			('$IDDec', '$payload')");
			$sth->execute() or die $DBI::errstr;
			$sth->finish();
		}

		elsif ($debug==1) {
			$payload = "No valid string received from Enecsys gateway.";
			$IDDec = 999999999;
			$sth = $dbh->prepare("INSERT INTO logging
	                			(inverter_id, payload)
	                        		values
	                      			('$IDDec', '$payload')");
			$sth->execute() or die $DBI::errstr;
			$sth->finish();
		}

		sleep 2;
	}
}
$sth1->finish();

# $payload = "Script finished. Ran for " .($y+1) . " rounds at 2s interval.";
# 			$sth = $dbh->prepare("INSERT INTO logging
# 	                			(payload)
# 	                        		values
# 	                      			('$payload')");
# $sth->execute() or die $DBI::errstr;
# $sth->finish();