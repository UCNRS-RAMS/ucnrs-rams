def mock_permit_answer(permit, answer)
  permit.define_singleton_method(:answer) do
    answer
  end
end

def mock_reserve_answer(question, text: "Yes", boolean: true)
  question.define_singleton_method(:boolean_answer) do
    boolean ? 1 : 0
  end
  question.define_singleton_method(:text_answer) do
    text
  end
end
