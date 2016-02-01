if Chef::Config[:solo]
    node.expand!('disk')
else
    node.expand!('server')
end

default['solr-config']['home'] = node['solr']['directory']
default['solr-config']['cores'] = nil
default['solr-config']['configsets'] = {}

default['solr-config']['solrconfig'] = {}
default['solr-config']['solrconfig']['handlers'] = {}
default['solr-config']['solrconfig']['components'] = {}
default['solr-config']['solrconfig']['response_writer'] = {}
