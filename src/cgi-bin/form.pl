#!/usr/bin/perl -wT

use DBI;
use strict;
use File::Copy;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(.);
use MyConnectStaff; 

my $query = new CGI;

my ($id, $employee, $lastname, $firstname, $email, $research1, $research2, $research3, $research4, $education1, $education2,
	$education3, $education4, $photoyes, $photono, @row);

#Generate "Content-type:text/html\n\n";
print $query->header;


	#Access ID number
	$id = $query->param('id');


#check if they didn't verify their name with the checkbox
if ($id eq "")
{
	header();
	print "<span class=\"style41\"><center>You did not verify your name. </center></span>";
	footer();
	exit;
}
	
#Establish database connection 
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}
#print "<p>Connected successfully!<br /><br />\n";

#did they already submit their information?
$query = qq{SELECT emp_id, firstname from employees_pic where emp_id=$id};

my $stmt = $dbh->prepare($query);
		
$stmt->execute() || die "The query was not made: $DBI::errstr";

#Check to see if employees_pic already has this person's information in it
my @count = $stmt->fetchrow_array();
my $count = $#count+1;

$stmt->finish();

#print the header
header();
if($count>0) 
	{	
		my $firstname = $count[1];		
		print "<span class=\"style41\"><center>Hi $firstname!<p>You have already submitted information<br>to the PIFSC Staff Directory<p>
		<a href=\"http://picahi.nmfs.local/cgi-bin/edit.pl?id=$id\">Edit Your Existing Information</a><p>
		</center></span>";
		footer();
		exit();
		
	}
	else
	{

		$query = qq{SELECT lastname, firstname, email_addr FROM picadm.vw_nonpii_pers_v
		WHERE id=$id 
		};
			
		
		$stmt = $dbh->prepare($query);
		
		$stmt->execute() || die "The query was not made: $DBI::errstr";

		while (@row = $stmt->fetchrow_array)
			{ 
				my $lastname = $row[0];
				my $firstname = $row[1];
				my $email = $row[2];

		

print"
<center><span class=\"style44\">Please Share Some Information About Yourself</span>
</center>
<p>&nbsp;</p>

<center>
<form action=\"/cgi-bin/final.pl\" method=\"post\">
<div class=\"pub_tb\">
<table border=0>

<tr>
<td align=\"right\"><span class=\"style42\">First Name\:</span> </td>
<td><span class=\"style43\">$firstname</span>
<input type=\"hidden\" name=\"id\" value=\"$id\"> 
<input type=\"hidden\" name=\"firstname\" value=\"$firstname\"></td>
</tr>

<tr>
<td align=\"right\"><span class=\"style42\">Last Name\: </span></td>
<td><span class=\"style43\">$lastname</span>
<input type=\"hidden\" name=\"lastname\" value=\"$lastname\"></td>
</tr>

<tr>
<td align=\"right\"><span class=\"style42\">Email\: </span></td>
<td><span class=\"style43\">$email</span>
<input type=\"hidden\" name=\"email\" value=\"$email\">
</td>
</tr>

<tr><td colspan=2><hr></td></tr>
<tr>
<td align=\"right\" valign=\"top\"><span class=\"style33\"><u>Briefly</u> Describe Your Research Interests at PIFSC:<br><i>(optional)</i></span>
</td>
<td>#1 <span class=\"style8\">(Ex: Stock assessment of tuna and billfish) </span><br><textarea name=\"research1\" rows=1 cols=40></textarea><p>
#2 <span class=\"style8\">(Ex: Population dynamics of the Hawaiian monk seal)</span><br><textarea name=\"research2\" rows=1 cols=40></textarea><p>
#3 <span class=\"style8\">(Ex: Marine debris accumulation in the NWHI)</span><br><textarea name=\"research3\" rows=1 cols=40></textarea><p>
#4 <span class=\"style8\">(Ex: Satellite remote sensing for fisheries oceanography)</span><br><textarea name=\"research4\" rows=1 cols=40></textarea>
</td>
</tr>

<tr><td colspan=2><hr></td></tr>

<tr>
<td align=\"right\" valign=\"top\"><span class=\"style33\">Educational Background:<br><i>(optional)</i></span></td>
<td>
<span class=\"style6\">List Most Recent First</span><br>
<span class=\"style8\">(Ex: Ph.D. Biostatistics, Oregon State University, 2008)</span><br><input type=\"text\" name=\"education1\" size=\"60\" maxlength=\"150\"><p>
<span class=\"style8\">(Ex: M.S. Biology, University of Washington, 2006)</span><br><input type=\"text\" name=\"education2\" size=\"60\" maxlength=\"150\"><p>
<span class=\"style8\">(Ex: B.A. Economics, University of Hawai'i, 2003)</span><br><input type=\"text\" name=\"education3\" size=\"60\" maxlength=\"150\"><p>
<span class=\"style8\">(Ex: A.A.S. Fisheries Technology, Kapiolani Community College, 2000)</span><br><input type=\"text\" name=\"education4\" size=\"60\" maxlength=\"150\">
</td>
</tr>

<tr><td colspan=2><hr></td></tr>


<tr>

<td align=\"right\" valign=\"top\"><span class=\"style33\">Do You Want to Display Your Photo?</span>


<td><input type=\"radio\" name=\"photo\" value=\"yes\" checked>&nbsp;<span class=\"style4\">Yes! (Please take my photo for me) </span> 

<br><input type=\"radio\" name=\"photo\" value=\"yes_\">&nbsp;<span class=\"style4\">Yes! (I'll provide my own photo) </span> 

<br><input type=\"radio\" name=\"photo\" value=\"no\">&nbsp;<span class=\"style4\">No Thanks.</span><p>
</td>
</tr>


<tr><td colspan=\"2\"><center><input value=\"SUBMIT\" type=\"submit\" name=\"requestType\"
onclick=\"this.disabled=true;this.form.submit()\">


 <input value=\"RESET\" type=\"reset\" name=\"requestType\"></center></td></tr>
</table>
</div>	
</form>
<center>
";

} #end While

	
		$stmt->finish();
		$dbh->disconnect();

footer();

# Clear the variables.  Otherwise they will show up in the form.
	$firstname = "";
	$lastname = "";
	$email = "";
	$research1 = "";
	$research2 = "";
	$research3 = "";
	$research4 = "";
	$education1 = "";
	$education2 = "";
	$education3 = "";
	$education4 = "";
	$photoyes = "";
	$photono = "";

} #end of ELSE
						
		







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
