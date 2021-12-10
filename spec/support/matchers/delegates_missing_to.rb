RSpec::Matchers.define :delegate_missing_methods_to do |target_name|
  match do |source|
    random_method_name = SecureRandom.uuid
    target = double(random_method_name => "Yay!")
    allow(source).to receive(target_name).and_return(target)

    result = source.public_send(random_method_name)

    expect(target).to have_received(random_method_name)
    expect(result).to eq "Yay!"
  end
end
