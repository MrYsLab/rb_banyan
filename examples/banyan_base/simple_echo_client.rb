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
########################################################################################

require_relative '../../lib/rb_banyan/banyan_base.rb'

# This is a simple echo client. It sends out a series of messages and expects an
# echo reply from the server

# To use: 1. Start the backplane.
#         2. Start the server.
#        3. Start this client.

class SimpleEchoClient < BanyanBase

  def initialize(process_name: 'SimpleEchoClient',
                 subscribe_topic: 'echo',
                 publish_topic: 'reply',
                 publish_payload: {'message_number': @message_number})

    super(process_name:process_name)

    # allow time for zmq connections to complete
    sleep(0.3)

    # initialize the number of messages to send and receive
    @number_of_messages = @message_number = 10



    # set the subscriber topic
    set_subscriber_topic('reply')

    # send the first message - make sure that the server is already started
    publish_payload({'message_number': @message_number}, 'echo')
    # adjust the message number for the next send
    @message_number -= 1

    # get the reply messages
    begin
      receive_loop
    rescue SystemExit, Interrupt
      clean_up
      exit(0)
    end
  end

  def incoming_message_processing(_topic, payload)
    if payload['message_number'] == 0
      # all messages sent - wait for user to press Enter to exit the client.
      begin
        puts((@number_of_messages).to_s + ' messages sent and received. ')
        puts('Press enter to exit.')
        gets
        clean_up
        exit(0)
      end

      # bump the message number and send the message out
    else
      @message_number -= 1
      publish_payload({'message_number': @message_number}, 'echo')
    end

  end
end

SimpleEchoClient.new
