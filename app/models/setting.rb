class Setting < ActiveRecord::Base
  attr_accessor :categories_attributes
  attr_accessible :auto_result,:categories_attributes

  def set_cutoff(percentages)
     Category.all.each do |cat|
        cat.update_attribute(:cutoff,percentages[cat.id.to_s].to_i)
      end
  end
end
