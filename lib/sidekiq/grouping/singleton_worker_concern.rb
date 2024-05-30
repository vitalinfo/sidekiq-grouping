# frozen_string_literal: true

module Sidekiq
  module Grouping
    module SingletonWorkerConcern
      def with_singleton_worker_lock(&)
        if singleton_worker?
          singleton_worker.with_singleton_worker_lock(&)
        else
          yield
        end
      end

      private

      def singleton_worker
        Sidekiq::Grouping::SingletonWorker.new(
          sidekiq_options_hash['queue'],
          self,
          worker_lock_ttl: sidekiq_options_hash['singleton_worker_lock_ttl']
        )
      end

      def singleton_worker?
        sidekiq_options_hash['singleton_worker']
      end
    end
  end
end
