require File.expand_path("../../spec_helper", __FILE__)

module Heroku
  describe Indentable do
    before do
      @dummy = Class.new do
        include Indentable
      end.new

      @output = ""
      @dummy.stub(:display) do |str, *args|
        @output += str
        @output += "\n" if args.count < 1 || args.first
      end
    end

    it "indents output" do
      @dummy.display_indented("i0 #0")
      @dummy.indent(1) do
        @dummy.display_indented("i1 #0")
        @dummy.indent(3) do
          @dummy.display_indented("i4 #0")
          @dummy.indent(7) do
            @dummy.display_indented("i11 #0")
          end
          @dummy.display_indented("i4 #1")
        end
        @dummy.display_indented("i1 #1")
      end
      @dummy.display_indented("i0 #1")

      @output.should == <<-eos
i0 #0
 i1 #0
    i4 #0
           i11 #0
    i4 #1
 i1 #1
i0 #1
      eos
    end
  end
end
