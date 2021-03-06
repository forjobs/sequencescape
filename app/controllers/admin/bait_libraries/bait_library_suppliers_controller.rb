class Admin::BaitLibraries::BaitLibrarySuppliersController < ApplicationController
  before_action :admin_login_required
  before_action :discover_bait_library_supplier, only: %i[edit update destroy]

  def new
    @bait_library_supplier = BaitLibrary::Supplier.new
  end

  def edit
  end

  def create
    @bait_library_supplier = BaitLibrary::Supplier.new(bait_library_supplier_params)

    respond_to do |format|
      if @bait_library_supplier.save
        flash[:notice] = 'Supplier was successfully created.'
        format.html { redirect_to(admin_bait_libraries_path) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @bait_library_supplier.update(bait_library_supplier_params)
        flash[:notice] = 'Supplier was successfully updated.'
        format.html { redirect_to(admin_bait_libraries_path) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    if @bait_library_supplier.bait_libraries.visible.count > 0
      respond_to do |format|
        flash[:error] = "Can not delete '#{@bait_library_supplier.name}', supplier is in use by #{@bait_library_supplier.bait_libraries.visible.count} libraries.<br/>"
        format.html { redirect_to(admin_bait_libraries_path) }
      end
    else
      respond_to do |format|
        if @bait_library_supplier.hide
          flash[:notice] = 'Supplier was successfully deleted.'
        end
        format.html { redirect_to(admin_bait_libraries_path) }
      end
    end
  end

  private

  def bait_library_supplier_params
    params.require(:bait_library_supplier).permit(:name)
  end

  def discover_bait_library_supplier
    @bait_library_supplier = BaitLibrary::Supplier.find(params[:id])
  end
end
