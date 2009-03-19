namespace :juggernaut do
  desc "Reinstall the Juggernaut js and swf files"
  task :reinstall do
    load "#{File.dirname(__FILE__)}/../install.rb"
  end
end

namespace :juggernaut do
  desc 'Compile the juggernaut flash file'
  task :compile_flash do
    `mtasc -version 8 -header 1:1:1 -main -swf media/juggernaut.swf media/juggernaut.as`
  end
end
