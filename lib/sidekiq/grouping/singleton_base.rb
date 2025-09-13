# frozen_string_literal: true

module Sidekiq
  module Grouping
    class SingletonBase
      attr_reader :queue, :worker_class

      def initialize(queue, worker_class)
        @queue = queue
        @worker_class = worker_class
      end

      def singleton_flusher_locked?
        redis_client.get(flusher_key).present?
      end

      def singleton_worker_locked?
        redis_client.get(worker_key).present?
      end

      def unlock_singleton_flusher
        redis_client.del(flusher_key)
      end

      private

      def flusher_key
        @flusher_key ||= "#{worker_key}:flusher"
      end

      def worker_key
        @worker_key ||= "#{worker_class.to_s.underscore}:#{queue}"
      end

      def redis_client
        @redis_client ||= Sidekiq.redis { _1 }
      end
    end
  end
end
