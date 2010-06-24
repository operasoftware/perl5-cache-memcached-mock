# ABSTRACT: A mock class for Cache::Memcached
package Cache::Memcached::Mock;

use strict;
use warnings;

use constant VALUE     => 0;
use constant TIMESTAMP => 1;

# All instances share the memory space
our %MEMCACHE_STORAGE = ();

sub new {

    my ($class) = @_;
    $class = ref $class || $class;
    my $self = [];
    bless $self, $class;
    $self->flush_all();
    return $self;
}

sub delete {
    my ($self, $memc_key) = @_;
    if (! exists $MEMCACHE_STORAGE{$memc_key}) {
        return;
    }
    delete $MEMCACHE_STORAGE{$memc_key};
    return 1;
}

sub flush_all {
    %MEMCACHE_STORAGE = ();
    return;
}

sub get {
    my ($self, $key) = @_;
    if (! exists $MEMCACHE_STORAGE{$key}) {
        return;
    }
    # Check if value had an expire time
    my $struct = $MEMCACHE_STORAGE{$key};
    my $expiry_time = $struct->[TIMESTAMP];
    if (defined $expiry_time && (time > $expiry_time)) {
        delete $MEMCACHE_STORAGE{$key};
        return;
    }
    return $struct->[VALUE];
}

sub get_multi {
    my ($self, @keys) = @_;
    my @values;
    for my $k (@keys) {
        my $v = $self->get($k);
        push @values, $v;
    }
    return @values;
}

sub set {
    my ($self, $key, $value, $expiry_time) = @_;
    if ($expiry_time) {
        $expiry_time += time();
    } else {
        $expiry_time = undef;
    }
    $MEMCACHE_STORAGE{$key} = [ $value, $expiry_time ];
    return 1;
}

1;

__END__

=pod

=head1 NAME

Cache::Memcached::Mock - A mock class for Cache::Memcached

=head1 VERSION

version 0.01

=head1 SYNOPSIS

Supports only a subset of L<Cache::Memcached> functionality.

    # Any arguments are just ignored
    my $cache = Cache::Memcached::Mock->new();

    # Values are stored in a process global hash
    my $value = $cache->get('somekey');
    my $set_ok = $cache->set('someotherkey', 'somevalue');
    $set_ok = $cache->set('someotherkey', 'somevalue', 60);  # seconds

    # new() also flushes all values
    $cache->flush_all();

    my @values = $cache->get_multi('key1', 'key2', '...');

=head1 DESCRIPTION

This class can be used to mock the real L<Cache::Memcached> object when you don't have
a memcached server running (and you don't want to run one actually), but you need
the functionality to be there.

I used it in unit tests, where I had to perform several tests against a given
memcached instance, to see that certain values were really created or deleted.

Instead of having a memcached instance running for every server where I need
unit tests running, or using a centralized memcached daemon, I can just pass
a L<Cache::Memcached::Mock> instance wherever a L<Cache::Memcached> one is required.

This is an example of how you would use this mock class:
    
    # Use the "Mock" one instead of C::MC
    my $memc = Cache::Memcached::Mock->new();

    my $business_object = My::Business->new({
        memcached_instance => $memc
    });

    $business_object->do_something_that_involves_caching();

In short, this allows you to avoid setting up a real memcached instance
whenever you don't necessarily need one, for example unit testing.

=head1 AUTHOR

  Cosimo Streppone <cosimo@opera.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Opera Software ASA.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

