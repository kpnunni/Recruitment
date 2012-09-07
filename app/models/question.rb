class Question < ActiveRecord::Base
  attr_accessible :options_attributes,:question, :allowed_time, :created_by, :complexity_id,:category_id, :type_id,:answer
   validates :question, :allowed_time,:presence =>true
   validates_numericality_of :allowed_time, :only_integer => true , :in => 21..30
   validates_inclusion_of :allowed_time, :in => 10..60, :message => "can only be between 10 and 60."
   belongs_to :category
   belongs_to :complexity
   belongs_to :type
   has_many :answers ,:dependent => :destroy
   has_many :options  ,:dependent => :destroy
   has_and_belongs_to_many :exams
   accepts_nested_attributes_for :options, :allow_destroy => true
   accepts_nested_attributes_for :answers







   def self.filtered ids,search
     if ids!=nil

       if search==""
         srch=Question.all(:order => 'created_at DESC')
       else
         search.gsub('+',' ')
          srch=nil
       end


       typ=com=cat=srch=Question.all(:order => 'created_at DESC')
       typ= Question.where("type_id = ?",ids[:type_id])             if ids[:type_id]!=""
       com= Question.where("complexity_id = ?",ids[:complexity_id]) if ids[:complexity_id]!=""
       cat= Question.where("category_id = ?",ids[:category_id])     if ids[:category_id]!=""
       srch= Question.where("question like ?","%#{search}%")        if search!=""
       qst=typ&com&cat&srch
     else
      qst=Question.all(:order => 'created_at DESC')
     end
   end

end
