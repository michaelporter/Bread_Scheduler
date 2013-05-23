require 'spec_helper'

describe Utility do
  describe Time do
    describe "classes where not included" do
      before :each do
        class TestClass
        end

        @test_class = TestClass.new
      end

      it "should not have the #to_seconds method" do
        @test_class.should_not respond_to :to_seconds
      end
    end

    describe "classes where is included" do
      before :each do
        class TestClass
          include Utility::Time
        end

        @test_class = TestClass.new
      end

      it "should provide a #to_seconds method" do
        @test_class.should respond_to :to_seconds
      end

      it "should accepts minutes as an argument and convert to seconds" do
        input = 10
        @test_class.to_seconds(10).should equal 60 * 10
      end
    end
  end
end

