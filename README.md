solr-config Cookbook
====================

This cookbook allows solr to be configured. The cookbook includes and will install solr 5.3+.

As well as being able to setup and configure cores, this cookbook provides the ability to generate a solrconfig.xml via configuration.
The solrconfig.xml is based on the 'sample_techproducts_configs' example distributed with solr.

Attributes
----------

- cores
  - name: The name of the core
  - configset: The configset to use for this core (used to share configurations between cores).


For 'handlers' and 'components' no value is typically required, just a key with a null value will enable the handler/component. (See Example Configuration)

- solrconfig
  - luceneMatchVersion: (default: '5.3.0') Controls what version of Lucene various components of Solr adhere to.  Generally, you want to use the latest version to get all bug fixes and improvements. It is highly recommended that you fully re-index after changing this setting as it can affect both how text is indexed and queried.
  - dataDir: (default: '${solr.data.dir:}' ) Used to specify an alternate directory to hold all index data other than the default ./data under the Solr home.  If replication is in use, this should match the replication configuration.
  - schemaFactory: (default: classic) Change this to 'managed' in order to use the dynamic schema REST API for managing the schema.

  - handlers: 
  	- query: Adds the 'query' handler
  	- export: Adds the 'export' handler
  	- stream: Adds the 'stream' handler
  	- browse: Adds the 'browse' handler
  	- update_extract: Adds the 'update/extract' handler
  	- analysis_field: Adds the 'analysis/field' handler
  	- analysis_document: Adds the 'analysis/document' handler
    - debug_dump: Adds the 'debug/dump' handler
  	- admin_ping: Adds the 'admin/ping' handler
  - components:
  	- clustering: Enables the clustering component
  	- elevate: Enables the Query Elevation component
  	- highlight: Enables the highlighter component
  	- spellcheck: If enabled will add spellchecking to the 'select' handler, and enable the spellcheck component.
  	- suggest: Enables the suggest component
  	- terms: Enables the terms component
  	- term_vector: Enables the term vector component
  - response_writer:
  	- json_plain:
  	- velocity:
  	- xslt:


Usage
-----

The following is a sample role.json that can be used with this cookbook. This example is used with Centos (hence the pidfile_path & log_path).

roles/solr.json
```json
{
  "name": "solr",
  "chef_type": "role",
  "json_class": "Chef::Role",
  "description": "Solr server role",
  "default_attributes":
  {
    "solr" : {
      "pidfile_path" : "/var/run/solr",
      "log_path" : "/var/log/solr",
      "home_path" : "/var/solr"
    },
    "solr-config" : {
      "cores" : {
        "example_core_1": {
          "name": "example_core_1",
          "configset": "default"
        },
        "example_core_2": {
          "name": "example_core_2",
          "configset": "default"
        }
      },
      "configsets": {
        "default": {
          "schema": "/var/www/site/config/solr/schema.xml"
        }
      },
      "solrconfig": {
        "luceneMatchVersion": "LUCENE_35",
        "components": {
          "spellcheck": null
        }
      }
    },
    "java" : {
      "jdk_version": "7"
    }
  },
  "run_list": [
    "recipe[solr-config]"
  ]
}
```
