template "/opt/install_apache.sh" do
    source "install_apache.sh.erb"
    mode "0777"
end

execute "run apache installer" do
    command "/opt/install_apache.sh"
    action :run
    user "root"
    cwd "/opt"
end
