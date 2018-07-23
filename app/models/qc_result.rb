# frozen_string_literal: true

# QcResult
class QcResult < ApplicationRecord
  include Api::Messages::QcResultIO::Extensions

  belongs_to :asset, required: true
  belongs_to :qc_assay, required: false

  after_save :update_asset
  after_commit :broadcast_qc_result, on: [:create, :update]

  validates :key, :value, :units, presence: true

  scope :last_qc_result_for, ->(key) { where(key: key).order(id: :desc).limit(1) }

  def unit_value
    # Don't cache to avoid the need to worry about cache invalidation
    Unit.new(value, unit)
  end

  def unit_value=(unit_value)
    self.value = unit_value.scalar
    self.units = unit_value.units
  end

  private

  def update_asset
    asset.update_from_qc(self)
  end

  def broadcast_qc_result
    Messenger.new(target: self, template: 'QcResultIO', root: 'qc_result').broadcast
  end
end
