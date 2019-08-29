# frozen_string_literal: true

# Autogenerated migration to convert tag_layouts to utf8mb4
class MigrateTagLayoutsToUtf8mb4 < ActiveRecord::Migration[5.1]
  include MigrationExtensions::EncodingChanges

  def change
    change_encoding('tag_layouts', from: 'latin1', to: 'utf8mb4')
  end
end