SimpleCov.start do
  add_group 'Clients', 'lib/hey_listen_me/clients'
  add_group 'Entities', 'lib/hey_listen_me/entities'
  add_group 'Enumerations', 'lib/hey_listen_me/enumerations'
  add_group 'Repositories', 'lib/hey_listen_me/repositories'
  add_group 'Services', 'lib/hey_listen_me/services'
  add_group 'Web', 'apps/web'

  add_filter 'config'
  add_filter 'spec'
  add_filter 'apps/web/application.rb'
end
