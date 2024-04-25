require 'ostruct'

class OpenStruct
  def self.openstruct_to_hash(object, hash = {})
    case object
    when OpenStruct then
      object.each_pair do |key, value|
      hash[key] = openstruct_to_hash(value)
      end
      hash
    when Array then
      object.map { |v| openstruct_to_hash(v) }
    else object
    end
  end

  def deep_to_h
    each_pair.map do |key, value|
      [
        key,
        case value
          when OpenStruct then value.deep_to_h
          when Array then value.map {|el| el === OpenStruct ? el.deep_to_h : el}
          else value
        end
      ]
    end.to_h
  end
end
