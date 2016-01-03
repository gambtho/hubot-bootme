expect = require('chai').expect
nock = require('nock')
Helper = require('hubot-test-helper')
helper = new Helper('../src/boot-me.coffee')
CONFIG = require('./util/config')

sinon = require 'sinon'


describe 'bootme', ->
  room = null
  beforeEach ->
    room = helper.createRoom()

    nock("http://localhost.localhost.com:8080")
    .get("/metrics")
    .reply 200, CONFIG.BOOT_METRICS_RESPONSE
    .get("/health")
    .reply 200, CONFIG.BOOT_HEALTH_RESPONSE
    .get("/info")
    .reply 200, CONFIG.BOOT_INFO_RESPONSE
    nock("http://localhost.localhost.com:8082")
    .get("/metrics")
    .reply 404, " "
    .get("/health")
    .reply 404, " "
    .get("/info")
    .reply 404, " "

  afterEach ->
    room.destroy()
    nock.cleanAll()

  context 'user makes a bad bootme request', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot bootme blah"
      room.user.say 'alice', "hubot bootme http://localhost.localhost.com:8082"
      setTimeout done, 100

    it 'and it should reply with an error message for a request without a url',  ->
      expect(room.robot.emit.firstCall.args[1].content.title).equals("Invalid Url - please use this format: bootme <url>")
    it 'and it should reply with an error message for a request with an invalid url',  ->
      expect(room.robot.emit.lastCall.args[1].content.title).to.match(/Unable to connect to \/info for http:\/\/localhost.localhost.com:8082/)


  context 'user request boot data on a valid url', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot bootme http://localhost.localhost.com:8080"
      setTimeout done, 100

    it 'and it should reply with boot data for the requested url',  ->
      expect(room.robot.emit.firstCall.args[1].content.title).equals("http://localhost.localhost.com:8080")
      expect(room.robot.emit.firstCall.args[1].content.title_link).equals("http://localhost.localhost.com:8080")
      expect(room.robot.emit.firstCall.args[1].content.thumb_url).equals("https://yt3.ggpht.com/-zF4TRgEyKkg/AAAAAAAAAAI/AAAAAAAAAAA/IBt_QgQUASE/s900-c-k-no/photo.jpg")
      expect(room.robot.emit.firstCall.args[1].content.fields[0].value).equals("0d/0h/5m/54s/951ms")
      expect(room.robot.emit.firstCall.args[1].content.fields[1].value).equals("UP")
      expect(room.robot.emit.firstCall.args[1].content.fields[2].value).equals("usom-tax")
      expect(room.robot.emit.firstCall.args[1].content.fields[3].value).equals("")
      expect(room.robot.emit.firstCall.args[1].content.fields[4].value).equals("HEAD")
      expect(room.robot.emit.firstCall.args[1].content.fields[5].value).equals("840f43d")
      expect(room.robot.emit.firstCall.args[1].content.fields[6].value).equals("Thu Dec 17 10:12:57 EST 2015")





