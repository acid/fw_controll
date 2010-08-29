FwControll
==========

A Rails plugin for the control of the systems firewall.

It's higly recommended to secure the access to a rails-app which is using this plugin. Handling the firewall can do big harm to your access to the systems!


Example
=======

Get a list of all rules:

    fw_rules_list

Get a list of all rules of a special chain:

    fw_rules_list "INPUT"

Allow Connections to Port 23 on the INPUT chain

    fw_cmd 'INPUT', :action => :append, :dport => 23, :jump => :accept

Installation
============

I recommend you add it as a submodule.

    git submodule add git@github.com:acid/fw_controll.git vendor/plugins/fw_controll

You must add a new line to your /etc/sudoers file:

    rails_user ALL=NOPASSWD: /path/to/iptables

If your iptables binary isn't located in /sbin/, add a initializer:

    FwControll.configure do |config|
      config.command = '/path/to/iptables'
    end

Contribute
==========

Please do! This Project has lots of work on it, like documentation, support for other firewall systems (ipfw, pf, etc.) and many more!
Just fork your version, add some new magic and send me a pull request. I will give you commiter access after a patch or two.


Copyright (c) 2010 Daniel 'acid' Schweighöfer, released under the MIT license
