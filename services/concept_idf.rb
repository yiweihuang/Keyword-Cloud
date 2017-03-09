class ConceptIdf
    def self.call(concept:)
      arr = concept[0].map do |wordlist|
          word = wordlist.split("\n")
          word
      end
      first, *rest = *arr
      concept_arr = first.zip(*rest).flatten.compact
      concept_arr = concept_arr.join(',')
      `python3 helpers/concept.py "#{concept_arr}"`
    end
end
