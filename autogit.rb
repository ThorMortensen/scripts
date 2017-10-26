#   Auther  : thm
#   Date    : 25-October-2017
#   File    : autogit.rb
#   Project : scripts


require_relative 'rubyHelpers.rb'
require 'net/http'
require 'uri'
require 'json'


NEW_PATH_GET_GIT_CMD = "git rev-parse --show-toplevel"

$homePath = `echo $HOME` #ARGV[0]
scriptFolderPath = File.dirname(__FILE__)
scriptConfFilePath = "#{scriptFolderPath}/script.conf"


def exitPoint
  puts "Thank you for using one of Thor's QOF scripts. Exerting...".bold.magenta
  exit()
end

# @param [string] repoName
# @return [Net::Net::HTTP]
def makeGithubRepo(repoName)
  uri = URI.parse('https://api.github.com/user/repos')
  request = Net::HTTP::Post.new(uri)
  request.basic_auth('send.tilmig@gmail.com', 'f5e43333c5b9f00206f54ac1f778da221ca6ca7e')
  request.body = JSON.dump("name" => "#{repoName}")

  req_options = { use_ssl: uri.scheme == 'https' }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  
  return response
  
end


def makeRemoteGitRepo

  newRemoteRepoName = Dir.pwd
  newRemoteRepoName = newRemoteRepoName.split("/").last
  puts
  puts "Remote repo will get this name ".bg_magenta.black
  puts
  puts "#{newRemoteRepoName}".bold
  puts
  puts "Type another name OR leave empty".bg_magenta.black
  print"~> "
  userInput = gets

  newRemoteRepoName = userInput unless userInput[/^\n/]

  puts "Going with this name #{newRemoteRepoName.to_s.green}"

  puts "Makeing remote repo".cyan

  response = makeGithubRepo(newRemoteRepoName)

  respBody = JSON.parse(response.body)
  
  if response.code == 422
    puts "#{respBody["message"]}".red
  end

  puts "response code #{response.code}"

  # puts "response url body -> #{response.body}"
  # puts "response JSON body -> #{respBody["id"]}"


  puts "response html_url addr -> #{respBody["html_url"]}"
  puts "response ssh addr -> #{respBody["ssh_url"]}"



  # puts response. #.to_s.gray


  exitPoint
end


def createGitRepo

  puts "Auto make remote repo? [Y/n]".bg_blue.black

  unless gets()['n']
    makeRemoteGitRepo
  end

  puts "Add remote repo OR leave empty for local repo only".bg_blue.black
  print "~> "
  remote = gets.chomp
  unless remote.empty?
    remote = "git remote add origin #{remote}"
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


  puts "Creating new git repo:".cyan
  puts `git init && git add . && git commit -m "initial commit"`.gray

  unless remote.empty?
    puts "Linking repo to remote:".cyan
    puts `#{remote} && git push -u origin master`.gray
  end

  return Dir.pwd

end


def checkForGitRepo

  gitBasePath = `#{NEW_PATH_GET_GIT_CMD}`

  if gitBasePath == ""
    puts "No git repo found.".red
    puts "Make one now? [Y/n]".bg_brown.black
    if gets['n']
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

oldAutoCommitPath = text[/AUTO_COMMIT_PATHS=.*/]

if oldAutoCommitPath[newRepoPath]
  puts "This repo is already added in paths".red
  exitPoint
end

newAutoCommitPath = "#{oldAutoCommitPath}:#{newRepoPath}"

puts "old -> #{oldAutoCommitPath}"
puts "new -> #{newAutoCommitPath}"


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
