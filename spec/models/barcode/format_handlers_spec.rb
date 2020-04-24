# frozen_string_literal: true

require 'rails_helper'

describe Barcode::FormatHandlers do
  # Set up the expectations for a valid barcode
  # @example
  #  it_has_a_valid_barcode 'DN12345S', number: 12345, prefix: 'DN', suffix: 'S'
  def self.it_has_a_valid_barcode(barcode, number: nil, prefix: nil, suffix: nil)
    context "with the barcode #{barcode}" do
      subject(:format_handler) { described_class.new(barcode) }

      it 'parses the barcode correctly', :aggregate_failures do
        expect(format_handler).to be_valid
        expect(format_handler).to have_attributes(number: number, barcode_prefix: prefix, suffix: suffix)
      end
    end
  end

  # Set up the expectations for an invalid barcode
  # @example
  #  it_has_an_invalid_barcode 'INVALID'
  def self.it_has_an_invalid_barcode(barcode)
    context "with the barcode #{barcode}" do
      subject(:format_handler) { described_class.new(barcode) }

      it { is_expected.not_to be_valid }
    end
  end

  # These groups aren't empty, we just use a helper to generate the tests
  # rubocop:disable RSpec/EmptyExampleGroup
  describe Barcode::FormatHandlers::UkBiocentreV1 do
    it_has_a_valid_barcode '1234567890NBC', prefix: nil, number: 1234567890, suffix: 'NBC'
    it_has_an_invalid_barcode '123456789ANBC'
    it_has_an_invalid_barcode 'INVALID'
    it_has_an_invalid_barcode '123456789NCB'
    it_has_an_invalid_barcode '123456789MBC'
    it_has_an_invalid_barcode '1234567890ANBC'
    it_has_an_invalid_barcode 'RNA_1234'
    it_has_an_invalid_barcode ' 1234567890NBC'
    it_has_an_invalid_barcode " 1234567890NBC\na"
  end

  describe Barcode::FormatHandlers::UkBiocentreV2 do
    it_has_a_valid_barcode '123456789ANBC', prefix: nil, number: 123456789, suffix: 'ANBC'
    it_has_an_invalid_barcode 'INVALID'
    it_has_an_invalid_barcode '123456789NCB'
    it_has_an_invalid_barcode '123456789MBC'
    it_has_an_invalid_barcode '1234567890ANCB'
    it_has_an_invalid_barcode 'RNA_1234'
    it_has_an_invalid_barcode ' 1234567890NCB'
    it_has_an_invalid_barcode " 1234567890NCB\na"
  end

  describe Barcode::FormatHandlers::AlderlyParkV1 do
    it_has_a_valid_barcode 'RNA_1234', prefix: 'RNA', number: 1234, suffix: nil
    it_has_an_invalid_barcode 'RNA_12345'
    it_has_an_invalid_barcode 'DNA_1234'
    it_has_an_invalid_barcode '1234567890NCB'
    it_has_an_invalid_barcode 'RNA_1234 '
    it_has_an_invalid_barcode "RNA_1234\n1"
  end

  describe Barcode::FormatHandlers::AlderlyParkV2 do
    it_has_a_valid_barcode 'AP-rna-12345678', prefix: 'AP-rna', number: 12345678
    it_has_a_valid_barcode 'AP-rna-00110029', prefix: 'AP-rna', number: 110029
    it_has_a_valid_barcode 'AP-kfr-00090016', prefix: 'AP-kfr', number: 90016
    it_has_an_invalid_barcode 'SD-rna-1234567'
    it_has_an_invalid_barcode 'AP-rna-123456789'
    it_has_an_invalid_barcode 'AP-cdna-1234567'
    it_has_an_invalid_barcode 'AP-rna-1234567 '
    it_has_an_invalid_barcode "AP-rna-1234567\n1"
  end
  # rubocop:enable RSpec/EmptyExampleGroup
end
