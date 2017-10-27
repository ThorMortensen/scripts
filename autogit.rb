#   Auther  : thm
#   Date    : 25-October-2017
#   File    : autogit.rb
#   Project : scripts


require_relative 'rubyHelpers.rb'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'


@homePath = `echo $HOME` #ARGV[0]
@homePath["\n"] = ""

SCRIPTS_FOLDER_PATH = File.dirname(__FILE__)

AUTO_COMMIT_PATHS = "AUTO_COMMIT_PATHS"
AUTO_ADD_PATHS = "AUTO_ADD_PATHS"


def exitPoint
  puts "Thank you for using one of Thor's QOF scripts. Exerting..".green
  exit()
end

# @param [string] repoName
# @param [string] githubUsername
# @param [string] githubToken
# @return [Net::Net::HTTP]
def makeGithubRepo(repoName, githubUsername, githubToken)
  uri = URI.parse('https://api.github.com/user/repos')
  request = Net::HTTP::Post.new(uri)
  request.basic_auth(githubUsername, githubToken)
  request.body = JSON.dump("name" => "#{repoName}")

  req_options = {use_ssl: uri.scheme == 'https'}

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  return response

end


def makeRemoteGitRepo

  begin

    userInfo = YAML.load_file("#{SCRIPTS_FOLDER_PATH}/GITHUB_SETTINGS.yml")

  rescue SystemCallError
    puts 'No "GITHUB_SETTINGS.yml" file found'.red
    puts 'make one now? [Y/n]'.bg_magenta.black
    if gets()[/[^n]/]
      puts "Please enter your Github #{'Username'.bold} ".bg_magenta.black
      print '~> '
      userInputEmail = gets
      puts "Please enter your Github access #{'Token'.bold} ".bg_magenta.black
      print '~> '
      userInputToken = gets

      File.write("#{SCRIPTS_FOLDER_PATH}/GITHUB_SETTINGS_2.yml",
                 "GITHUB_ACCESS_TOKEN: #{userInputToken}\nGITHUB_USERNAME: #{userInputEmail}")
    end
  end

  githubUsername = userInputEmail || userInfo["GITHUB_USERNAME"]
  githubToken = userInputToken || userInfo["GITHUB_ACCESS_TOKEN"]

  newRemoteRepoName = Dir.pwd
  newRemoteRepoName = newRemoteRepoName.split("/").last

  puts "Remote repo will get this name: ".bg_magenta.black
  puts
  puts "  #{newRemoteRepoName}".bold
  puts
  puts "Enter another name OR leave empty".bg_magenta.black
  print "~> "
  userInput = gets

  userInput["\n"] = ""

  newRemoteRepoName = userInput unless userInput.empty?

  puts "Creating remote repo".cyan

  remoteRepoFailed = true
  abortRepoCration = false

  while remoteRepoFailed

    response = makeGithubRepo(newRemoteRepoName, githubUsername, githubToken)
    respBody = JSON.parse(response.body)

    if response.code == "422"
      puts "Remote #{respBody["message"]}".red
      puts "Remote repo name \"#{newRemoteRepoName.bold}\" may already be in use.".bg_magenta.black
      puts "Try another name OR leave empty to skip remote repo creation".bg_magenta.black
      print "~> "
      newRemoteRepoName = gets
      newRemoteRepoName["\n"] = ""
      if newRemoteRepoName.empty?
        puts "Aborting remote repo creation".cyan
        abortRepoCration = true
        break
      end
      next
    end

    remoteRepoFailed = false

  end

  unless abortRepoCration
    puts "Remote repo was successfully created. It can be found here: ".green
    puts
    puts "  #{respBody["html_url"]}"
    puts
  end

  return respBody["ssh_url"]
end


def createGitRepo

  puts "Auto make remote repo? [Y/n]".bg_blue.black

  userSays = gets()

  if userSays[/^\n/]
    remote = makeRemoteGitRepo
  end

  if userSays['n'] or remote.nil? or remote.empty?

    puts "Add remote repo OR leave empty for local repo only".bg_blue.black
    print "~> "
    remote = gets.chomp
    unless remote.empty?
      remote = "#{remote}"
      puts
      puts "Remote repo is correct?".bg_blue.black
      puts
      puts "#{remote}".bold
      puts
      print "[Y/n] "
      if gets()['n']
        exitPoint()
      end
    end

  end

  puts "Creating new git repo:".cyan
  puts `git init && git add . && git commit -m "initial commit"`.gray

  unless remote.empty?
    puts "Linking repo to remote:".cyan
    puts `git remote add origin #{remote} && git push -u origin master`.gray
  end

  return Dir.pwd

end

def homeToTilde(path)
  return path.gsub(@homePath, "~")
end

def tildeToHome(path)
  return path.gsub("~", @homePath)
end

def checkForGitRepo

  gitBasePath = `git rev-parse --show-toplevel`

  if gitBasePath.empty?
    puts "No git repo found.".red
    puts "Make one now? [Y/n]".bg_brown.black
    if gets['n']
      exitPoint()
    end
    gitBasePath = createGitRepo()
  else
    gitBasePath["\n"] = ""
  end

  return homeToTilde(gitBasePath)

end

def getCurrentPaths
  autogitPathYaml = "#{SCRIPTS_FOLDER_PATH}/autogit_paths.yml"
  return YAML.load_file(autogitPathYaml)
end

def setNewPaths(newPaths)
  autogitPathYaml = "#{SCRIPTS_FOLDER_PATH}/autogit_paths.yml"
  File.open(autogitPathYaml, 'w') {|f| YAML.dump(newPaths, f)}
end

def autogit_add(pathToAdd)

  begin
    Dir.chdir pathToAdd unless pathToAdd.nil?
  rescue SystemCallError
    puts "Input path not valid".red
    exitPoint
  end

  paths = getCurrentPaths

  newAutogitPath = checkForGitRepo

  if paths[AUTO_COMMIT_PATHS].nil?
    paths[AUTO_COMMIT_PATHS] = [newAutogitPath]
  elsif paths[AUTO_COMMIT_PATHS].include? newAutogitPath
    puts "Path already added to autogit".red
    exitPoint
  else
    paths[AUTO_COMMIT_PATHS].push(newAutogitPath)
  end

  setNewPaths(paths)

  puts "Path \"#{newAutogitPath.bold}\" successfully added to autocommit ".green
  exitPoint

end

def autogit_remove(pathToAdd)


  pathToRemove = homeToTilde(pathToAdd || Dir.pwd)


  paths = getCurrentPaths

  if paths[AUTO_COMMIT_PATHS].nil?
    puts "Path \"#{pathToRemove.bold}\" is currently not in aoutogit".green
  elsif not paths[AUTO_COMMIT_PATHS].delete(pathToRemove)
    puts "Path \"#{pathToRemove.bold}\" is currently not in aoutogit".green
  else
    puts "Path \"#{pathToRemove.bold}\" successfully removed from autogit".green
  end

  setNewPaths(paths)
  exitPoint

end


def autogitCommitAndPush



  begin
    Dir.chdir pathToAdd unless pathToAdd.nil?
  rescue SystemCallError
    puts "Input path not valid".red
    exitPoint
  end

end


################################################
#               MAIN
################################################

runMode = ARGV[0]
pathArg = ARGV[1]
ARGV.clear


case runMode
  when 'add'
    autogit_add(pathArg)

  when 'remove'
    autogit_remove(pathArg)
  else
    puts "Not sported mode. Did you forget script arguments?"

end


# newRepoPath = checkForGitRepo
#
# text = File.read(scriptConfFilePath)
#
#
# # puts "The file is:".red
# # puts
# # puts text
#
# oldAutoCommitPath = text[/AUTO_COMMIT_PATHS=.*/]
#
# if oldAutoCommitPath[newRepoPath]
#   puts "This repo is already added in paths".red
#   exitPoint
# end
#
# newAutoCommitPath = "#{oldAutoCommitPath}:#{newRepoPath}"
#
# puts "old -> #{oldAutoCommitPath}"
# puts "new -> #{newAutoCommitPath}"


# new_contents = text.gsub(/search_regexp/, "replacement string")

# To merely print the contents of the file, use:
# puts new_contents

# To write changes to the file, use:
# File.open(file_name, "w") {|file| file.puts new_contents }


# {
#     "id": 1296269,
#     "owner": {
#         "login": "octocat",
#         "id": 1,
#         "avatar_url": "https://github.com/images/error/octocat_happy.gif",
#         "gravatar_id": "",
#         "url": "https://api.github.com/users/octocat",
#         "html_url": "https://github.com/octocat",
#         "followers_url": "https://api.github.com/users/octocat/followers",
#         "following_url": "https://api.github.com/users/octocat/following{/other_user}",
#         "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
#         "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
#         "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
#         "organizations_url": "https://api.github.com/users/octocat/orgs",
#         "repos_url": "https://api.github.com/users/octocat/repos",
#         "events_url": "https://api.github.com/users/octocat/events{/privacy}",
#         "received_events_url": "https://api.github.com/users/octocat/received_events",
#         "type": "User",
#         "site_admin": false
#     },
#     "name": "Hello-World",
#     "full_name": "octocat/Hello-World",
#     "description": "This your first repo!",
#     "private": false,
#     "fork": false,
#     "url": "https://api.github.com/repos/octocat/Hello-World",
#     "html_url": "https://github.com/octocat/Hello-World",
#     "archive_url": "http://api.github.com/repos/octocat/Hello-World/{archive_format}{/ref}",
#     "assignees_url": "http://api.github.com/repos/octocat/Hello-World/assignees{/user}",
#     "blobs_url": "http://api.github.com/repos/octocat/Hello-World/git/blobs{/sha}",
#     "branches_url": "http://api.github.com/repos/octocat/Hello-World/branches{/branch}",
#     "clone_url": "https://github.com/octocat/Hello-World.git",
#     "collaborators_url": "http://api.github.com/repos/octocat/Hello-World/collaborators{/collaborator}",
#     "comments_url": "http://api.github.com/repos/octocat/Hello-World/comments{/number}",
#     "commits_url": "http://api.github.com/repos/octocat/Hello-World/commits{/sha}",
#     "compare_url": "http://api.github.com/repos/octocat/Hello-World/compare/{base}...{head}",
#     "contents_url": "http://api.github.com/repos/octocat/Hello-World/contents/{+path}",
#     "contributors_url": "http://api.github.com/repos/octocat/Hello-World/contributors",
#     "deployments_url": "http://api.github.com/repos/octocat/Hello-World/deployments",
#     "downloads_url": "http://api.github.com/repos/octocat/Hello-World/downloads",
#     "events_url": "http://api.github.com/repos/octocat/Hello-World/events",
#     "forks_url": "http://api.github.com/repos/octocat/Hello-World/forks",
#     "git_commits_url": "http://api.github.com/repos/octocat/Hello-World/git/commits{/sha}",
#     "git_refs_url": "http://api.github.com/repos/octocat/Hello-World/git/refs{/sha}",
#     "git_tags_url": "http://api.github.com/repos/octocat/Hello-World/git/tags{/sha}",
#     "git_url": "git:github.com/octocat/Hello-World.git",
#     "hooks_url": "http://api.github.com/repos/octocat/Hello-World/hooks",
#     "issue_comment_url": "http://api.github.com/repos/octocat/Hello-World/issues/comments{/number}",
#     "issue_events_url": "http://api.github.com/repos/octocat/Hello-World/issues/events{/number}",
#     "issues_url": "http://api.github.com/repos/octocat/Hello-World/issues{/number}",
#     "keys_url": "http://api.github.com/repos/octocat/Hello-World/keys{/key_id}",
#     "labels_url": "http://api.github.com/repos/octocat/Hello-World/labels{/name}",
#     "languages_url": "http://api.github.com/repos/octocat/Hello-World/languages",
#     "merges_url": "http://api.github.com/repos/octocat/Hello-World/merges",
#     "milestones_url": "http://api.github.com/repos/octocat/Hello-World/milestones{/number}",
#     "mirror_url": "git:git.example.com/octocat/Hello-World",
#     "notifications_url": "http://api.github.com/repos/octocat/Hello-World/notifications{?since, all, participating}",
#     "pulls_url": "http://api.github.com/repos/octocat/Hello-World/pulls{/number}",
#     "releases_url": "http://api.github.com/repos/octocat/Hello-World/releases{/id}",
#     "ssh_url": "git@github.com:octocat/Hello-World.git",
#     "stargazers_url": "http://api.github.com/repos/octocat/Hello-World/stargazers",
#     "statuses_url": "http://api.github.com/repos/octocat/Hello-World/statuses/{sha}",
#     "subscribers_url": "http://api.github.com/repos/octocat/Hello-World/subscribers",
#     "subscription_url": "http://api.github.com/repos/octocat/Hello-World/subscription",
#     "svn_url": "https://svn.github.com/octocat/Hello-World",
#     "tags_url": "http://api.github.com/repos/octocat/Hello-World/tags",
#     "teams_url": "http://api.github.com/repos/octocat/Hello-World/teams",
#     "trees_url": "http://api.github.com/repos/octocat/Hello-World/git/trees{/sha}",
#     "homepage": "https://github.com",
#     "language": null,
#     "forks_count": 9,
#     "stargazers_count": 80,
#     "watchers_count": 80,
#     "size": 108,
#     "default_branch": "master",
#     "open_issues_count": 0,
#     "topics": [
#         "octocat",
#         "atom",
#         "electron",
#         "API"
#     ],
#     "has_issues": true,
#     "has_wiki": true,
#     "has_pages": false,
#     "has_downloads": true,
#     "pushed_at": "2011-01-26T19:06:43Z",
#     "created_at": "2011-01-26T19:01:12Z",
#     "updated_at": "2011-01-26T19:14:43Z",
#     "permissions": {
#         "admin": false,
#         "push": false,
#         "pull": true
#     },
#     "allow_rebase_merge": true,
#     "allow_squash_merge": true,
#     "allow_merge_commit": true,
#     "subscribers_count": 42,
#     "network_count": 0,
#     "has_projects": true
# }
#
#
#

