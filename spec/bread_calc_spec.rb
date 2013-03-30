require 'lib/bread_calc.rb'

describe BreadCalc do 
	before(:each) do
		date = Time.local(2012, 2, 12)
		@breadcalc = BreadCalc.new(date, 12, 0, nil)
	end

	it "should make a new BreadCalc instance" do
		@breadcalc.should be_instance_of(BreadCalc)
  end

  it "should reject unreasonable times" do
    expect {@breadcalc = BreadCalc.new("gfh")}.to raise_error
  end

  describe "counting methods" do
    before(:each) do
      3.times do
        bread = Bread.new("bread", rand(100), 30, 2, 0, false)
        @breadcalc.bread_list << bread
      end 
    end 

    it "should have a count_loaves method" do
      @breadcalc.should respond_to :count_loaves
    end 

    it "should calculate the total number of loaves" do
      @breadcalc.count_loaves
      @breadcalc.loaf_count.should eq(6)
    end

    it "should have a dot_count method" do
      @breadcalc.should respond_to :dot_count
    end

    it "should add a dot for each 35 minute diff between two times" do
      t1 = Time.now
      t2 = Time.now + 60 * 35 * 2

      dashes = @breadcalc.dot_count(t1,t2) 
      dashes.split("\n").length.should eq(2)
    end

    it "should have a make_hash method" do
      @breadcalc.should respond_to :make_hash
    end

    it "should create a hash for the given time, using each bread" do 
      result = @breadcalc.make_hash({}, :rise)
      result.keys.length.should eq(@breadcalc.bread_list.length)
    end 

  end
end
