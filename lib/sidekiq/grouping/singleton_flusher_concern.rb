# frozen_string_literal: true

module Sidekiq
  module Grouping
    module SingletonFlusherConcern
      def could_flush_on_singleton_worker?
        return true unless singleton_worker?

        !(singleton_worker_running? || singleton_flusher_locked?)
      end

      def lock_singleton_flusher
        # This lock is released within Sidekiq::Grouping::SingletonWorker#with_singleton_worker_lock.
        # It prevents plucking again between the time when data is plucked and when the worker starts.
        singleton_flusher.lock_singleton_flusher if singleton_worker?
      end

      private

      def flusher_lock_ttl
        worker_class_options["singleton_flusher_lock_ttl"]
      end

      def singleton_flusher
        @singleton_flusher ||=
          Sidekiq::Grouping::SingletonFlusher.new(queue, worker_class, flusher_lock_ttl:)
      end

      def singleton_flusher_locked?
        @singleton_flusher.singleton_flusher_locked?
      end

      def singleton_worker?
        !!worker_class_options["singleton_worker"]
      end

      def singleton_worker_running?
        @singleton_flusher.singleton_worker_locked?
      end
    end
  end
end
