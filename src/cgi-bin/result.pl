#!/usr/bin/perl -wT

use DBI;
use strict;
use File::Copy;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(.);
use MyConnectStaff; 



#Create new CGI object and assigns the variable $query to point to it.  
#The new() method parses GET and POST method variables and all of the parameters from the input stream
#does all URI decoding, and then stores the results as a new CGI object into the variable named $query.
my $query = new CGI;
# my $sql;

#Generate "Content-type:text/html\n\n";
print $query->header;

#Access parameters using the CGI object and store them in the $variables.  This is param() method of CGI module.
my $lastname = $query->param('lastname');
my $firstname = $query->param('firstname');

#Establish database connection 
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}
#print "<p>Connected successfully!<br /><br />\n";

		my @search; #array that contains the search criteria $search[0] or $search[1] or $search[2]
		my $search_string;
		my $sql;
		my @keywords1;
		my @keywords2;
		# my @search;
		my @searchfields;
		my @searchphrase1;
		my @searchphrase2;
		my $string_final;
		my $string;
		my $m;
		my $n;
		my $string1;
		my $string2;

#check for last or first name entered, one of the boxes must be filled in
if ($lastname eq "" && $firstname eq "")
	{
		header();
		print "
		<p>&nbsp;</p>
		<p><center><span class=\"style41\">You Must Enter Either a Last Name or First Name. <p> <a href=\"http://picahi.nmfs.local/staffsearch.html\">Return to Search Page</span></a></center><p>&nbsp;</p></div>
		";
		
		footer();
		exit;
	} #end of IF
		
		
#Check for lastname entered in query box 1, this is $search[1]
if ($lastname)
	{
		#eliminate anything but letters, numbers, hyphens, apostrophes, and spaces from the user input
		$lastname =~ s/[^A-Za-z0-9\-\' ]*//g;
		#replace any apostrophe with 2 apostrophes, like O'Malley becomes O''Malley, the second ' escapes the third '
		$lastname =~ s/[\']+/\'\'/g;
		#change keywords input to lower case and add the wildcards
		$lastname =~ tr/[A-Z]/[a-z]/;
		$string1 = "lower(picadm.vw_nonpii_pers_v.lastname) LIKE '$lastname%'";
	
	
	}

else
	{
		$string1 = "";
	
	}




#Check for firstname entered in query box 2, this is $search[2]
if ($firstname)
	{
		
		#eliminate anything but letters, numbers, hyphens, apostrophes, and spaces from the user input
		$firstname =~ s/[^A-Za-z0-9\-\' ]*//g;
		#replace any apostrophe with 2 apostrophes
		$firstname =~ s/[\']+/\'\'/g;
		#change keywords input to lower case and add the wildcards
		$firstname =~ tr/[A-Z]/[a-z]/;

		if ($string1 eq "")
			{ $string2 = "lower(picadm.vw_nonpii_pers_v.firstname) LIKE '%$firstname%'"; }

		else
			{ $string2 = " AND lower(picadm.vw_nonpii_pers_v.firstname) LIKE '%$firstname%'"; }
		

	}
else
	{
		$string2 = "";


	}	

#unite strings
$search_string = join "", $string1, $string2;
			
			$query = qq{SELECT picadm.vw_nonpii_pers_v.id, picadm.vw_nonpii_pers_v.perstype, 
				picadm.vw_nonpii_pers_v.lastname,
				picadm.vw_nonpii_pers_v.firstname, picadm.vw_nonpii_pers_v.lastfirst,
				picadm.vw_nonpii_pers_v.email_addr, picadm.vw_nonpii_pers_v.workph1, picadm.vw_nonpii_pers_v.worksite,
				picadm.vw_nonpii_pers_v.room_num, picadm.vw_nonpii_pers_v.workph2
				FROM picadm.vw_nonpii_pers_v
				WHERE $search_string
				ORDER BY picadm.vw_nonpii_pers_v.lastname, picadm.vw_nonpii_pers_v.firstname
				};

			#print "$query<p />";

				
		my $stmt = $dbh->prepare($query);
		
		#Execute sql
		$stmt->execute() || die "The query was not made: $DBI::errstr";
		
		my $alink;
		my @row;
		my $i;
		my $p;
		my @count;
		my $count;
		my $row;

		#my @column = ("Name","Location");
	
		@count = $stmt->fetchrow_array();
		$count = $#count+1;
		
		header();
			if($count==0) 
			{			
				print "<center><span class=\"style41\"><p>&nbsp;</p>No Results Where Found.&nbsp;  Please Try Your Search Again.
				<p><a href=\"http://picahi.nmfs.local/staffsearch.html\">Return to Search Page</a></span></center>";
			}
			else
			{
				
				print "<center><p><span class=\"style44\"><p>
				Click Employee's Name to View Biography</span></center>";
				print "<center><table border='1' bordercolor='#999999' width='600' cellpadding='3' bgcolor='#FFFFFF'>";
				print "<tr bgcolor='dddddd'><td align='left'><span class=\"style42\">NAME</span></td>
				<td align='left'><span class=\"style42\">LOCATION</span></td>
				<td align='left'><span class=\"style42\">PHONE #1</span></td>
				<td align='left'><span class=\"style42\">PHONE #2</span></td>
				<td align='left'><span class=\"style42\">EMAIL</span></td></tr>
				";
			}

		#frees up any resources associated with the query we just ran.
		$stmt->finish();


		#Execute sql
		$stmt->execute();


		#Retrieves multiple rows
		while  (@row = $stmt->fetchrow_array)
		{

		if ($row[5] eq "")
				{$row[5]="";} #email

		if ($row[6] eq "")
				{$row[6]="none";} #ph1
		if ($row[7] eq "")
				{$row[7]="Other";} #worksite
		if ($row[9] eq "")
				{$row[9]="none";} #ph2
		
		

		#############LINK TO EMPLOYEE INFORMATION USING ID NUMBER $row[0]################### 
		print "<tr><td><span class=\"style46\"><a href=\"employee.pl\?id=$row[0]\">$row[4]</a></span></td>
		<td><span class=\"style46\">$row[7]&nbsp;$row[8]</span></TD><TD><span class=\"style46\">$row[6]</span></td>
		<td><span class=\"style46\">$row[9]</span></td>";

		#email
		if ($row[5] eq "")
				{print "<td><span class=\"style46\">none</span></td></tr>";} 
		else	
				{print "<td><span class=\"style46\"><a href=\"mailto:$row[5]\">$row[5]</a></span></td></tr>";}

			
				
		
		
		}#End of While

print "</table></center><p></div>
";						
		
$stmt->finish();

#disconnect from the database.
$dbh->disconnect();

###Email to Owner that a Search Occurred#############################################
# Set the PATH environment variable to the same path
# where sendmail is located:

#$ENV{PATH} = "/usr/sbin";

# send email using UNIX/Linux sendmail
#open (MAIL, "|/usr/sbin/sendmail -oi -t") or 
 #   die ("Can't fork for sendmail: $!\n");


# Start printing the mail headers
# You must specify who it's to, or it won't be delivered:

#print MAIL "To: PIFSC.Librarian\@noaa.gov\n";

# From should probably be the webserver.

#print MAIL "From: auto-reply\@pifsc.noaa.gov\n";

# print a subject line so you know it's from your form cgi.

#print MAIL "Subject: Someone Just Searched the PIFSC Staff Directory\n\n";

# Now print the body of your mail message.
#print MAIL "1 Person Just Searched the PIFSC Staff Directory for:\n
#LAST NAME: $lastname\n
#FIRST NAME: $firstname\n
#";

#close(MAIL);

###Close Email to Owner#############################################


footer();




#####SUBROUTINES#######################################################		
sub header{
	#Start HTML Page
print "<HTML><HEAD><TITLE>PIFSC Staff Directory - Search Results</TITLE>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style/staffdir_style.css\" />\n";
print "<link rel=\"SHORTCUT ICON\" href=\"/images/noaa_sm.jpg\" />\n";

print "</HEAD><BODY>

<div id=\"border\">
<div id =\"container\">
<div id=\"topmenu\"><a href=\"http://picahi.nmfs.local/staffsearch.html\">PIFSC Staff Directory</a>&nbsp; > &nbsp;<font color=\"black\">Search Results</font></div>
<div id=\"header\"></div>

<div id=\"content\">
<p>
<center>
<span class=\"style24\">PIFSC Staff Directory</span> 
</center>
</div>


</BODY></HTML>";
}




sub footer{
print "<HTML><HEAD>\n";

print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style/staffdir_style.css\" />\n";

print "</HEAD><BODY>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<center><b><a href=\"http://picahi.nmfs.local/staffsearch.html\">New Search</a></b>
</center>
<p>

<div id=\"footer\">
<p><span class=\"style8\">Please send questions or comments to <a href=\"mailto:PIFSC.Librarian\@noaa.gov\">PIFSC Librarian</a><br></span>
</div>     



</body>

</html>
";
}			
