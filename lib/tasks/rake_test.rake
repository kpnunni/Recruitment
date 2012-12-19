
  desc "rake test"
  task :testing => :environment   do
    Category.all.each do |cat|
        cat.cutoff  = 60
        cat.save
      end
    end
