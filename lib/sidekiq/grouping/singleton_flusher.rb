# frozen_string_literal: true

module Sidekiq
  module Grouping
    class SingletonFlusher < SingletonBase
      attr_reader :flusher_lock_ttl

      def initialize(queue, worker_class, flusher_lock_ttl: 5)
        super(queue, worker_class)

        @flusher_lock_ttl = flusher_lock_ttl
      end

      def lock_singleton_flusher
        raise "Singleton flusher lock for '#{flusher_key}' already exists" if singleton_flusher_locked?

        redis_client.set(flusher_key, Time.current.to_s, ex: flusher_lock_ttl)
      end
    end
  end
end
