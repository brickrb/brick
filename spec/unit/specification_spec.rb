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

    it "returns the brick's license" do
      @spec.license.should == 'MIT'
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

  describe "A Brick::Specification, in general," do
    before do
      @spec = Specification.new
    end

    def validate(&block)
      Proc.new(&block).should.raise(Informative)
    end

    it "raises if the specification does not contain the minimum required attributes" do
      exception = validate { @spec.validate! }
      exception.message =~ /name.+?version.+?summary.+?homepage.+?authors.+?license/
     end

    it "raises if the platform is unrecognized" do
      validate { @spec.validate! }.message.should.not.include 'platform'
      @spec.platform = :jruby
      validate { @spec.validate! }.message.should.not.include 'platform'
      @spec.platform = :ree
      validate { @spec.validate! }.message.should.not.include 'platform'
      @spec.platform = :windows
      validate { @spec.validate! }.message.should.include 'platform'
    end

    it "returns the platform that the static library should be build for" do
      @spec.should.be.any_platform
      @spec.platform = :jruby
      @spec.platform.should == :jruby
      @spec.should.not.be.any_platform
    end
  end
end