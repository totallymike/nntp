# NNTPClient

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'NNTPClient'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install NNTPClient

## Usage

### Connection
Two different methods can be usde to connect to a usenet server:

1.  First, by supplying a URL and a port number as hash values:
    ```ruby
    nntp = NNTPClient.new(:url => 'nntp.example.org', :port => 119)
    ```
    An optional `:socket_factory` value can be included if you'd with for something other than TCPSocket to be used.  
    Please note that the signature of `::new` must match `TCPSocket::new`'s signature.

2.  By supplying an existing socket:
```ruby
my_socket = TCPSocket.new('nntp.example.org', 119)
nntp = NNTPClient.new(:socket => my_socket)
```

### Listing Newsgroups
Upon connecting to a server, a list of valid newsgroups may be retrieved as such:
```ruby
groups = nntp.groups
```

The first time `#groups` is called, it retrieves the list of groups from the server.  Subsequent calls return an instance variable.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
