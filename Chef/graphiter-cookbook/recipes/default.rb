
directory node['graphiter']['setup_location'] do
  owner 'root'
  group 'root'
end

cookbook_file node['graphiter']['setup_location'] + '/graphiter.rb' do
  source 'graphiter.rb'
  owner 'root'
  group 'root'  
end

template node['graphiter']['setup_location'] + '/graphiter.sh' do
  source 'graphiter.sh.erb'
  owner 'root'
  group 'root'
  variables(
    {
      :graphiter_endpoint => node['graphiter']['graphite']['endpoint'],
      :graphiter_port => node['graphiter']['graphite']['port'],
      :graphiter_location => node['graphiter']['setup_location'],
    }
  )
end

template '/etc/systemd/system/' + node['graphiter']['service_name'] + '.service' do
  source 'graphiter.service.erb'
  owner 'root'
  group 'root'
  variables(
    {
      :graphiter_location => node['graphiter']['setup_location'],
    }
  )
end

service node['graphiter']['service_name'] do
  action [:start, :enable]
end


# - name: Create Service File
#   template:
#     src: graphiter.service.j2
#     dest: /etc/systemd/system/graphiter.service

# - name: Start & Enable the Service
#   service:
#     name: graphiter
#     enabled: true
#     state: started
