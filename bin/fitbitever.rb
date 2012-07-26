# -*- coding: utf-8 -*-
$: << File.dirname(__FILE__) + "/../lib"
require 'fitbitever'
require 'clockwork'
include Clockwork

schedule = FitbitEver.clock_time
handler {|job| job.run }
every(1.day, FitbitEver, :at => schedule)