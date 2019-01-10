class CustomersController < ApplicationController
  def load
    if params[:loadnmbr].present?
      @customers = Customer.where("latitude is ?", nil).take(params[:loadnmbr])
      @customers.each do |c|
        c.save
        # take out the sleep when we go pro on Google
        sleep 0.25
      end
    end
  end

  def fix
    @customers = Customer.all
    @customers.each do |c|
      c.latitude = c.latitude.round(7)
      c.longitude = c.longitude.round(7)
      c.save
    end
  end

  def index
    @customers = Customer.all
  end

  def show
    @customer = Customer.find(params[:id])
    @cust_latlong = "http://maps.googleapis.com/maps/api/staticmap?size=900x600&zoom=16&markers=color:red|" + @customer.latitude.to_s + ',' + @customer.longitude.to_s + '&key=AIzaSyAftTXSB1QPVg_bQmTlghf6q0kasIU40TY'
    $return = true
  end

  def map
    if $return
      # we have been here before
      params[:type] = $type
      params[:radius] = $radius.to_s
      params[:zip] = $zip
      $return = false
    end

    @market = true
    if params[:type].present? && params[:type] == 'Restaurant'
      @market = false
    end

    if params[:zip].present?
      # User has entered a zip
      location = params[:zip]
      location = location.upcase
    else
      # the code below should work if real IP addresses, need to poke another hold in the fire wall
      # location = request.location
      # location = []
      # location[0] = request.location.latitude
      # location[1] = request.location.longitude
      # location = '600 GREEN LANE, UNION, NJ, 07083'
      location = 'Statue of Liberty, NY'
    end
    if params[:radius].present?
      if params[:radius].to_i > 20
        radius = 20
      else
        if params[:radius].to_i < 1
          radius = 1
        else
          radius = params[:radius].to_i
        end
      end
    else
      radius = 20
    end
    customers = []
    cust_near = []
    cust_near = Customer.near(location, radius)
    if !cust_near
      # seems to cock up the first time (sometimes) so try again
      cust_near = Customer.near(location, radius)
    end
    # restrict customers based on type selection
    if !params[:type].present?
      type = 'Market'
    else
      type = params[:type]
    end

    cust_near.each do |c|
      if (type == 'Market' && c.cust_group != 'FS') || (c.cust_group == 'FS' && type == 'Restaurant')
        customers.push(c)
      end
    end
    # only want the first 10
    if customers.length < 10
      i = customers.length
    else
      i = 10
    end

    @customers = customers[0...i]
    # get the location lat and long
    loc_array = Geocoder.coordinates(location)
    # find distance between location and each customer
    @distances = []
    i = 0
    @customers.each do |c|
      @distances[i] = Geocoder::Calculations.distance_between(loc_array, [c.latitude, c.longitude])
      i += 1
    end
    # use the distance of the customer farthest from the location to set zoom
    case @distances.last
    when 0..0.25
      zoom = 16
    when 0.25..0.5
      zoom = 15
    when 0.5..1
      zoom = 14
    when 1..2
      zoom = 13
    when 2..6
      zoom = 12
    when 6..12
      zoom = 11
    else
      zoom = 10
    end

    i = 0
    @ab = ['A','B','C','D','E','F','G','H','I','J']
    @latlong = "http://maps.googleapis.com/maps/api/staticmap?size=700x467&zoom=" + zoom.to_s
    if !@customers.empty?
      @customers.each do |c|
        @latlong = @latlong + '&markers=color:red|label:' + @ab[i] + '|' + c.latitude.to_s + ',' + c.longitude.to_s
        i += 1
      end
    end
    @latlong = @latlong + '&key=AIzaSyAftTXSB1QPVg_bQmTlghf6q0kasIU40TY'
    $zip = location
    $type = type
    $radius = radius
  end
end
