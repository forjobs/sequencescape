class Io::AssetRack < Io::Asset
  set_model_for_input(::AssetRack)
  set_json_root(:asset_rack)
  set_eager_loading { |model| model.include_asset_rack_purpose }

  define_attribute_and_json_mapping(%Q{
                                            size <=> size
                                    purpose.name  => purpose.name

                                           state  => state
                                            role  => label.prefix
                                    purpose.name  => label.text
                                   location.name  => location
                                        priority  => priority

                               source_plate.uuid  => stock_plate.uuid
                            source_plate.barcode  => stock_plate.barcode.number
              source_plate.barcode_prefix.prefix  => stock_plate.barcode.prefix
            source_plate.two_dimensional_barcode  => stock_plate.barcode.two_dimensional
                      source_plate.ean13_barcode  => stock_plate.barcode.ean13
                       source_plate.barcode_type  => stock_plate.barcode.type

                                         barcode  => barcode.number
                           barcode_prefix.prefix  => barcode.prefix
                         two_dimensional_barcode  => barcode.two_dimensional
                                   ean13_barcode  => barcode.ean13
                                    barcode_type  => barcode.type
  })
end