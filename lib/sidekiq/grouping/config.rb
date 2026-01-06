# frozen_string_literal: true

module Sidekiq
  module Grouping
    module Config
      class << self
        %i[lock_ttl max_batch_size poll_interval tests_env].each do |method_name|
          define_method(method_name) do
            config[method_name]
          end
          define_method(:"#{method_name}=") do |value|
            config[method_name] = value
          end
        end

        private

        def config
          @config ||= ActiveSupport::InheritableOptions.new(
            lock_ttl: options[:lock_ttl] || 1,
            max_batch_size: options[:max_batch_size] || 1_000,
            poll_interval: options[:poll_interval] || 3,
            tests_env: options[:tests_env] || (
              defined?(::Rails) && ::Rails.respond_to?(:env) && ::Rails.env.test?
            )
          )
        end

        def options
          @options ||=
            begin
              if Sidekiq.respond_to?(:[]) # Sidekiq 6.x
                Sidekiq[:grouping] || {}
              elsif Sidekiq.respond_to?(:options) # Sidekiq <= 5.x
                Sidekiq.options[:grouping] || Sidekiq.options["grouping"] || {}
              elsif Sidekiq.server?  # Sidekiq >= 7.x
                Sidekiq::CLI.instance.config[:grouping]
              else
                Sidekiq.default_configuration[:grouping] || {}
              end
           end
        end
      end
    end
  end
end
