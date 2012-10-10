class Question < ActiveRecord::Base
  attr_accessor :to_delete
  attr_accessible :updated_by,:to_delete,:options_attributes,:question, :allowed_time, :created_by, :complexity_id,:category_id, :type_id,:answer
   validates :question, :allowed_time,:presence =>true
   validates_numericality_of :allowed_time, :only_integer => true , :in => 21..30
   validates_inclusion_of :allowed_time, :in => 10..200, :message => "can only be between 10 and 200."
   belongs_to :category
   belongs_to :complexity
   belongs_to :type
   has_many :answers ,:dependent => :destroy
   has_many :options  ,:dependent => :destroy
   has_and_belongs_to_many :exams
   accepts_nested_attributes_for :options, :allow_destroy => true,:reject_if => proc { |attributes| attributes['option'].blank? }

   accepts_nested_attributes_for :answers







   def self.filtered ids,search
     if ids!=nil

       if search==""
         srch=Question.all(:order => 'created_at DESC')
       else
         search.gsub('+',' ')
          srch=nil
       end


       typ=com=cat=srch=by=range=Question.all(:order => 'created_at DESC')
       typ= Question.where("type_id = ?",ids[:type_id])             if ids[:type_id]!=""
       com= Question.where("complexity_id = ?",ids[:complexity_id]) if ids[:complexity_id]!=""
       cat= Question.where("category_id = ?",ids[:category_id])     if ids[:category_id]!=""
       by= Question.where("created_by = ?",ids[:by])     if ids[:by]!=""
       range= Question.where(:created_at => (ids[:from].to_date)..(ids[:to].to_date))     if ids["from"]!="" && ids["to"]!=""
       srch= Question.where("question like ?","%#{search}%")        if search!=""
       qst=typ&com&cat&srch&by&range
     else
      qst=Question.all(:order => 'created_at DESC')
     end
   end

end
