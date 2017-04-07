module SampleManifestExcel
  module Worksheet
    # DataWorksheet creates a data worksheet to be filled in by a client.

    class DataWorksheet < Base
      attr_accessor :sample_manifest, :type

      include Helpers::Worksheet

      def initialize(attributes = {})
        super
        create_styles
        add_title_and_description(sample_manifest.study.abbreviation, sample_manifest.supplier.name, sample_manifest.count)
        add_columns
        freeze_panes
      end

      def type
        @type ||= case sample_manifest.asset_type
                  when '1dtube', 'multiplexed_library'
                    'Tubes'
                  when 'plate'
                    'Plates'
                  else
                    ''
                  end
      end

      # Using axlsx worksheet creates data worksheet with title, description, all required columns, values,
      # data validations, conditional formattings, freezes panes at required place.

      # Adds columns with all required data to a worksheet

      def add_columns
        columns.update(first_row, last_row, ranges, axlsx_worksheet)
        add_headers
        sample_manifest.details_array.each do |detail|
          create_row(detail)
        end
      end

      # Creates row filled in with required column values, also unlocks (adds unlock style)
      # the cells that should be filled in by clients

      def create_row(detail)
        axlsx_worksheet.add_row do |row|
          columns.each do |column|
            if column.unlocked?
              row.add_cell column.attribute_value(detail), type: column.type, style: styles[:unlocked].reference
            else
              row.add_cell column.attribute_value(detail), type: column.type
            end
          end
        end
      end

      # Freezes panes vertically after particular column (sanger_sample_id by default)
      # and horizontally after headings

      def freeze_panes(name = :sanger_sample_id)
        axlsx_worksheet.sheet_view.pane do |pane|
          pane.state = :frozen
          pane.y_split = first_row - 1
          pane.x_split = freeze_after_column(name)
          pane.active_pane = :bottom_right
        end
      end

      # Finds the column after whech the panes should be frozen. If the column was not found
      # freezes the panes after column 0 (basically not frozen vertically)

      def freeze_after_column(name)
        columns.find_by(:name, name) ? columns.find_by(:name, name).number : 0
      end

      # The row where the table with data end
      def last_row
        @last_row ||= sample_manifest.details_array.count + first_row - 1
      end
    end
  end
end
