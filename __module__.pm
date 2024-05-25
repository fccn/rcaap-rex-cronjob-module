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

desc "Initialize Cronjob";
task "init",
	sub {
		delete_all();
		prepare();
	};

desc "Delete all Cronjob entries for all users or for a specific user";
task "delete_all",
	sub {
		my $param_user = shift;
		my @users = ();
		my $actions;

		# we need to know which users are configured and delete all entries for each one
		if (defined($param_user) && %{$param_user}) {
			push(@users, $param_user);
		} else {
			# it will try to lookup on Rex::Module::Commands::Cronjob::actions, or Module::Commands::Cronjob::actions or actions at your CMDB file.
			$actions = param_lookup ('actions');

			if ($actions) {
				foreach my $action (sort(keys %{$actions})) {
					push(@users, $actions->{$action}->{"user"});
				}
			}

		}

		# delete all cron entries
		foreach my $user (@users) {
			my @crons = cron list => $user;
			my $array_size = scalar(@crons);
			for (my $i = 0 ; $i < $array_size ; $i++) {
				# always delete the first element
				cron delete => $user, 0;
			}
		}

	};

desc "Cronjob prepare";
task "prepare",
	sub {
		my $actions = shift;

		if (!defined($actions) || !%{$actions}) {
			# it will try to lookup on Rex::Module::Commands::Cronjob::actions, or Module::Commands::Cronjob::actions or actions at your CMDB file.
			$actions = param_lookup ('actions');
		}

		if ($actions) {
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
		} else {
			Rex::Logger::info("No cronjob actions defined",'error');
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
