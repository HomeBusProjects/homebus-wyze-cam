#!/usr/bin/env ruby

require './options'
require './app'

camera_app_options = CameraHomeBusAppOptions.new

camera = CameraHomeBusApp.new camera_app_options.options
camera.run!
