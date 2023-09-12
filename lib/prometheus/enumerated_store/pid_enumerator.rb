module Prometheus
  # Класс мапит текущий PID на минимальный "свободный" номер
  # "свободность" определяется по принципу процесс с пидом есть? - значит занято
  # реестр хранится в файле в виде {"22655":1,"22760":2,"22813":3,"22832":4}
  #  где слева PID, справа занятый им (когда-то) номер
  # Информация актуализируется (удаляются несуществующие записи) при очередном выделении
  # многопроцессность синхронизируется через механизм эксключзивных блокировок flock
  module EnumeratedStore
    class PidEnumerator

      MAX_INSTANCES = 1000

      attr_reader :dir, :instances_path, :lock_path

      def initialize(dir:)
        @dir = dir

        @lock_path = File.join(@dir, 'enumetated_instances.lock')
        @instances_path = File.join(@dir, 'enumetated_instances.json')
        reset
      end

      def reset
        @obtained = nil
      end

      def with_lock
        File.open(lock_path, File::RDWR | File::CREAT, 0o644) do |file|
          file.flock(File::LOCK_EX)
          Dir.chdir(@dir) do
            tmpfilename = ".tmp-#{$$}-#{rand(0x100000000).to_s(36)}.json"
            yield(tmpfilename)
          ensure
            File.delete(tmpfilename) rescue nil
          end
        end
      end

      def read_instances
        raw = File.read(instances_path).strip
        raw.empty? ? '{}' : raw
      rescue Errno::ENOENT
        # there is no file yet
        '{}'
      end

      def obtained
        @obtained ||= obtain_enumerated_number
      end

      def obtain_enumerated_number
        with_lock do |tmpfilename|
          break @obtained if @obtained # double check-lock

          raw_data = read_instances
          data = JSON.parse(raw_data) || {} # set {} if "null" in file
          data = clean_dead_instances(data)

          current = find_minimal_number(data)
          File.write(tmpfilename, data.to_json) # We are inside tmpdir
          File.rename(tmpfilename, instances_path)
          current
        end
      end

      def find_minimal_number(data)
        values = data.values
        current = data[Process.pid.to_s] || (1..MAX_INSTANCES).find{|i| !values.include?(i) }
        raise "Unable to find any number between 1 and #{MAX_INSTANCES}" unless current

        data[Process.pid.to_s] = current
      end

      def clean_dead_instances(data)
        data.select do |pid, num|
          next nil if num.to_i <= 0 || num.to_i > MAX_INSTANCES

          alive?(pid.to_i)
        end
      end

      def alive?(pid)
        return nil if pid <= 1

        Process.getpgid(pid)
        true
      rescue Errno::ESRCH
        false
      end


    end
  end
end

