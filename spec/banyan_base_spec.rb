require 'rspec'
require_relative '../lib/rb_banyan/banyan_base.rb'
require 'socket'

describe 'banyan_base' do
  describe 'initialize' do
    context 'no parameters' do
      b = BanyanBase.new
      it 'should initialize all parameters with defaults' do
        expect(b.instance_variable_get(:@back_plane_ip_address)).to eq(Socket.ip_address_list[1].ip_address)
        expect(b.instance_variable_get(:@subscriber_port)).to eq('43125')
        expect(b.instance_variable_get(:@publisher_port)).to eq('43124')
        expect(b.instance_variable_get(:@process_name)).to eq('Unnamed')
        expect(b.instance_variable_get(:@loop_time)).to eq(0.1)
      end
    end
    context 'specify parameters' do
      b = BanyanBase.new(back_plane_ip_address: '111.222.333.444',
                         subscriber_port: '7777',
                         publisher_port: '8888',
                         process_name: 'Tester',
                         loop_time: 0.003)
      it 'should initialize all parameters with specified values' do
        expect(b.instance_variable_get(:@back_plane_ip_address)).to eq('111.222.333.444')
        expect(b.instance_variable_get(:@subscriber_port)).to eq('7777')
        expect(b.instance_variable_get(:@publisher_port)).to eq('8888')
        expect(b.instance_variable_get(:@process_name)).to eq('Tester')
        expect(b.instance_variable_get(:@loop_time)).to eq(0.003)
      end
    end
  end

  describe 'set_subscriber_topic' do
    context 'valid topic string' do
      b = BanyanBase.new
      it 'should not raise an error' do
        expect {b.set_subscriber_topic('valid')}.not_to raise_error
      end
    end
    context 'invalid topic string' do
      b = BanyanBase.new
      it 'should raise an error' do
        expect {b.set_subscriber_topic(1)}.to raise_error('Subscriber topic must be a string')
      end
    end
  end

  describe 'publish_payload' do
    context 'valid topic string' do
      b = BanyanBase.new
      it 'should not raise an error' do
        expect {b.set_subscriber_topic('valid')}.not_to raise_error
      end
    end
    context 'invalid topic string' do
      b = BanyanBase.new
      it 'should raise an error' do
        expect {b.set_subscriber_topic(1)}.to raise_error('Subscriber topic must be a string')
      end
    end
  end
end