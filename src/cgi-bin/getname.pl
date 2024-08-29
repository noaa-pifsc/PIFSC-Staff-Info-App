#!/usr/bin/perl -wT

use DBI;
use strict;
use File::Copy;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(.);
use MyConnectStaff; 
use Time::Local;

#Create new CGI object and assigns the variable $query to point to it.  
#The new() method parses GET and POST method variables and all of the parameters from the input stream
#does all URI decoding, and then stores the results as a new CGI object into the variable named $query.
my $query = new CGI;
my $sql;

my ($lastname, $firstname);

#Generate "Content-type:text/html\n\n";
print $query->header;

#See if user submitted data 
	#Access parameters using the CGI object and store them in the $variables.  
	$lastname = $query->param('lastname');
	$firstname = $query->param('firstname');

	if ($lastname eq "")
	{
		header();
		print "<span class=\"style41\"><center>Oops! You Must Fill in Your <font color='red'>Last Name</font>. <br /><br /> Click on Your Browser's Back Button.</center></span>";
		footer();
		exit;

	}


	if (($lastname) && ($firstname eq ""))
	{
		#eliminate anything but letters, numbers, hyphens, apostrophes, and spaces from the user input
		$lastname =~ s/[^A-Za-z0-9\-\' ]*//g;
		#replace any apostrophe with 2 apostrophes for O'Malley, O'Brien, etc.
		$lastname =~ s/[\']+/\'\'/g;	
		#make all lower case
		$lastname =~ tr/[A-Z]/[a-z]/;
		#add the %	
		$lastname =~ s/$lastname/'$lastname%'/;
		#Search database for the employee's id and email
		$query = qq{SELECT id, lastname, firstname, lastfirst, email_addr FROM picadm.vw_nonpii_pers_v WHERE lower(lastname) LIKE $lastname ORDER BY lastname, firstname};

		
	}

	if ($lastname && $firstname)
	{
		#eliminate anything but letters, numbers, hyphens, apostrophes, and spaces from the user input
		$lastname =~ s/[^A-Za-z0-9\-\' ]*//g;
		$firstname =~ s/[^A-Za-z0-9\-\' ]*//g;
		#replace any apostrophe with 2 apostrophes for O'Malley, O'Brien, etc.
		$lastname =~ s/[\']+/\'\'/g;	
		$firstname =~ s/[\']+/\'\'/g;	
		#make all lower case
		$lastname =~ tr/[A-Z]/[a-z]/;
		$firstname =~ tr/[A-Z]/[a-z]/;
		#add the %
		$lastname =~ s/$lastname/'$lastname%'/;	
		$firstname =~ s/$firstname/'$firstname%'/;
		#Search database for the employee's id and email
		$query = qq{SELECT id, lastname, firstname, lastfirst, email_addr FROM picadm.vw_nonpii_pers_v WHERE lower(lastname) LIKE $lastname AND lower(firstname) LIKE $firstname ORDER BY lastname, firstname};		
	}


#Establish database connection 
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}
#print "<p>Connected successfully!<br /><br />\n";

my $stmt = $dbh->prepare($query);
		
$stmt->execute() || die "The query was not made: $DBI::errstr";


my @count;
my $count;

#See if the employee is found in PEEPS
@count = $stmt->fetchrow_array();
$count = $#count+1;
		
	if($count==0) 
	{	
		header();
		print "<span class=\"style41\"><center>Your name could not be verified in the database. &nbsp; Please try again.</span>"; 
		
		print "<span class=\"style41\"><p><a href=\"http://picahi.nmfs.local/staffdir_name.html\">Return to Search</a></span></p>";
		footer();
		exit;							
	}	

#frees up any resources associated with count query we just ran.
$stmt->finish();

#Execute sql query
$stmt->execute();

header();
print "<span class=\"style44\"><center>Please verify your name using the checkbox.</center></span>";
print "<p><center><table border='0' width='250' cellpadding='3' bgcolor='#FFFFFF'>";
print "<form action=\"../cgi-bin/form.pl\" method=\"get\">\n";  

my @row;
while  (@row = $stmt->fetchrow_array)
	{ 
		
			print "<tr><td align=\"right\"><input type=\"checkbox\" name=\"id\" value=\"$row[0]\"></td><td><span class=\"style41\">&nbsp;$row[3]</span></td>
			";
			
	}

print "<tr><td colspan=\"2\" align=\"center\"><p>&nbsp;</p><input value=\"SUBMIT NAME\" type=\"submit\" name=\"requestType\"></td></tr>";
print "</table></center>";
print "</form>";
print "</BODY></HTML>";

$stmt->finish();

#disconnect from the database.
$dbh->disconnect();

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
<div id=\"topmenu\"></div>
<div id=\"header\"></div>

<div id=\"content\">
<p>
<center>
<span class=\"style24\">PIFSC Staff Directory</span> 
</center>
<p>&nbsp;</p>
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



<div id=\"footer\">
<p><span class=\"style8\">Please send questions or comments to <a href=\"mailto:PIFSC.Librarian\@noaa.gov\">PIFSC Librarian</a>.<br></span>
</div>     



</body>

</html>
";
}			
