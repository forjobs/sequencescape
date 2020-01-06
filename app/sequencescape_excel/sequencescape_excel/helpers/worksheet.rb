# frozen_string_literal: true

module SequencescapeExcel
  module Helpers
    ##
    # Add the basic styles which are the same across all worksheets.
    module Worksheet
      STYLES = { unlocked: { locked: false, border: { style: :thin, color: '00' } },
                 unlocked_no_border: { locked: false },
                 wrap_text: { alignment: { horizontal: :center, vertical: :center, wrap_text: true },
                              border: { style: :thin, color: '00', edges: %i[left right top bottom] } } }.freeze

      def add_headers
        add_row columns.headings, styles[:wrap_text].reference
      end

      # The row where the table with data starts (after headings)
      def first_row
        10
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

      ##
      # Style
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
