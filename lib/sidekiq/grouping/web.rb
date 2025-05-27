# frozen_string_literal: true

require "sidekiq/web"

module Sidekiq
  module Grouping
    module Web
      VIEWS = File.expand_path("views", File.dirname(__FILE__))

      def self.registered(app)
        app.get "/grouping" do
          @batches = Sidekiq::Grouping::Batch.all
          erb File.read(File.join(VIEWS, "index.erb")),
              locals: { view_path: VIEWS }
        end

        app.delete "/grouping/:name64" do
          name = Base64.decode64(params["name64"])
          worker_class, queue =
            Sidekiq::Grouping::Batch.extract_worker_klass_and_queue(
              name
            )
          batch = Sidekiq::Grouping::Batch.new(worker_class, queue)
          batch.delete
          redirect "#{root_path}grouping"
        end
      end
    end
  end
end

args = {
  name: "grouping",
  tab: ["Grouping"],
  index: ["grouping"],
  root_dir: File.dirname(__FILE__)
}

if Gem::Version.new(Sidekiq::VERSION) >= Gem::Version.new("8.0.0")
  Sidekiq::Web.configure do |cfg|
    cfg.register(Sidekiq::Grouping::Web, **args)
  end
else
  Sidekiq::Web.register(Sidekiq::Grouping::Web, **args)
end
