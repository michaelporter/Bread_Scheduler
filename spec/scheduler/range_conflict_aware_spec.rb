require 'spec_helper'

class TestClass
  include RangeConflictAware
end

describe RangeConflictAware do
  before :each do
    @test_class = TestClass.new
  end

  describe "methods" do
    describe "#range_conflict?" do
      it "should provide the #range_conflict? method" do
        @test_class.should respond_to :range_conflict?
      end

      it "should return true if the range covers the time" do
        t = Time.now
        range = Range.new(t, t+ 100)
        time = t + 50
        @test_class.range_conflict?(range, time).should be_true
      end

      it "should return false if the range does not cover the time" do
        t = Time.now
        range = Range.new(t, t+ 100)
        time = t + 500
        @test_class.range_conflict?(range, time).should be_false
      end
    end

    describe "#range_conflict_both_ends?" do
      it "should provide the #range_conflict_both_ends? method" do
        @test_class.should respond_to :range_conflict_both_ends?
      end

      it "should return true if the first range covers the start and end of the second range" do
        first_range = Range.new(0, 100)
        second_range = Range.new(5, 20)

        @test_class.range_conflict_both_ends?(first_range, second_range).should be_true
      end

      it "should return false if the first range covers only the start or end of the second range" do
        first_range = Range.new(0, 100)
        second_range = Range.new(5, 200)

        @test_class.range_conflict_both_ends?(first_range, second_range).should be_false
      end
    end

    describe "#range_conflict_either_end?" do
      it "should provide the #range_conflict_either_end? method" do
        @test_class.should respond_to :range_conflict_either_end?
      end

      it "should return true if the first range covers either the start or the end of the second range" do
        first_range = Range.new(0, 100)
        second_range = Range.new(5, 200)

        @test_class.range_conflict_either_end?(first_range, second_range).should be_true
      end

      it "should return false if the first range covers neither the start nor end of the second range" do
        first_range = Range.new(0, 100)
        second_range = Range.new(500, 700)

        @test_class.range_conflict_either_end?(first_range, second_range).should be_false
      end
    end

    describe "#no_conflict?" do
      it "should provide the #no_conflict? method" do
        @test_class.should respond_to :no_conflict?
      end

      it "should return true if there is no conflict" do
        range1 = Range.new(0, 5)
        range2 = Range.new(6, 10)
        @test_class.should_receive(:range_conflict_either_end?).and_return(false)
        @test_class.no_conflict?(range1, range2).should be_true
      end

      it "should return false if there is a conflict" do
        range1 = Range.new(0, 7)
        range2 = Range.new(6, 10)

        @test_class.should_receive(:range_conflict_either_end?).and_return(true)
        @test_class.no_conflict?(range1, range2).should be_false
      end
    end
  end
end
