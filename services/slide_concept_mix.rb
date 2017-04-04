require 'base64'

class SlideConceptMix
  def self.call(slide:, concept:)
    arr = concept[0].map do |wordlist|
      if wordlist.include? "\r\n"
        word = wordlist.split("\r\n")
        word
      elsif wordlist.include? "\n"
        word = wordlist.split("\n")
        word
      else
        [wordlist]
      end
    end
    first, *rest = *arr
    concept_arr = first.zip(*rest).flatten.compact
    concept_arr = concept_arr.join(",")
    `python3 helpers/slide_concept.py "#{slide}" "#{concept_arr}"`
  end
end
