require 'couchbase'
require 'msgpack'
require 'json'
require 'active_support/core_ext/hash'

module Fluent

  class CouchbaseOutput < BufferedOutput
    Fluent::Plugin.register_output('couchbase', self)

    config_param :hostname,      :string
    config_param :port,          :integer
    config_param :pool,          :string
    config_param :bucket,        :string
    config_param :ttl,           :integer, :default => 0
    config_param :include_ttl,   :bool, :default => false

    def connection
      @connection ||= get_connection(self.hostname, self.port, self.pool, self.bucket)
    end

    def configure(conf)
      super

      # perform validations
      raise ConfigError, "'hostname' is required by Couchbase output (ex: localhost)" unless self.hostname
      raise ConfigError, "'port' is required by Couchbase output (ex: 8091)" unless self.port
      raise ConfigError, "'pool' is required by Couchbase output (ex: default)" unless self.pool
      raise ConfigError, "'bucket' is required by Couchbase output (ex: default)" unless self.bucket
      raise ConfigError, "'ttl' is required by Couchbase output (ex: 0)" unless self.ttl
    end

    def start
      super
      connection
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      record.to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each  { |record|
        # store ttl in the document itself?
        record[:ttl] = self.ttl if self.include_ttl

        # persist
        connection[record.delete('key'), :ttl => self.ttl] = record
      }
    end

    private

    def get_connection(hostname, port, pool, bucket)
      Couchbase.connect(:hostname => hostname,
                        :port => port,
                        :pool => pool,
                        :bucket => bucket)
    end

  end
end
