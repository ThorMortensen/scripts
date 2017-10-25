#   Auther  : thm
#   Date    : 25-October-2017
#   File    : autogit_add.rb
#   Project : scripts


require_relative 'rubyHelpers.rb'


NEW_PATH_GET_GIT_CMD = "git rev-parse --show-toplevel"

$homePath = `echo $HOME`
$homePath["\n"] = ""
scriptFolderPath = File.dirname(__FILE__)
scriptConfFilePath = "#{scriptFolderPath}/script.conf"

def exitPoint
  puts "The party is over. Exerting...".bold
  exit()
end


def createGitRepo

  puts "Add remote repo?".bg_blue.black
  print "~> "
  remote = gets.chomp
  unless remote.empty?
    remote = "#{remote}".bold
    remote = "git remote add origin #{remote}"
    puts "Remote repo is correct?".bg_blue.black
    puts "#{remote}".bg_green.black
    puts "[Y/n]"
    if gets()['n']
      exitPoint()
    end
  end
  puts "Making new git repo"

  `git init && git add . && git commit -m "initial commit"`

  exitPoint()

end


def checkForGitRepo

  gitBasePath = `#{NEW_PATH_GET_GIT_CMD}`

  if gitBasePath == ""
    puts "No git repo found.".red
    puts "Make one now? [Y/n]".bg_brown.black
    if gets()['n']
      exitPoint()
    end
    gitBasePath = createGitRepo()
  end
  return gitBasePath.gsub!($homePath, "~")
end


newRepoPath = checkForGitRepo

text = File.read(scriptConfFilePath)


# puts "The file is:".red
# puts
# puts text

unless text[newRepoPath, 1] # Note: str[regexp, capture] → new_str or nil
  puts "Repo already added, all is good :-)".cyan
  exit(1)
end

oldAutoCommitPath = text.scan(/AUTO_COMMIT_PATHS=.*/).last
newAutoCommitPath = "#{oldAutoCommitPath}:#{newRepoPath}"

puts "old -> #{oldAutoCommitPath}"
puts "new -> #{newAutoCommitPath}"

# new_contents = text.gsub(/search_regexp/, "replacement string")

# To merely print the contents of the file, use:
# puts new_contents

# To write changes to the file, use:
# File.open(file_name, "w") {|file| file.puts new_contents }
