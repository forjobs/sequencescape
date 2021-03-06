# frozen_string_literal: true

module Api
  module V2
    # Provides a JSON API representation of TubeRack
    # See: http://jsonapi-resources.com/ for JSONAPI::Resource documentation
    class TubeRackResource < BaseResource
      # Constants...

      # immutable # uncomment to make the resource immutable

      # model_name / model_hint if required

      default_includes :uuid_object

      # Associations:

      # Attributes
      attribute :uuid, readonly: true
      attribute :labware_barcode, readonly: true

      # Filters

      # Custom methods
      # These shouldn't be used for business logic, and a more about
      # I/O and isolating implementation details.

      # Class method overrides

      # Custom methods
      # These shouldn't be used for business logic, and are more about
      # I/O and isolating implementation details.
      def labware_barcode
        {
          'ean13_barcode' => _model.ean13_barcode,
          'machine_barcode' => _model.machine_barcode,
          'human_barcode' => _model.human_barcode
        }
      end
    end
  end
end
