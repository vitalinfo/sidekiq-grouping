# frozen_string_literal: true

module Sidekiq
  module Grouping
    class SingletonWorker < SingletonBase
      attr_reader :worker_lock_ttl

      def initialize(queue, worker_class, worker_lock_ttl: 3_600)
        super(queue, worker_class)

        @worker_lock_ttl = worker_lock_ttl
      end

      def with_singleton_worker_lock(&)
        lock_singleton_worker

        yield
      ensure
        unlock_singleton_worker
      end

      def lock_singleton_worker
        raise "Singleton lock for '#{worker_key}' already exists" if singleton_worker_locked?

        redis_client.set(worker_key, Time.current.to_s, ex: worker_lock_ttl)
      ensure
        unlock_singleton_flusher
      end

      def unlock_singleton_worker
        redis_client.del(worker_key)
      end

      # Method handy for unlocking from the console in case of need.
      def release_locks
        unlock_singleton_worker
        unlock_singleton_flusher
      end
    end
  end
end
