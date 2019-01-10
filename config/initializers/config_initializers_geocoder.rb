# Rewritten bearing function that supports SQL Server:
#  - ATAN2 function renamed ATN2
#  - Use `%` operator instead of `MOD()` function
# This seems like it would be very reasonable to apply more dynamically.
#
# Original source: https://github.com/alexreisner/geocoder/blob/317832ca2b7ec234fca6039184686d921bac925d/lib/geocoder/sql.rb#L57
#
module Geocoder
  module Sql
    ##
    #
    # Fairly accurate bearing calculation. Takes a latitude, longitude,
    # and an options hash which must include a :bearing value
    # (:linear or :spherical).
    #
    # For use with a database that supports MOD() and trigonometric functions
    # SIN(), COS(), ASIN(), ATAN2().
    #
    # Based on:
    # http://www.beginningspatial.com/calculating_bearing_one_point_another
    #
    def self.full_bearing(latitude, longitude, lat_attr, lon_attr, options = {})
      degrees_per_radian = Geocoder::Calculations::DEGREES_PER_RADIAN
      case options[:bearing] || Geocoder.config.distances
      when :linear
        "CAST(" +
          "(ATN2( " +
            "((#{lon_attr} - #{longitude.to_f}) / #{degrees_per_radian}), " +
            "((#{lat_attr} - #{latitude.to_f}) / #{degrees_per_radian})" +
          ") * #{degrees_per_radian}) + 360 " +
        "AS decimal) % 360"
      when :spherical
        "CAST(" +
          "(ATN2( " +
            "SIN( (#{lon_attr} - #{longitude.to_f}) / #{degrees_per_radian} ) * " +
            "COS( (#{lat_attr}) / #{degrees_per_radian} ), (" +
              "COS( (#{latitude.to_f}) / #{degrees_per_radian} ) * SIN( (#{lat_attr}) / #{degrees_per_radian})" +
            ") - (" +
              "SIN( (#{latitude.to_f}) / #{degrees_per_radian}) * COS((#{lat_attr}) / #{degrees_per_radian}) * " +
              "COS( (#{lon_attr} - #{longitude.to_f}) / #{degrees_per_radian})" +
            ")" +
          ") * #{degrees_per_radian}) + 360 " +
        "AS decimal) % 360"
      end
    end
  end
end
