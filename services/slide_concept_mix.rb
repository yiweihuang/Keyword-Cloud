require 'base64'

class SlideConceptMix
  def self.call(slide:, concept:)
    arr = concept[0].map do |wordlist|
      word = wordlist.split("\n")
      word
    end
    first, *rest = *arr
    concept_arr = first.zip(*rest).flatten.compact
    concept_arr = concept_arr.join(",")
    `python3 helpers/slide_concept.py "#{slide}" "#{concept_arr}"`
  end
end
