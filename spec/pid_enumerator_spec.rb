require 'tmpdir'

RSpec.describe Prometheus::EnumeratedStore::PidEnumerator do
  let(:dir){ @tmpdir }
  subject(:enumerator){ described_class.new(dir: dir) }

  around do |example|
    Dir.mktmpdir(described_class.to_s) do |dir|
      @tmpdir = dir
      Dir.chdir(dir) { example.run }
    end
  end

  it { is_expected.to have_attributes(dir: dir) }
  it { is_expected.to have_attributes(lock_path: /#{dir}/) }
  it { is_expected.to have_attributes(instances_path: /#{dir}/) }

  it { is_expected.to have_attributes(lock_path: /enumetated_instances.lock/) }
  it { is_expected.to have_attributes(instances_path: /enumetated_instances.json/) }

  context '#with_lock' do
    it { expect{|b| subject.with_lock(&b) }.to yield_with_args(/.*json/) }
    it {
      expect(File.exist?(subject.lock_path)).not_to be_truthy

      subject.with_lock do |_|
        expect(File.exist?(subject.lock_path)).to be_truthy
      end
    }
  end

  context '#obtained' do
    let(:json){ { Process.pid => 1 } }
    it { expect { subject.obtained }.to change{ subject.read_instances }.from('{}').to(json.to_json) }

    context 'fork' do
      let(:pid) do
        fork do
          sleep 0.2
          subject.obtained
        end
      end

      it do
        expect(pid).not_to be_nil

        expect do
          subject.obtained
          Process.waitpid(pid)
        end.to change{ subject.read_instances }.from('{}').to(json.merge(pid => 2).to_json)
      end

      it do
        expect(pid).not_to be_nil

        expect do
          subject.obtained
          Process.waitpid(pid)
        end.to change{ subject.read_instances }.from('{}').to(json.merge(pid => 2).to_json)

        expect do
          subject.reset
          subject.obtained
        end.to change{ subject.read_instances }.from(json.merge(pid => 2).to_json).to(json.to_json)
      end
    end
  end

  context '#reset' do
    before { subject.obtained }

    it { expect{ subject.reset }.to(change{ subject.instance_variable_get('@obtained')}.from(1).to(nil)) }
  end
end

