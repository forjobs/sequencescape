# frozen_string_literal: true

# Autogenerated migration to convert work_completions to utf8mb4
class MigrateWorkCompletionsToUtf8mb4 < ActiveRecord::Migration[5.1]
  include MigrationExtensions::EncodingChanges

  def change
    change_encoding('work_completions', from: 'latin1', to: 'utf8mb4')
  end
end