class AI
  def initialize
    @client = HuggingFace::InferenceApi.new(api_token: ENV['HUGGING_FACE_API_TOKEN'])
  end
  def ask q, *c
    x = @client.question_answering( question: q, context: [c].flatten.join(" ") )
    puts %[[Z4][ai][ask] #{x}]
    return x['answer']
  end
  def generate i
    @client.text_generation(input: i)[0]['generated_text']
  end
  def summary i
    @client.summarization(input: i)
  end
  def embed *a
    @client.embedding(input: [a].flatten )
  end
  def ponder q, *c
    hh = Hash.new { |h,k| h[k] = ask(q,File.read("#{k}.txt").gsub("\r",'').split("\n"),c); }
    h, o = {},[]
    Dir['books/*'].each { |e| k = e.gsub('.txt','').gsub('~','').gsub('#',''); h[k] = hh[k] }
    h.each_pair { |k,v|
      x = [:says, :thinks, 'wrote about', 'supported', 'wanted', 'sought'].sample;
      o << %[#{k.gsub('books/','')} #{x} #{v}];
    }
    h[:bot] = ask(q,c,o.shuffle);
    o.shuffle;
    x = [:simply, :finally, 'And finally', :especially, 'And especially', 'Most importantly'].sample
    o << %[#{x}, #{h[:bot]}]
    return o.join('. ').strip
  end
end

module Z4
  @@AI = AI.new
  def self.ai
    @@AI
  end
end
