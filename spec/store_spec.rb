require 'tmpdir'
require 'prometheus/client'

RSpec.describe Prometheus::EnumeratedStore::Store do
  let(:dir){ @tmpdir }
  subject(:store){ described_class.new(dir: dir) }
  let(:pid_enumerator){ store.pid_enumerator }

  around do |example|
    Dir.mktmpdir(described_class.to_s) do |dir|
      @tmpdir = dir
      Dir.chdir(dir) { example.run }
    end
  end

  before do
    Prometheus::Client.config.data_store = store
  end

  context 'counter' do
    let(:counter){ Prometheus::Client.registry.counter(:test_counter, docstring: 'Any counter for test') }
    let(:metric_store){ counter.instance_variable_get('@store') }

    after { Prometheus::Client.registry.unregister(:test_counter) }

    it { expect(metric_store).to be_a(described_class.metric_store_class) }
    it {
      expect(subject.pid_enumerator).to receive(:obtain_enumerated_number).and_call_original
      counter.increment
    }

    context '#reset' do
      before { counter.increment }

      it { expect{ subject.reset }.to(change{ pid_enumerator.instance_variable_get('@obtained') }.from(1).to(nil)) }
    end
  end
end

