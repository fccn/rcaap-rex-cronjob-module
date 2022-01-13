# Rex cronjob module

This rex Module intends to facilitate Crontab management by allowing you to configured it in an CMDB yaml file.

# Usage

Include it in your project meta.yaml
```
Require:
    Rex::Module::Commands::Cronjob:
        git: https://github.com/fccn/rcaap-rex-cronjob-module.git
        branch: main
```


You need to have in your CMDB yaml file the tasks configuration, example:

CMDB.yml
```
 Rex::Module::Commands::Cronjob::actions:
  wp_cron:
       command: "/usr/bin/php /wordpress/wp-cron.php"
       user: wp_user
       hour: 0
       minute: 0
```

You can execute it directly from the command line (please mind to firstly add `use Rex::Module::Commands::Cronjob;`):
```
rex -H $host Module:Commands:Cronjob:prepare
```

Or, you can use it as a library in your project
```
 use Rex::Module::Commands::Cronjob;
    
 task "prepare", sub {
    Rex::Module::Commands::Cronjob::prepare({
       Action => {
        {
            command => "/usr/bin/php /wordpress/wp-cron.php",
            user => wp_user,
            hour => 0,
            minute => 0,
        }  
       }
    });
 };
 ```
