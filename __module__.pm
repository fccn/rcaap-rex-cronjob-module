package Rex::Module::Commands::Cronjob;

use strict;
use warnings;
use Rex -base;
use Rex::Logger;
use Data::Dumper;


# VERSION
use base qw(Rex::Cron);
use Rex::Resource::Common;

#rexify --use Rex::Ext::ParamLookup
#also requires Devel::Caller

desc "Cronjob prepare";
task "prepare",
	sub {
		my $actions = shift;

		if ($actions ne "") {
			#$actions = param_lookup($?)->{'Rex::Module::Commands::Cronjob'};
			$actions = param_lookup ('actions');
		}

		die ("No cronjob actions defined") unless $actions;

		
		foreach my $action (sort(keys %{$actions})) {
			my $cron_config = {
				cron      => $action,
				ensure    => exists ( $actions->{$action}->{"ensure"})? $actions->{$action}->{"ensure"} : 'present',
				user      => exists ( $actions->{$action}->{"user"})? $actions->{$action}->{"user"} : 'root',
				minute    => exists ( $actions->{$action}->{"minute"})? $actions->{$action}->{"minute"} : undef,
				hour      => exists ( $actions->{$action}->{"hour"})? $actions->{$action}->{"hour"} : undef,
				day_of_month      => exists ( $actions->{$action}->{"day_of_month"})? $actions->{$action}->{"day_of_month"} : undef,
				month     => exists ( $actions->{$action}->{"month"})? $actions->{$action}->{"month"} : undef,    
				day_of_week      => exists ( $actions->{$action}->{"day_of_week"})? $actions->{$action}->{"day_of_week"} : undef,
				command   => exists ( $actions->{$action}->{"command"})? $actions->{$action}->{"command"} : undef,
			};

			if (defined $cron_config->{'command'}) {
				cron add => $cron_config->{'user'}, $cron_config;
				Rex::Logger::info("Cronjob $cron_config->{'cron'} added to user $cron_config->{'user'}");
			} else {
				Rex::Logger::info("Cronjob adding failed. CRON command isn't defined",'error');
			}
		}

	};




=pod
=head1 NAME
Rex::Module::Commands::Cronjob - A cronjob module for Rex
=head1 USAGE
 rex -H $host Module:Commands:Cronjob:prepare
 
Or, to use it as a library and use it as a parameter
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

You need to have in your CMDB yaml file the tasks configuration, example:

CMDB.yml

 Rex::Module::Commands::Cronjob::actions:
  wp_cron:
       command: "/usr/bin/php /wordpress/wp-cron.php"
       user: wp_user
       hour: 0
       minute: 0

1;
