#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2015 Genome Research Ltd.

class QcReportsController < ApplicationController

  before_filter :login_required
  before_filter :check_required, :only => :create

  def index
    # Build a conditions hash of acceptable parameters, ignoring those that are blank

    @qc_reports = QcReport.for_report_page(conditions).paginate(:page => params[:page],:include => [:study,:product])
    @qc_report = QcReport.new(:exclude_existing => true,:study_id => params[:study_id])
    @studies = Study.alphabetical.for_listing.all.map {|s| [s.name,s.id] }
    @states = QcReport.available_states.map {|s| [s.humanize,s] }

    @all_products = Product.alphabetical.all.map {|product| [product.display_name,product.id]}
    @active_products = Product.with_stock_report.active.alphabetical.all.map {|product| [product.display_name,product.id]}
  end

  def create

    study = Study.find_by_id(params[:qc_report][:study_id])
    exclude_existing = params[:qc_report][:exclude_existing] == "1"

    qc_report = QcReport.new(:study=>study, :product_criteria => @product.stock_criteria, :exclude_existing => exclude_existing)

    if qc_report.save
      flash[:notice] = 'Your report has been requested and will be presented on this page when complete.'
      redirect_to qc_report
    else # We failed to save
      error_messages = qc_report.errors.full_messages.join('; ')
      flash[:error] = "Failed to create report: #{error_messages}"
      redirect_to :back
    end

  end

  def show
    qc_report = QcReport.find(params[:id])
    queue_count = qc_report.queued? ? Delayed::Job.count : 0
    @report_presenter = Presenters::QcReportPresenter.new(qc_report,queue_count)

    respond_to do |format|
      format.html
      # TODO: We should either stream directly, or create a tmp file.
      format.csv  do
        render :text => proc { |response, output| @report_presenter.to_csv(output); debugger; output.flush; }, :content_type => "text/csv"
      end if qc_report.available?
    end
  end

  private

  def check_required
    return fail('No report options were provided') unless params[:qc_report].present?
    return fail('You must select a product') if params[:qc_report][:product_id].nil?
    @product = Product.find_by_id(params[:qc_report][:product_id])
    return fail('Could not find product') if @product.nil?
    return fail("#{product.name} is inactive") if @product.deprecated?
    return fail("#{product.name} does not have any stock criteria set") if @product.stock_criteria.nil?
    true
  end

  def fail(message)
    redirect_to :back, :alert => message
    false
  end

  def conditions
    conds = {}
    conds[:study_id] = params[:study_id] if params[:study_id].present?
    conds[:product_criteria] = {:product_id => params[:product_id]} if params[:product_id].present?
    conds[:state] = params[:state] if params[:state].present?
    conds
  end


end
