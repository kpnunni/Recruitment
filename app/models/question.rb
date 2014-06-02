class Question < ActiveRecord::Base
  attr_accessor :to_delete
  attr_accessible :question_image, :updated_by,:to_delete,:options_attributes,:question, :allowed_time, :created_by, :complexity_id,:category_id, :type_id,:answer,:question_image_file_name,:question_image_content_type,:question_image_file_size
  validates :allowed_time,:presence =>true
  #validates_numericality_of :allowed_time, :only_integer => true , :in => 21..30
  validates_inclusion_of :allowed_time, :in => 10..200, :message => "can only be between 10 and 200."
  validate :options_status
  belongs_to :category
  belongs_to :complexity
  belongs_to :type
  has_many :answers ,:dependent => :destroy
  has_many :options  ,:dependent => :destroy
  has_and_belongs_to_many :exams
  has_attached_file :question_image
  accepts_nested_attributes_for :options, :allow_destroy => true,:reject_if => proc { |attributes| attributes['option'].blank? }
  accepts_nested_attributes_for :answers
  scope :additional, where("category_id in (?)", Category.where(category: "Additional").map(&:id))
  def options_status
    if self.question.empty? && self.question_image_file_name.nil?
      self.errors[:base]<<"Question or image should not be blank"
    end
    if self.options.empty?
      self.errors[:base]<<"Options can't be empty"
    end
  end
  def self.filtered search
    @questions = Question.order('created_at DESC').includes([:options,:category,:complexity,:type,:exams]).all
    @questions.select! { |q| q.type_id == search[:type_id].to_i               } if search.try(:[],:type_id).present?
    @questions.select! { |q| q.complexity_id == search[:complexity_id].to_i   } if search.try(:[],:complexity_id).present?
    @questions.select! { |q| q.category_id == search[:category_id].to_i       } if search.try(:[],:category_id).present?
    @questions.select! { |q| q.created_by == search[:by]                      } if search.try(:[],:by).present?
    @questions.select! { |q| q.question.downcase.include?(search[:text].downcase)               } if search.try(:[],:text).present?
    @questions.select! { |q| q.created_at.between?(search[:from],search[:to]) } if search.try(:[],:from).present? && search.try(:[],:to).present?
    @questions
  end
  #def to_param
  #  "#{id} #{question.first(50)}".parameterize
  #end
  def next_question(exam_id,additional)
    if additional
      question_ids = Question.additional.order(:id).map(&:id)
    else
      @exam = Exam.where(id: exam_id).first
      question_ids = @exam.questions.order(:category_id,:id).map(&:id)
    end
    next_q = question_ids[question_ids.index(self.id)+1]
  end

  def previous_question(exam_id,additional)
    if additional
      question_ids = Question.additional.order(:id).map(&:id)
    else
      @exam = Exam.where(id: exam_id).first
      question_ids = @exam.questions.order(:category_id,:id).map(&:id)
    end
    prev_q = question_ids[question_ids.index(self.id)-1]
    prev_q == question_ids[-1] ? nil : prev_q
  end

end
