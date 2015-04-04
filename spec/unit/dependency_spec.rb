require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Dependency do
    describe 'In general' do
      it 'can be initialized with no requirements' do
        dependency = Dependency.new('bananas')
        dependency.name.should == 'bananas'
      end

      it 'can be initialized with multiple requirements' do
        dependency = Dependency.new('bananas', '> 1.0', '< 2.0')
        dependency.requirement.to_s.should == '< 2.0, > 1.0'
      end

      it 'can be initialized with a requirement on a pre-release version' do
        dependency = Dependency.new('bananas', '> 1.0-pre')
        dependency.requirement.to_s.should == '> 1.0-pre'
      end

      it 'can be initialized with an external source' do
        dep = Dependency.new('rails', :git => 'git://github.com/rails/rails')
        dep.should.be.external
      end

      it 'can be initialized with an empty external source and not be ' \
         'considered external' do
        dep = Dependency.new('rails', :git => nil)
        dep.should.not.be.external
      end

      it "knows if it's local" do
        dep = Dependency.new('rails', :path => '/tmp/rails')
        dep.should.be.local
      end

      it "says it's not local if nothing was passed in" do
        dep = Dependency.new('rails')
        dep.should.not.be.local
      end

      it 'keeps the backward compatibility with :local' do
        dep = Dependency.new('rails', :local => '/tmp/rails')
        dep.should.be.local
      end

      it 'raises if initialized with an external source and requirements are provided' do
        should.raise Informative do
          Dependency.new('rails', '1.0', :git => 'git://github.com/rails/rails')
        end
      end

      describe '#from_string' do
        it 'creates a dependency from a string' do
          d =  Dependency.from_string('BananaLib (1.0)')
          d.name.should == 'BananaLib'
          d.requirement.should =~ Version.new('1.0')
          d.external_source.should.be.nil
        end

        it 'creates a dependency from a string with multiple version requirements' do
          d =  Dependency.from_string('FontAwesomeIconFactory (< 2.0, >= 1.0.1)')
          d.name.should == 'FontAwesomeIconFactory'
          d.requirement.should == Requirement.new('< 2.0', '>= 1.0.1')
        end

        it "doesn't include external source when initialized from a string as incomplete and thus it should be provided by the client" do
          d = Dependency.from_string("BananaLib (from `www.example.com', tag `1.0')")
          d.name.should == 'BananaLib'
          d.requirement.should.be.none?
          d.external?.should.be.false
        end

        it 'handles strings with no requirements' do
          d =  Dependency.from_string('rails')
          d.name.should == 'rails'
          d.requirement.should.be.none?
        end
      end

      it 'includes the external sources in the string representation' do
        dependency = Dependency.new('rails', :hg => 'example.com')
        dependency.to_s.should == 'rails (from `example.com`)'
      end

      it 'raises if an invalid initialization flag is given' do
        should.raise ArgumentError do
          Dependency.new('rails', :foot)
        end
      end

      it 'can store a specific version which is used in place of the requirements' do
        dependency = Dependency.new('rails', '> 1.0')
        dependency.specific_version = Version.new('1.23')
        dependency.requirement.as_list.should == ['= 1.23']
      end

      #--------------------------------------#

      it 'preserves the external source on duplication' do
        dep = Dependency.new('bananas', :brickspec => 'bananas')
        dep.dup.external_source.should == { :brickspec => 'bananas' }
      end

      #--------------------------------------#

      it 'returns whether it is compatible with another dependency' do
        dep1 = Dependency.new('bananas', '>= 1.8')
        dep2 = Dependency.new('bananas', '1.9')
        dep1.compatible?(dep2).should.be.true
      end

      it 'is not compatible with another dependency with non satisfied version requirements' do
        dep1 = Dependency.new('bananas', '> 1.9')
        dep2 = Dependency.new('bananas', '1.9')
        dep1.compatible?(dep2).should.be.false
      end

      it 'is not compatible with another if the external sources differ' do
        dep1 = Dependency.new('bananas', :brickspec => 'bananas')
        dep2 = Dependency.new('bananas', '1.9')
        dep1.compatible?(dep2).should.be.false
      end

      #--------------------------------------#

      it 'is equal to another dependency if `external_source` is the same' do
        dep1 = Dependency.new('bananas', :git => 'GIT-URL')
        dep2 = Dependency.new('bananas')
        dep1.should.not == dep2
        dep3 = Dependency.new('bananas', :git => 'GIT-URL')
        dep1.should == dep3
      end

      it 'supports Array#uniq' do
        d_1 = Dependency.new('bananas')
        d_2 = Dependency.new('bananas')
        [d_1, d_2].uniq.should == [d_1]
      end

      #--------------------------------------#

      it 'is able to match against proper SemVer pre-release versions' do
        dep = Dependency.new('bananas', '< 2.0.0')
        should.not.raise do
          dep.match?('bananas', '2.0.0-rc1')
        end
      end

      #--------------------------------------#

      it 'merges with another dependency' do
        dep1 = Dependency.new('bananas', '>= 1.8')
        dep2 = Dependency.new('bananas', '1.9')
        dep1.merge(dep2).should == Dependency.new('bananas', '>= 1.8', '1.9')
      end

      it 'it preserves the external source while merging with another dependency' do
        dep1 = Dependency.new('bananas', '1.9')
        dep2 = Dependency.new('bananas', :brickspec => 'bananas')
        result = dep1.merge(dep2)
        result.should.be.external
        result.requirement.as_list.should == ['= 1.9']
      end

      it 'raises if there is an attempt to merge with a dependency with a different name' do
        should.raise ArgumentError do
          dep1 = Dependency.new('bananas', '>= 1.8')
          dep2 = Dependency.new('orange', '1.9')
          dep1.merge(dep2)
        end
      end

      #--------------------------------------#

      it 'matches a specification with the correct name' do
        dep = Dependency.new('bananas', '1.0')
        dep.match?('bananas', '1.0').should.be.true
        dep.match?('orange', '1.0').should.be.false
      end

      it 'matches any version if no requirements are provided' do
        dep = Dependency.new('bananas')
        dep.match?('bananas', '1.0').should.be.true
      end

      it 'matches a specification with the correct version if requirements are provided' do
        dep = Dependency.new('bananas', '> 0.5')
        dep.match?('bananas', '1.0').should.be.true
        dep.match?('bananas', '0.1').should.be.false
      end

      it 'matching supports the comparison with pre-release version' do
        dep = Dependency.new('bananas', '> 0.5')
        dep.match?('bananas', '1.0-rc1').should.be.true
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Private helpers' do
      before do
        @dep = Dependency.new('bananas', '1.9')
      end

      describe '#external_source_description' do
        it 'returns the description of git sources' do
          source = {
            :git => 'example.com/repo.git',
            :branch => 'master',
            :commit => 'SHA',
            :tag => '1.0.0',
          }
          description = @dep.send(:external_source_description, source)
          description.should == 'from `example.com/repo.git`, commit `SHA`, branch `master`, tag `1.0.0`'
        end

        it 'returns the description of other sources' do
          @dep.send(:external_source_description, :hg => 'example.com').should == 'from `example.com`'
          @dep.send(:external_source_description, :svn => 'example.com').should == 'from `example.com`'
          @dep.send(:external_source_description, :brickspec => 'example.com').should == 'from `example.com`'
          @dep.send(:external_source_description, :path => 'example.com').should == 'from `example.com`'
          @dep.send(:external_source_description, :local => 'example.com').should == 'from `example.com`'
          @dep.send(:external_source_description, :other => 'example.com').should.match /from.*example.com/
        end
      end
    end

    #-------------------------------------------------------------------------#
  end
end