use DBI;
use Data::Dumper;
use IPC::System::Simple qw(capture EXIT_ANY);

my $dsn = "DBI:mysql:database=monitor;host=localhost;";

sub getAllChecks {
	$dbh = DBI->connect($dsn, "monitor", "monitor") or die "Connection Error: $DBI::errstr\n";
	$sql = <<'ALLCHECKSSQL';
SELECT C.ID as check_id, H.name as hostname, H.address as address, S.command as check_command
FROM services S, hosts H, checks C
where C.service = S.ID and C.HOST = H.ID;
ALLCHECKSSQL
	
	$sth = $dbh->prepare($sql);
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	while (my $ref = $sth->fetchrow_hashref()) {
		push(@asd,{'check_id' => $ref->{'check_id'},'hostname' => $ref->{'hostname'} , 'address' => $ref->{'address'}, 'check_command' => $ref->{'check_command'}} );
	  
	}
	return \@asd;
	
}

# fetch next element of a rotating list

sub getNextCheck{
	my $arrayref = $_[0];
	my $nextCheck = shift @$arrayref;
	push(@$arrayref, $nextCheck);
	return $nextCheck;
}

sub doCheck{
	%check = @_;
	my $address = %check->{address};
	my $command = %check->{check_command};
	my $retval = capture(EXIT_ANY,"perl /root/serviceChecker.pl $address $command");
    return $retval;
}

sub storeResult{
	$out = shift;
	%check = @_;
	my @output = split(":::",$out);
	my $check_id = %check->{check_id};
	my $scapedOutput = $output[1];
	$dbh = DBI->connect($dsn, "monitor", "monitor") or die "Connection Error: $DBI::errstr\n";
	$sql = "INSERT INTO log (date,exit_code,output,checkID) VALUES (now(),?,?,?)";
	$sth = $dbh->prepare($sql);
	$sth->execute($output[0],$scapedOutput,$check_id) or die "SQL Error: $DBI::errstr\n";
}

my @checks = @{getAllChecks()};
while (1) {
	my %nextCheck = %{getNextCheck(\@checks)};
	$result = doCheck(%nextCheck);
	storeResult($result,%nextCheck);
	sleep 3;
}