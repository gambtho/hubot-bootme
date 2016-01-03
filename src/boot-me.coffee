# Description
#   A hubot script that returns information about spring boot apps in slack
#
# Commands:
#   hubot bootme <url> - returns informational data from spring boot apps
#
# Author:
#   gambtho <thomas_gamble@homedepot.com>

# URL Regex - http://stackoverflow.com/a/17773849 - foufos
# Human readable ms - http://stackoverflow.com/a/12420737 - Nick Grealy

module.exports = (robot) ->

  robot.respond /bootme (.*)$/i, (res) ->
    validateURL res, (url, err) ->
      return emitData(res, err) if err
      payload =
        title: url
        title_link: url
        thumb_url: "https://yt3.ggpht.com/-zF4TRgEyKkg/AAAAAAAAAAI/AAAAAAAAAAA/IBt_QgQUASE/s900-c-k-no/photo.jpg"
        fields: []
      metricsQuery url, payload, (mPayload, err) ->
        #console.log err
        healthQuery url, mPayload, (hPayload, err) ->
          #console.log err
          infoQuery url, hPayload, (iPayload, err) ->
            return emitData(res, err) if payload.fields.length == 0
            robot.emit 'slack-attachment',
              channel: res.envelope.room
              content: payload

  validateURL = (res, cb) ->
    urlPattern = /(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/
    if ( res.match[1].match( urlPattern ) )
      cb(res.match[1], null)
    else
      cb(res.match[1], "Invalid Url - please use this format: bootme <url>")

  emitData = (res, string="Bootme Error") ->
    payload =
      title: string
    robot.emit 'slack-attachment',
      channel: res.envelope.room
      content: payload

  metricsQuery = (url, sPayload, cb) ->
    robot.http("#{url}/metrics")
    .header('Accept', 'application/json')
    .get() (err, resp, body) ->
      if (err or not resp.statusCode == 200)
        err = "Unable to connect to /metrics for #{url} - #{err}"
        cb(null, err)
      else
        try
          data = JSON.parse body
          fields = sPayload.fields
          fields.push { short: true, title: "Uptime", value: formatTime(data.uptime) }
          cb(sPayload, err)
        catch err
          err = "Unable to connect to /metrics for #{url} - #{err}"
          cb(null, err)

  healthQuery = (url, sPayload, cb) ->
    robot.http("#{url}/health")
    .header('Accept', 'application/json')
    .get() (err, resp, body) ->
      if (err or not resp.statusCode == 200)
        err = "Unable to connect to /health for #{url} - #{err}"
        cb(null, err)
      else
        try
          data = JSON.parse body
          fields = sPayload.fields
          fields.push { short: true, title: "Status", value: data.status }
          cb(sPayload, err)
        catch err
          err = "Unable to connect to /health for #{url} - #{err}"
          cb(null, err)

  infoQuery = (url, sPayload, cb) ->
    robot.http("#{url}/info")
    .header('Accept', 'application/json')
    .get() (err, resp, body) ->
      if (err or not resp.statusCode == 200)
        err = "Unable to connect to /info for #{url} - #{err}"
        cb(null, err)
      else
        try
          data = JSON.parse body
          fields = sPayload.fields
          fields.push { short: true, title: "Name", value: data.build.name }
          fields.push { short: true, title: "Version", value: data.build.version }
          fields.push { short: true, title: "Git branch", value: data.git.branch }
          fields.push { short: true, title: "Commit id", value: data.git.commit.id }
          fields.push { short: true, title: "Commit time", value: data.git.commit.time }
          cb(sPayload, err)
        catch err
          err = "Unable to connect to /info for #{url} - #{err}"
          cb(null, err)

  formatTime = (milliseconds) ->
    date = new Date(milliseconds)
    str = ''
    str += date.getUTCDate()-1 + "d/"
    str += date.getUTCHours() + "h/"
    str += date.getUTCMinutes() + "m/"
    str += date.getUTCSeconds() + "s/"
    str += date.getUTCMilliseconds() + "ms"
    str


