# Development Setup
#-----------------------------------------------------------------------------#

  namespace :dev do
    task :setup do

      # Check if Bacon is installed
      begin
        gem "bacon"
      rescue Gem::LoadError
        exec "gem install bacon"
      end

      # Make sure tmp directory exists
      if Dir.exists?('tmp')
      else
        exec 'mkdir tmp'
      end

      puts "Your development setup is ready to go!"
    end
  end

# Testing
#-----------------------------------------------------------------------------#
  namespace :spec do
    def specs(dir)
      FileList["spec/#{dir}_spec.rb"].shuffle.join(' ')
    end

    #--------------------------------------#

    task :all do
      if Dir.exists?('tmp')
        exec 'bacon -a'
      else
        exec 'mkdir tmp && bacon -a'
      end
    end

    #--------------------------------------#

    task :command do
      if Dir.exists?('tmp')
        exec "bacon #{specs('command/**/*')}"
      else
        exec "mkdir tmp && bacon #{specs('command/**/*')}"
      end
    end

    #--------------------------------------#

    task :unit do
      if Dir.exists?('tmp')
        exec "bacon #{specs('unit/**/*')}"
      else
        exec "mkdir tmp && bacon #{specs('unit/**/*')}"
      end
    end
  end

# Vendored Libraries
#-----------------------------------------------------------------------------#
  def clean_files(files, regex, replacement = '')
    files.each do |file|
      contents = File.read(file)
      contents.gsub!(regex, replacement)
      File.open(file, 'w') { |f| f << contents }
    end
  end

  namespace :claide do
    task :namespace do
      files = Dir.glob('lib/brick/vendor/claide*/**/*.rb')
      clean_files(files, 'CLAide', 'Brick::CLAide')
      clean_files(files, /require (["'])claide/, 'require \1brick/vendor/claide/lib/claide')
    end

    task :clean do
      files = Dir.glob('lib/brick/vendor/claide*/*', File::FNM_DOTMATCH).reject { |f| %(. .. lib).include? f.split('/').last }
      rm_r files
    end

    task :update do
      Dir.chdir 'lib/brick/vendor' do
        rm_rf 'claide'
        sh "curl -L https://github.com/CocoaPods/claide/archive/0.8.1.tar.gz | tar -xz"
        sh "mv CLAide-* claide"
      end
      Rake::Task['claide:namespace'].invoke
      Rake::Task['claide:clean'].invoke
    end
  end

  namespace :molinillo do
    task :namespace do
      files = Dir.glob('lib/brick/vendor/molinillo*/**/*.rb')
      clean_files(files, 'Molinillo', 'Brick::Molinillo')
      clean_files(files, /require (["'])molinillo/, 'require \1brick/vendor/molinillo/lib/molinillo')
    end

    task :clean do
      files = Dir.glob('lib/brick/vendor/molinillo*/*', File::FNM_DOTMATCH).reject { |f| %(. .. lib).include? f.split('/').last }
      rm_r files
    end

    task :update do
      Dir.chdir 'lib/brick/vendor' do
        rm_rf 'molinillo'
        sh "curl -L https://github.com/CocoaPods/molinillo/archive/0.2.3.tar.gz | tar -xz"
        sh "mv Molinillo-* molinillo"
      end
      Rake::Task['molinillo:namespace'].invoke
      Rake::Task['molinillo:clean'].invoke
    end
  end
