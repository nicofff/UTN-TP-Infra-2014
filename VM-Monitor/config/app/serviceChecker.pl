use IO::Socket::INET;
 
# auto-flush on socket
sub clientlog {
	# TODO: Implement logging
 	print shift, "\n";
	return;
}

sub docheck {
	
	my $host = shift;
	my $service = shift ;

	# create a connecting socket
	my $socket = new IO::Socket::INET (
	    PeerHost => $host,
	    PeerPort => '7777',
	    Proto => 'tcp',
	);

	unless($socket){
		print "-1:::cannot connect to the server $!\n";
		exit;
	}
	clientlog("connected to the server\n");
	 
	# data to send to a server
	my $size = $socket->send($service);
	clientlog("sent data of length $size\n");
	 
	# notify server that request has been sent
	shutdown($socket, 1);
	 
	# receive a response of up to 1024 characters from server
	my $response = "";
	$socket->recv($response, 1024);
	clientlog("received response: $response\n");
	$socket->close();
	return $response;
}

$| = 1;

my $host = shift  || "127.0.0.1";
my $service = shift || "uptime";

print "host:", $host, "\n";
print "service:", $service, "\n";
print docheck($host,$service);
