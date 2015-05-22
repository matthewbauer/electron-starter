Menu = require 'menu'
BrowserWindow = require 'browser-window'
app = require 'app'
fs = require 'fs-plus'
ipc = require 'ipc'
path = require 'path'
os = require 'os'
net = require 'net'
url = require 'url'

{EventEmitter} = require 'events'
_ = require 'underscore-plus'

AppMenu = require './appmenu'

module.exports =
class Application
  _.extend @prototype, EventEmitter.prototype

  constructor: (options) ->
    @pkgJson = require '../../package.json'
    @windows = []

    app.on 'window-all-closed', ->
      app.quit() if process.platform in ['win32', 'linux']

    @menu = new AppMenu
      pkg: @pkgJson

    @menu.on 'application:quit', -> app.quit()

    @menu.on 'window:reload', ->
      BrowserWindow.getFocusedWindow().reload()

    @menu.on 'window:toggle-full-screen', ->
      focusedWindow = BrowserWindow.getFocusedWindow()
      fullScreen = true
      if focusedWindow.isFullScreen()
        fullScreen = false

      focusedWindow.setFullScreen(fullScreen)

    @menu.on 'window:toggle-dev-tools', ->
      BrowserWindow.getFocusedWindow().toggleDevTools()

  # Removes the given window from the list of windows, so it can be GC'd.
  #
  # options -
  #   :appWindow - The {AppWindow} to be removed.
  removeAppWindow: (appWindow) =>
    @windows.splice(idx, 1) for w, idx in @windows when w is appWindow
