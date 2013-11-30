
#
# redipe mediawiki::appserver
# written by piousbox
#

app = data_bag_item( 'apps', node[:apache2][:app_server_role] )

template "/etc/apache2/sites-available/#{app['id']}" do
  action :create
  owner app['owner']
  group app['group']
  variables({
              :domain => app['domain'],
              :domains => app['domains'],
              :deploy_to => app['deploy_to'],
              :port => app['appserver_port']
            })
end

# enable site
execute 'enable the site' do
  command "sudo a2ensite #{app['id']}" 
end

# restart apache
execute 'restart apache' do
  command "sudo service apache2 restart"
end
