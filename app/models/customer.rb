class Customer < ApplicationRecord
  self.table_name = "dart_cust_lat_long"
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  def address
    [address1, city, zip, state].compact.join(', ')
  end

  def address_changed?
    address1_changed? || city_changed? || state_changed? || zip_changed?
  end

end
