# Class: graphiter
# ===========================
#
# Full description of class graphiter here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `graphiter_location`
# * `graphiter_port`
# * `graphiter_endpoint`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'graphiter':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2019 Your name here, unless otherwise noted.
#



class graphiter {

  $graphiter_location = '/opt/graphiter'
  $graphiter_endpoint = 'localhost'
  $graphiter_port = 2003
  $graphiter_service_name = 'graphiter'

  file { $graphiter_location:
    ensure => 'directory'
  }

  file { "${graphiter_location}/graphiter.rb":
    ensure => 'present',
    mode   => '0705',
    source => 'puppet:///modules/graphiter/graphiter.rb'
  }

  file { '/root/cpu_latency.bt':
    ensure => 'present',
    mode   => '0755',
    source => 'puppet:///modules/graphiter/cpu_lat.bt',
    owner  => 'ubuntu',
    group  => 'ubuntu'
  }

  file { "${graphiter_location}/graphiter.sh":
    ensure  => 'present',
    mode    => '0705',
    content => epp(
      'graphiter/graphiter.sh.epp',
      {
        'graphiter_port'     => $graphiter_port,
        'graphiter_endpoint' => $graphiter_endpoint,
        'graphiter_location' => $graphiter_location
      }
    )
  }

  file { "/etc/systemd/system/${graphiter_service_name}.service":
    ensure  => 'present',
    content => epp(
      'graphiter/graphiter.service.epp',
      {
        'graphiter_location' => $graphiter_location
      }
    )
  }

  service { $graphiter_service_name:
    ensure   => 'running',
    enable   => true,
    provider => 'systemd'
  }
}
