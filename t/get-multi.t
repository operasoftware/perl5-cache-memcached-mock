use Test::More tests => 7;
use Cache::Memcached::Mock;

my $c = Cache::Memcached::Mock->new();
ok($c, 'Got an object');

ok($c->set('key1', 'value1'),    'Preparing some keys for get_multi()');
ok($c->set('key2', 'value2', 2), 'Preparing some keys for get_multi()');
ok($c->set('key3', 'value3'),    'Preparing some keys for get_multi()');
ok($c->set('key5', 'value5'),    'Preparing some keys for get_multi()');

my @values = $c->get_multi(qw(key1 key2 key3 key4 key5));

is_deeply(
    \@values,
    ['value1', 'value2', 'value3', undef, 'value5'],
    'get_multi() works'
);

# Allow key2 to expire
sleep 3;

@values = $c->get_multi(qw(key1 key2 key3 key4 key5));

is_deeply(
    \@values,
    ['value1', undef, 'value3', undef, 'value5'],
    'get_multi() work and respects expired keys'
);

