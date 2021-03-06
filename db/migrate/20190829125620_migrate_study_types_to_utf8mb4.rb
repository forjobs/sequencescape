# frozen_string_literal: true

# Autogenerated migration to convert study_types to utf8mb4
class MigrateStudyTypesToUtf8mb4 < ActiveRecord::Migration[5.1]
  include MigrationExtensions::EncodingChanges

  def change
    change_encoding('study_types', from: 'latin1', to: 'utf8mb4')
  end
end
