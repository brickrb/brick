require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe "A Brick::Specification loaded from a brickspec" do
    before do
      fixture('banana-lib') # ensure the archive is unpacked
      @spec = Specification.from_brickspec(fixture('banana-lib/BananaLib.brickspec'))
    end

    it "returns the path to the brickspec" do
      @spec.defined_in_file.should == fixture('banana-lib/BananaLib.brickspec')
    end

    it "returns the brick's name" do
      @spec.name.should == 'BananaLib'
    end

    it "returns the brick's version" do
      @spec.version.should == Version.new('0.0.1')
    end

    it "returns a list of authors and their email addresses" do
      @spec.authors.should == {
        'Banana Corp' => nil,
        'Monkey Boy' => 'monkey@banana-corp.local'
      }
    end

    it "returns the brick's homepage" do
      @spec.homepage.should == 'http://banana-corp.local/banana-lib.html'
    end

    it "returns the brick's summary" do
      @spec.summary.should == 'Chunky bananas!'
    end

    it "returns the brick's description" do
      @spec.description.should == 'Full of chunky bananas.'
    end

    #it "returns the brick's source" do
    #  @spec.read(:source).should == {
    #    :git => 'http://banana-corp.local/banana-lib.git',
    #    :tag => 'v1.0'
    #  }
    #end

    #it "returns the brick's source files" do
    #  @spec.read(:source_files).should == [
    #    Pathname.new('Classes/*.{h,m}'),
    #    Pathname.new('Vendor')
    #  ]
    #end

    #it "returns the brick's dependencies" do
    #  expected = Dependency.new('monkey', '~> 1.0.1', '< 1.0.9')
    #  @spec.read(:dependencies).should == [expected]
    #  @spec.dependency_by_name('monkey').should == expected
    #end

    it "returns that it's equal to another specification if the name and version are equal" do
      @spec = Specification.new { |s| s.name = 'BananaLib'; s.version = '1.0' }
      @spec.should.not == Specification.new { |s| s.name = 'OrangeLib'; s.version = '1.0' }
      @spec.should.not == Specification.new { |s| s.name = 'BananaLib'; s.version = '1.1' }
      @spec.should.not == Specification.new
    end
  end
end