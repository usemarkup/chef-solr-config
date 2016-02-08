#
# Cookbook Name:: solr-config
# Recipe:: default
#

include_recipe "solr"

template "#{node['solr-config']['home']}/solr.xml" do
  source 'solr.xml.erb'
  owner "#{node["solr"]["user"]}"
  group "#{node["solr"]["user"]}"
  mode '0755'
end

# validate cores attribute
ruby_block 'validate_cores' do
  block do
    unless node["solr-config"]["cores"].nil?
      node['solr-config']['cores'].each do |key, confighash|
        unless [:name, :configset].all? {|s| confighash.key? s}
            raise "Solr core config hash must contain keys `name` & `configset`"
        end
      end
    end
  end
  action :run
end

# install cores
node["solr-config"]["cores"].each do |key, confighash|
  directory "#{node["solr-config"]["home"]}/cores/#{confighash.name}" do
    owner "#{node["solr"]["user"]}"
    group "#{node["solr"]["user"]}"
    mode '0755'
    recursive true
    action :create
  end
  template "#{node["solr-config"]["home"]}/cores/#{confighash.name}/core.properties" do
    source "core.properties.erb"
    owner "#{node["solr"]["user"]}"
    group "#{node["solr"]["user"]}"
    mode '0755'
    variables({
     :coreconfig => confighash
    })
    action :create
    notifies :restart, resources(:service => "solr"), :delayed
  end
end

# write configset folder for each configset - symlink to schema files which are absolute
node["solr-config"]["configsets"].each do |key, confighash|
  directory "#{node["solr-config"]["home"]}/configsets/#{key}/conf" do
    owner "#{node["solr"]["user"]}"
    group "#{node["solr"]["user"]}"
    recursive true
    mode '0755'
    action :create
  end

  # if schema defined for configset then symlink to solrconfig.xml
  if confighash.has_key?("config")
      link "#{node["solr-config"]["home"]}/configsets/#{key}/conf/solrconfig.xml" do
        to confighash.config
      end
  else
    # write default solrconfig.xml
    template "#{node["solr-config"]["home"]}/configsets/#{key}/conf/solrconfig.xml" do
      source "solrconfig.xml.erb"
      owner "#{node["solr"]["user"]}"
      group "#{node["solr"]["user"]}"
      mode '0755'
      variables({
        :config => node["solr-config"]["solrconfig"]
      })
      action :create
      notifies :restart, resources(:service => "solr"), :delayed
    end
  end
  unless confighash.schema.nil?
      link "#{node["solr-config"]["home"]}/configsets/#{key}/conf/schema.xml" do
        to confighash.schema
      end
  end 
end

# copy in configuration files (stopwords.txt etc.)
node["solr-config"]["configsets"].each do |key, confighash|
  remote_directory "#{node["solr-config"]["home"]}/configsets/#{key}/conf" do
    source "conf"
    files_owner "#{node["solr"]["user"]}"
    files_group "#{node["solr"]["user"]}"
    files_mode '0755'
    owner "#{node["solr"]["user"]}"
    group "#{node["solr"]["user"]}"
    mode '0755'
    recursive true
    action :create
  end
end

# copy in dist/libs
remote_directory "#{node["solr-config"]["install"]}/dist" do
  source "dist"
  files_owner "#{node["solr"]["user"]}"
  files_group "#{node["solr"]["user"]}"
  files_mode '0755'
  owner "#{node["solr"]["user"]}"
  group "#{node["solr"]["user"]}"
  mode '0755'
  recursive true
  action :create
end
