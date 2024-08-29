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
my $sql;

my ($id, $lastname, $firstname, $email, $research1, $research2, $research3, $research4, $education1, $education2,
	$education3, $education4, $photo);

#Generate "Content-type:text/html\n\n";
print $query->header;

	#Access parameters using the CGI object and store them in the $variables.  This is param() method of CGI module.		
	$id = $query->param('id');
	$lastname = $query->param('lastname');
	$firstname = $query->param('firstname');
	$email = $query->param('email');
	$research1 = $query->param('research1');
	$research2 = $query->param('research2');
	$research3 = $query->param('research3');
	$research4 = $query->param('research4');
	$education1 = $query->param('education1');
	$education2 = $query->param('education2');
	$education3 = $query->param('education3');
	$education4 = $query->param('education4');
	$photo = $query->param('photo');



if ($research1 || $research2 || $research3 || $research4 || $education1 || $education2 || $education3 || $education4)
{
	#eliminate anything but letters, numbers, hyphens, apostrophes, periods, & sign, spaces from the user input
	$research1 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$research2 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$research3 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$research4 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$education1 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$education2 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$education3 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	$education4 =~ s/[^A-Za-z0-9\-\'\.\(\)\+\,\& ]*//g;
	#replace any 1 apostrophe with 2 apostrophes for Center's or Hawai'i, etc.
	$research1 =~ s/[\']+/\'\'/g;	
	$research2 =~ s/[\']+/\'\'/g;	
	$research3 =~ s/[\']+/\'\'/g;
	$research4 =~ s/[\']+/\'\'/g;
	$education1 =~ s/[\']+/\'\'/g;
	$education2 =~ s/[\']+/\'\'/g;
	$education3 =~ s/[\']+/\'\'/g;
	$education4 =~ s/[\']+/\'\'/g;
	#strip leading spaces on first string only
	$research1 =~ s/^\s+// ; 
	$research2 =~ s/^\s+// ; 
	$research3 =~ s/^\s+// ; 
	$research4 =~ s/^\s+// ; 
	$education1 =~ s/^\s+// ; 
	$education2 =~ s/^\s+// ; 
	$education3 =~ s/^\s+// ; 
	$education4 =~ s/^\s+// ; 
	#replace slashes with a space
	$research1 =~ s/[\\\/]+/, /g;	
	$research2 =~ s/[\\\/]+/, /g;
	$research3 =~ s/[\\\/]+/, /g;	
	$research4 =~ s/[\\\/]+/, /g;	
	$education1 =~ s/[\\\/]+/, /g;
	$education2 =~ s/[\\\/]+/, /g;	
	$education3 =~ s/[\\\/]+/, /g;
	$education4 =~ s/[\\\/]+/, /g;	



}


	if (length($research1)>200) 
	{
		header();
		print "<span class=\"style41\"><center>Oops!  You entered too much information for your Research Interests #1.<p>  There is a 200 character limit per box.</center></span>";
		footer();
		exit();
	}
	elsif (length($research2)>200) 
	{
		header();
		print "<span class=\"style41\"><center>Oops!  You entered too much information for your Research Interests #2.<p>  There is a 200 character limit per box.</center></span>";
		footer();
		exit();
	}
	elsif (length($research3)>200) 
	{
		header();
		print "<span class=\"style41\"><center>Oops!  You entered too much information for your Research Interests #3.<p>  There is a 200 character limit per box.</center></span>";
		footer();
		exit();
	}
	elsif (length($research4)>200) 
	{
		header();
		print "<span class=\"style41\"><center>Oops!  You entered too much information for your Research Interests #4.<p>  There is a 200 character limit per box.</center></span>";
		footer();
		exit();
	}
	
	


if ($photo eq "yes")
{ $photo ="yes";}
elsif ($photo eq "yes_")
{ $photo ="yes_";}
elsif ($photo eq "no")
{ $photo = "no";}

#Establish database connection 
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}
#print "<p>Connected successfully!<br /><br />\n";

		
		my @count;
		my $count;
		my @row;

#See if they already entered information

#did they already submit their information?
$query = qq{SELECT emp_id, firstname from employees_pic where emp_id=$id};

my $stmt = $dbh->prepare($query);
		
$stmt->execute() || die "The query was not made: $DBI::errstr";

#Check to see if employees_pic already has this person's information in it
my @count = $stmt->fetchrow_array();
my $count = $#count+1;

$stmt->finish();



if($count>0) 
	{	header();
		my $firstname = $count[1];		
		print "<span class=\"style41\"><center>Hi $firstname!<p>You have already submitted information<br>to the PIFSC Staff Directory<p>
		<a href=\"http://picahi.nmfs.local/cgi-bin/edit.pl?id=$id\">Edit Your Existing Information</a><p>
		</center></span>";
		footer();
		exit();
		
	}


#Insert values into employees_pic
$query = qq{INSERT INTO EMPLOYEES_PIC (EMP_ID, EMP_RSCH1, EMP_RSCH2, EMP_RSCH3, EMP_RSCH4, EMP_EDUC1,
		EMP_EDUC2, EMP_EDUC3, EMP_EDUC4, PHOTO_OPT, LASTNAME, FIRSTNAME, EMAIL, ENTRY_DATE)
		VALUES ('$id','$research1', '$research2', '$research3', '$research4', '$education1', '$education2',
		'$education3', '$education4', '$photo', '$lastname', '$firstname', '$email', sysdate)	
		
		};



my $stmt = $dbh->prepare($query);

#Execute sql or not
$stmt->execute() || die "The values were not inserted: $DBI::errstr";

$stmt->finish();

#disconnect from the database.
$dbh->disconnect();

###Email to Staff Member#############################################
# Set the PATH environment variable to the same path
# where sendmail is located:

$ENV{PATH} = "/usr/sbin";

# send email using UNIX/Linux sendmail
open (MAIL, "|/usr/sbin/sendmail -oi -t") or 
    die ("Can't fork for sendmail: $!\n");

my $recipient = $email;


# Start printing the mail headers
# You must specify who it's to, or it won't be delivered:

print MAIL "To: $recipient\n";

# From should probably be the webserver.

print MAIL "From: auto-reply\@pifsc.noaa.gov\n";

# print a subject line so you know it's from your form cgi.

print MAIL "Subject: PIFSC Staff Directory Confirmation for $firstname $lastname\n\n";

# Now print the body of your mail message.
print MAIL "

Dear $firstname $lastname,\n
Your information for the Intranet Staff Directory has been submitted as follows:\n
http://webdev.nmfs.local/cgi-bin/employee.pl?id=$id\n\n";

#make any double apostrophes into single ones
#$research1 =~ s/[\'\']+/\'/g;	
#$research2 =~ s/[\'\']+/\'/g;	
#$research3 =~ s/[\'\']+/\'/g;
#$research4 =~ s/[\'\']+/\'/g;
#$education1 =~ s/[\'\']+/\'/g;
#$education2 =~ s/[\'\']+/\'/g;
#$education3 =~ s/[\'\']+/\'/g;
#$education4 =~ s/[\'\']+/\'/g;

#print MAIL "Firstname: $firstname\n
#Lastname: $lastname\n
#Research Interests:\n $research1\n $research2\n $research3\n $research4\n
#Education:\n $education1\n $education2\n $education3\n $education4\n
#";

if ($photo eq "yes")
{print MAIL "Someone will contact you to take your photo.\n\n";}
elsif ($photo eq "yes_")
{print MAIL "Please send us your photo at your earliest convenience. Email photo to PIFSC.Librarian\@noaa.gov\n\n";}
elsif ($photo eq "no")
{print MAIL "You have chosen not to include your photo.\n\n";}


print MAIL "You may edit your information at http://picahi.nmfs.local/cgi-bin/edit.pl?id=$id\n\nThank you!";
# Be sure to close the MAIL input stream so that the
# message actually gets mailed.

close(MAIL);

###Email to Owner#############################################
$ENV{PATH} = "/usr/sbin";

#send email using UNIX/Linux sendmail
open (MAIL, "|/usr/sbin/sendmail -oi -t") or 
    die ("Can't fork for sendmail: $!\n");

# Start printing the mail headers
# You must specify who it's to, or it won't be delivered:

print MAIL "To: PIFSC.Librarian\@noaa.gov\n";

# From should probably be the webserver.

print MAIL "From: auto-reply\@pifsc.noaa.gov\n";

# print a subject line so you know it's from your form cgi.

print MAIL "Subject: $firstname $lastname Submitted to PIFSC Staff Directory\n\n";

# Now print the body of your mail message.
print MAIL "Copy of Email\n

_____________________________________\n

Dear $firstname $lastname,\n
Your information for the Intranet Staff Directory has been submitted as follows:\n\n";

#make any double apostrophes into single ones
$research1 =~ s/[\'\']+/\'/g;	
$research2 =~ s/[\'\']+/\'/g;	
$research3 =~ s/[\'\']+/\'/g;
$research4 =~ s/[\'\']+/\'/g;
$education1 =~ s/[\'\']+/\'/g;
$education2 =~ s/[\'\']+/\'/g;
$education3 =~ s/[\'\']+/\'/g;
$education4 =~ s/[\'\']+/\'/g;

print MAIL "Firstname: $firstname\n
Lastname: $lastname\n
Research Interests:\n $research1\n $research2\n $research3\n $research4\n
Education:\n $education1\n $education2\n $education3\n $education4\n
";

if ($photo eq "yes")
{print MAIL "Someone will contact you to take your photo.\n\n";}
elsif ($photo eq "yes_")
{print MAIL "Please send us your photo at your earliest convenience. Email photo to PIFSC.Librarian\@noaa.gov\n\n";}
elsif ($photo eq "no")
{print MAIL "You have chosen not to include your photo.\n\n";}


print MAIL "You may edit your information at http://picahi.nmfs.local/cgi-bin/edit.pl?id=$id\n\nThank you!";
# Be sure to close the MAIL input stream so that the
# message actually gets mailed.

close(MAIL);

#########

header();
print"
<center>

<span class=\"style41\">Thank you $firstname.  <p>You will receive an email shortly. <p> 	<a href=\"http://picahi.nmfs.local/staffsearch\">Search PIFSC Staff Directory</a></font></span><p>
";
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
