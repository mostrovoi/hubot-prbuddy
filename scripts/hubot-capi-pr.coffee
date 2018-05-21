# Description:
#  This script shows open PRs based on a label to be filtered
#
#  Dependencies:
#    "hubot": "2.5.5",
#    "octokat": "^0.4.11",
#    "bluebird": "^3.5.1"
#
# Configuration:
#   HUBOT_SLACK_TOKEN - API token for this bot user 
#   GITHUB_TOKEN - A Github token for this bot user
#
# Commands:
#   hubot pr all - Shows a summary of all open PRs of this project 
#   hubot pr - Shows a summary of PRs filtered by label

githubToken = process.env.GITHUB_TOKEN || "5dd6f3d22680718b3d9ef00a449e9d54c49cdffa"
slackToken  = process.env.HUBOT_SLACK_TOKEN
githubRootURL = 'https://github.schibsted.io/api/v3'
whiteListLabels = ['Cremita Review']
blackListLabels = ['wip']
organization = 'scmspain'
repository = 'all-ij--web-empleo'

PrService = require("../src/pull-request-service")

if !(githubToken)
  error =
    "\n
    Oops!\n
    Looks like some required environment variables are missing. Please refer to\n
    the README to know how to obtain these variables, if you haven't alredy got\n
    them. The necessary variables are:\n\n

      HUBOT_SLACK_TOKEN\n
      GITHUB_TOKEN\n

    Exiting now\n
    "

  console.log error
  process.exit(1)

module.exports = (robot) ->

  robot.hear /pr (label|all)/, (res) ->
    label = whiteListLabels[0]
    command = res.match[1]

    switch command
      when "all"
        robot.emit "PrAll",
          room: res.message.room
          apiURL: githubRootURL
          ghToken: githubToken
          org: organization
          repo: repository
          label: label

  robot.on "PrAll", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"
    
    prService = new PrService(metadata.apiURL, metadata.ghToken, metadata.org, metadata.repo, metadata.label)
    prService.generateSummary().then (summary) =>
      robot.send {
        room: metadata.room
      }, summary
