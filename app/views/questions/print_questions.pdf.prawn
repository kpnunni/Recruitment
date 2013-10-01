prawn_document() do |pdf|
  @questions.each_with_index do |question,i|
    pdf.text "Q#{i+1}."+question.question
    question.options.each_with_index do |op,i|
      pdf.text (('A'..'Z').to_a[i]).to_s+")"+op.option
    end
    pdf.text "_"
  end
  pdf.text "Answer key:"
    @questions.each_with_index do |question,i|
        pdf.text "Q#{i+1}"
            question.options.each_with_index do |op,i|
              pdf.text (('A'..'Z').to_a[i]) if op.is_right
            end
    end
end