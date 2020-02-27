# frozen_string_literal: true

# This helper contains the default values to report failures in plates from the Report Fail UI
#
module ReportFailsHelper
  FAILURE_KEYS = %w[
    sample_integrity
    quantification
    lab_error
  ].freeze
  def report_fail_failure_options
    FAILURE_KEYS.each_with_object({}) do |val, obj|
      obj[I18n.t("report_fails.#{val}")] = val
    end
  end

  def report_fail_selected_option
    FAILURE_KEYS.first
  end

  def report_fail_disabled_options
    []
  end
end
