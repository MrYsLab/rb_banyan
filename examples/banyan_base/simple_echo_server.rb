########################################################################################
# Copyright (c) 2017 Alan Yorinks - All Rights Reserved.
#
# This file is part of JavaScript-Banyan.
#
# Ruby Banyan is free software; you can redistribute it and/or
# modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
# Version 3 as published by the Free Software Foundation; either
# or (at your option) any later version.
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU AFFERO GENERAL PUBLIC LICENSE
# along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# simple_echo_server.rb
#############################################################################

require_relative '../../lib/rb_banyan/banyan_base.rb'
###################################################################
# This is a very basic echo server.
# It subscribes to receive messages with a topic of 'echo', and
# when a message is received, it publishes the received payload,
# with a topic of 'reply'
###################################################################
class SimpleEchoServer < BanyanBase

  def initialize(process_name: 'SimpleEchoServer',
                 subscribe_topic: 'echo',
                 publish_topic: 'reply')

    super(process_name:process_name)
    sleep(0.3)

    @subscribe_topic = subscribe_topic
    @publish_topic = publish_topic

    # allow time for zmq connections to complete

    # set the subscriber topic
    set_subscriber_topic(@subscribe_topic)

    # wait for messages to arrive
    begin
      receive_loop
    rescue SystemExit, Interrupt
      clean_up
    end

  end

  # process incoming messages - just resend the payload with
  # a topic of 'reply'
  def incoming_message_processing(_topic, payload)
    publish_payload(payload, @publish_topic)
  end

end


options = { process_name: 'MultiEchoClient',
            subscribe_topic: 'echo',
            publish_topic: 'reply'}

optparse = OptionParser.new do |opts|
  opts.on('-n', '--n Process Name',
          'Name Of This Banyan Component') do |process_name|
    options[:process_name] = process_name
  end

  opts.on('-p', '--p Publish Topic',
          'Topic String') do |loop_time|
    options[:publish_topic] = loop_time
  end

  opts.on('-s', '--s Subscribe Topic',
          'Topic String') do |loop_time|
    options[:subscribe_topic] = loop_time
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

begin
  optparse.parse!
end

options[:loop_time] = options[:loop_time].to_f
SimpleEchoServer.new(process_name: options[:process_name],
                    publish_topic: options[:publish_topic],
                    subscribe_topic: options[:subscribe_topic])
