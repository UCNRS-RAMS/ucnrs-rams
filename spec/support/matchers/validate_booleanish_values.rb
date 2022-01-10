require "rspec/expectations"

RSpec::Matchers.define :validate_booleanish_values do |attribute|
  match do |record|
    (@true_values || [true, 1, "on", "true"]).each do |value|
      record.send("#{attribute}=", value)
      record.validate
      expect(record.send(attribute)).to eq true
      expect(record.errors[attribute]).to be_empty
    end

    (@false_values || [false, 0, "off", "false"]).each do |value|
      record.send("#{attribute}=", value)
      record.validate
      expect(record.send(attribute)).to eq false
      expect(record.errors[attribute]).to be_empty
    end

    record.send("#{attribute}=", nil)
    record.validate
    if @allow_nil
      expect(record.errors[attribute]).to be_empty
    else
      expect(record.errors[attribute]).to_not be_empty
    end
  end

  chain :true_values do |*values|
    @true_values = values
  end

  chain :false_values do |*values|
    @false_values = values
  end

  chain :allow_nil do |allow_nil|
    @allow_nil = allow_nil
  end
end
