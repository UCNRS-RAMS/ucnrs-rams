class VisitReserveAnswer < ApplicationRecord
  belongs_to :visit
  belongs_to :reserve_question

  validates :text_answer, presence: true, if: :required_text_answer
  validates :boolean_answer, inclusion: { in: [true, false] }, if: :required_boolean_answer

  def self.replace_all(visit_reserve_answers)
    if visit_reserve_answers.present?
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

  def self.with_reserve_name_column
    select("visit_reserve_answers.*, reserves.name AS reserve_name")
      .left_joins(reserve_question: :reserve)
  end

  def self.with_affirmative_answer
    joins(:reserve_question)
      .where("(reserve_questions.question_type = 'Boolean' AND boolean_answer IS TRUE) OR (reserve_questions.question_type = 'Text' AND text_answer IS NOT NULL)")
  end

  def self.for_visit(visit)
    if visit.present?
      where(visit_id: visit)
    else
      all
    end
  end

  private

  def required_text_answer
    reserve_question&.answer_required && reserve_question.question_type == "text"
  end

  def required_boolean_answer
    reserve_question&.answer_required && reserve_question.question_type == "boolean"
  end
end
