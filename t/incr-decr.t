use Test::More tests => 13;
use Cache::Memcached::Mock;

my $c = Cache::Memcached::Mock->new();
my $k = 'counter1';

is($c->get($k), undef, 'Key doesn\'t initially exist');

ok($c->incr($k));
is($c->get($k) => 1, 'First incr() returns 1');

ok($c->incr($k));
is($c->get($k) => 2, 'Test that incr() really works');

$c->incr($k);
is($c->incr($k) => 4, 'incr() returns the new value of the counter');

$c->decr($k);
is($c->get($k) => 3, 'decr() also works');

$c->incr($k);
$c->incr($k);
is($c->get($k) => 5, 'Test that incr() really works');

is($c->incr($k, 2) => 7, 'incr() returns the new value?');
is($c->get($k) => 7, 'Test that incr() with offset works');

is($c->incr($k, 0) => 7, 'Increment by zero.');
is($c->decr($k, 0) => 7, 'Decrement by zero.');
is($c->get($k) => 7, 'Value is left unchanged.');
