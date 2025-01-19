class IncreaseReserveQuestionColumnLength < ActiveRecord::Migration[6.1]
  def change
    change_column(:reserve_questions, :description, :text)
    change_column(:reserve_questions, :url_1, :string, limit: 1000)
    change_column(:reserve_questions, :url_link_text_1, :text)
    change_column(:reserve_questions, :url_2, :string, limit: 1000)
    change_column(:reserve_questions, :url_link_text_2, :text)
    change_column(:reserve_questions, :url_3, :string, limit: 1000)
    change_column(:reserve_questions, :url_link_text_3, :text)
  end
end
