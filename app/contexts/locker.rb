class Locker
  include Singleton

  attr_reader :client

  def initialize
    @client = Redis.new(
      host: Rails.configuration.redis_host,
      port: Rails.configuration.redis_port
    )
  end

  def lock(k)
    @client.set(k, "lock", ex: Rails.configuration.ttl_transc_lock)
  end

  def locked?(k)
    @client.get(k) ? true : false
  end
end
