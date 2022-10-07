class VisitReserveAnswer < ApplicationRecord
  belongs_to :visit
  belongs_to :reserve_question

  validates :text_answer, presence: true, if: :required_text_question

  def self.replace_all(visit_reserve_answers)
    if !visit_reserve_answers.blank?
      rows = visit_reserve_answers.map do |answer|
        ActiveRecord::Base.sanitize_sql([
          "(?,?,?,?,?,?)",
          answer.visit_id,
          answer.reserve_question_id,
          answer.text_answer,
          answer.boolean_answer,
          Time.current,
          Time.current
        ])
      end

      connection.execute(<<~end_sql)
      INSERT INTO #{table_name} (
        #{arel_table[:visit_id].name},
        #{arel_table[:reserve_question_id].name},
        #{arel_table[:text_answer].name},
        #{arel_table[:boolean_answer].name},
        #{arel_table[:created_at].name},
        #{arel_table[:updated_at].name})
      VALUES
        #{rows.join(",\n  ")}
      AS new
      ON DUPLICATE KEY UPDATE
        text_answer = new.text_answer,
        boolean_answer = new.boolean_answer,
        updated_at = new.updated_at
      end_sql
    end
  end

  def required_text_question
    reserve_question.answer_required && reserve_question.question_type == "text"
  end
end
