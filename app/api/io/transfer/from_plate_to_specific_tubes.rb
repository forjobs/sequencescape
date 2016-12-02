# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2012,2015 Genome Research Ltd.

class ::Io::Transfer::FromPlateToSpecificTubes < ::Core::Io::Base
  set_model_for_input(::Transfer::FromPlateToSpecificTubes)
  set_json_root(:transfer)
  set_eager_loading { |model| model.include_source.include_transfers }

  define_attribute_and_json_mapping("
            user <=> user
          source <=> source
         targets <=  targets
       transfers  => transfers
  ")
end
