git "/opt/opencop" do
    repository "git://github.com/OpenCOP/OpenCOP.git"
    action :checkout
end

file "/opt/opencop/scripts/install.sh" do
    action :delete
end

template "/opt/opencop/scripts/install.sh" do
    source "install.sh.erb"
    mode "0777"
end

execute "run geoserver installer" do
    command "./install.sh"
    action :run
    user "root"
    cwd "/opt/opencop/scripts"
end
