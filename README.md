
[![Build Status](https://travis-ci.org/Piousbox-cookbooks/mediawiki.svg?branch=0.2.0)](https://travis-ci.org/Piousbox-cookbooks/mediawiki)

Mediawiki Cookbook
==================
To install mediawiki, add "recipe[mediawiki::defailt]" to the runlist.

This cookbook assumes that the database may be on a different node.

Requirements
------------

Attributes
----------

#### mediawiki::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['mediawiki']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### mediawiki::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `mediawiki` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[mediawiki]"
  ]
}
```