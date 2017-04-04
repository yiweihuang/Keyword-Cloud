class ConvertJson
  def self.call(cid:, chid:)
    `python3 helpers/hash_to_json.py "#{cid}" "#{chid}"`
  end
end
