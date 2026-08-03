class ProjectSummaryFlow
  def initialize(page)
    @page = page
  end

  def visit_show_page(project)
    page.visit("/projects/#{project.id}")
  end

  def on_project_show_page?
    page.has_css?("body.projects.projects-show")
  end

  def on_home_page?
    page.has_css?("body.home.home-index")
  end

  def has_project_status?(status)
    page.within("header .subheader") { page.has_content?(status) }
  end

  def has_submitted_date?(request_type:, submitted_at:)
    page.within("header .subheader") do
      page.has_content?("#{request_type}: #{submitted_at}")
    end
  end

  def has_summary_row?(label:, value:)
    summary_row(label)&.all("td")&.last&.text == value
  end

  def has_method_statement?(statement)
    page.has_css?(".project-methods li", text: statement)
  end

  def has_no_method_statement?(statement)
    page.has_no_css?(".project-methods li", text: statement)
  end

  def has_method_detail?(label:, value:)
    detail = page.all(".project-methods-detail").find do |method_detail|
      method_detail.find("span").text == label
    end

    detail&.has_css?("p", text: value)
  end

  def has_no_files?
    page.within(".project-files") { page.has_css?("td.empty", text: "No Files") }
  end

  def has_team_member?(name:, institution:, project_role:)
    has_row_with_cells?("tr.team-membership", [name, institution, project_role])
  end

  def has_no_team_member?(name)
    page.has_no_css?("tr.team-membership", text: name)
  end

  def has_funding?(title:, funding_agency:, award_amount:)
    has_row_with_cells?("tr.funding", [title, funding_agency, award_amount])
  end

  def has_no_fundings?
    page.within(".project-funding") { page.has_css?("td.empty", text: "No Funding") }
  end

  def has_permit?(authority:, statement:)
    page.within("#permit-summary-list .#{authority}_permits") do
      page.has_css?("h3", text: "#{authority} Permits") &&
        page.has_css?("li", text: statement)
    end
  end

  def has_no_permit?(statement)
    page.has_no_css?("#permit-summary-list li", text: statement)
  end

  def has_approved_permits?(text)
    page.within(".project-permit header") { page.has_content?(text) }
  end

  def has_reserve_answer?(reserve_name:, question:, answer:)
    reserve_answers_for(reserve_name).any? do |question_answer|
      question_answer.find("p.question").text == question &&
        question_answer.find("p.answer").text == answer
    end
  end

  def has_no_reserve_answer?(question)
    page.has_no_css?("#reserve_question-summary-list p.question", text: question)
  end

  def has_visit?(status:, date_range:, reserve_name:, visitors_and_amenities:)
    has_row_with_cells?(
      "#project-visit-requests tr.visit",
      [status, date_range, reserve_name, visitors_and_amenities],
    )
  end

  def has_visits_count?(count)
    page.has_css?("#project-visit-requests tr.visit", count: count)
  end

  def has_section_heading?(heading)
    page.has_css?("h2.main-header", text: heading)
  end

  def has_navigation_link?(text:, href:)
    page.has_link?(text, href: href)
  end

  def has_completed_sidebar?
    page.within(".sidebar") do
      page.has_css?("h2.main-header", text: "Congratulations on successfully creating your project") &&
        page.has_css?("ul.next-steps-list li")
    end
  end

  def has_incomplete_sidebar?
    page.within(".sidebar") do
      page.has_css?("h2.main-header", text: "Incomplete") &&
        page.has_link?("Edit Project")
    end
  end

  def has_contact_reserve_form?
    page.has_css?("#project-contact-reserve select.reserve-list")
  end

  def contact_reserve(reserve_name)
    page.within("#project-contact-reserve") do
      page.select(reserve_name, from: "email_manager_reserve_id")
      page.click_button("Submit")
    end
  end

  def has_flash_message?(message)
    page.has_css?(".flash", text: message)
  end

  private

  attr_reader :page

  def has_row_with_cells?(row_selector, cells)
    page.all(row_selector).any? do |row|
      row.all("td").map(&:text).take(cells.size) == cells
    end
  end

  def summary_row(label)
    page.all(".project-summary-table tr").find do |row|
      row.all("td").first.text == label
    end
  end

  def reserve_answers_for(reserve_name)
    reserve_group = page.all("#reserve_question-summary-list > div").find do |group|
      group.find("h3").text == reserve_name
    end

    reserve_group ? reserve_group.all(".question-answer") : []
  end
end
