# frozen_string_literal: true

module SampleManifestExcel
  module NullObjects
    ##
    # NullColumn
    class NullColumn
      def number
        -1
      end

      def value; end
    end
  end
end
