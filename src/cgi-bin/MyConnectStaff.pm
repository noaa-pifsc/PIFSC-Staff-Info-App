package MyConnectStaff;

use strict;
use vars qw($VERSION);
use DBI;



$VERSION = '0.01';

sub ConnectDB {

my $db = "pickaku.nmfs.local/PIC";
my $usr = "[USERNAME]";
my $pwd = "[PASSWORD]";
my $dbi=DBI->connect( "dbi:Oracle:$db", $usr, $pwd,
                       {
                        RaiseError => 1,
                        AutoCommit => 0
                        }
                        ) || die "Database connection not made: $DBI::errstr";

return $dbi;

}


1;

__END__
