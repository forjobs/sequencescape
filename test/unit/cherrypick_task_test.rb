require "test_helper"

class CherrypickTaskTest < ActiveSupport::TestCase
  # Pads the cherrypicked view of a plate with empty wells
  def pad_expected_plate_with_empty_wells(template, plate)
    plate.concat([CherrypickTask::EMPTY_WELL] * (template.size - plate.size))
  end

  context CherrypickTask do
    setup do
      @pipeline = Pipeline.find_by_name('Cherrypick') or raise StandardError, "Cannot find cherrypick pipeline"
      @task = CherrypickTask.new(:workflow => @pipeline.workflow)

      @barcode = 10000
    end 

    context '#map_wells_to_plates' do
      setup do
        @robot    = mock('robot')
        @batch    = mock('batch')

        @template = PlateTemplate.create!(:size => 96)
      end

      should 'error when the robot has no beds' do
        @robot.stubs(:max_beds).returns(0)

        assert_raises(StandardError) do
          @task.map_wells_to_plates(nil, nil, @robot, nil, nil)
        end
      end

      context '' do
        setup do
          @robot.stubs(:max_beds).returns(2)
        end

        context 'with limited number of source beds' do
          setup do
            plates = (1..3).map { |_| PlatePurpose.find(2).create!(:barcode => (@barcode += 1)) }
            @requests = plates.map { |p| Factory(:request, :asset => p.wells.first) }
            @expected = @requests.map do |request|
              [request.id, request.asset.plate.barcode, request.asset.map.description]
            end.in_groups_of(2).map do |group|
              group.compact!
              pad_expected_plate_with_empty_wells(@template, group)
            end
          end

          should 'not generate a second plate if beds are not full' do
            plates, source_plates = @task.map_wells_to_plates(@requests.slice(0, 2), @template, @robot, @batch, nil)
            assert_equal(@expected.slice(0, 1), plates, "Incorrect plate pick")
            assert_equal(Set.new(@requests.slice(0, 2).map(&:asset).map(&:plate).map(&:barcode)), source_plates, "Incorrect source plates used")
          end

          should 'generate new plate when all source beds are full' do
            plates, source_plates = @task.map_wells_to_plates(@requests, @template, @robot, @batch, nil)
            assert_equal(@expected, plates, "Incorrect plate pick")
            assert_equal(Set.new(@requests.map(&:asset).map(&:plate).map(&:barcode)), source_plates, "Incorrect source plates used")
          end
        end

        context 'with partial plate' do
          setup do
            plate     = PlatePurpose.find(2).create!(:barcode => (@barcode += 1))
            @requests = plate.wells.map { |w| Factory(:request, :asset => w) }
          end

          context 'with left 6 columns filled' do
            setup do
              @partial = PlatePurpose.find(2).create!(:barcode => (@barcode += 1)).tap do |partial|
                partial.wells -= partial.wells.in_column_major_order.slice(48, 48)
              end
              @expected_partial = [CherrypickTask::TEMPLATE_EMPTY_WELL] * @partial.wells.size
            end

            should 'represent partial plate correctly when there are no picks made' do
              expected = [ @expected_partial ]
              pad_expected_plate_with_empty_wells(@template, expected.first)

              plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)
              assert_equal(expected, plates, "Incorrect partial plate representation")
            end

            should 'generate a second plate when the partial is full' do
              plates, source_plates = @task.map_wells_to_plates(@requests, @template, @robot, @batch, @partial)
              assert_equal(2, plates.size, "Incorrect number of plates")
            end

            should 'fill plate with empty wells' do
              expected, requests = [@expected_partial], @requests.slice(0, 5)
              expected.first.concat(requests.map { |request| [request.id, request.asset.plate.barcode, request.asset.map.description] })
              pad_expected_plate_with_empty_wells(@template, expected.first)

              plates, source_plates = @task.map_wells_to_plates(requests, @template, @robot, @batch, @partial)
              assert_equal(expected, plates, "Incorrect plate pick")
            end

            should 'error if the pick is horizontal'
          end

          context 'with top 4 rows filled' do
            setup do
              @partial = PlatePurpose.find(2).create!(:barcode => (@barcode += 1)).tap do |partial|
                partial.wells -= partial.wells.in_row_major_order.slice(48, 48)
              end
            end

            should 'represent partial plate correctly when there are no picks made' do
              expected = (1..12).inject([]) do |plate, row|
                plate.tap do
                  plate.concat([CherrypickTask::TEMPLATE_EMPTY_WELL] * 4)
                  plate.concat([CherrypickTask::EMPTY_WELL] * 4)
                end
              end

              plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)
              assert_equal([expected], plates, "Incorrect partial plate representation")
            end

            should 'error if the pick is vertical'
          end

          context 'with left & right columns filled' do
            setup do
              @partial = PlatePurpose.find(2).create!(:barcode => (@barcode += 1)).tap do |partial|
                partial.wells -= partial.wells.in_column_major_order.slice(8, 80)
              end
            end

            should 'represent partial plate correctly when there are no picks made' do
              expected = []
              expected.concat([CherrypickTask::TEMPLATE_EMPTY_WELL] * 8) # Column 1
              expected.concat([CherrypickTask::EMPTY_WELL] * 80)         # Columns 2-11
              expected.concat([CherrypickTask::TEMPLATE_EMPTY_WELL] * 8) # Column 12

              plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)
              assert_equal([expected], plates, "Incorrect partial plate representation")
            end

            should 'not pick on top of any wells that are already present' do
              plate    = PlatePurpose.find(2).create!(:barcode => (@barcode += 1))
              requests = plate.wells.in_column_major_order.map { |w| Factory(:request, :asset => w) }

              expected_partial = []
              expected_partial.concat([CherrypickTask::TEMPLATE_EMPTY_WELL] * 8) # Column 1
              expected_partial.concat(requests.slice(0, 80).map { |request| [request.id, request.asset.plate.barcode, request.asset.map.description] })
              expected_partial.concat([CherrypickTask::TEMPLATE_EMPTY_WELL] * 8) # Column 12

              expected_second = requests.slice(80, 16).map { |request| [request.id, request.asset.plate.barcode, request.asset.map.description] }
              pad_expected_plate_with_empty_wells(@template, expected_second)

              plates, source_plates = @task.map_wells_to_plates(requests, @template, @robot, @batch, @partial)
              assert_equal([expected_partial, expected_second], plates, "Incorrect partial plate representation")
            end
          end
        end

        context 'where the template defines a control well' do
          setup do
            @partial = PlatePurpose.find(2).create!(:barcode => (@barcode += 1)).tap do |partial|
              partial.wells -= partial.wells.in_column_major_order.slice(24, 72)
            end
            @expected_partial = [CherrypickTask::TEMPLATE_EMPTY_WELL] * @partial.wells.size
            pad_expected_plate_with_empty_wells(@template, @expected_partial)

            @template.set_control_well(1)

            @control_plate = ControlPlate.create!(:barcode => (@barcode += 1)).tap do |plate|
              Map.where_plate_size(96).where_description(ControlPlate::ILLUMINA_CONTROL_WELL_LOCATIONS).all.each do |location|
                well = plate.wells.create!(:map => location)
                well.aliquots.create!(:sample => Factory(:sample))
              end
            end

            @batch = @pipeline.batches.create!
          end

          should 'add a control well to the plate in the bottom corner' do
            plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)

            picked = plates.first
            control_well_details = picked.pop
            assert_equal(@expected_partial.slice(0, @expected_partial.size-1), picked, "Incorrect pick of plate up to control well")

            # To check the control well we have to account for the well being picked being random
            assert_equal(@batch.requests.first.id, control_well_details[0], "Incorrect control request ID")
            assert_equal(@control_plate.barcode.to_s, control_well_details[1], "Incorrect control plate barcode")
            assert(ControlPlate::ILLUMINA_CONTROL_WELL_LOCATIONS.include?(control_well_details[2]), "Incorrect control well location")
          end

          should 'not add a control well to the plate if it already has one' do
            Factory(:request, :asset => @control_plate.wells.first, :target_asset => @partial.wells.first)

            plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)
            assert_equal([@expected_partial], plates, "Incorrect plate pick without control well")
          end

          should 'add a control request to the batch' do
            plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)
            assert_equal(1, @batch.requests(true).size)
          end

          should 'add the control plate to the source list' do
            plates, source_plates = @task.map_wells_to_plates([], @template, @robot, @batch, @partial)
            assert(source_plates.include?(ControlPlate.first.barcode), "control plate not part of sources")
          end
        end
      end
    end
  end
end
