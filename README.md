# Graphiter
Simple implementation demonstrating how to parse [BPFTrace](https://github.com/iovisor/bpftrace) files in a particular format and out put values to [Graphite](https://graphiteapp.org/)

## Features

* Creates a bash file that can be used to start a bpftrace file and output data to a staging file called .staging.txt
* Creates a script file at /opt/graphiter/graphite.rb which will parse the staging file from above
* Creates a systemd service to allow graphiter to be ran as a service and constantly log to Graphite, every 15 seconds.
* Can easily be modified to support many other bpftrace files or any log file.
* Ruby and Python versions
* Utilises a simple Regex to find the bucket and value for each line output by the .bt file.
* Python version uses a module called graphyte which wraps some common use cases of sending data to graphite
* Ruby version simply opens a TCP connection to a host and port and sends data as expected
* Both versions can be passed environment variables to change the Graphite server to send to.
* Environment variables default to `localhost` and `2003`
* Provides a mechanism to deploy with Ansible, Puppet & Chef with examples of how to use each



# Installation/Deployment

## Puppet
You can also easily integrate Graphiter with your existing Puppet Deployments. Included in the repo is a simple Puppet Module called `graphiter` that when run, will configure your hosts and ensure graphiter is running as a service

In order to use the module, please include it in your manifest files. 

See the example below

```puppet

# manifest.pp
node default {
	class { 'graphiter': }
}

modules
└── graphiter
    ├── Gemfile
    ├── README.md
    ├── Rakefile
    ├── files
    │   ├── cpu_lat.bt
    │   └── graphiter.rb
    ├── manifests
    │   └── init.pp
    ├── metadata.json
    └── templates
        ├── graphiter.service.epp
        └── graphiter.sh.epp

```

Either run this with your Puppet Master or if you wish to run it locally, try

```bash
puppet apply --modulepath modules/ manifest.pp

```

**Example Output:**

```bash
root@ip-172-31-29-191:/opt/pippet# puppet apply --modulepath modules/ manifest.pp
Notice: Compiled catalog for ip-172-31-29-191.eu-west-1.compute.internal in environment production in 0.14 seconds
Notice: /Stage[main]/Graphiter/File[/opt/graphiter]/ensure: created
Notice: /Stage[main]/Graphiter/File[/opt/graphiter/graphiter.rb]/ensure: defined content as '{md5}cb8f8bfd817d144e697efb245340d328'
Notice: /Stage[main]/Graphiter/File[/opt/graphiter/graphiter.sh]/ensure: defined content as '{md5}023df7adb1a95e13941e8016b790dc87'
Notice: /Stage[main]/Graphiter/Service[graphiter]/ensure: ensure changed 'stopped' to 'running'
Notice: Applied catalog in 32.42 seconds
```


## Ansible
Graphiter includes an Ansible role you can easily include in existing Ansible based deployments/configurations. Included in the repo is a playbook that utilises the role.

The role will configure your hosts appropriately and ensure `graphiter` is running as a service


To run the playbook which in turn runs the role, try the following (Requires ansible to be installed)

```bash
ansible-playbook deploy_graphiter.yml -i inventory.txt --user <HOST Username> --key-file <HOST KEY LOCATION>
```


```bash 
Ansible
├── deploy_graphiter.yml 
├── graphiter-role
│   ├── defaults
│   │   └── main.yml
│   ├── files
│   │   └── graphiter.rb
│   ├── meta
│   ├── tasks
│   │   └── main.yml
│   ├── templates
│   │   ├── graphiter.service.j2
│   │   └── graphiter.sh.j2
│   └── test
│       └── integration
│           └── ubuntu
│               └── default.yml
└── inventory.txt

```

**Example Output:**

```bash
PLAY [webservers] *****************************************************************************

TASK [Gathering Facts] ************************************************************************
ok: [54.171.71.94]

TASK [graphiter-role : Setup Graphiter Directory] *********************************************
ok: [54.171.71.94]

TASK [graphiter-role : Add Ruby Graphiter File] ***********************************************
ok: [54.171.71.94]

TASK [graphiter-role : Add Bash File] *********************************************************
ok: [54.171.71.94]

TASK [graphiter-role : Create Service File] ***************************************************
ok: [54.171.71.94]

TASK [graphiter-role : Start & Enable the Service] ********************************************
changed: [54.171.71.94]

PLAY RECAP ************************************************************************************
54.171.71.94               : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Chef
Graphiter includes a Chef cookbook you can easily include in existing Chef based deployments/configurations. Included in the repo is a kitchen.ci file that utilises the cookbook.

The cookbook will configure your hosts appropriately and ensure `graphiter` is running as a service


To run kitchen.ci which will run the cookbook, try the following (Requires ChefDK to be installed and the kitchen-ssh gem)
```bash
kitchen converge
``

**Example Output**:

```bash
-----> Starting Kitchen (v2.2.5)
-----> Converging <default-ubuntu>...
$$$$$$ Running legacy converge for 'Ssh' Driver
       Preparing files for transfer
       Preparing dna.json
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
       Preparing solo.rb
-----> Chef installation detected (install only if missing)
       Transferring files to <default-ubuntu>
       Starting Chef Infra Client, version 15.0.300
       resolving cookbooks for run list: ["graphiter"]
       Synchronizing Cookbooks:
         - graphiter (0.0.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 5 resources
       Recipe: graphiter::default
         * directory[/opt/graphiter] action create (up to date)
         * cookbook_file[/opt/graphiter/graphiter.rb] action create (up to date)
         * template[/opt/graphiter/graphiter.sh] action create
           - update content in file /opt/graphiter/graphiter.sh from 0bdb50 to 72be85
           (no diff)
         * template[/etc/systemd/system/graphiter.service] action create
           - update content in file /etc/systemd/system/graphiter.service from 2c330c to 4e97f8
           --- /etc/systemd/system/graphiter.service	2019-06-16 19:19:42.947456765 +0000
           +++ /etc/systemd/system/.chef-graphiter20190616-17113-1h7l3mi.service	2019-06-16 20:01:45.273345437 +0000
           @@ -8,10 +8,8 @@
            ExecStart=/opt/graphiter/graphiter.sh start
            ExecStop=/opt/graphiter/graphiter.sh stop
            KillMode=process
           -
            Restart=on-failure
            RestartSec=42s
           -
            [Install]
            WantedBy=default.target
         * service[graphiter] action start
           - start service service[graphiter]
         * service[graphiter] action enable (up to date)

       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 3/6 resources updated in 05 seconds
       Downloading files from <default-ubuntu>
       Finished converging <default-ubuntu> (0m11.53s).
-----> Kitchen is finished. (0m11.69s)
```

# Extra Fun Findings:

During the course of development, I was assigned a test server to use to demonstrate that Graphiter worked as expected. Through some inital digging, I was able to determine a few things.


### The Instance is an EC2 Server

* By simplying running `curl http://169.254.169.254/latest/meta-data` I was quickly able to confirm that the server being run in AWS as an EC2 Instance. The Instance in question had an instance-id of `i-0c3a8c6d8341b1334`

* Digging into the instance meta data, I was also able to determine the instance AMI is `ami-0306570396793d9ae` which I believe is a custom AMI as a quick search on Images in eu-west-1 (Ireland) or eu-west-2 (London) for Public images returned no results.

* The instance lives in an account `589549358292`. This is achieved by first calling `curl http://169.254.169.254/latest/meta-data/identity-credentials/ec2/security-credentials/ec2-instance/` which will return some temporary credentials identitfying the EC2 Instance. I can then take these creds and create a profile with the AWS CLI (first needed to install it with pip) by running `aws configure`. Once setup, I ran `aws sts get-calling-identity` which returns some basic information about who I am to AWS with said creds. Which shows me the role and account number being used.

### Hello to the FreeAgent Ops Team 👋
![Dominic Cleal](https://www.freeagent.com/components/images/company/team/dominic-cleal-6dd298b9.jpg)
![Ian McAlpine](https://www.freeagent.com/components/images/company/team/ian-mcalpine-f4825c85.jpg)
![Nathan Howard](https://www.freeagent.com/components/images/company/team/nathan-howard-fa83358d.jpg)
![Steven Williamson](https://www.freeagent.com/components/images/company/team/steven-williamson-126c38c9.jpg)

Whilst digging around the server, I was able to find some authorised keys enabled on the server. I found this at `~/.ssh/authorized_keys`

With the output, I noticed appended at the end of each key was a user and host name of where the keys originated. The list showed me names that I could then search in Google "FreeAgent \<name>", this took me to the meet the team page which I was then able to use to figure out who was who. 

Amongst the keys was a name "packer", this validated my theory that this is a custom AMI as if it has been built with Packer, the key seems to have been left over from a Packer build. 

I also spotted a name "Thomas" but I wasn't able to find him on the team page. 