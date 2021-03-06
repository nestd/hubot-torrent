EventEmitter = require('events').EventEmitter
Promise      = require('promise')

class BaseAdapter extends EventEmitter
  constructor: (@_authorizer) ->
    @http        = require('http')
    @querystring = require('querystring')

  search: (query) ->
    @query = query

    new Promise(
      @_authorizer.authorize
      this._displayError
    ).then(
      this.doSearch
    ).then(
      this.parseResp
    )

  doSearch: (resolve) =>
    new Promise(
      (resolve) =>
        this._doRequest(
          this._searchOptions()
          resolve
        )
      this._displayError
    )

  downloadTorrentFile: (requestOptions) ->
    torrentFile = '/tmp/test.torrent'

    fs = require('fs')

    if fs.existsSync(torrentFile)
      fs.unlink(torrentFile)

    file = fs.createWriteStream(torrentFile)

    req = @http.request(
      requestOptions
    )

    req.on(
      'response'
      (res) =>
        res.pipe(file)

        res.on(
          'end'
          =>
            file.end()
            this.emit('torrent:file', torrentFile)
        )
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.end()

  _doRequest: (requestOptions, resolve) ->
    req = @http.request(
      requestOptions
    )

    req.on(
      'response'
      (res) =>
        html = ''

        res.setEncoding('binary')

        res.on(
          'data'
          (chunk) =>
            html += chunk
        )

        res.on(
          'end'
          =>
            resolve(html)
        )
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.end()

  _displayError: (errors) ->
    for error in errors
      console.info(error)

module.exports = BaseAdapter