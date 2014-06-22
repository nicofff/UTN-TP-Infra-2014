use IO::Socket::INET;
 
# auto-flush on socket
$| = 1;

my $host = shift || "127.0.0.1";
my $service = shift || "pcsstatus";


# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => $host,
    PeerPort => '7777',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";
 
# data to send to a server
my $size = $socket->send($service);
print "sent data of length $size\n";
 
# notify server that request has been sent
shutdown($socket, 1);
 
# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, 1024);
print "received response: $response\n";
 
$socket->close();