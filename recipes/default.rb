#
# Author:: piousbox
# Cookbook Name:: mediawiki
# Recipe:: default
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "ish_apache::install_apache"
include_recipe "php::default"
# include_recipe "apache2::mod_php5" # Apache is running a threaded MPM, but your PHP Module is not compiled to be threadsafe.  You need to recompile PHP.

%w{ mysql-client php5-mysql libapache2-mod-auth-mysql libapache2-mod-php5 awscli }.each do |pkg|
  package pkg
end
package "libapache2-mod-php5" do
  action [ :remove, :install ]
end


# configure
app                 = data_bag_item("apps", "wiki_wasya")
user                = app['user'][node.chef_environment]
aws_key             = app['aws_key'][node.chef_environment]
aws_secret          = app['aws_secret'][node.chef_environment]
mysql_user          = app['databases'][node.chef_environment]['username']
mysql_password      = app['databases'][node.chef_environment]['password']
mysql_host          = app['databases'][node.chef_environment]['host']
mysql_database      = app['databases'][node.chef_environment]['database']
wiki_version        = app['mediawiki_version'][node.chef_environment]
wiki_version_short  = wiki_version.split(".")[0..1].join(".")
restore_name        = app['restore_name'][node.chef_environment] # YYYYMMDD.db_name
restore_path        = "ish-backups/sql_backup/#{restore_name}.sql.tar.gz"
domain              = app['domains'][node.chef_environment][0]

directory     "/home/#{user}/projects/wiki.tmp" do
  action      :create
  recursive   true
  owner       user
  group       user
end


execute    "download tarball" do
  cwd      "/home/#{user}/projects"
  command  <<-EOL
rm -rf mediawiki && \
wget https://releases.wikimedia.org/mediawiki/#{wiki_version_short}/mediawiki-#{wiki_version}.tar.gz && \
tar xvzf mediawiki-*.tar.gz -C wiki.tmp && \
mv wiki.tmp/* mediawiki && \
chown #{user} mediawiki -R && \
rm -rf wiki.tmp mediawiki-*gz && \
echo ok
EOL
end


template "/home/#{user}/projects/mediawiki/LocalSettings.php" do
  source "LocalSettings-#{wiki_version_short}.php.erb"
  owner  user
  group  user
  mode   "0664"
  variables({
              :db_host      => mysql_host,
              :db_user      => mysql_user,
              :db_password  => mysql_password,
              :db_name      => mysql_database,
              :domain       => domain
  })
end


execute   "restore data" do
  cwd     "/home/#{user}/projects"
  not_if  "mysql -u#{mysql_user} -p#{mysql_password} -h #{mysql_host} -se'USE #{mysql_database};' 2>&1"
  command <<-EOL
rm -f *sql* ; \
echo "create database #{mysql_database}" > trash.sql && \
mysql -u #{mysql_user} -p#{mysql_password} -h #{mysql_host} < trash.sql && \
AWS_ACCESS_KEY_ID=#{aws_key} AWS_SECRET_ACCESS_KEY=#{aws_secret} aws s3 cp s3://#{restore_path} .  --region us-west-1 && \
tar -xvf #{restore_name}.sql.tar.gz && \
mysql -u #{mysql_user} -p#{mysql_password} -h #{mysql_host} #{mysql_database} < #{restore_name}.sql && \
echo ok
EOL
end
