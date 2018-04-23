# frozen_string_literal: true

module SampleManifestExcel
  module SpecialisedField
    ##
    # ValueToInteger
    module ValueToInteger
      def value=(value)
        @value = value.to_i if value.present?
      end
    end
  end
end
