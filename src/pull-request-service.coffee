Octokat = require 'octokat'
Promise = require 'bluebird'

class PullRequestService
  constructor: (@apiURL, @ghToken, @org, @repo, @label) ->
    github = new Octokat(rootURL: @apiURL, token: @ghToken)
    repo = github.repos(@org, @repo)

    @allPrs =
      #repo.issues.fetch({label: ""})
      repo.pulls.fetch().then (prs) =>
        Promise.all (prs.items.map (pr) -> repo.pulls(pr.number).reviews.fetch()) 

  list: ->
    @repo.pulls.fetch()

  listByStatus: (status) ->
    @repo.pulls.fetch({state: status})

  listByLabel: (label) ->
    @repo.issues.fetch({labels: label})
  
  get: (number) ->
    @repo.pulls(number).fetch()

  filterByState: (reviews, state) ->
    reviews.filter (review) -> (review.state == state)
       
  getReviews: (pulls) =>
    Promise.all(pulls.map(pr) -> @repo.pulls(3190).reviews().fetch())

  getReviewx: (pn) =>
    @repo.pulls(pn).reviews().fetch()

  getPRNumbers: (pulls) ->
    pr.number for pr in pulls

  getItems: (pulls) ->
    pr.items for pr in pulls

  generateSummary: ->
    @allPrs.then (pulls) =>
      if pulls.length > 0
        collection = []
        for pr in pulls
           mypr: pr
           passed: Object.keys(@filterByState(pr.items,"APPROVED")).length
           
           stats += "\n"
           stats += "-------------------------"
           

        #totalApproved = @getTotalByState(pulls, 'APPROVED')
       #prNumbers = @getPRNumbers (pulls)
        items = @getItems(pulls)
       # totalByState = @getTotalByState(pulls)
       # stats = "Summary of all open PRs\n\n"
        stats += "#{pulls.length}\n"
       # stats += "TOTAL: #{totalByState}"
        stats += "-------------------------"
        #stats += JSON.stringify(items[1][1].state)
        stats += "\n"
        #stats += "#{prNumbers}"
       # stats += "\n"
      else
        stats = "No open PRs :tada:"
        stats += JSON.stringify(pulls)
    .catch (error) =>
      stats = "error..:"
      stats += "#{error}"

module.exports = PullRequestService
