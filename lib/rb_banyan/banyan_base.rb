##############################################################################
# Copyright (c) 2017 Alan Yorinks - All Rights Reserved.
#
# This file is part of Ruby Banyan.
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
# banyan_base.rb
###############################################################################

require 'rubygems'
# noinspection RubyResolve
require 'ffi-rzmq'
require 'socket'
# noinspection RubyResolve
require 'msgpack'
require 'optparse'

# This class is used as a base class to create a Banyan compatible
# component that connects to a single Banyan Backplane.
# A banyan component inherits and extends this class
# to encapsulate zeromq and message pack functionality.
# Its methods may be overridden by the user in the derived class
# to meet the needs of the component.
# noinspection ALL
class BanyanBase
  ## Parameters:
  #   back_plane_ip_address: banyan_base back_planeIP Address.
  #                          If not specified, it will be set to the
  #                          IP address of local computer.
  #   subscriber_port:       banyan_base back plane subscriber port.
  #                          This must match that of the banyan_base backplane
  #   publisher_port:        banyan_base back plane publisher port.
  #                          This must match that of the banyan_base backplane
  #   process_name:          Component identifier
  #   loop_time:             receive loop sleep time.
  #
  # Example Usage:
  #
  ## require 'rubygems'
  ## require 'rb_banyan/banyan_base.rb'
  ## class Myexample < BanyanBase
  #
  #   def initialize
  #     super(process_name: 'MyExample')
  #   end
  ## end
  #
  ## MyExample.new
  #
  ## => This banner appears in the console
  ##
  ## ***********************************************************************
  ## *****  Reminder: Make Sure That The Backplane is Already Running  *****
  ## ***********************************************************************
  ##
  ## ************************************************************
  ## MyExample using BackPlane IP address: 192.168.2.194
  ## Subscriber Port = 43125
  ## Publisher  Port = 43124
  ## Loop Time = 0.1 seconds
  ## ************************************************************


  def initialize(back_plane_ip_address: nil, subscriber_port: '43125',
                 publisher_port: '43124', process_name: 'Unnamed',
                 loop_time: 0.1)
    # If no back plane address was specified, determine the IP address
    # of the local machine
    if back_plane_ip_address.nil?
      @back_plane_ip_address = Socket.ip_address_list[1].ip_address
    else
      @back_plane_ip_address = back_plane_ip_address
    end
    @subscriber_port = subscriber_port
    @publisher_port = publisher_port
    @process_name = process_name
    @loop_time = loop_time

    puts('***********************************************************************')
    puts('*****  Reminder: Make Sure That The Backplane is Already Running  *****')
    puts('***********************************************************************')
    puts

    puts('************************************************************')
    # noinspection RubyResolve
    puts(@process_name + ' using BackPlane IP address: ' +
             @back_plane_ip_address)
    puts('Subscriber Port = ' + @subscriber_port)
    puts('Publisher  Port = ' + @publisher_port)
    puts('Loop Time = ' + (@loop_time.to_s) + ' seconds')
    puts('************************************************************')

    # establish the zeromq sub and pub sockets and connect to the backplane
    @context = ZMQ::Context.create
    @subscriber = @context.socket ZMQ::SUB
    # noinspection RubyResolve
    @subscriber.connect 'tcp://' + @back_plane_ip_address + ':' + @subscriber_port

    @publisher = @context.socket ZMQ::PUB
    @publisher.connect 'tcp://' + @back_plane_ip_address + ':' + @publisher_port

    trap('INT') {'puts Control C detected - bye bye.'; @publisher.close; @subscriber.close; @context.terminate; exit}
  end

  # This method sets a subscriber topic.
  #   Parameters:
  #     topic: Message topic - must be in the form of a string
  def set_subscriber_topic(topic)

    # You can subscribe to multiple topics by calling this method for
    # each topic.

    if topic.is_a? String
      @subscriber.setsockopt ZMQ::SUBSCRIBE, topic
    else
      raise TypeError, 'Subscriber topic must be a string'
    end
  end

  # This method will publish a python_banyan payload and its associated topic
  #   Parameters:
  #     payload: Message payload in the form of a hash
  #     topic: Message topic - must be in the form of a string
  def publish_payload(payload, topic)
    if topic.is_a? String
      message = payload.to_msgpack
      pub_envelope = topic.encode('UTF-8')
      @publisher.send_strings([pub_envelope, message], flags = ZMQ::DONTWAIT)
    else
      raise TypeError, 'Subscriber topic must be a string'
    end

  end

  # receive_loop
  #
  # This is the receive loop for zmq messages.
  #
  # This method may be overwritten to meet the needs
  # of the application before handling received messages.
  def receive_loop
    loop do
      list = []
      p = @subscriber.recv_strings(list, ZMQ::DONTWAIT)
      begin
        if p == -1
          if ZMQ::Util.errno == ZMQ::EAGAIN
            sleep(@loop_time)
          else
            sleep(@loop_time)
            puts ZMQ::Util.errno
          end
        else
          incoming_message_processing(list[0], MessagePack.unpack(list[1]))
        end
      rescue Interrupt
        clean_up
      end
    end
  end

  # This method should be overwritten to process incoming messages.
  #   Parameters:
  #     topic: Message topic - must be in the form of a string
  #     payload: Message payload in the form of a hash
  def incoming_message_processing(topic, payload)
    puts(topic, payload)
  end

  #  This method closes all zmq connections.
  def clean_up
    @publisher.close
    @subscriber.close
    @context.terminate
  end
end
