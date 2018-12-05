# frozen_string_literal: true

FactoryBot.define do
  factory :sample_manifest do
    study
    supplier
    asset_type { 'plate' }
    count { 1 }

    factory :sample_manifest_with_samples do
      samples { create_list(:sample_with_well, 5) }
    end

    factory :sample_manifest_with_empty_plate do
      transient do
        well_count { 96 }
        plate_count { 1 }
      end
      labware { create_list(:plate_with_empty_wells, plate_count, well_count: well_count) }

      factory :sample_manifest_with_empty_plate_and_manifest_assets do
        after(:build) do |sample_manifest|
          sample_manifest.labware.each do |plate|
            plate.wells.each do |well|
              create(:sample_manifest_asset,
                     sanger_sample_id: generate(:sanger_sample_id),
                     asset: well,
                     sample_manifest: sample_manifest)
            end
          end
        end
      end
    end

    factory :tube_sample_manifest do
      asset_type { '1dtube' }

      factory :tube_sample_manifest_with_tubes_and_manifest_assets do
        transient do
          tube_count { 1 }
        end

        labware { create_list :empty_sample_tube, tube_count }

        after(:build) do |sample_manifest|
          sample_manifest.labware.each do |tube|
            create(:sample_manifest_asset,
                   sanger_sample_id: generate(:sanger_sample_id),
                   asset: tube,
                   sample_manifest: sample_manifest)
          end
        end
      end

      factory :tube_sample_manifest_with_samples do
        samples { create_list(:sample_tube, 5).map(&:samples).flatten }

        factory :tube_sample_manifest_with_tubes do
          count { 5 }

          after(:build) do |sample_manifest|
            sample_manifest.barcodes = sample_manifest.labware.map(&:human_barcode)
          end
        end
      end
    end

    factory :sample_manifest_with_samples_for_plates do
      transient do
        num_plates { 2 }
        num_samples_per_plate { 2 }
      end

      samples { FactoryBot.create_list(:plate_with_untagged_wells, num_plates, sample_count: num_samples_per_plate).map(&:contained_samples).flatten }

      # set sanger_sample_id on samples
      after(:build) do |sample_manifest|
        sample_manifest.samples.each do |smpl|
          smpl.sanger_sample_id = "test_#{smpl.id}"
          smpl.save
        end
      end
    end
  end

  factory :supplier do
    name { 'Test supplier' }
  end
end
