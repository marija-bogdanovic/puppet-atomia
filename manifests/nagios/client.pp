class atomia::nagios::client(
    $username           = "nagios",
    $password           = "nagios",
    $public_ip          = $ipaddress_eth0,
    $nagios_ip          
) {

    package { [
        'nagios-nrpe-server',
    ]:
        ensure => installed,
    }
    

    # Define hostgroups based on custom fact
    case $atomia_role {
        'apache_agent':         { $hostgroup = 'linux-customer-webservers'}
        'atomiadns_master':     { $hostgroup = 'linux-dns'}
        'awstats':              { $hostgroup = 'linux-atomia-agents'}
        'cronagent':            { $hostgroup = 'linux-atomia-agents'}
        'daggre':               { $hostgroup = 'linux-atomia-agents,linux-all'}
        'domainreg':            { $hostgroup = 'linux-atomia-agents'}
        'fsagent':              { $hostgroup = 'linux-atomia-agents'}
        'nameserver':           { $hostgroup = 'linux-dns'}
        'pureftpd':             { $hostgroup = 'linux-ftp-servers'}
        
    }
        

    service { 'nagios-nrpe-server':
        ensure => running,
        require => Package["nagios-nrpe-server"],
    }
    
    # Configuration files
    file { '/etc/nagios/nrpe.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('atomia/nagios/nrpe.cfg.erb'),
        require => Package["nagios-nrpe-server"],
        notify  => Service["nagios-nrpe-server"]
    }  
    
    @@nagios_host { "${fqdn}-host" :
        use                 => "generic-host",
        host_name           => "$fqdn",
        address             => $public_ip ,
        target              => "/etc/nagios3/conf.d/${hostname}_host.cfg",
        hostgroups          => $hostgroup
     
    }
    

    

}

# TODO
