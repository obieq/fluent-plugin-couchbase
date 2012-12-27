# Couchbase 2.0 plugin for Fluentd

Couchbase 2.0 output plugin for Fluentd.

# Installation

via RubyGems

    fluent-gem install fluent-plugin-couchbase

# Quick Start

## Setup Couchbase Server 2.0 Environment
    # install couchbase server 2.0
      http://www.couchbase.com/download

    # install libcouchbase
      http://www.couchbase.com/develop/c/current

    # install couchbase gem
      gem install couchbase

## Fluentd.conf Configuration
    <match couchbase.**>
      type couchbase      # fluent output plugin file name (sans fluent_plugin_ prefix)
      hostname localhost  # host name
      port 8091           # port name
      pool default        # pool name
      bucket default      # bucket name
      ttl 0               # number of seconds before document expires. 0 = no expiration
      include_ttl false   # store the ttl value w/ each document
    </match>

# Tests

rake

    NOTE: requires the following:
          1) Couchbase Server 2.0
          2) libcouch
          3) couchbase gem
          4) update spec/out_couchbase_spec.rb with your
             hostname, port, pool, and bucket prior to running the tests

# TODOs
    1) specify multiple nodes?
