require 'base64'

class SlideTfidf
  def self.call(arr:, signal:)
    gram_tfidf = Hash.new
    signal.map do |x|
      line = x.split("\n\n")
      line.map do |y|
        content = y.split("\t")
        docfreq = 0
        arr.map do |z|
          z.map do |str|
            if str.include? content[0]
              docfreq += 1
            end
          end
        end
        len = arr.length + signal.length - 1
        idf = Math.log(len/docfreq,2)
        gram_tfidf.merge!({content[0] => content[1]*idf})
      end
    end
    word_tfidf = Hash.new
    old = gram_tfidf
    old.map do |old_k, old_v|
      gram_tfidf.map do |k, v|
        if(v == old_v)
          if k.include? old_k
            old_k = k
          elsif old_k.include? k
            next
          else
            old_k, old_v = k, v
          end
        else
          old_k, old_v = k, v
          word_tfidf.merge!({old_k => old_v})
        end
      end
    end
    `python3 helpers/tfidf.py "#{word_tfidf}"`
  end
end
