use Test::More tests => 3;
use Test::Exception;
use Cache::Memcached::Mock;

ok(Cache::Memcached::Mock->new(), 'Got an object');

lives_and(sub {
    my $c = Cache::Memcached::Mock->new(servers => 'localhost');
    is($c->{servers}, 'localhost');
}, 'can create an object with params');

lives_and(sub {
    my $c = Cache::Memcached::Mock->new({servers => 'localhost'});
    is($c->{servers}, 'localhost');
}, 'can create an object with hashref params');
