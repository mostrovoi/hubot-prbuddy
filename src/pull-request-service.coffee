Octokat = require 'octokat'
Promise = require 'bluebird'

class PullRequestService
  constructor: (@apiURL, @ghToken, @org, @repo, @label) ->
    github = new Octokat(rootURL: @apiURL, token: @ghToken)
    repo = github.repos(@org, @repo)

    @allPrs =
      repo.issues.fetch({label: ""}).then (prs) =>
        Promise.all (prs.map (pr) -> repo.pulls(prs[0].number).reviews.fetch())

  list: ->
    @repo.pulls.fetch()

  listByStatus: (status) ->
    @repo.pulls.fetch({state: status})

  listByLabel: (label) ->
    @repo.issues.fetch({labels: label})
  
  get: (number) ->
    @repo.pulls(number).fetch()

  #getTotalByState: (reviews, state) ->
  #  reviews.reduce (n, review) ->  
  #     n + (review.state == state)
  #     0

       
  getReviews: (pulls) =>
    Promise.all(pulls.map(pr) -> @repo.pulls(pr.number).reviews().fetch())

  getReviewx: (pn) =>
    @repo.pulls(pn).reviews().fetch()

  getPRNumbers: (pulls) ->
    pr.number for pr in pulls

  generateSummary: ->
    @allPrs.then (pulls) =>
      if pulls.length > 0

           #totalApproved = @getTotalByState(reviews, 'APPROVED')
       #prNumbers = @getPRNumbers (pulls)

        stats = "Summary of all open PRs\n\n"
        stats += "#{pulls.length} open PRs\n"
        stats += "#{pulls}"
        stats += "\n"
        #stats += "#{prNumbers}"
       # stats += "\n"
      else
        stats = "No open PRs :tada:"
    .catch (error) =>
      stats = "error..:"
      stats += "#{error}"

module.exports = PullRequestService
