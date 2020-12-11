namespace :db do
  namespace :fixtures do
    desc 'Create YAML test fixtures from data in an existing database.
    Defaults to development database.  Set RAILS_ENV to override.'
    task dump: :environment do
      skip_tables = ["schema_migrations", "ar_internal_metadata"]
      Dir.mkdir(Rails.root.join("test/fixtures_dump")) unless File.exist?(Rails.root.join("test/fixtures_dump"))

      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
        # Gather table information
        columns_and_types_query = "SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.columns WHERE TABLE_NAME = '%s'"
        columns_and_types = ActiveRecord::Base.connection.execute(columns_and_types_query % table_name)
        column_names = columns_and_types.map { |ct| ct["column_name"] }

        # Make order of output more deterministic
        table_query_with_order = "SELECT * FROM %s"
        if column_names.include?("id")
          table_query_with_order << " ORDER BY id ASC"
        elsif column_names.select { |column_name| column_name.match(/.*_id\Z/) }.present?
          other_id_columns = column_names.select { |column_name| column_name.match(/.*_id\Z/) }.sort
          other_id_sql = other_id_columns.map { |cn| "#{cn} ASC" }
          table_query_with_order << " ORDER BY #{other_id_sql.join(", ")}"
        else
          table_query_with_order << " ORDER BY #{column_names.min} ASC"
        end

        # Write table data to yml fixture file
        File.open(Rails.root.join("test/fixtures_dump/#{table_name}.yml"), "w") do |file|
          data = ActiveRecord::Base.connection.execute(table_query_with_order % table_name)
          json_columns = columns_and_types.select { |ct| ct["data_type"] == "jsonb" }.map { |ct| ct["column_name"] }

          i = "000"
          hash_with_keys = data.each_with_object({}) { |record, hash|
            json_columns.each { |column_name| record[column_name] = JSON.parse(record[column_name]) }
            hash["#{table_name}_#{i.succ!}"] = record
          }
          file.write hash_with_keys.to_yaml
        end
      end
    end
  end
end
