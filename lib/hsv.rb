class HSV
  attr_accessor :h, :s, :v
  def initialize(h,s,v)
    @h, @s, @v = h, s, v
  end

  def to_a
    [h, s, v]
  end
end

class HSVRange
  attr_accessor :from, :to
  def initialize(from, to)
    @from, @to = from, to
  end

  def to_a
    [from, to].map(&:to_a)
  end

  def to_cv_scalars
    to_a.map { |(h,s,v)| CvScalar.new h, s, v }
  end
end
