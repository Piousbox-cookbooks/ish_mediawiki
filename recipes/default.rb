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
include_recipe "apache2::mod_php5"

%w{ mysql-client php5-mysql libapache2-mod-auth-mysql libapache2-mod-php5 awscli }.each do |pkg|
  package pkg
end


# configure
app             = data_bag_item("apps", "wiki_wasya")
user            = app['user'][node.chef_environment]
aws_key         = app['aws_key']
aws_secret      = app['aws_secret']
backup_date     = app['backup_date']
mysql_user      = node['mediawiki']['db']['user']
mysql_password  = node['mediawiki']['db']['password']
mysql_host      = node['mediawiki']['db']['host']
mysql_database  = node['mediawiki']['db']['database']

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
# wget https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz && \
wget https://releases.wikimedia.org/mediawiki/1.23/mediawiki-1.23.0.tar.gz && \
tar xvzf mediawiki-*.tar.gz -C wiki.tmp && \
mv wiki.tmp/* mediawiki && \
chown #{user} mediawiki -R && \
rm -rf wiki.tmp mediawiki-*gz && \
echo ok
EOL
end


## configure
template "/home/#{user}/projects/mediawiki/LocalSettings.php" do
  source "LocalSettings.php.erb"
  owner  user
  group  user
  mode   "0664"
  variables({
  })
end


execute   "restore data" do
  cwd     "/home/#{user}/projects"
  command <<-EOL
rm #{backup_date}.wiki_cac.sql* && \
AWS_ACCESS_KEY_ID=#{aws_key} AWS_SECRET_ACCESS_KEY=#{aws_secret} aws s3 cp s3://ish-backups/sql_backup/#{backup_date}.wiki_cac.sql.tar.gz .  --region us-west-1 && \
tar -xvf #{backup_date}.wiki_cac.sql.tar.gz && \
mysql -u #{mysql_user} -p#{mysql_password} -h #{mysql_host} #{mysql_database} < #{backup_date}.wiki_cac.sql && \
echo ok
EOL
end
