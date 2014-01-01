module RecruitmentTestsHelper
  def find_extra(recruitment_test)
    @candidate = recruitment_test.candidate
    questions = @candidate.schedule.exam.question_ids
    @answers =  @candidate.answers.where("question_id in (?)",questions)
    @extra_answers = @candidate.answers.where("question_id not in (?)",questions)
  end
end