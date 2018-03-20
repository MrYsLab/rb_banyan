

# RbBanyan
This is the ruby compatible version of the [Python Banyan Framework](https://mryslab.github.io/python_banyan/).

Banyan is a lightweight, reactive framework used to create flexible, non-blocking, 
event driven, asynchronous applications. It was designed primarily to 
implement physical computing applications for devices such as the 
Raspberry Pi and Arduino, but it is not limited to just the physical computing domain, 
and may be used to create applications in any domain.

Banyan applications are comprised of a set of components, each component being a seperate process. 
Components communicate with each other by publishing and subscribing to language independent protocol messages.
As a result, any component can communicate with any other component, regardless of computer language.
Each Banyan component connects to a common Banyan backplane that distributes published messages to all message
subscribers. The backplane is provided as a command line executable as part of this package and is invoked with

```apple js
rb_backplane
```
The backplane must be started before invoking any Banyan component.

In addiition, there is a command line backplane provided as part of the package to monitor all traffic
going across the backplane.

To invoke the monitor, type:
```apple js
rb_monitor
```

## Installation


    $ gem install rb_banyan

## banyan_base.rb API
![](https://github.com/MrYsLab/rb_banyan/blob/master/images/banyan_base_api.png)

## A Simple Echo Server
```
require 'rb_banyan/banyan_base.rb'

class SimpleEchoServer < BanyanBase

  def initialize
    # set the process name for the console banner
    super(process_name: 'SimpleEchoServer')
    
    # allow time for zmq connections to complete
    sleep(0.3)

    # set the subscriber topic
    set_subscriber_topic('echo')

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
    publish_payload(payload, 'reply')
  end
end


SimpleEchoServer.new

```
## A Simple Echo Client

```
require 'rubygems'
require 'rb_banyan/banyan_base.rb'

# This is a simple echo client. It sends out a series of messages and expects an
# echo reply from the server

# To use: 1. Start the backplane.
#         2. Start the server.
#         3. Start this client.

class SimpleEchoClient < BanyanBase

  def initialize

    # set the process name for the console banner
    super(process_name:'SimpleEchoClient')

    # allow time for zmq connections to complete
    sleep(0.3)

    # initialize the number of messages to send and receive
    @number_of_messages = @message_number = 10

    # set the subscriber topic
    set_subscriber_topic('reply')

    # send the first message
    publish_payload({'message_number': @message_number}, 'echo')

    # adjust the message number for the next send
    @message_number -= 1

    # get the reply messages
    # wait for messages to arrive
    begin
      receive_loop
    rescue SystemExit, Interrupt
      clean_up
    end
  end

  # With each incoming message, adjust the message number and 
  # publish the next message until the count is achieved.
  def incoming_message_processing(_topic, payload)
    # if all messages received, we are done.
    if payload['message_number'] == 0
        puts('All messages sent and received')
        clean_up
        exit(0)

    # we have more to send - bump the message number and send the message out
    else
      @message_number -= 1
      publish_payload({'message_number': @message_number}, 'echo')
    end
  end
end

SimpleEchoClient.new

```