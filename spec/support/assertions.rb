class Assertions
  def initialize(subject)
    @subject = subject
  end

  def self.all(subject, &block)
    block.call(Assertions.new(subject))
    true
  end

  def has_field?(field, **args)
    result = @subject.has_field?(field, **args)
    if !result
      raise RuntimeError.new("Assertion failed finding #{field} with #{args}")
    end
  end
end
