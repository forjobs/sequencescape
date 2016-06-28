module SampleManifestExcel

	module Worksheet

    #DataWorksheet creates a data worksheet to be filled in by a client.

	  class DataWorksheet < Base

       STYLES = {  unlocked: { locked: false, border: { style: :thin, color: "00"}},
                  wrap_text: {alignment: { horizontal: :center, vertical: :center, wrap_text: true},
                  border: {style: :thin, color: "00", edges: [:left, :right, :top, :bottom]}}
                }

      def initialize(attributes = {})
        super
        create_styles
        add_title_and_description
        add_columns
        freeze_panes
      end

      def type
        @type ||= case sample_manifest.asset_type
        when "1dtube", "multiplexedlibrary"
          "Tubes"
        when "plate"
          "Plates"
        else
          ""
        end
      end

      #Using axlsx worksheet creates data worksheet with title, description, all required columns, values,
      #data validations, conditional formattings, freezes panes at required place.

      def create_worksheet
      	insert_axlsx_worksheet("DNA Collections Form")
      end

      #Adds title and description (study abbreviation, supplier name, number of assets sent)
      #to a worksheet.

    	def add_title_and_description
        add_row ["DNA Collections Form"]
        add_rows(3)
        add_row ["Study:", sample_manifest.study.abbreviation]
        add_row ["Supplier:", sample_manifest.supplier.name]
        add_row ["No. #{type} Sent:", sample_manifest.count]
        add_rows(1)
    	end

      #Adds columns with all required data to a worksheet

      def add_columns
        columns.update(first_row, last_row, ranges, axlsx_worksheet)
        add_row columns.headings, styles[:wrap_text].reference

        sample_manifest.samples.each do |sample| 
          create_row(sample)
        end

      end

      #Creates row filled in with required column values, also unlocks (adds unlock style)
      #the cells that should be filled in by clients

      def create_row(sample)
        values, types, s = [], [], []
        # axlsx_worksheet.add_row do |row|
        #   columns.each do |k, column|
        #     if column.unlocked?
        #       row.add_cell column.attribute_value(sample), type: column.type, style: styles[:unlocked].reference
        #     else
        #       row.add_cell column.attribute_value(sample), type: column.type
        #     end
        #   end
        # end

        columns.each do |k, column|
          values << column.attribute_value(sample)
          types << column.type
          s << (column.unlocked? ? styles[:unlocked].reference : nil)
        end
        axlsx_worksheet.add_row values, types: types, style: s
      end

      #Freezes panes vertically after particular column (sanger_sample_id by default)
      #and horizontally after headings

      def freeze_panes(name = :sanger_sample_id)
        axlsx_worksheet.sheet_view.pane do |pane|
          pane.state = :frozen
          pane.y_split = first_row-1
          pane.x_split = freeze_after_column(name)
          pane.active_pane = :bottom_right
        end
      end

      #Finds the column after whech the panes should be frozen. If the column was not found
      #freezes the panes after column 0 (basically not frozen vertically)

      def freeze_after_column(name)
        columns.find_by(name) ? columns.find_by(name).number : 0
      end

      #The row where the table with data starts (after headings)

      def first_row
        10
      end

      #The row where the table with data end

      def last_row
        @last_row ||= sample_manifest.samples.count + first_row - 1
      end

      def styles
        @styles ||= {}
      end

      def create_styles
        styles.tap do |s|
          STYLES.each do |k, style|
            s[k] = Style.new(workbook, style)
          end
        end
      end

      class Style
        attr_reader :options, :reference

        def initialize(workbook, options)
          @options = options
          @reference = workbook.styles.add_style options
        end
      end

	  end

	end

end