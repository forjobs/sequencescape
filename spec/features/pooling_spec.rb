require 'rails_helper'

feature 'Pooling', js: true do
  let(:user) { create :user, email: 'login@example.com' }
  let!(:empty_lb_tube) { create :empty_library_tube, barcode: 1 }
  let!(:untagged_lb_tube1) { create :library_tube, barcode: 2 }
  let!(:untagged_lb_tube2) { create :library_tube, barcode: 3 }
  let!(:tagged_lb_tube1) { create :tagged_library_tube, barcode: 4 }
  let!(:tagged_lb_tube2) { create :tagged_library_tube, barcode: 5 }

  scenario 'user can pool from different tubes to stock and standard mx tubes' do
    login_user user
    visit root_path
    visit new_pooling_path
    expect(page).to have_content 'Scan tube'
    click_on 'Transfer'
    expect(page).to have_content 'Source assets were not scanned or were not found in sequencescape'
    fill_in('asset_scan', with: '1234567890123')
    within('.barcode_list') do
      expect(page).to have_content '1234567890123'
    end
    fill_in('asset_scan', with: (empty_lb_tube.ean13_barcode).to_s)
    fill_in('asset_scan', with: (untagged_lb_tube1.ean13_barcode).to_s)
    fill_in('asset_scan', with: (untagged_lb_tube2.ean13_barcode).to_s)
    click_on 'Transfer'
    expect(page).to have_content 'Source assets with barcode(s) 1234567890123 were not found in sequencescape'
    expect(page).to have_content "Source assets with barcode(s) #{empty_lb_tube.ean13_barcode} do not have any aliquots"
    expect(page).to have_content 'Tags combinations are not unique'
    first('a', text: 'Remove from list').click
    first('a', text: 'Remove from list').click
    first('a', text: 'Remove from list').click
    expect(page).to have_content 'Scanned: 1'
    fill_in('asset_scan', with: (tagged_lb_tube1.ean13_barcode).to_s)
    fill_in('asset_scan', with: (tagged_lb_tube2.ean13_barcode).to_s)
    check 'Create stock multiplexed tube'
    click_on 'Transfer'
    expect(page).to have_content 'Samples were transferred successfully'
  end
end
