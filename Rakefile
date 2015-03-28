task :default do
  puts "Hello from the Rakefile!"
end

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