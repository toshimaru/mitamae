# Prefixing `::` for https://github.com/mruby/mruby/issues/3200
module ::RecipeHelper
  def include_role(name)
    include_role_or_cookbook(name, "roles")
  end

  def include_cookbook(name)
    include_role_or_cookbook(name, "cookbooks")
  end

  def include_role_or_cookbook(name, type)
    dir = File.expand_path("#{__FILE__}/../../..")
    names = name.split("::")
    names << "default" if names.length == 1
    names[-1] += ".rb"
    recipe_file = File.join(dir, type, *names)
    if File.exist?(recipe_file)
      include_recipe(recipe_file)
    else
      raise "#{type.capitalize} #{name} is not found at #{recipe_file}."
    end
  end
end

define :install_package, darwin: nil, ubuntu: nil, arch: nil do
  pkgs = params[node[:platform].to_sym]
  if pkgs
    Array(pkgs).each do |pkg|
      package pkg
    end
  end
end

define :add_profile, content: nil, priority: 50 do
  ct = params[:content]
  unless ct
    raise 'add_profile requires content parameter'
  end
  priority = params[:priority]
  name = params[:name]

  file "#{node[:dummy][:root]}/profile.d/#{priority}-#{name}.sh" do
    owner node[:dummy][:user]
    group node[:dummy][:group]
    mode '644'
    content ct
  end
end

execute "apt-get update" do
  action :nothing
end

execute "systemctl daemon-reload" do
  action :nothing
end
