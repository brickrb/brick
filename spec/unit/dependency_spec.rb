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

      describe '#from_string' do
        it 'creates a dependency from a string' do
          d =  Dependency.from_string('BananaLib (1.0)')
          d.name.should == 'BananaLib'
          d.requirement.should =~ Version.new('1.0')
        end

        it 'creates a dependency from a string with multiple version requirements' do
          d =  Dependency.from_string('FontAwesomeIconFactory (< 2.0, >= 1.0.1)')
          d.name.should == 'FontAwesomeIconFactory'
          d.requirement.should == Requirement.new('< 2.0', '>= 1.0.1')
        end

        it 'handles strings with no requirements' do
          d =  Dependency.from_string('rails')
          d.name.should == 'rails'
          d.requirement.should.be.none?
        end
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

      #--------------------------------------#

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
  end
end