# frozen_string_literal: true

require 'proxmox'
require 'sinatra'
require 'sinatra/json'

client = Proxmox::Client.new(
  base_url: ENV['PROXMOX_URL'],
  username: ENV['PROXMOX_USER'],
  password: ENV['PROXMOX_PASSWORD'],
  ignore_ssl: true
)

get '/' do
  'Hello world!'
end

get '/updates' do
  updates = check_updates(client)
  status 204 unless updates.count.positive?
  json updates
end

def check_updates(client)
  cluster = Proxmox::Resources::Cluster.new(client)
  updates = []

  cluster.nodes.each do |n|
    node = Proxmox::Resources::Node.new(client, n['node'])
    proxmox_updates = node.updates.select { |p| p['Origin'] == 'Proxmox' }
    updates.push(proxmox_updates) if proxmox_updates.count.positive?
  end

  updates
end
