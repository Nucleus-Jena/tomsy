namespace :db do
  namespace :definitions do
    desc "Dump all models defined in current database."
    task dump: :environment do
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      tables = ["dossier_definitions", "dossier_definition_fields"]
      database = ActiveRecord::Base.connection.current_database
      dump_tables_options = tables.map { |table| "--table=#{table}" }.join(" ")
      `pg_dump --no-acl --no-owner #{dump_tables_options} #{database} > #{Date.current}_db-definitions-dump.sql`
    end
  end
end
