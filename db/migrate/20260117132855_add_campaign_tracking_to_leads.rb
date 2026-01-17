class AddCampaignTrackingToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :campaign_source, :string
    add_column :leads, :campaign_id, :string
    add_column :leads, :campaign_url, :string

    add_index :leads, :campaign_source
    add_index :leads, [:campaign_source, :campaign_id]
  end
end
