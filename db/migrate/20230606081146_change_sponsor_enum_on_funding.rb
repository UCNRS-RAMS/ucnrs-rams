class ChangeSponsorEnumOnFunding < ActiveRecord::Migration[6.1]
  def up
    execute("ALTER TABLE fundings MODIFY COLUMN sponsor ENUM('National Science Foundation (NSF)','National Institute of Health (NIH)','U.S. Geological Survey (USGS)','U.S. Forest Service (USFS)','U.S. Department of Agriculture (USDA)','California Department of Fish and Wildlife','Other')")
  end

  def down
    execute("ALTER TABLE fundings MODIFY COLUMN sponsor ENUM('National Science Foundation (NSF)','National Institute of Health (NIH)','U.S. Geological Survey (USGS)','U.S. Forest Service (USFS),U.S. Department of Agriculture (USDA)','California Department of Fish and Wildlife','Other')")
  end
end
