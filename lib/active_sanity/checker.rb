module ActiveSanity
  class Checker
    class << self
      attr_accessor :batch_size
    end

    def initialize
      Checker.batch_size ||= 500
    end

    def self.check!
      new.check!
    end

    def check!
      puts 'Sanity Check'
      puts "Checking the following models: #{models.join(', ')}"

      # TODO: Wouldnt this list already be checked by the next all records call if those records do exist?
      # This will validate and destroy the records that either dont exist currently, or are now valid. But the ones are continue to be invalid - these will
      # have been run through the validation process twice
      check_previously_invalid_records
      check_all_records
    end

    # @return [Array] of [ActiveRecord::Base] direct descendants
    def models
      return @models if @models

      load_all_models

      @models ||= direct_active_record_base_descendants
      @models -= [InvalidRecord]
      if File.exist?('active_sanity.ignore.yml')
        yaml_contents = YAML.load_file('active_sanity.ignore.yml')
        model_names_to_ignore = Array(yaml_contents['models'] || []).uniq
        @models = @models.reject { |model| model_names_to_ignore.include?(model.name) }
      end
      @models
    end

    protected

    # Require all files under /app/models.
    # All models under /lib are required when the rails app loads.
    def load_all_models
      Dir["#{Rails.root}/app/models/**/*.rb"].each { |file_path| require file_path rescue nil }
    end

    # @return [Array] of direct ActiveRecord::Base descendants.
    # Example:
    # The following tree:
    #   ActiveRecord::Base
    #   |
    #   |- User
    #   |- Account
    #   |  |
    #   |  |- PersonalAccount
    #   |  |- BusinessAccount
    #
    # Should return: [Account, User]
    def direct_active_record_base_descendants
      parent_class = defined?(ApplicationRecord) ? ApplicationRecord : ActiveRecord::Base
      parent_class.descendants.select(&:descends_from_active_record?).sort_by(&:name)
    end

    # Remove records that are now valid from the list of invalid records.
    def check_previously_invalid_records
      return unless InvalidRecord.table_exists?

      InvalidRecord.find_each(batch_size: Checker.batch_size) do |invalid_record|
        begin
          invalid_record.destroy if invalid_record.record.valid?
        rescue
          # Record does not exists.
          invalid_record.delete
        end
      end
    end

    # Go over every single record. When the record is not valid
    # log it to STDOUT and into the invalid_records table if it exists.
    def check_all_records
      models.each do |model|
        begin
          # TODO: Can we filter based on those records that are already present in the 'invalid_records' table - especially since they have been re-verified in the method before?
          model.find_each(batch_size: Checker.batch_size) do |record|
            invalid_record!(record) unless record.valid?
          end
        rescue => e
          # Rescue from exceptions (table does not exists,
          # deserialization error, ...)
          puts e.message
          puts "Skipping validations for #{model}"
        end
      end
    end

    def invalid_record!(record)
      log_invalid_record(record)
      store_invalid_record(record)
    end

    # Say that the record is invalid. Example:
    #
    # Account | 10 | :name => "Can't be blank"
    def log_invalid_record(record)
      puts "#{type_of(record)} | #{record.id} | #{pretty_errors(record)}"
    end

    # Store invalid record in InvalidRecord table if it exists
    def store_invalid_record(record)
      return unless InvalidRecord.table_exists?

      invalid_record = InvalidRecord.where(record_type: type_of(record), record_id: record.id).first
      invalid_record ||= InvalidRecord.new
      invalid_record.record = record
      invalid_record.validation_errors = record.errors.messages
      invalid_record.save!
    end

    def type_of(record)
      record.class.base_class
    end

    def pretty_errors(record)
      record.errors.messages.inspect.sub(/^#<OrderedHash (.*)>$/, '\1')
    end
  end
end
