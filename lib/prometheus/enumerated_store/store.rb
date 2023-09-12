require 'prometheus/client/data_stores/direct_file_store'

module Prometheus
  module EnumeratedStore
    class Store < Prometheus::Client::DataStores::DirectFileStore

      attr_reader :pid_enumerator

      def initialize(*_args, dir:, **_kwargs)
        super
        @pid_enumerator = PidEnumerator.new(dir: dir)
        # pass enumerator through store_settings to every MetricStore
        @store_settings[:pid_enumerator] = @pid_enumerator
      end

      def reset
        @pid_enumerator.reset
      end

      def self.metric_store_class
        MetricStore
      end

      MetricStore.class_eval do
        # Monkeypatch! there is no normal method to overload filename generation
        # https://github.com/prometheus/client_ruby/blob/e144d6225d3c346e9a4dd0a11f41f8acde386dd8/lib/prometheus/client/data_stores/direct_file_store.rb#L190
        def process_id
          @store_settings[:pid_enumerator].obtained
        end
      end

    end
  end
end

