###########This cookbook recipe is using below resources
#winrm gems
#Powershell_script
#service
#cookbook_file
#directory
#git
#firewall_rule : not sure will work or not
#DISM 
#Windows_feature can be used as replacement over Powershell_script
# .ps1 files to be placed in files folder for of the respecive cookbook
####1: Update windows patches : Ref https://blogs.technet.microsoft.com/configmgrdogs/2012/02/14/applying-windows-updates-to-a-base-wim-using-dism-and-powershell/

######Using powershell_script ########## 
cookbook_file "c:/enable_firewall/update_patch.ps1" do
  source "update_patch.ps1"
end
powershell_script "run update_patch script" do
  code "c:/enable_firewall/update_patch.ps1"
end

####2: Install Web server
powershell_script ‘Install IIS’ do 
  code ‘ windowsFeature Web-server’
  guard_interpreter :powershell_script 
  not_if “(Get-WindowsFeature -Name Web-Server).Installed”  
End 
 
####3: Install Management Console 
Powershell_script ‘Install IIS Management Console’ do 
  Code ‘Add-WindowsFeature Web-Mgmt-Console’ 
  Guard_interpreter :powershell_script
  Not_if “(Get-WindowsFeature-Name Web-MGMT-Console).Installed” 
end 

####4: Install ASP.NET 
Powershell_script ‘Install ASP.NET’ do 
  code ‘Add-WindowsFeature  web-ASP-Net45’
  guard_interpreter :powershell_script
  not_if “(Get-WindowsFeature -Name Web-Server).Installed”
end  

####5: Install web static contents 
Powershell_script ‘Install IIS Static Content’ do 
  code ‘Add-WindowsFeature Web-Static-Content’ 
  guard_interpreter :powershell_script
  Not_if “(Get-WindowsFeature -Name Web-Static-Content).Installed”
end 

####6: Start w3svc IIS service 
service ‘w3svc’ do 
  Action [:start, :enable]
end 

####6: Enable firewall port tcp/80
powershell_script "Add firewall rule" do
  code <<-EOH
    netsh advfirewall firewall set rule group="remote administration" new enable=yes & netsh advfirewall firewall add rule name="WinRM Port" dir=in action=allow protocol=TCP remoteip=<IP_ADDR> localport=80
  EOH
  guard_interpreter :powershell_script
end

OR

cookbook_file "c:/enable_firewall/script.ps1" do
  source "script.ps1"
end
powershell_script "run some script" do
  code "c:/enable_firewall/script.ps1"
end

OR

firewall_rule 'http' do  ///Not sure if it will work
  port     80
  protocol :tcp
  position 1
  command   :allow
end

####7: Create webroot for IIS
directory “C:/inetpub/wwwroot” do
 Recursive true 
end 

####8: host the icon contents
git 'C:/inetpub/wwwroot/index.html' do
  repository 'https://github.com/colebemis/feather/tree/master/icons.git'
  revision 'master/add-icons'
  action :sync
end
 
 
 
 
 
 
